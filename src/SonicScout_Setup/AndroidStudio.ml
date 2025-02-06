let ask_launch () =
  let rec ask () =
    StdIo.print_string
      {|
Android Studio will be downloaded and launched.

SETUP WIZARD INSTRUCTIONS

1. The download step has a big 1GB download. DON'T BE SURPRISED IF IT TAKES
   10 MINUTES OR MORE.
2. If a "Trust and Open Project 'SonicScoutAndroid'" popup appears then
   enable "Trust projects in .../scoutapps/us" and then click the
   "Trust Project" button.
3. If a "Android SDK Manager" popup appears, click the button
   "Use Project's SDK".
4. When you first start Android Studio, take time to do the SETUP WIZARD:
      Import Settings? "No"
      Help Improve Android Studio? "Don't send"
      Install Type: "Standard"
      License Agreement: Accept

   If it complains about "Missing SDK" - "No Android SDK found", use "Next"
   to download it with all the default options selected.

BUILDING INSIDE ANDROID STUDIO

5. If you get a "Multiple Gradle daemons might be spawned because the Gradle
   JDK and JAVA_HOME locations are different." notification then you should
   click the "Select the Gradle JDK location". Choose the
   `ci/local/share/jdk` (or `ci/local/share/Android Studio App/Contents/jbr/Contents/Home`
   if on a macOS).
6. If Windows Firewall asks, you should GRANT ACCESS to "adb.exe". If you
   don't it is likely connecting to your Android devices will be difficult.

Do you want to launch Android Studio now? (y/N) |};
    StdIo.flush StdIo.stdout;
    try
      match StdIo.input_line StdIo.stdin with
      | "y" | "Y" -> true
      | "n" | "N" -> false
      | "" -> raise Utils.StopProvisioning
      | _ -> ask ()
    with End_of_file ->
      StdIo.print_endline "<terminal or standard input closed> ... exiting";
      raise Utils.StopProvisioning
  in
  ask ()

let run ~slots () =
  let open Bos in
  Utils.start_step "Running Android Studio";
  let cwd = OS.Dir.current () |> Utils.rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutAndroid") in

  (* Download Android Studio *)
  OS.Dir.with_current projectdir
    (fun () -> Utils.dk ~slots [ "dksdk.android.studio.download"; "NO_SYSTEM_PATH" ])
    ()
  |> Utils.rmsg;

  (* Find the executable or script launcher *)
  let launcher =
    let studio_app_bin =
      Fpath.(
        projectdir / ".ci" / "local" / "share" / "Android Studio.app"
        / "Contents" / "MacOS" / "studio")
    in
    Logs.debug (fun l -> l "Checking for macOS at %a" Fpath.pp studio_app_bin);
    if OS.File.exists studio_app_bin |> Utils.rmsg then Some studio_app_bin
    else
      let home =
        Fpath.(projectdir / ".ci" / "local" / "share" / "android-studio")
      in
      Logs.debug (fun l -> l "Checking for Linux/Windows in %a" Fpath.pp home);
      if Sys.win32 then
        if OS.File.exists Fpath.(home / "bin" / "studio.bat") |> Utils.rmsg then
          Some Fpath.(home / "bin" / "studio.bat")
        else None
      else if OS.File.exists Fpath.(home / "bin" / "studio") |> Utils.rmsg then
        Some Fpath.(home / "bin" / "studio")
      else if OS.File.exists Fpath.(home / "bin" / "studio.sh") |> Utils.rmsg
      then Some Fpath.(home / "bin" / "studio.sh")
      else None
  in
  let slots =
    match launcher with
    | Some b -> Slots.set_android_studio_launcher slots b
    | None ->
        failwith
          "No local Android Studio detected. The './dk \
           dksdk.android.studio.download NO_SYSTEM_PATH' had a failure."
  in

  if ask_launch () then RunAndroidStudio.run ~debug_env:() ~projectdir ~slots []
