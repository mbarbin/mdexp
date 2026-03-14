(********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                        *)
(*  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(********************************************************************************)

module Phase = struct
  type t =
    | Looking_for_open
    | Inside of { hash_count : int }
end

type t = { mutable phase : Phase.t }

let create () = { phase = Looking_for_open }

(* Find a Rust string literal opening: "..." or r#"..."# in a line.
   Returns (hash_count, content_start_pos) where hash_count=0 for regular strings
   and hash_count=N for r###"..."### raw strings. *)
let find_string_open line =
  let len = String.length line in
  let rec search i =
    if i >= len
    then None
    else if Char.equal line.[i] 'r' && i + 1 < len
    then (
      (* Count hashes after 'r' *)
      let rec count_hashes j =
        if j < len && Char.equal line.[j] '#' then count_hashes (j + 1) else j
      in
      let hash_end = count_hashes (i + 1) in
      let hash_count = hash_end - (i + 1) in
      if hash_end < len && Char.equal line.[hash_end] '"'
      then Some (hash_count, hash_end + 1)
      else search (i + 1))
    else if Char.equal line.[i] '"'
    then
      (* Regular string literal - but skip if preceded by 'r' (already handled above)
         or by '@' which is part of insta syntax and should be skipped over *)
      Some (0, i + 1)
    else search (i + 1)
  in
  search 0
;;

(* Find the closing delimiter: " for regular strings, "#...# for raw strings. *)
let find_string_close ~hash_count line start_pos =
  let len = String.length line in
  let rec search i =
    if i >= len
    then None
    else if Char.equal line.[i] '"'
    then
      if hash_count = 0
      then Some i
      else (
        (* Check for hash_count '#' characters after '"' *)
        let rec check_hashes j count =
          if count >= hash_count
          then true
          else if j < len && Char.equal line.[j] '#'
          then check_hashes (j + 1) (count + 1)
          else false
        in
        if check_hashes (i + 1) 0 then Some i else search (i + 1))
    else search (i + 1)
  in
  search start_pos
;;

let feed (t : t) ~line : Snapshot_parser.Action.t =
  match t.phase with
  | Looking_for_open ->
    (match find_string_open line with
     | Some (hash_count, content_start) ->
       let rest =
         String.sub line ~pos:content_start ~len:(String.length line - content_start)
       in
       (match find_string_close ~hash_count rest 0 with
        | Some close_pos ->
          let content = String.sub rest ~pos:0 ~len:close_pos in
          Done { content }
        | None ->
          t.phase <- Inside { hash_count };
          Continue { content = rest })
     | None -> Skip)
  | Inside { hash_count } ->
    (match find_string_close ~hash_count line 0 with
     | Some close_pos ->
       let content = String.sub line ~pos:0 ~len:close_pos in
       Done { content }
     | None -> Continue { content = line })
;;
