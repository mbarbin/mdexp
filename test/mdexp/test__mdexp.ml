(********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                        *)
(*  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(********************************************************************************)

(* At the moment this test is empty, however this library needs to exist for
   [windtrap] to include the [mdexp] library in the coverage analyzis. *)

open! Mdexp

let%expect_test "empty" =
  ();
  [%expect {||}];
  ()
;;
