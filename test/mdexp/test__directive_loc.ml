(********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                        *)
(*  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(********************************************************************************)

(* Tests verifying the positional accuracy of directive locations.

   These tests enable [Loc.include_sexp_of_locs] to inspect the computed
   locations, then verify that they point to the correct characters in the
   source file. *)

module Directive = Mdexp.Private.Directive

let with_locs_shown f =
  let prev = !Loc.include_sexp_of_locs in
  Loc.include_sexp_of_locs := true;
  Fun.protect ~finally:(fun () -> Loc.include_sexp_of_locs := prev) f
;;

(* -- Directive.parse_line location tests -- *)

let%expect_test "location covers the directive keyword and trailing text" =
  with_locs_shown (fun () ->
    let file_contents = {|@mdexp.code { lang: "bash" }|} ^ "\n" in
    let content = {|@mdexp.code { lang: "bash" }|} in
    let file_cache = Loc.File_cache.create ~path:(Fpath.v "test.ml") ~file_contents in
    let result = Directive.parse_line ~content ~file_cache ~line:1 ~col:0 in
    Option.iter result ~f:(fun (d : Directive.With_trailing.t) ->
      print_endline (Loc.to_string d.loc)));
  [%expect {| File "test.ml", line 1, characters 0-28: |}]
;;

let%expect_test "location with leading whitespace in content" =
  with_locs_shown (fun () ->
    let file_contents = "  @mdexp  \n" in
    let content = "  @mdexp  " in
    let file_cache = Loc.File_cache.create ~path:(Fpath.v "test.ml") ~file_contents in
    let result = Directive.parse_line ~content ~file_cache ~line:1 ~col:0 in
    Option.iter result ~f:(fun (d : Directive.With_trailing.t) ->
      print_endline (Loc.to_string d.loc));
    Option.iter result ~f:(fun (d : Directive.With_trailing.t) ->
      let loc = d.loc in
      Printf.printf
        "start_offset=%d stop_offset=%d\n"
        (Loc.start_offset loc)
        (Loc.stop_offset loc)));
  [%expect
    {|File "test.ml", line 1, characters 2-8:
start_offset=2 stop_offset=8|}]
;;

let%expect_test "location with col offset (simulating comment stripping)" =
  with_locs_shown (fun () ->
    (* Simulate: original line is "(* @mdexp.code { lang: "bash" } *)"
       After stripping "(* ", the content is the directive, col=3. *)
    let file_contents = {|(* @mdexp.code { lang: "bash" } *)|} ^ "\n" in
    let content = {|@mdexp.code { lang: "bash" }|} in
    let col = 3 in
    let file_cache = Loc.File_cache.create ~path:(Fpath.v "test.ml") ~file_contents in
    let result = Directive.parse_line ~content ~file_cache ~line:1 ~col in
    Option.iter result ~f:(fun (d : Directive.With_trailing.t) ->
      print_endline (Loc.to_string d.loc)));
  [%expect {| File "test.ml", line 1, characters 3-31: |}]
;;

let%expect_test "location on second line of file" =
  with_locs_shown (fun () ->
    let file_contents =
      "let x = 42\n(* @mdexp.snapshot { lang: \"json\" } *)\nlet y = 0\n"
    in
    let content = {|@mdexp.snapshot { lang: "json" }|} in
    let col = 3 in
    let file_cache = Loc.File_cache.create ~path:(Fpath.v "test.ml") ~file_contents in
    let result = Directive.parse_line ~content ~file_cache ~line:2 ~col in
    Option.iter result ~f:(fun (d : Directive.With_trailing.t) ->
      print_endline (Loc.to_string d.loc)));
  [%expect {|File "test.ml", line 2, characters 3-35:|}]
;;

let%expect_test "location for line comment (Rust-style)" =
  with_locs_shown (fun () ->
    let file_contents = {|// @mdexp.code { lang: "rust" }|} ^ "\n" in
    let content = {|@mdexp.code { lang: "rust" }|} in
    let col = 3 in
    let file_cache = Loc.File_cache.create ~path:(Fpath.v "test.rs") ~file_contents in
    let result = Directive.parse_line ~content ~file_cache ~line:1 ~col in
    Option.iter result ~f:(fun (d : Directive.With_trailing.t) ->
      print_endline (Loc.to_string d.loc)));
  [%expect {| File "test.rs", line 1, characters 3-31: |}]
;;

(* -- Error reporting with locations -- *)

let%expect_test "error report with directive location" =
  Err.For_test.protect (fun () ->
    let file_contents =
      "let x = 42\n(* @mdexp.snapshot { invalid_field: true } *)\nlet y = 0\n"
    in
    let content = "@mdexp.snapshot { invalid_field: true }" in
    let col = 3 in
    let file_cache = Loc.File_cache.create ~path:(Fpath.v "test.ml") ~file_contents in
    match Directive.parse_line ~content ~file_cache ~line:2 ~col with
    | None -> ()
    | Some d ->
      Err.raise
        ~loc:d.loc
        ~hints:(Err.did_you_mean "blck" ~candidates:[ "block"; "lang" ])
        [ Pp.text "Unknown field in snapshot configuration." ]);
  [%expect
    {|File "test.ml", line 2, characters 3-42:
Error: Unknown field in snapshot configuration.
Hint: did you mean block?
[123]|}]
;;

let%expect_test "error report for wrong field type" =
  Err.For_test.protect (fun () ->
    let file_contents = "(* @mdexp.snapshot { block: \"yes\" } *)\n" in
    let content = {|@mdexp.snapshot { block: "yes" }|} in
    let col = 3 in
    let file_cache = Loc.File_cache.create ~path:(Fpath.v "test.ml") ~file_contents in
    match Directive.parse_line ~content ~file_cache ~line:1 ~col with
    | None -> ()
    | Some d ->
      Err.raise
        ~loc:d.loc
        [ Pp.textf "Invalid type for field \"block\": expected a boolean, got a string." ]);
  [%expect
    {|File "test.ml", line 1, characters 3-35:
Error: Invalid type for field "block": expected a boolean, got a string.
[123]|}]
;;
