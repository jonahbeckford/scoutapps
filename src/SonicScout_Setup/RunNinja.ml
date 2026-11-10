(* TODO: Make this a DkCoder "us" script. *)

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

  let ninja_dir = Slots.ninja_dir_exn slots in
  let ninja_exe = Fpath.(ninja_dir / "ninja") in

  let cmd =
    RunWithCompiler.get_command_for_program_and_args ?global_dkml ~tools_dir
      ~name ninja_exe args
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
