open Tezt
open DkSDKFFIOCaml_Std
module ProjectSchema = SquirrelScout_Std.Schema.Make (ComMessage.C)

let tags = [ "objs" ]

(* This module is for testing the Bridge object in OCaml.
   The Java code is the real code, but the Java code should do the same Capnp
   conversions as this test! *)
module BridgeTest = struct
  open ComStandardSchema.Make (ComMessage.C)

  let create com = Com.borrow_class_until_finalized com "SquirrelScout::Bridge"
  let method_create_object = Com.method_id "create_object"
  let method_generate_qr_code = Com.method_id "generate_qr_code"

  let method_get_team_for_match_and_position =
    Com.method_id "get_team_for_match_and_position"

  let method_insert_scouted_data = Com.method_id "insert_scouted_data"

  class bridge _clazz inst =
    object
      method get_team_for_match_and_position (matchnum : int)
          (position : SquirrelScout_Std.Types.robot_position) =
        let args =
          let open ProjectSchema.Builder in
          let pos : RobotPosition.t =
            match position with
            | Red_1 -> Red1
            | Red_2 -> Red2
            | Red_3 -> Red3
            | Blue_1 -> Blue1
            | Blue_2 -> Blue2
            | Blue_3 -> Blue3
          in
          let rw = MatchAndPosition.init_root () in
          MatchAndPosition.match_set_exn rw matchnum;
          MatchAndPosition.position_set rw pos;
          MatchAndPosition.to_message rw
        in
        let ret_ptr =
          Com.call_instance_method inst method_get_team_for_match_and_position
            args
        in
        Reader.Si16.i1_get (Reader.of_pointer ret_ptr)
      (* method insert_scouted_data match position =
         let args =
           let open Builder.St in
           let rw = init_root () in
           i1_set rw question;
           to_message rw
         in
         let ret_ptr = Com.call_instance_method inst method_ask args in
         Reader.St.i1_get (Reader.of_pointer ret_ptr) *)
    end

  let new_bridge clazz db_path =
    let args =
      let open Builder.St in
      let r = init_root () in
      i1_set r db_path;
      to_message r
    in
    Com.call_class_constructor clazz method_create_object
      (new bridge clazz)
      args

  let generate_qr_code clazz blob =
    let args =
      let open Builder.Sd in
      let r = init_root () in
      i1_set r blob;
      to_message r
    in
    let ret_ptr = Com.call_class_method clazz method_generate_qr_code args in
    Reader.Sd.i1_get (Reader.of_pointer ret_ptr)
end

let com = Com.create_c ()
let () = SquirrelScout_Objs.register_objects com
let bridge_clazz = BridgeTest.create com

let () =
  Tezt.Test.register ~__FILE__ ~title:"generate_qr_code" ~tags @@ fun () ->
  let actual = BridgeTest.generate_qr_code bridge_clazz "What am I?" in
  let expected_first_line =
    {|<svg xmlns='http://www.w3.org/2000/svg' version='1.1' width='50mm' height='50mm' viewBox='0 0 29 29'>|}
  in
  let actual_first_newline = String.index actual '\n' in
  let actual_first_line =
    String.sub actual 0 actual_first_newline |> String.trim
  in
  Check.((expected_first_line = actual_first_line) string)
    ~error_msg:"expected first line of QR code image to be %L, got %R";
  Lwt.return ()

let () =
  Tezt.Test.register ~__FILE__ ~title:"get_team_for_match_and_position" ~tags
  @@ fun () ->
  let db_path = Tezt.Temp.file "test.db" in
  let bridge = BridgeTest.new_bridge bridge_clazz db_path in
  let actual = bridge#get_team_for_match_and_position 1 Red_2 in
  Check.((actual = -1) int)
    ~error_msg:
      "expected team = -1 (that is 'not found') but instead received %L";
  Lwt.return ()

let () = Test.run ()

let () =
  let engine = Lwt_engine.get () in
  engine#destroy
