(********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                        *)
(*  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(********************************************************************************)

(* @mdexp
# Snapshot Examples

This file demonstrates snapshot extraction with both single-line and multi-line formats.
@mdexp.end *)

(* @mdexp
## Single-Line Snapshot

A simple single-line snapshot:
@mdexp.code *)
let%expect_test "single-line snapshot" =
  let greeting = "Hello, World!" in
  print_endline greeting;
  (* @mdexp.snapshot *)
  [%expect {| Hello, World! |}]
;;

(* @mdexp
## Multi-Line Snapshot

A multi-line snapshot with multiple lines:
@mdexp.code *)
let%expect_test "multi-line snapshot" =
  let lines = [ "First line"; "Second line"; "Third line" ] in
  List.iter ~f:print_endline lines;
  (* @mdexp.snapshot *)
  [%expect
    {|
    First line
    Second line
    Third line |}]
;;
