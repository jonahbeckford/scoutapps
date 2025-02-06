let clean areas =
  let open Bos in
  let cwd = OS.Dir.current () |> Utils.rmsg in
  if List.mem `CMakeNinjaInstallation areas then begin
    Utils.start_step "Cleaning CMake and Ninja";
    DkFs_C99.Path.rm ~recurse:() ~force:() ~kill:()
      Fpath.[ cwd / ".ci" / "cmake"; cwd / ".ci" / "ninja" ]
    |> Utils.rmsg
  end

let run ?opts ~slots () =
  let open Bos in
  let dk_env = Utils.dk_env ?opts () in
  let dk = Utils.dk ~env:dk_env ~slots in
  let cwd = OS.Dir.current () |> Utils.rmsg in

  (* CMake *)
  dk [ "dksdk.cmake.link"; "QUIET" ];
  let slots = Slots.set_cmake_home slots Fpath.(cwd / ".ci" / "cmake") in

  (* Ninja *)
  Utils.dk_ninja_link_or_copy ~dk;
  let slots = Slots.set_ninja_dir slots Fpath.(cwd / ".ci" / "ninja" / "bin") in

  slots
