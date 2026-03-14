(********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                        *)
(*  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(********************************************************************************)

module Phase = struct
  type t =
    | Looking_for_open
    | Inside of { id : string }
end

type t = { mutable phase : Phase.t }

let create () = { phase = Looking_for_open }

let is_id_char c =
  let code = Char.code c in
  (code >= Char.code 'a' && code <= Char.code 'z')
  || (code >= Char.code '0' && code <= Char.code '9')
  || Char.equal c '_'
;;

(* Find {<id>| in a line. OCaml block string syntax: {<id>|...|<id>}
   where <id> can be empty and may only contain [a-z0-9_]. *)
let find_block_string_open line =
  let len = String.length line in
  let result = ref None in
  let i = ref 0 in
  while !i < len && Option.is_none !result do
    if Char.equal line.[!i] '{'
    then (
      let brace_pos = !i in
      let j = ref (brace_pos + 1) in
      let found_pipe = ref false in
      let bad = ref false in
      while !j < len && (not !found_pipe) && not !bad do
        if Char.equal line.[!j] '|'
        then (
          let id = String.sub line ~pos:(brace_pos + 1) ~len:(!j - brace_pos - 1) in
          result := Some (id, !j + 1);
          found_pipe := true)
        else if is_id_char line.[!j]
        then incr j
        else bad := true
      done;
      if not !found_pipe then i := brace_pos + 1)
    else incr i
  done;
  !result
;;

let find_block_string_close ~id line =
  let len = String.length line in
  let id_len = String.length id in
  let close_len = 1 + id_len + 1 in
  let rec loop i =
    if i > len - close_len
    then None
    else if
      Char.equal line.[i] '|'
      && (id_len = 0 || String.sub line ~pos:(i + 1) ~len:id_len = id)
      && Char.equal line.[i + 1 + id_len] '}'
    then Some i
    else loop (i + 1)
  in
  loop 0
;;

let feed (t : t) ~line : Snapshot_parser.Action.t =
  match t.phase with
  | Looking_for_open ->
    (match find_block_string_open line with
     | Some (id, content_start) ->
       let rest =
         String.sub line ~pos:content_start ~len:(String.length line - content_start)
       in
       (match find_block_string_close ~id rest with
        | Some close_pos ->
          let content = String.sub rest ~pos:0 ~len:close_pos in
          Done { content }
        | None ->
          t.phase <- Inside { id };
          Continue { content = rest })
     | None -> Skip)
  | Inside { id } ->
    (match find_block_string_close ~id line with
     | Some close_pos ->
       let content = String.sub line ~pos:0 ~len:close_pos in
       Done { content }
     | None ->
       t.phase <- Inside { id };
       Continue { content = line })
;;
