(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let trim_blank_lines lines =
  let rec drop_leading = function
    | [] -> []
    | line :: rest ->
      if String.is_empty (String.trim line) then drop_leading rest else line :: rest
  in
  let rec drop_trailing = function
    | [] -> []
    | [ line ] -> if String.is_empty (String.trim line) then [] else [ line ]
    | line :: rest -> line :: drop_trailing rest
  in
  lines |> drop_leading |> List.rev |> drop_leading |> List.rev |> drop_trailing
;;

let dedent_lines lines =
  let count_leading_whitespace line =
    let len = String.length line in
    let i = ref 0 in
    while !i < len && (Char.equal line.[!i] ' ' || Char.equal line.[!i] '\t') do
      incr i
    done;
    !i
  in
  let min_indent =
    List.fold_left lines ~init:None ~f:(fun acc line ->
      let trimmed = String.trim line in
      if String.is_empty trimmed
      then acc
      else (
        let indent = count_leading_whitespace line in
        match acc with
        | None -> Some indent
        | Some current_min -> Some (Int.min current_min indent)))
  in
  match min_indent with
  | None | Some 0 -> lines
  | Some indent_to_remove ->
    List.map lines ~f:(fun line ->
      if String.length line >= indent_to_remove
      then
        String.sub line ~pos:indent_to_remove ~len:(String.length line - indent_to_remove)
      else line)
;;

let count_leading_backticks line =
  let s = String.ltrim line in
  let len = String.length s in
  let rec loop i =
    if i < len && Char.equal (String.get s i) '`' then loop (i + 1) else i
  in
  loop 0
;;

let compute_fence_length lines =
  let max_backticks =
    List.fold_left lines ~init:0 ~f:(fun acc line ->
      Int.max acc (count_leading_backticks line))
  in
  Int.max 3 (max_backticks + 1)
;;

let render_snapshot ~output ~(snapshot_config : Snapshot_config.t) ~lines =
  let lines = lines |> trim_blank_lines |> dedent_lines in
  if snapshot_config.block
  then (
    let fence_len = compute_fence_length lines in
    let fence = String.make fence_len '`' in
    Buffer.add_string output fence;
    (match snapshot_config.lang with
     | Some lang -> Buffer.add_string output (Markdown_lang_id.to_string lang)
     | None -> ());
    Buffer.add_char output '\n';
    List.iter lines ~f:(fun l ->
      Buffer.add_string output (String.rtrim l);
      Buffer.add_char output '\n');
    Buffer.add_string output fence;
    Buffer.add_char output '\n')
  else
    List.iter lines ~f:(fun l ->
      Buffer.add_string output (String.rtrim l);
      Buffer.add_char output '\n');
  Buffer.add_char output '\n'
;;
