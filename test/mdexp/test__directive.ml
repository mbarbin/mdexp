(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Directive = Mdexp.Private.Directive

let%expect_test "Directive.parse_line" =
  let test s =
    let file_cache = Loc.File_cache.create ~path:(Fpath.v "test.ml") ~file_contents:s in
    Directive.parse_line ~content:s ~file_cache ~line:1 ~col:0
    |> Dyn.option Directive.With_trailing.to_dyn
    |> print_dyn
  in
  test "@mdexp";
  [%expect {|Some { directive = Prose; trailing = None; loc = "_" }|}];
  test "@mdexp Some text here";
  [%expect {|Some { directive = Prose; trailing = Some "Some text here"; loc = "_" }|}];
  test "@mdexp.prose";
  [%expect {|Some { directive = Prose; trailing = None; loc = "_" }|}];
  test "@mdexp.prose # Title";
  [%expect {|Some { directive = Prose; trailing = Some "# Title"; loc = "_" }|}];
  test "@mdexp.code";
  [%expect {|Some { directive = Code; trailing = None; loc = "_" }|}];
  test {|@mdexp.code { lang: "bash" }|};
  [%expect {|Some { directive = Code; trailing = Some "{ lang: \"bash\" }"; loc = "_" }|}];
  test "@mdexp.end";
  [%expect {|Some { directive = End; trailing = None; loc = "_" }|}];
  test "@mdexp.snapshot";
  [%expect {|Some { directive = Snapshot; trailing = None; loc = "_" }|}];
  test {|@mdexp.snapshot { lang: "json" }|};
  [%expect
    {|Some
  { directive = Snapshot; trailing = Some "{ lang: \"json\" }"; loc = "_" }|}];
  test {|@mdexp.snapshot { block: true }|};
  [%expect
    {|Some { directive = Snapshot; trailing = Some "{ block: true }"; loc = "_" }|}];
  test "just text";
  [%expect {|None|}];
  test "";
  [%expect {|None|}];
  test "  @mdexp  ";
  [%expect {|Some { directive = Prose; trailing = None; loc = "_" }|}];
  test {|  @mdexp.code   { lang: "bash" }  |};
  [%expect {|Some { directive = Code; trailing = Some "{ lang: \"bash\" }"; loc = "_" }|}]
;;
