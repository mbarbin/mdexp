(*_********************************************************************************)
(*_  mdexp - Literate Programming with Embedded Snapshots                         *)
(*_  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** Top-level configuration for [@mdexp.config] directives.

    Parses the JSON object from a config directive, dispatching to
    {!Snapshot_config} and {!Code_config} for their respective sub-objects.
    Reports errors for unknown fields and non-object values.

    The [~inherited] parameter carries the previously accumulated configuration
    so that fields not mentioned in the current directive retain their earlier
    values. *)

type t =
  { snapshot : Snapshot_config.t
  ; code : Code_config.t
  }

val of_located_json : inherited:t -> Located_json.t -> t
