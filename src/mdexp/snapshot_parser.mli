(*_*******************************************************************************)
(*_  mdexp - Literate Programming with Embedded Snapshots                        *)
(*_  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(*_*******************************************************************************)

(** Shared abstraction used by several snapshot parser.

    We need several implementations of snapshot parser to cover different
    snapshot frameworks in different host languages. This module allows sharing
    some code and interfaces between them. *)

module Action : sig
  type t =
    | Skip (** The line does not contain or continue a string literal. *)
    | Continue of { content : string }
    (** A line of content was extracted; more lines are expected. *)
    | Done of { content : string }
    (** The closing delimiter was found; carries the final content fragment. *)
    | End_not_consumed
    (** The string literal ended because the line is not a continuation.
        The caller should re-process this line through the parser. *)
end

module type S = sig
  type t

  val feed : t -> line:string -> Action.t
end
