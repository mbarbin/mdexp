(*_*******************************************************************************)
(*_  mdexp - Literate Programming with Embedded Snapshots                        *)
(*_  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(*_*******************************************************************************)

type t =
  | Ocaml
  | Rust
  | Zig

val to_dyn : t -> Dyn.t
val all : t list

(** Detect the language from a file extension suffix without the leading dot.
    For example: ["ml"], not [".ml"]. *)
val of_file_extension : string -> t option

val markdown_lang_id : t -> Markdown_lang_id.t
