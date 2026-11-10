let clean areas =
  let open Bos in
  let fetch = Fpath.v "fetch" in
  if List.mem `DkSdkSourceCode areas then begin
    Utils.start_step "Cleaning dependencies' source code";
    let more_paths =
      let exists = OS.Dir.exists fetch |> Utils.rmsg in
      if exists then
        (* Get rid of `fetch / ocaml-backend-6ed153`, etc. *)
        let subdirs = OS.Dir.contents ~rel:true fetch |> Utils.rmsg in
        List.map
          (fun p ->
            if String.starts_with ~prefix:"ocaml-backend-" (Fpath.basename p)
            then Fpath.[ fetch // p ]
            else [])
          subdirs
        |> List.flatten
      else []
    in
    DkFs_C99.Path.rm ~recurse:() ~force:() ~kill:()
      Fpath.(
        more_paths
        @ [
            fetch / "dkml-runtime-common";
            fetch / "dksdk-access";
            fetch / "dksdk-ffi-c";
            fetch / "dksdk-ffi-java";
            fetch / "dksdk-ffi-ocaml";
          ])
    |> Utils.rmsg
  end

let run ?opts ~slots () =
  Utils.start_step "Getting source code dependencies";
  let dk_env = Utils.dk_env ?opts () in
  let dk = Utils.dk ~env:dk_env ~slots in
  (match opts with
  | Some { Utils.skip_fetch = false; _ } ->
      let project_get =
        match opts with
        | Some { next = true; _ } -> [ "DKSDK_CMAKE_GITREF"; "next" ]
        | _ -> []
      in
      dk ("dksdk.project.get" :: project_get)
  | _ -> ());
  slots
