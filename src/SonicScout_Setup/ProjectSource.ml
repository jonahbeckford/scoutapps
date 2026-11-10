let run ?global_dkml ~slots () =
  let open Bos in
  Utils.start_step "Regenerating Java and OCaml schema";
  let cwd = OS.Dir.current () |> Utils.rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutBackend") in
  let projectdir_android = Fpath.(cwd / "us" / "SonicScoutAndroid") in
  let builddir = Fpath.(projectdir / "build_dev") in

  (* Delete Android generated source code (which has a copy of the
     Java schema) *)
  DkFs_C99.Path.rm ~recurse:() ~force:() ~kill:()
    Fpath.[ projectdir_android / "data" / "build" / "generated" ]
  |> Utils.rmsg;

  let schema_java =
    Fpath.(projectdir / "src" / "SonicScout_Std" / "Schema.java")
  in
  let schema_ml = Fpath.(projectdir / "src" / "SonicScout_Std" / "Schema.ml") in

  let p = Fpath.to_string in
  RunNinja.run ?global_dkml ~projectdir ~name:"projectsource" ~slots
    [ "-C"; p builddir; "-v"; "-d"; "explain"; p schema_java; p schema_ml ]
