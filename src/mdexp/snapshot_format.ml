(********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                        *)
(*  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(********************************************************************************)

type t =
  | Ocaml_block_string
  | Zig_multiline_string
  | Rust_string

let to_dyn = function
  | Ocaml_block_string -> Dyn.variant "Ocaml_block_string" []
  | Zig_multiline_string -> Dyn.variant "Zig_multiline_string" []
  | Rust_string -> Dyn.variant "Rust_string" []
;;

let for_host_language : Host_language.t -> t list = function
  | Ocaml -> [ Ocaml_block_string ]
  | Rust -> [ Rust_string ]
  | Zig -> [ Zig_multiline_string ]
;;
