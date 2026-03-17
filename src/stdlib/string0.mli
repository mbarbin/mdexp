(*_**************************************************************************************)
(*_  mdexp-stdlib - Extending OCaml's Stdlib for Mdexp                                  *)
(*_  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>        *)
(*_  SPDX-License-Identifier: MIT OR LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(*_**************************************************************************************)

include module type of struct
  include StringLabels
end

val chop_prefix : t -> prefix:string -> t option
val concat : string list -> sep:string -> string
val equal : string -> string -> bool
val is_empty : string -> bool
val ltrim : string -> string
val rtrim : string -> string
val split_lines : string -> string list
val to_string : t -> string
