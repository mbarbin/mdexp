(********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                        *)
(*  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(********************************************************************************)

(* @mdexp
   # Snapshot Block Mode Test

   This tests snapshot extraction with block mode enabled.
   @mdexp.end *)

let%expect_test "snapshot block mode" =
  (* @mdexp.code *)
  print_endline "single line without newline";
  (* @mdexp.end *)
  [%expect {| single line without newline |}]
;;

(* @mdexp
   Another section to verify spacing.
   @mdexp.end *)

let%expect_test "another section" =
  (* @mdexp.code { lang: "text" } *)
  print_endline "another single line";
  (* @mdexp.end *)
  [%expect {| another single line |}]
;;
