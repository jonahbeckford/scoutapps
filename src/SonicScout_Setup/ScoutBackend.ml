open Bos

let build_reldir = Fpath.v "build_dev"
let user_presets_relfile = Fpath.v "CMakeUserPresets.json"

let clean areas =
  let open Utils in
  let cwd = OS.Dir.current () |> rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutBackend") in
  Qt.clean areas;
  if List.mem `DkSdkSourceCode areas then begin
    start_step "Cleaning SonicScoutBackend DkSDK source code";
    DkFs_C99.Path.rm ~recurse:() ~force:() ~kill:()
      Fpath.
        [
          projectdir / "fetch" / "dkml-compiler";
          projectdir / "fetch" / "dkml-runtime-common";
          projectdir / "fetch" / "dkml-runtime-distribution";
          projectdir / "fetch" / "dksdk-access";
          projectdir / "fetch" / "dksdk-cmake";
          projectdir / "fetch" / "dksdk-ffi-c";
          projectdir / "fetch" / "dksdk-ffi-ocaml";
          projectdir / "fetch" / "dksdk-opam-repository-core";
          projectdir / "fetch" / "dksdk-opam-repository-js";
          (* These aren't DkSDK source code but they need to be deleted somewhere ... *)
          projectdir / "fetch" / "opam-repository-dkml";
          projectdir / "fetch" / "opam-repository-dune-universe";
          projectdir / "fetch" / "opam-repository-ocaml";
        ]
    |> rmsg
  end;
  if List.mem `DkSdkCMake areas then begin
    start_step "Cleaning SonicScoutBackend dksdk-cmake source code";
    DkFs_C99.Path.rm ~recurse:() ~force:() ~kill:()
      Fpath.[ projectdir / "fetch" / "dksdk-cmake" ]
    |> rmsg
  end;
  if List.mem `BackendBuilds areas then begin
    start_step
      "Cleaning SonicScoutBackend build artifacts (this may take tens of \
       minutes)";
    DkFs_C99.Path.rm ~recurse:() ~force:() ~kill:()
      Fpath.
        [
          projectdir // build_reldir;
          projectdir / "_build";
          projectdir / ".tools";
          projectdir // user_presets_relfile;
        ]
    |> rmsg
  end

let package ~notarize () =
  let open Utils in
  start_step "Packaging SonicScoutBackend";
  let cwd = OS.Dir.current () |> rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutBackend") in
  let builddir = Fpath.(projectdir // build_reldir) in
  let tools_dir = Qt.tools_dir ~projectdir in
  match DkCoder_Std.Context.(abi (get_exn ())) with
  | `Darwin_x86_64 | `Darwin_arm64 ->
      let env = OS.Env.current () |> rmsg in
      let env =
        if notarize then env |> OSEnvMap.(add "SCOUT_NOTARIZE" "1") else env
      in
      let env =
        match Logs.level () with
        | Some Logs.Debug -> env |> OSEnvMap.(add "SCOUT_VERBOSE" "2")
        | _ -> env
      in
      (* TODO: Use https://cmake.org/cmake/help/latest/cpack_gen/external.html.
         We only use [TGZ] so the intermediate .dmg is produced. Any generator
         can do that. Or just do a plain [cmake --install]. *)
      RunCPack.run ~env ~projectdir ~builddir [ "-G"; "TGZ" ];
      let dmg =
        Fpath.(
          builddir / "_CPack_Packages" / "Darwin" / "TGZ"
          / "SonicScoutBackend-1.0.0-Darwin" / "SonicScoutQRScanner.dmg")
      in
      Logs.app (fun l -> l "The macOS dmg for publishing is at %a" Fpath.pp dmg)
  | `Windows_x86_64 | `Windows_x86 | `Windows_arm32 | `Windows_arm64 ->
      let default_search =
        OS.Cmd.search_path_dirs (Sys.getenv "PATH") |> rmsg
      in

      (* > The wix.exe tool requires the .NET SDK, version 6 or later. *)
      (* https://learn.microsoft.com/en-us/dotnet/core/install/windows#install-the-sdk *)
      Winget.install [ "Microsoft.DotNet.SDK.8" ];

      (* Install WiX in local path and don't add to PATH.
         Confer: https://cmake.org/cmake/help/latest/cpack_gen/wix.html *)
      let wixdir = Fpath.(tools_dir / "wix") in
      let wixmajorver = 4 in
      let wixver = "4.0.5" in
      let dotnet =
        (* If just installed, it will not be in the PATH. *)
        OS.Cmd.get_tool
          ~search:Fpath.(v {|C:\Program Files\dotnet|} :: default_search)
          Cmd.(v "dotnet")
        |> rmsg
      in
      OS.Cmd.run
        Cmd.(
          v (p dotnet)
          % "tool" % "install" % "--tool-path" % p wixdir % "wix" % "--version"
          % wixver)
      |> rmsg;

      (* Add WiX UI extension. The [--global] installs to USERPROFILE.
         Confer: https://cmake.org/cmake/help/latest/cpack_gen/wix.html *)
      let wix = Fpath.(wixdir / "wix.exe") in
      OS.Cmd.run
        Cmd.(
          v (p wix)
          % "extension" % "add" % "--global"
          % Fmt.str "WixToolset.UI.wixext/%s" wixver)
      |> rmsg;

      (* Sigh. Hadn't realized that WIX version 4 requires CPack 3.30+
         until too late. So just download a newer CPack. *)
      let cpack_new =
        Fpath.(
          tools_dir / "cmake-3.30.0-rc4-windows-x86_64" / "bin" / "cpack.exe")
      in
      if not (OS.File.exists cpack_new |> rmsg) then (
        let cmake_zip = Fpath.(tools_dir / "cmake.zip") in
        (* https://github.com/Kitware/CMake/releases/download/v3.30.0-rc4/cmake-3.30.0-rc4-windows-x86_64.zip *)
        Lwt_main.run
        @@ DkNet_Std.Http.download_url ~max_time_ms:300_000
             ~checksum:
               (`SHA_256
                  "9086fa9c83e5a3da2599220d4e426d1dfeefac417f2abf19862a91620c38faee")
             ~destination:cmake_zip
             (Uri.of_string
                "https://github.com/Kitware/CMake/releases/download/v3.30.0-rc4/cmake-3.30.0-rc4-windows-x86_64.zip");
        OS.Cmd.run
          Cmd.(
            v (if Sys.win32 then "powershell.exe" else "pwsh")
            % "-NoProfile" % "-InputFormat" % "None" % "-ExecutionPolicy"
            % "Bypass" % "-File"
            % Filename.concat (Tr1Assets.LocalDir.v ()) "unzip.ps1"
            % Fpath.to_string cmake_zip % Fpath.to_string tools_dir)
        |> rmsg);

      (* Run CPack with WIX *)
      let env =
        OS.Env.current () |> rmsg
        |> OSEnvMap.(add "WIX" (Fpath.to_string wixdir))
      in
      RunCPack.run ~cpack:cpack_new ~env ~projectdir ~builddir
        [ "-G"; "WIX"; "-D"; Fmt.str "CPACK_WIX_VERSION=%d" wixmajorver ];

      Logs.app (fun l ->
          l "The Windows .msi for publishing is at %a" Fpath.pp
            Fpath.(builddir / "SonicScoutBackend-1.0.0-win64.msi"))
  | _ -> failwith "Currently your host machine is not supported by Sonic Scout"

let cmake_properties ~cwd ~(opts : Utils.opts) slots : string list =
  let cprops =
    match Slots.msys2 slots with
    | Some fpath -> [ Fmt.str "-DDKSDK_MSYS2_DIR=%a" Fpath.pp fpath ]
    | None -> []
  in
  let cprops =
    Fmt.str "-DCMAKE_BUILD_TYPE=%s"
      (match Utils.build_type opts with
      | `Debug -> "Debug"
      | `Release -> "Release")
    :: cprops
  in
  (* Avoid:
        C:\VS\VC\Tools\MSVC\14.38.33130\bin\Hostx64\x64\cl.exe  /nologo /TP -DKJ_USE_FIBERS -IC:\scoutapps2\us\SonicScoutBackend\build_dev\_deps\capnproto-src\c++\src /wo4503 -std:c++14 /showIncludes /Foc++\src\kj\CMakeFiles\kj-async.dir\async.c++.obj /Fdc++\src\kj\CMakeFiles\kj-async.dir\kj-async.pdb /FS -c C:\scoutapps2\us\SonicScoutBackend\build_dev\_deps\capnproto-src\c++\src\kj\async.c++
        C:\scoutapps2\us\SonicScoutBackend\build_dev\_deps\capnproto-src\c++\src\kj\async.h(39): fatal error C1189: #error:  "Fibers cannot be enabled when exceptions are disabled."
  *)
  let cprops = "-DWITH_FIBERS=OFF" :: cprops in
  let cprops = "-DSONIC_SCOUT_FEATURE_CLI=OFF" :: cprops in
  let open Utils in
  let cprops =
    (* Override what is forced in CMakePresets.json *)
    let p project =
      let project_upcase = String.uppercase_ascii project in
      match opts with
      | { fetch_siblings = true; _ } ->
          Fmt.str "-DFETCHCONTENT_SOURCE_DIR_%s=%s" project_upcase
            (Utils.sibling_dir_mixed ~cwd ~project)
      | { fetch_siblings = false; _ } ->
          Fmt.str "-DFETCHCONTENT_SOURCE_DIR_%s=%s" project_upcase
            (Utils.mixed_path Fpath.(cwd / "fetch" / project))
    in
    p "dkml-runtime-common" :: p "dkml-compiler" :: p "dksdk-access"
    :: p "dksdk-cmake" :: p "dksdk-ffi-c" :: cprops
  in
  cprops

let run ?(opts = Utils.default_opts) ?global_dkml ~slots () =
  let open Utils in
  start_step "Building SonicScoutBackend";
  let cwd = OS.Dir.current () |> rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutBackend") in
  let dk_env = dk_env ~opts () in
  let dk = dk ~env:dk_env in
  let preset =
    match DkCoder_Std.Context.(abi (get_exn ())) with
    | `Darwin_x86_64 -> "dev-AppleIntel"
    | `Darwin_arm64 ->
        (* We would like [dev-AppleSilicon]. But only Qt6.2.0+ are universal binaries!
           So until the manager app (SonicScoutBackend) has an upgrade to Qt6, we are stuck with Rosetta emulation. *)
        "dev-AppleIntel"
    | `Windows_x86_64 -> "dev-Windows64"
    | `Linux_x86_64 -> "dev-Linux-x86_64"
    | _ ->
        failwith "Currently your host machine is not supported by Sonic Scout"
  in
  OS.Dir.with_current projectdir
    (fun () ->
      if Utils.not_skip_fetch opts then
        dk ~slots [ "dksdk.cmake.link"; "QUIET" ];
      if Utils.not_skip_fetch opts then
        Utils.dk_ninja_link_or_copy ~opts ~dk:(dk ~slots) ();
      let user_presets = Fpath.v "CMakeUserPresets.json" in
      if not (OS.File.exists user_presets |> rmsg) then
        OS.File.write user_presets
          (OS.File.read (Fpath.v "CMakeUserPresets-SUGGESTED.json") |> rmsg)
        |> rmsg;

      (* DkCoder has no way to detect changes to .ml source files. *)
      DkFs_C99.Path.rm ~recurse:() ~force:() ~kill:()
        Fpath.
          [
            projectdir / "build_dev" / "DkFiles" / "c";
            projectdir / "build_dev" / "src" / "SonicScout_MainCLI";
            projectdir / "build_dev" / "src" / "SonicScout_ManagerApp";
          ]
      |> rmsg;

      RunCMake.run ?global_dkml ~projectdir ~name:"backend-preset" ~slots
        ([ "--preset"; preset ] @ cmake_properties ~cwd ~opts slots);
      RunCMake.run ?global_dkml ~projectdir ~name:"backend-build" ~slots
        [
          "--build";
          Fpath.to_string build_reldir;
          "--target";
          "DkSDK_DevTools";
          "DkSDKTest_UnitTests_ALL";
          "ManagerApp_ALL";
          "SquirrelScout_ObjsLib";
        ])
    ()
  |> rmsg;
  slots
