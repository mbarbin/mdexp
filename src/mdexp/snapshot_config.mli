(*_*******************************************************************************)
(*_  mdexp - Literate Programming with Embedded Snapshots                        *)
(*_  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(*_*******************************************************************************)

(** Controls how a snapshot is rendered into the output Markdown.

    When a [@mdexp.snapshot] directive carries an inline JSON5 object (e.g.
    [{ lang: "json", block: true }]), or when defaults have been set via
    [@mdexp.config], those values are decoded into a {!t} that drives the
    renderer: whether the snapshot is wrapped in a fenced code block, and which
    language tag the fence carries. *)

type t =
  { block : bool
  ; lang : Markdown_lang_id.t option
  }

val to_dyn : t -> Dyn.t
val default : t
val of_json : ?defaults:t -> Yojson.Basic.t -> t

(** Like {!of_json} but takes a {!Located_json.t} and reports located errors
    for unknown fields and wrong value types via [Err.error]. *)
val of_located_json : ?defaults:t -> Located_json.t -> t

(** The set of recognized field names in a snapshot configuration object. *)
val known_fields : string list
