(*_*******************************************************************************)
(*_  mdexp - Literate Programming with Embedded Snapshots                        *)
(*_  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(*_*******************************************************************************)

(** Stateful processor for snapshot string extraction.

    Manages one or more format-specific extractors and an internal content
    buffer. Feed it raw source lines; it tries each extractor in sequence until
    one finds the opening delimiter, then commits to that extractor for
    subsequent lines until the closing delimiter is found.

    The accumulator owns all mutable state internally — no closures, external
    refs, or callbacks are needed. *)

type t

module Action : sig
  type t =
    | Consumed (** The line was absorbed by snapshot extraction. *)
    | Done of { lines : string list }
    (** The snapshot is complete. Carries the accumulated content lines. *)
    | Done_not_consumed of { lines : string list }
    (** The snapshot is complete because the line is not a continuation.
        The caller should re-process this line through the parser. *)

  val to_dyn : t -> Dyn.t
end

val create : snapshot_formats:Snapshot_format.t list -> t

(** Feed a raw source line into the accumulator. Mutates internal state. *)
val feed : t -> line:string -> Action.t
