(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Located_json = Mdexp.Private.Located_json
module Json5_accumulator = Mdexp.Private.Json5_accumulator
module Snapshot_config = Mdexp.Private.Snapshot_config

(** Helper: parse a single-line JSON5 config and build a Located_json. *)
let parse_single_line ~file_contents ~json5_text ~file_offset =
  let file_cache = Loc.File_cache.create ~path:(Fpath.v "test.ml") ~file_contents in
  let acc = Json5_accumulator.create () in
  match Json5_accumulator.feed acc ~file_offset ~line:json5_text with
  | Done { json_text } ->
    (match Yojson_five.Basic.from_string json_text |> Result.to_option with
     | Some (`Assoc _ as json) ->
       Some (Located_json.create ~file_cache ~accumulator:acc ~json)
     | _ -> None)
  | Need_more | Error -> None
;;

let%expect_test "key_loc returns correct position for single-line config" =
  Loc.include_sexp_of_locs := true;
  let file_contents = "(* @mdexp.snapshot { block: true, lang: \"json\" } *)\n" in
  let json5_text = "{ block: true, lang: \"json\" }" in
  let file_offset = 20 in
  (match parse_single_line ~file_contents ~json5_text ~file_offset with
   | None -> assert false
   | Some lj ->
     Option.iter (Located_json.key_loc lj "block") ~f:(fun loc ->
       Printf.printf "block key: %s\n" (Loc.to_string loc));
     Option.iter (Located_json.key_loc lj "lang") ~f:(fun loc ->
       Printf.printf "lang key: %s\n" (Loc.to_string loc)));
  Loc.include_sexp_of_locs := false;
  [%expect
    {|
    block key: File "test.ml", line 1, characters 22-27:
    lang key: File "test.ml", line 1, characters 35-39:
    |}]
;;

let%expect_test "value_loc returns correct position via phys_equal" =
  Loc.include_sexp_of_locs := true;
  let file_contents = "(* @mdexp.snapshot { block: true } *)\n" in
  let json5_text = "{ block: true }" in
  let file_offset = 20 in
  (match parse_single_line ~file_contents ~json5_text ~file_offset with
   | None -> assert false
   | Some lj ->
     let fields = Json_object.fields (Located_json.json lj) in
     (match List.assoc_opt "block" fields with
      | Some value ->
        Option.iter (Located_json.value_loc lj value) ~f:(fun loc ->
          Printf.printf "block value: %s\n" (Loc.to_string loc))
      | None -> assert false));
  Loc.include_sexp_of_locs := false;
  [%expect
    {|
    block value: File "test.ml", line 1, characters 29-33:
    |}]
;;

let%expect_test "key_loc returns None for missing key" =
  let file_contents = "{ block: true }\n" in
  let json5_text = "{ block: true }" in
  (match parse_single_line ~file_contents ~json5_text ~file_offset:0 with
   | None -> assert false
   | Some lj ->
     (match Located_json.key_loc lj "nonexistent" with
      | None -> print_endline "None (correct)"
      | Some _ -> assert false));
  [%expect {| None (correct) |}]
;;

let%expect_test "of_located_json reports unknown field" =
  Err.For_test.protect (fun () ->
    let file_contents = "(* @mdexp.snapshot { blck: true } *)\n" in
    let json5_text = "{ blck: true }" in
    let file_offset = 20 in
    match parse_single_line ~file_contents ~json5_text ~file_offset with
    | None -> assert false
    | Some lj ->
      let config =
        Snapshot_config.of_located_json ~inherited:Snapshot_config.default lj
      in
      print_dyn (Snapshot_config.to_dyn config));
  [%expect
    {|
    File "test.ml", line 1, characters 22-26:
    Error: Unknown field [blck] in snapshot configuration.
    Hint: did you mean block?
    { block = false; lang = None }
    [123]
    |}]
;;

let%expect_test "of_located_json reports wrong type for block" =
  Err.For_test.protect (fun () ->
    let file_contents = "(* @mdexp.snapshot { block: \"yes\" } *)\n" in
    let json5_text = "{ block: \"yes\" }" in
    let file_offset = 20 in
    match parse_single_line ~file_contents ~json5_text ~file_offset with
    | None -> assert false
    | Some lj ->
      let config =
        Snapshot_config.of_located_json ~inherited:Snapshot_config.default lj
      in
      print_dyn (Snapshot_config.to_dyn config));
  [%expect
    {|
    File "test.ml", line 1, characters 29-34:
    Error: Field [block] expects a boolean value.
    { block = false; lang = None }
    [123]
    |}]
;;
