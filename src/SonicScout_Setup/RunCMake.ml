(* TODO: Make this a DkCoder "us" script.

   REPLACES: Legacy ./dk that runs CMake scripts.

   FIXES BUGS:
   1. `./dk` would inject OCaml environment and mess up direct CMake invocations.
   2. Using Ninja with Visual Studio requires that you launch the Visual
      Studio Command Prompt (or vsdevcmd/vcvars). That is burdensome for the user.
      Confer: https://discourse.cmake.org/t/best-practice-for-ninja-build-visual-studio/4653/6

   PREREQS (must be replaced before dksdk.gradle.run is replaced):
   1. `./dk` and `./dk.cmd` and `__dk.cmake`
*)

open Bos

(* Ported from Utils since this script is standalone. *)
let rmsg = function Ok v -> v | Error (`Msg msg) -> failwith msg

let run ?debug_env ?env ?global_dkml ~projectdir ~name ~slots args =
  let tools_dir = Fpath.(projectdir / ".tools") in
  let env =
    match env with Some env -> env | None -> OS.Env.current () |> rmsg
  in

  (* Don't leak DkCoder OCaml environment to Android Gradle Plugin. *)
  let env = RunGradle.remove_ocaml_dkcoder_env env in

  let cmake_home = Slots.cmake_home_exn slots in
  let cmake_exe = Fpath.(cmake_home / "bin" / "cmake") in

  let cmd =
    RunWithCompiler.get_command_for_program_and_args ?global_dkml ~tools_dir ~name
      cmake_exe args
  in

  (* Run *)
  (match debug_env with
  | Some () ->
      OSEnvMap.fold
        (fun k v () ->
          Logs.debug (fun l -> l "Environment for CMake: %s=%s" k v))
        env ()
  | None -> ());
  let env = Utils.slot_env ~env ~slots () in
  Logs.info (fun l -> l "%a" Cmd.pp cmd);
  OS.Dir.with_current projectdir (fun () -> OS.Cmd.run ~env cmd |> rmsg) ()
  |> rmsg
