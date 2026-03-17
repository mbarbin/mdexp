(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

(* @mdexp # Single-Line Directives Test (OCaml) *)

let (_ : int) = 1

(* @mdexp This is a single-line block comment with inline prose. *)

let (_ : int) = 2

(* @mdexp
## Multi-Line Block with Initial Content

This block started with "## Multi-Line Block..." as initial content,
and continues on subsequent lines.
*)

let (_ : int) = 3

(* @mdexp ### Single-Line Block Comment *)

let (_ : int) = 4

(* @mdexp ### Multi-Line with Initial Content

   This continues on the next line because the block comment
   didn't close on the first line. *)

let (_ : int) = 5
