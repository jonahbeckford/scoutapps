type common = {
  dksdk_data_home : Fpath.t;
  opts : Utils.opts;
  global_dkml : bool;
}

let compile_base ?skip_android { dksdk_data_home; opts; global_dkml } =
  let global_dkml = if global_dkml then Some () else None in

  InitialSteps.run ~dksdk_data_home ();
  Qt.run ();
  Sqlite3.run ();
  let slots = Slots.create () in
  let slots = DkML.run ?global_dkml ~slots () in
  let slots = ScoutBackend.run ?global_dkml ~opts ~slots () in
  let slots =
    match skip_android with
    | Some () -> slots
    | None -> ScoutAndroid.run ~opts ~slots ()
  in
  slots

let compile common =
  try
    let slots = compile_base common in
    ignore slots;
    Utils.done_steps "Developing"
  with Utils.StopProvisioning -> ()

let launch_android common =
  try
    let slots = compile_base common in
    let slots = AndroidStudio.run ~slots () in
    ignore slots;
    Utils.done_steps "Developing"
  with Utils.StopProvisioning -> ()

let launch_scanner common =
  try
    let slots = compile_base ~skip_android:() common in
    let slots = Scanner.run ~slots () in
    ignore slots;
    Utils.done_steps "Developing"
  with Utils.StopProvisioning -> ()

module Cli = struct
  open Cmdliner

  let common_t =
    let open SSCli in
    Term.(
      const (fun _ dksdk_data_home opts global_dkml ->
          {
            dksdk_data_home;
            opts;
            global_dkml =
              (match global_dkml with Some () -> true | None -> false);
          })
      $ Tr1Logs_Term.TerminalCliOptions.term ~short_opts:() ()
      $ dksdk_data_home_t $ opts_t $ global_dkml_t)

  let compile_cmd =
    let open SSCli in
    let doc =
      "Compile all Sonic Scout code. Your machine will be setup with \
       prerequisites if it hasn't been already."
    in
    let man = [ `S Manpage.s_description; `Blocks help_secs ] in
    Cmd.v (Cmd.info ~doc ~man "compile") Term.(const compile $ common_t)

  let android_cmd =
    let open SSCli in
    let doc =
      "Launch Android Studio and open the Sonic Scout Android application. \
       Your machine will be setup with prerequisites, and code will be \
       compiled (everything except the Android application itself), if it \
       hasn't been already. Use Android Studio to build and run the Android \
       application on a device emulator or your Android phone / tablet."
    in
    let man = [ `S Manpage.s_description; `Blocks help_secs ] in
    Cmd.v (Cmd.info ~doc ~man "android") Term.(const launch_android $ common_t)

  let scanner_cmd =
    let open SSCli in
    let doc =
      "Launch the QR code scanner. Your machine will be setup with \
       prerequisites, and code will be compiled (everything except Android), \
       if it hasn't been already."
    in
    let man = [ `S Manpage.s_description; `Blocks help_secs ] in
    Cmd.v (Cmd.info ~doc ~man "scanner") Term.(const launch_scanner $ common_t)

  let groups_cmd =
    let doc = "Develop the Sonic Scout software." in
    let man = [ `S Manpage.s_description; `Blocks SSCli.help_secs ] in
    let default =
      Term.(ret (const (fun _ -> `Help (`Pager, None)) $ common_t))
    in
    Cmd.group ~default
      (Cmd.info ~doc ~man ("./dk " ^ __MODULE_ID__))
      [ compile_cmd; android_cmd; scanner_cmd ]
end

let () =
  Tr1Logs_Term.TerminalCliOptions.init ();
  StdExit.exit (Cmdliner.Cmd.eval Cli.groups_cmd)
