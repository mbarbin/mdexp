(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

(* At the moment this test is empty, however this library needs to exist for
   [windtrap] to include the [mdexp_cli] library in the coverage analyzis. *)

open! Mdexp_cli

let%expect_test "empty" =
  ();
  [%expect {||}];
  ()
;;
