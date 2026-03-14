(*_*******************************************************************************)
(*_  mdexp - Literate Programming with Embedded Snapshots                        *)
(*_  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(*_*******************************************************************************)

(** A parsed JSON value together with position information for all its keys
    and values at every nesting level.

    Given a [Yojson.Basic.t] that was parsed from JSON5 text accumulated by
    [Json5_accumulator], this module lets you look up the source-file location
    of any key (by name) or any value node (by physical identity [==]).
    Positions are resolved via the accumulator's chunk map and a
    [Loc.File_cache.t]. *)

type t

(** The underlying JSON value. *)
val json : t -> Yojson.Basic.t

(** Return a view focused on a different JSON node but sharing the same
    position index. Useful for navigating into nested objects. *)
val with_json : t -> Yojson.Basic.t -> t

(** Return the file-level location of a key by name, searching at all
    nesting levels. Returns the first match found. *)
val key_loc : t -> string -> Loc.t option

(** Return the file-level location of a value node by physical identity
    ([==]).  Works for any node at any depth in the JSON tree. *)
val value_loc : t -> Yojson.Basic.t -> Loc.t option

(** Build a {!t} from a parsed JSON5 value, indexing all keys and values
    at every nesting level. Uses the accumulator's chunk map and the file
    cache to translate buffer-relative positions to file-level [Loc.t]. *)
val create
  :  file_cache:Loc.File_cache.t
  -> accumulator:Json5_accumulator.t
  -> json:Yojson.Basic.t
  -> t
