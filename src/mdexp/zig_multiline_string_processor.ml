(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Phase = struct
  type t =
    | Looking_for_open
    | Inside
end

type t = { mutable phase : Phase.t }

let create () = { phase = Looking_for_open }

let find_multiline_open line =
  let len = String.length line in
  let rec loop i =
    if i > len - 2
    then None
    else if Char.equal line.[i] '\\' && Char.equal line.[i + 1] '\\'
    then (
      let content_start = i + 2 in
      Some (String.sub line ~pos:content_start ~len:(len - content_start)))
    else loop (i + 1)
  in
  loop 0
;;

let starts_with_continuation line =
  let trimmed = String.ltrim line in
  String.length trimmed >= 2 && Char.equal trimmed.[0] '\\' && Char.equal trimmed.[1] '\\'
;;

let extract_continuation_content line =
  let trimmed = String.ltrim line in
  String.sub trimmed ~pos:2 ~len:(String.length trimmed - 2)
;;

let feed (t : t) ~line : Snapshot_parser.Action.t =
  match t.phase with
  | Looking_for_open ->
    (match find_multiline_open line with
     | None -> Skip
     | Some content ->
       t.phase <- Inside;
       Continue { content })
  | Inside ->
    if starts_with_continuation line
    then Continue { content = extract_continuation_content line }
    else End_not_consumed
;;
