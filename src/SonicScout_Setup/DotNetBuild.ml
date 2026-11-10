module Cmdliner = Tr1Cmdliner_Std.Cmdliner
module Logs = Tr1Logs_Std.Logs
module StdExit = Tr1Stdlib_V414Extras.StdExit

(** Builds the Browser app continuously so that "restore" is done implicitly,
    and once it succeeds then continuously run the "publish --no-restore". *)

(** [configuration] is ["Release"] to avoid issues like
    {:https://github.com/dotnet/AspNetCore.Docs/issues/24443}. *)
let configuration = "Release"

let clean areas =
  if List.mem `DotNet areas then begin
    Utils.start_step "Cleaning .NET source code";
    let ctx = DkCoder_Std.Context.get_exn () in
    let project_dir =
      DkCoder_Std.Context.project_dir ctx |> Option.get |> Fpath.v
    in
    let version_dir = Fpath.(project_dir / "2026") in
    DkFs_C99.Path.rm ~recurse:() ~force:()
      Fpath.
        [
          version_dir / "ScoutApp" / "bin";
          version_dir / "ScoutApp" / "obj";
          version_dir / "ScoutApp.Android" / "bin";
          version_dir / "ScoutApp.Android" / "obj";
          version_dir / "ScoutApp.Browser" / "bin";
          version_dir / "ScoutApp.Browser" / "obj";
          version_dir / "ScoutApp.Desktop" / "bin";
          version_dir / "ScoutApp.Desktop" / "obj";
          version_dir / "ScoutApp.iOS" / "bin";
          version_dir / "ScoutApp.iOS" / "obj";
        ]
    |> Utils.rmsg
  end

let build () =
  let open Bos in
  match
    OS.Cmd.run
      Cmd.(
        v "dotnet" % "build" % "2026/ScoutApp.Browser" % "--configuration"
        % configuration)
  with
  | Ok () -> true
  | Error (`Msg msg) ->
      Logs.err (fun l -> l "dotnet build failed ...@ %a" Fmt.lines msg);
      false

let publish () =
  let open Bos in
  match
    OS.Cmd.run
      Cmd.(
        v "dotnet" % "publish" % "2026/ScoutApp.Browser" % "--configuration"
        % configuration % "--no-restore")
  with
  | Ok () -> ()
  | Error (`Msg msg) ->
      Logs.err (fun l -> l "dotnet publish failed ...@ %a" Fmt.lines msg)

let build_until_success () =
  while not (build ()) do
    ()
  done

let publish_continually () =
  while true do
    publish ()
  done

let __init (_ : DkCoder_Std.Context.t) =
  Tr1Logs_Term.TerminalCliOptions.init ();
  let open Cmdliner in
  let publish_t =
    Term.(
      const (fun _cliopts ->
          build_until_success ();
          publish_continually ())
      $ Tr1Logs_Term.TerminalCliOptions.term ())
  in
  let publish_cmd = Cmd.v (Cmd.info __MODULE_ID__) publish_t in
  StdExit.exit (Cmd.eval publish_cmd)
