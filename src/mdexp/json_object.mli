(*_********************************************************************************)
(*_  mdexp - Literate Programming with Embedded Snapshots                         *)
(*_  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** A JSON value that is known to be an object ([\`Assoc]).

    Since the type is a polymorphic variant subset of [Yojson.Basic.t],
    it can be cast with [:>] when the full JSON type is needed. *)

type t = [ `Assoc of (string * Yojson.Basic.t) list ]

val fields : t -> (string * Yojson.Basic.t) list
