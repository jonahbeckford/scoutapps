let get_command_for_program_and_args ?global_dkml ~tools_dir ~name program args =
  if Sys.win32 then
    (* Ninja requires that Visual Studio is already in the environment.
       Confer: https://discourse.cmake.org/t/best-practice-for-ninja-build-visual-studio/4653/6.

       Could use PowerShell to avoid writing a temporary Command Prompt vcvars/vsdev launch script.

         Import-Module C:\VS\Common7\Tools\Microsoft.VisualStudio.DevShell.dll;
         Enter-VsDevShell -VsInstallPath C:\VS -DevCmdArguments "-arch=amd64"

       Confer:
         https://learn.microsoft.com/en-us/visualstudio/ide/reference/command-prompt-powershell?view=vs-2022
         https://devblogs.microsoft.com/visualstudio/say-hello-to-the-new-visual-studio-terminal/ *)
    let vsstudio_dir =
      match global_dkml with
      | Some () ->
          Bos.OS.File.read
            Fpath.(
              v (Sys.getenv "LOCALAPPDATA")
              / "Programs" / "DkML" / "vsstudio.dir.txt")
          |> Utils.rmsg |> String.trim |> Fpath.v
      | None -> Fpath.v "C:/VS"
    in
    let quoted_cmdargs =
      Fpath.to_string program :: args |> List.map Filename.quote
    in
    let with_vsdev = Fpath.(tools_dir / Printf.sprintf "vsdev-%s.ps1" name) in
    let _ =
      Bos.OS.File.write with_vsdev
        (Fmt.str
           {|
# https://github.com/microsoft/terminal/issues/280#issuecomment-1728298632
# This happens in Windows Sandbox which starts in Consolas font.
# (also see run-ps1.cmd)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ErrorActionPreference='Stop';

# Clear out any parent VsDev/vcvarsall environment variables. We only want
# the `-VsInstallPath <installation>` selected.
Function Remove-EnvItem {
  param ( [string]$Name )
  if (Test-Path "$Name") {
    Remove-Item "$Name"
  }
}
Remove-EnvItem Env:__devinit_path
Remove-EnvItem Env:__VCVARS_REDIST_VERSION
Remove-EnvItem Env:__VSCMD_PREINIT_PATH
Remove-EnvItem Env:__VSCMD_PREINIT_VCToolsVersion
Remove-EnvItem Env:DevEnvDir
Remove-EnvItem Env:EXTERNAL_INCLUDE
Remove-EnvItem Env:INCLUDE
Remove-EnvItem Env:LIB
Remove-EnvItem Env:LIBPATH
Remove-EnvItem Env:VCIDEInstallDir
Remove-EnvItem Env:VCINSTALLDIR
Remove-EnvItem Env:VCToolsInstallDir
Remove-EnvItem Env:VCToolsRedistDir
Remove-EnvItem Env:VCToolsVersion
Remove-EnvItem Env:VS160COMNTOOLS
Remove-EnvItem Env:VS170COMNTOOLS
Remove-EnvItem Env:VSCMD_ARG_app_plat
Remove-EnvItem Env:VSCMD_ARG_HOST_ARCH
Remove-EnvItem Env:VSCMD_ARG_TGT_ARCH
Remove-EnvItem Env:VSCMD_DEBUG
Remove-EnvItem Env:VSCMD_VER
Remove-EnvItem Env:VSINSTALLDIR

Import-Module '%a\Common7\Tools\Microsoft.VisualStudio.DevShell.dll';
Enter-VsDevShell -VsInstallPath '%a' -DevCmdArguments '-arch=amd64';
& %s;
exit $LASTEXITCODE|}
           Fpath.pp vsstudio_dir Fpath.pp vsstudio_dir
           (String.concat " " quoted_cmdargs))
      |> Utils.rmsg
    in
    let run_ps1 = Filename.concat (Tr1Assets.LocalDir.v ()) "run-ps1.cmd" in
    Bos.Cmd.(v run_ps1 % p with_vsdev)
  else Bos.Cmd.(v (p program) %% of_list args)
