(*_********************************************************************************)
(*_  mdexp - Literate Programming with Embedded Snapshots                         *)
(*_  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** A character-level state machine that detects the boundary of a JSON5 object.

    The accumulator is fed lines of text (typically comment content stripped of
    comment markers). It tracks brace depth while correctly handling string
    literals and escape sequences. As soon as the closing [}] that balances the
    opening [{] is encountered, the accumulator returns [Done] with the complete
    JSON5 text.

    Intended usage: after a directive like [@mdexp.config] or
    [@mdexp.snapshot], the inline text (and possibly subsequent comment lines)
    is fed to the accumulator. When [Done] is returned, the extracted text is
    parsed with [Yojson_five.Basic.from_string] for validation. *)

type t

val create : unit -> t

module Action : sig
  type t =
    | Need_more (** The JSON5 object is not yet complete; feed more lines. *)
    | Done of { json_text : string }
    (** The JSON5 object is complete; carries the full text. The rest of the
        line after the closing [}] is discarded. *)
    | Error (** A non-whitespace character was encountered before [{]. *)

  val to_dyn : t -> Dyn.t
end

(** Feed a line of text into the accumulator. [~file_offset] is the byte offset
    in the original file where [string] starts; this is used to build a chunk
    map so that buffer-relative positions can later be translated to file-level
    positions (see {!buffer_offset_to_file_offset}). *)
val feed : t -> file_offset:int -> line:string -> Action.t

(** Return the text accumulated so far, even if the object is incomplete. *)
val buffer_contents : t -> string

(** Translate a byte offset within the accumulator buffer to the corresponding
    byte offset within the original file, using the chunk map. *)
val buffer_offset_to_file_offset : t -> buffer_offset:int -> int
