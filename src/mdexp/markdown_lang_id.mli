(*_********************************************************************************)
(*_  mdexp - Literate Programming with Embedded Snapshots                         *)
(*_  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** Language identifier used in markdown fenced code blocks.

    For example, a code fence like [```ocaml] uses the language identifier
    ["ocaml"]. This type wraps such identifiers to distinguish them from
    arbitrary strings. *)

type t

val of_string : string -> t
val to_string : t -> string
val to_dyn : t -> Dyn.t
