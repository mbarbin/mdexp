(*_********************************************************************************)
(*_  mdexp - Literate Programming with Embedded Snapshots                         *)
(*_  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** Declarative description of the comment syntax used by a source language.

    Each language uses either line comments, block comments, or both. mdexp
    needs to know the comment delimiters to locate directives and extract prose
    and code content from source files.

    - {b OCaml} uses block comments only ([( * ... * )]), since it has no line
      comment syntax.
    - {b Zig} uses line comments only ([//]), as the language has no block
      comment syntax.
    - {b Rust} supports both line comments ([//]) and block comments
      ([/ * ... * /]). Block comments allow natural multi-line prose without
      repeating a prefix on every line. When both styles are available,
      line comments take precedence outside of block comment regions. *)

module Block : sig
  type t = private
    { start_ : string
    ; end_ : string
    }

  val to_dyn : t -> Dyn.t
end

type t = private
  { line_prefix : string option
  ; block : Block.t option
  }

val to_dyn : t -> Dyn.t
val of_host_language : Host_language.t -> t
