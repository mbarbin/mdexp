(*_********************************************************************************)
(*_  mdexp - Literate Programming with Embedded Snapshots                         *)
(*_  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** Controls how a code block is rendered into the output Markdown.

    When a [@mdexp.code] directive carries an inline JSON5 object (e.g.
    [{ lang: "bash" }]), or when defaults have been set via [@mdexp.config],
    those values are decoded into a {!t} that drives the renderer: which
    language tag the code fence carries. *)

type t = { lang : Markdown_lang_id.t option }

val to_dyn : t -> Dyn.t
val default : t
val of_json : ?defaults:t -> Yojson.Basic.t -> t

(** Like {!of_json} but takes a {!Located_json.t} and reports located errors
    for unknown fields and wrong value types via [Err.error]. *)
val of_located_json : ?defaults:t -> Located_json.t -> t

(** The set of recognized field names in a code configuration object. *)
val known_fields : string list
