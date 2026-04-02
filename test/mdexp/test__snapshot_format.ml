(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Snapshot_format = Mdexp.Private.Snapshot_format

let%expect_test "to_dyn" =
  List.iter
    [ Snapshot_format.Ocaml_block_string; Zig_multiline_string; Rust_string ]
    ~f:(fun t -> print_dyn (Snapshot_format.to_dyn t));
  [%expect
    {|
    Ocaml_block_string
    Zig_multiline_string
    Rust_string
    |}]
;;
