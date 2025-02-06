(* TODO: Make this a DkCoder "us" script.

   REPLACES: dksdk.gradle.run and dksdk.android.gradle.configure.

   FIXES BUGS:
   1. `./dk dksdk.gradle.run` would inject OCaml environment and mess up Android Gradle Plugin.
   2. `./dk dksdk.android.gradle.configure` had a chicken-and-egg problem with valid/invalid cmake.dir.

   PREREQS (must be replaced before dksdk.gradle.run is replaced):
   1. `./dk dksdk.java.jdk.download NO_SYSTEM_PATH JDK 17`
   2. `./dk dksdk.gradle.download ALL NO_SYSTEM_PATH`
   3. `./dk dksdk.android.gradle.configure [OVERWRITE]`
*)

open Bos

(* Ported from Utils since this script is standalone. *)
let rmsg = function Ok v -> v | Error (`Msg msg) -> failwith msg

(** Don't leak DkCoder OCaml environment to Android Gradle Plugin which will infect DkSDK CMake
    host detection of OCaml (`ocamlc -where` in dksdk-cmake/.../115-ocaml-config).
    In fact, don't leak any existing OCaml environment. *)
let remove_ocaml_dkcoder_env env =
  let env =
    OSEnvMap.(
      remove "OPAMROOT" env
      |> remove "OPAM_SWITCH_PREFIX"
      |> remove "CAML_LD_LIBRARY_PATH"
      |> remove "OPAM_LAST_ENV"
      |> remove "OCAML_TOPLEVEL_PATH"
      |> remove "OCAMLRUNPARAM" |> remove "OCAMLLIB")
  in
  (* Also remove DkCoder from the PATH *)
  let open OSEnvMap in
  match
    (Sys.getenv_opt "PATH", Sys.getenv_opt "DKCODER_HELPERS", Sys.win32)
  with
  | Some path, Some helpers, true when helpers <> "" ->
      remove "PATH" env
      |> add "PATH"
           (Stringext.replace_all path ~pattern:(helpers ^ ";") ~with_:""
           |> Stringext.replace_all ~pattern:(helpers ^ "\\stublibs;") ~with_:""
           )
  | Some path, Some helpers, false when helpers <> "" ->
      remove "PATH" env
      |> add "PATH"
           (Stringext.replace_all path ~pattern:(helpers ^ ":") ~with_:""
           |> Stringext.replace_all ~pattern:(helpers ^ "/stublibs:") ~with_:""
           )
  | _ -> env

let find_java_home ~slots =
  let jdk =
    match Slots.jdk slots with
    | None -> failwith "Missing jdk slot"
    | Some jdk -> jdk
  in
  let java_home_opt =
    let home = Fpath.(jdk / "Contents" / "Home") in
    if OS.File.exists Fpath.(home / "bin" / "javac") |> rmsg then Some home
    else if
      Sys.win32 && OS.File.exists Fpath.(jdk / "bin" / "javac.exe") |> rmsg
    then Some jdk
    else if
      (not Sys.win32) && OS.File.exists Fpath.(jdk / "bin" / "javac") |> rmsg
    then Some jdk
    else None
  in
  match java_home_opt with
  | Some h -> h
  | None ->
      failwith
        "No local JAVA_HOME detected. Make sure that './dk \
         dksdk.java.jdk.download NO_SYSTEM_PATH JDK 17' has been run."

let add_java_env ~slots env =
  (* Add JAVA_HOME *)
  let java_home = find_java_home ~slots in
  let env = OSEnvMap.(add "JAVA_HOME" (Fpath.to_string java_home) env) in

  (* Gradle jvmToolchain detection has problems if the Java
     is not in the PATH.
     https://github.com/ankidroid/Anki-Android/issues/13340#issuecomment-1445218572 *)
  let java_bin = Fpath.(java_home / "bin") |> Fpath.to_string in
  OSEnvMap.(
    update "PATH"
      (function
        | None -> Some java_bin
        | Some path ->
            Some
              (if Sys.win32 then java_bin ^ ";" ^ path
               else java_bin ^ ":" ^ path))
      env)

let add_ninja_env ~slots env =
  let ninja_dir = Fpath.to_string (Slots.ninja_dir slots) in
  OSEnvMap.(
    update "PATH"
      (function
        | None -> Some ninja_dir
        | Some path ->
            Some
              (if Sys.win32 then ninja_dir ^ ";" ^ path
               else ninja_dir ^ ":" ^ path))
      env)

let find_gradle_binary ~slots =
  let gradle_home =
    match Slots.gradle_home slots with
    | None -> failwith "Missing gradle_home slot"
    | Some gradle_home -> gradle_home
  in
  let binary_opt =
    if
      Sys.win32
      && OS.File.exists Fpath.(gradle_home / "bin" / "gradle.bat") |> rmsg
    then Some Fpath.(gradle_home / "bin" / "gradle.bat")
    else if
      (not Sys.win32)
      && OS.File.exists Fpath.(gradle_home / "bin" / "gradle") |> rmsg
    then Some Fpath.(gradle_home / "bin" / "gradle")
    else None
  in
  match binary_opt with
  | Some b -> b
  | None ->
      failwith
        "No local Gradle detected. Make sure that './dk dksdk.gradle.download \
         ALL NO_SYSTEM_PATH' has been run."

(** Mimic the escaping done by Android Studio itself.

    Example:

    {v
     sdk.dir=Y\:\\source\\dksdk-ffi-java\\.ci\\local\\share\\android-sdk
     cmake.dir=C\:/Users/beckf/AppData/Local/Programs/DkSDK/dkcoder/cmake-3.25.3-windows-x86_64
    v}

    So backslashes and colons are escaped. *)
let android_local_properties_escape s =
  Stringext.replace_all s ~pattern:"\\" ~with_:"\\\\"
  |> Stringext.replace_all ~pattern:":" ~with_:"\\:"

(** [generate_local_properties] creates a ["local.properties"].

    Because ["bin/cmake.exe"] is an output of a Gradle task, it is deleted
    at arbitrary times by Android Gradle (ex. during a clean). {b Always} call
    this function to mitigate the deletion. *)
let generate_local_properties ~slots ~projectdir () =
  (* keep the directories forward-slashed so readable *)
  let sdk_dir =
    match Slots.android_sdk_dir slots with
    | None -> failwith "Expected slot android_sdk_dir"
    | Some sdk_dir -> Utils.mixed_path sdk_dir
  in
  let local_properties = Fpath.(projectdir / "local.properties") in
  let content ~cmake_dir =
    [
      Printf.sprintf "# Generated by %s script" __MODULE_ID__;
      Printf.sprintf "sdk.dir=%s" (android_local_properties_escape sdk_dir);
      Printf.sprintf "cmake.dir=%s"
        (android_local_properties_escape (Utils.mixed_path cmake_dir));
    ]
  in
  let cmake_3_25_3_home = Slots.cmake_home slots in
  OS.File.write_lines local_properties (content ~cmake_dir:cmake_3_25_3_home)
  |> rmsg

and run ?env ?debug_env ~projectdir ~slots args =
  let env =
    match env with Some env -> env | None -> OS.Env.current () |> rmsg
  in

  (* Don't leak DkCoder OCaml environment to Android Gradle Plugin. *)
  let env = remove_ocaml_dkcoder_env env in

  (* Add JAVA_HOME and Java to PATH *)
  let env = add_java_env ~slots env in

  (* Add Ninja to PATH.
     Fixes: [CXX1416] Could not find Ninja on PATH or in SDK CMake bin folders. *)
  let env = add_ninja_env ~slots env in

  (* Find Gradle *)
  let gradle = find_gradle_binary ~slots in

  (* Run *)
  (match debug_env with
  | Some () ->
      OSEnvMap.fold
        (fun k v () ->
          Logs.debug (fun l -> l "Environment for Gradle: %s=%s" k v))
        env ()
  | None -> ());
  Logs.info (fun l ->
      l "%a %a" Fpath.pp gradle (Fmt.list ~sep:Fmt.sp Fmt.string) args);
  OS.Dir.with_current projectdir
    (fun () -> OS.Cmd.run ~env Cmd.(v (p gradle) %% of_list args) |> rmsg)
    ()
  |> rmsg
