(*_*******************************************************************************)
(*_  mdexp - Literate Programming with Embedded Snapshots                        *)
(*_  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(*_*******************************************************************************)

(** Stateful line-by-line processor for host files. Internally tracks comment
    nesting and the current output mode (prose, code block, etc.). Each call to
    {!feed} classifies the line, updates internal state, and returns the
    resulting actions. Lines must be fed in order. *)

type t

val create
  :  file_cache:Loc.File_cache.t
  -> comment_syntax:Comment_syntax.t
  -> default_code_lang:Markdown_lang_id.t
  -> t

module Action : sig
  type t =
    | Emit_prose_line of string
    | Emit_code_line of string
    | Open_code_fence of { language : Markdown_lang_id.t }
    | Close_code_fence
    | Flush_prose
    | Flush_code
    | Blank_separator
    | Enter_snapshot of Located_json.t option
    | Enter_code of Located_json.t option
    | Configure of Located_json.t

  val to_dyn : t -> Dyn.t
end

(** Feed the next line and return output actions. Updates internal state
    (comment tracking and output mode). *)
val feed : t -> line:string -> Action.t list

(** Flush any pending output for the current mode. Call after the last line has
    been fed. *)
val flush : t -> Action.t list
