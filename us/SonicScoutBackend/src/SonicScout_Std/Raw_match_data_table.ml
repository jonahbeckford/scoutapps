(*EDITABLE FILE FOR CHANGING APP OVER THE SEASONS*)

module type Fetchable_Data = sig
  val already_contains_record :
    Sqlite3.db ->
    team_number:int ->
    match_number:int ->
    scouter_name:string ->
    bool

  module Fetch : sig
    val latest_match_number : Sqlite3.db -> int option

    val missing_data :
      Sqlite3.db ->
      (int * Intf.Types.robot_position list) list

    val all_match_numbers_in_db : Sqlite3.db -> int list
    val teams_for_match_number : Sqlite3.db -> int -> int list
    (* FIXME: add missing match data function  *)
    (* val average_auto_game_pieces : Sqlite3.db -> float
       val average_auto_cones : Sqlite3.db -> float
       val average_auto_cubes : Sqlite3.db -> float
       val average_auto_cones : Sqlite3.db -> float *)
  end
end

module type Table_type = sig
  include Db_utils.Generic_Table
  include Fetchable_Data
end

type field_type =
  | Integer
  | Bool
  | String
  [@@warning "-unused-type-declaration"]

type field_kind =
  | Scouter_Name
  | Match_Number
  | Team_number

type field = {
  field_name: string;
  field_type: field_type;
  field_is_primary : bool;
  field_kind : field_kind option;
}
let fi field_name = { field_name; field_is_primary=false; field_type = Integer; field_kind=None }
let fb field_name = { field_name; field_is_primary=false; field_type = Bool; field_kind=None }
let fs field_name = { field_name; field_is_primary=false; field_type = String; field_kind=None }
let as_primary field = { field with field_is_primary=true }
let as_kind kind field = { field with field_kind = Some kind }

let fields = [
  (* An individual QR scan is tied to an individual scout ("Name")
     who scouts a single team ("Team") at an individual match ("Match").

     See [already_contains_record] which uses these fields. *)
  as_primary (as_kind Team_number (fi "Team"));
  as_primary (as_kind Match_Number (fi "Match"));
  as_primary (as_kind Scouter_Name (fs "Name"));
  fs "Alliance";
  fs "StartingPosition";
  fs "AutoMove";
  fi "AutoFuelScored";
  fi "AutoFuelMissed";
  fs "AutoObstacles";
  fs "AutoIntakes";
  fs "AutoClimb";
  fi "TeleOpFuelScored";
  fi "TeleOpFuelMissed";
  fs "TeleOpObstacles";
  fs "TeleOpIntakes";
  fs "TowerClimb";
  fs "ClimbTime";
  fs "Breakdown";
  fs "BreakdownTime";
]

let getfield name =
  List.find_opt
    (fun { field_name; _} -> String.equal field_name name)
    fields

let getcolname ~kindname kind = 
  let maybe_found =
    List.find_opt
      (fun field -> match field.field_kind with Some ct when ct = kind -> true | _ -> false)
      fields
  in
  match maybe_found with
  | Some field -> field.field_name
  | None -> failwith (Printf.sprintf "No field with field kind %s found! Use `as_kind %s (fs \"field_name\")` in `let fields = [...]` to designate a field as the field kind." kindname kindname)

let col_team_number () = getcolname ~kindname:"Team_number" Team_number
let col_match_number () = getcolname ~kindname:"Match_Number" Match_Number
let col_scouter_name () = getcolname ~kindname:"Scouter_Name" Scouter_Name

let primaryfields () =
  let fields =
    List.filter_map
      (fun {field_is_primary; field_name; field_type=_; field_kind=_} ->
        if field_is_primary then Some field_name else None)
      fields
  in
  match fields with
  | [] -> failwith "No primary fields defined for the Raw_match_data_table! Use `as_primary (fs \"field_name\")` in `let fields = [...]` to make a field primary."
  | _ :: _ -> fields

(*Code which can be edited for each specific season*)
module Table : Table_type = struct
  let table_name = "raw_match_data"

  let create_table db =
    let columns = Buffer.create 1024 in
    List.iteri
      (fun idx { field_name; field_type=_; field_is_primary=_; field_kind=_ } ->
            if (idx > 0) then (
              Buffer.add_string columns " ,";
            );
            Printf.bprintf columns "%s" field_name)
      fields;
    let createtable = Printf.sprintf "CREATE TABLE IF NOT EXISTS %s (%s, PRIMARY KEY (%s))"
      table_name
      (Buffer.contents columns)
      (String.concat "," (primaryfields ()))
    in
    match Sqlite3.exec db createtable with
    | Sqlite3.Rc.OK ->
        print_endline "create table successful";
        Db_utils.Successful
    | r ->
        Db_utils.formatted_error_message db r
          (Printf.sprintf "failed to create table with sql: %s" createtable);
        Db_utils.Failed

  let drop_table _db = Db_utils.Failed

  let already_contains_record db ~team_number ~match_number ~scouter_name =
    let to_select = col_team_number () in
    let where =
      [
        (col_team_number (), Db_utils.Select.Int team_number);
        (col_match_number (), Db_utils.Select.Int match_number);
        (col_scouter_name (), Db_utils.Select.String scouter_name);
      ]
    in

    let result =
      Db_utils.Select.select_ints_where db ~table_name ~to_select ~where
    in

    match result with _ :: [] -> true | _ -> false

  (** The QR code format is carriage-return, line-feed separated
      name value parameters.

      An example code is the following, broken onto many lines
      for readability:

      {v
        Name-\r\nSPos-Left\r\nTeam-0\r\n
        Match-0\r\nALeave-True\r\nAL4-0\r\n
        AL3-0\r\nAL2-0\r\nAL1-0\r\nAM4-0\r\n
        AM3-0\r\nAM2-0\r\nAM1-0\r\n
        GPickup-False\r\nTL4-0\r\nTL3-0\r\n
        TL2-0\r\nTL1-0\r\nTM4-0\r\nTM3-0\r\n
        TM2-0\r\nTM1-0\r\nAPS-0\r\nAPM-0\r\n
        ANS-0\r\nANM-0\r\nTPS-0\r\nTPM-0\r\n
        TNS-0\r\nTNM-0\r\nTBK-None\r\nCLB-Success
      v}

      For example, the name ["GPickup"] has the value ["False"].
    *)
  let insert_record db qr_string =
    (* NAME1-VALUE1\r\nNAME2-VALUE2\r\n...
       ==>
       NAME1-VALUE1\r
       NAME2-VALUE2\r
       ... *)
    let namevalues = String.split_on_char '\n' qr_string in
    (* NAME1-VALUE1\r
       NAME2-VALUE2\r
       ==>
       NAME1-VALUE1
       NAME2-VALUE2
       ... *)
    let namevalues = List.map String.trim namevalues in
    (* NAME1-VALUE1
       NAME2-VALUE2
       ==>
       (NAME1,VALUE1)
       (NAME2,VALUE2)
       ... *)
    let namevalues = List.filter_map (fun s ->
      let splitted = String.split_on_char '-' s in
      match splitted with
      | [name; value] ->
        (* Printf.eprintf "(name, value) = (%s, %s)\n%!" name value; *)
        Some (name, value)
      | _ -> None
      ) namevalues in

    (* This uses string manipulation to make a SQL command ...
       it follows what the original authors did in 2023.
       If you were making an application for a customer, this would
       be a security vulnerability because a malicious person
       could make a QR code that ran arbitrary commands on your
       computer. Not good! It is an attack called
       "SQL injection attack". *)
    let column_names = Buffer.create 1024 in
    let field_values = Buffer.create 1024 in
    List.iteri
      (fun idx (name, value) ->
        match getfield name with
        | None ->
            Printf.eprintf "WARNING! The QR code contained `%s` but the QR scanning code in %s.ml did not add a field for it.\n" name __MODULE__
        | Some { field_name; field_type=_; field_is_primary=_; field_kind=_ } ->
            if (idx > 0) then (
              Buffer.add_string column_names " ,";
              Buffer.add_string field_values " ,";
            );
            Buffer.add_string column_names field_name;
            Buffer.add_string field_values ("\"" ^ value ^ "\""))
      namevalues;

    let sql = Printf.sprintf "INSERT INTO %s(%s) VALUES(%s)"
          table_name
          (Buffer.contents column_names)
          (Buffer.contents field_values)
    in
    Logs.info (fun l -> l "raw_match_table sql: %s" sql);

    match Sqlite3.exec db sql with
    | Sqlite3.Rc.OK ->
        print_endline "exec successful";
        Db_utils.Successful
    | r ->
        Db_utils.formatted_error_message db r
          "failed to exec raw_match_data insert sql";
        Db_utils.Failed

  module Fetch = struct
    let latest_match_number db =
      let to_select = col_match_number () in

      let where = [] in

      let order_by = [ (col_match_number (), Db_utils.Select.DESC) ] in

      let result =
        Db_utils.Select.select_ints_where db ~table_name ~to_select ~where
          ~order_by
      in

      match result with [] -> None | x :: _ -> Some x

    let all_match_numbers_in_db db =
      let to_select = col_match_number () in

      Db_utils.Select.select_ints_where db ~table_name ~to_select ~where:[]

    let teams_for_match_number db match_num =
      let to_select = col_team_number () in
      let where =
        [ (col_match_number (), Db_utils.Select.Int match_num) ]
      in

      Db_utils.Select.select_ints_where db ~table_name ~to_select ~where

    let missing_data db =
      (* let scheduled_matches =
        Match_schedule_table.Table.Fetch.get_all_match_numbers db
      in *)

      (* let all_matches_in_db = all_match_numbers_in_db db in *)

      let latest_match = latest_match_number db in

      match latest_match with
      | None -> []
      | Some l_match ->
          let num_entries_for_match_num match_num =
            let to_select = col_match_number () in
            let where =
              [ (col_match_number (), Db_utils.Select.Int match_num) ]
            in

            List.length
              (Db_utils.Select.select_ints_where db ~table_name ~to_select
                 ~where)
          in

          let rec build_missing_lst lst current_match =
            match current_match > l_match with
            | true -> lst
            | false ->
                let num_entries = num_entries_for_match_num current_match in
                let new_lst =
                  if num_entries < 6 then current_match :: lst else lst
                in

                build_missing_lst new_lst (current_match + 1)
          in

          let missing_data_matches = build_missing_lst [] 1 in

          let teams_missing_per_match_list =
            let rec build matches_missing_data lst =
              match matches_missing_data with
              | [] -> lst
              | match_n :: l ->
                  let teams_scheduled =
                    Match_schedule_table.Table.Fetch.get_all_teams_for_match db
                      match_n
                  in
                  let teams_actually_in_db =
                    teams_for_match_number db match_n
                  in

                  let teams_missing_for_this_match =
                    let rec fliter all_teams missing =
                      match all_teams with
                      | x :: l ->
                          if List.exists (fun a -> a == x) teams_actually_in_db
                          then fliter l missing
                          else fliter l (x :: missing)
                      | [] -> missing
                    in

                    fliter teams_scheduled []
                  in

                  build l ((match_n, teams_missing_for_this_match) :: lst)
            in

            build missing_data_matches []
          in

          let positions_missing_per_match =
            let rec build teams_list pose_list =
              match teams_list with
              | (match_n, lst) :: l ->
                  let rec build_pos_list team_nums pos_lst =
                    match team_nums with
                    | [] -> pos_lst
                    | x :: l ->
                        let p =
                          Match_schedule_table.Table.Fetch
                          .get_position_for_team_and_match db x match_n
                        in
                        build_pos_list l (p :: pos_lst)
                  in

                  let poses = build_pos_list lst [] in

                  build l ((match_n, poses) :: pose_list)
              | [] -> pose_list
            in

            build teams_missing_per_match_list []
          in

          let de_optioned_positions =
            let rec build pose_lst no_opt_lst =
              match pose_lst with
              | [] -> no_opt_lst
              | (match_n, opt_poses) :: l ->
                  let rec de_opt_lst opt_poses de_opted =
                    match opt_poses with
                    | [] -> de_opted
                    | Some x :: l ->
                        let d = x :: de_opted in
                        de_opt_lst l d
                    | None :: l -> de_opt_lst l de_opted
                  in

                  let non_optioned = de_opt_lst opt_poses [] in

                  build l ((match_n, non_optioned) :: no_opt_lst)
            in

            build positions_missing_per_match []
          in

          de_optioned_positions
  end
end
