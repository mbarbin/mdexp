(*_********************************************************************************)
(*_  mdexp - Literate Programming with Embedded Snapshots                         *)
(*_  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** This processor works on top of the line processor and knows to dispatch to
    other processors. *)

type t

val create : file_cache:Loc.File_cache.t -> host_language:Host_language.t -> t
val feed : t -> line:string -> unit
val flush : t -> string

(** Wrapper to process one file at once. *)
val process_file : t -> file_contents:string -> string
