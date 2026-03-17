(*_********************************************************************************)
(*_  mdexp - Literate Programming with Embedded Snapshots                         *)
(*_  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** The directive keyword found inside a source comment.

    A directive is recognized only when it is the first word on a comment line
    (after the comment marker and whitespace). Depending on the directive, the
    line parser enters a mode that determines how subsequent comment lines are
    interpreted — as prose, as code, or as JSON5 configuration (for [Code],
    [Snapshot] and [Config] directives whose trailing text begins a [{...}]
    object). *)
type t =
  | Prose
  | Code
  | End
  | Snapshot
  | Config

val to_dyn : t -> Dyn.t

module With_trailing : sig
  (** A directive as it appears on a line: the keyword and any text that follows
      it on the same line.

      {v
        @mdexp            → Prose,    trailing = None
        @mdexp # Title    → Prose,    trailing = Some "# Title"
      v} *)

  type nonrec t =
    { directive : t
    ; trailing : string option
    ; loc : Loc.t
    }

  val to_dyn : t -> Dyn.t
end

(** Parse a single line of comment content (after stripping comment markers and
    leading whitespace). A directive is recognized only when [@mdexp] is the
    first word on the line. Returns [None] for non-directive content.

    The [file_cache], [line] and [col] parameters are used to compute the
    location of the directive. [col] is the 0-based byte offset within the line
    where the [content] argument starts. *)
val parse_line
  :  content:string
  -> file_cache:Loc.File_cache.t
  -> line:int
  -> col:int
  -> With_trailing.t option
