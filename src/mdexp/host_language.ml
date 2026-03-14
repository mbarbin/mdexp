(********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                        *)
(*  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(********************************************************************************)

type t =
  | Ocaml
  | Rust
  | Zig

let to_dyn = function
  | Ocaml -> Dyn.variant "Ocaml" []
  | Rust -> Dyn.variant "Rust" []
  | Zig -> Dyn.variant "Zig" []
;;

let all = [ Ocaml; Rust; Zig ]

let of_file_extension = function
  | "ml" | "mli" -> Some Ocaml
  | "rs" -> Some Rust
  | "zig" -> Some Zig
  | _ -> None
;;

let markdown_lang_id t =
  Markdown_lang_id.of_string
    (match t with
     | Ocaml -> "ocaml"
     | Rust -> "rust"
     | Zig -> "zig")
;;
