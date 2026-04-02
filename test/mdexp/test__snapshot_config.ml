(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Snapshot_config = Mdexp.Private.Snapshot_config

let%expect_test "to_dyn" =
  print_dyn (Snapshot_config.to_dyn { block = false; lang = None });
  print_dyn
    (Snapshot_config.to_dyn
       { block = true; lang = Some (Markdown_lang_id.of_string "json") });
  [%expect
    {|
    { block = false; lang = None }
    { block = true; lang = Some "json" }
    |}]
;;

let%expect_test "equal" =
  let a = Snapshot_config.default in
  let b =
    { Snapshot_config.block = true; lang = Some (Markdown_lang_id.of_string "json") }
  in
  require (Snapshot_config.equal a a);
  require (not (Snapshot_config.equal a b));
  require_equal (module Snapshot_config) a { block = false; lang = None };
  [%expect {||}]
;;
