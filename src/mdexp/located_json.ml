(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

(* Position association list for all JSON nodes, keyed by physical identity.
   We store every key string position by (key_name, Loc.t) and every value
   node position by (Yojson.Basic.t, Loc.t) — including nested ones. *)

type t =
  { json : Yojson.Basic.t
  ; key_positions : (string * Loc.t) list
  ; node_positions : (Yojson.Basic.t * Loc.t) list
  }

let json t = t.json
let with_json t json = { t with json }

let key_loc t name =
  List.find_map t.key_positions ~f:(fun (k, loc) ->
    if String.equal k name then Some loc else None)
;;

let value_loc t node =
  List.find_map t.node_positions ~f:(fun (n, loc) ->
    if phys_equal n node then Some loc else None)
;;

(* -- JSON5 text scanner -- *)

(* We walk the buffer text and the parsed JSON tree in parallel.  The text
   tells us byte offsets; the tree tells us which heap-allocated node each
   range corresponds to.  We record every key and every value at every
   nesting level. *)

type scan_ctx =
  | Outside_string
  | In_double_quote
  | In_double_quote_escaped
  | In_single_quote
  | In_single_quote_escaped

let is_ident_char c =
  let code = Char.code c in
  (code >= Char.code 'a' && code <= Char.code 'z')
  || (code >= Char.code 'A' && code <= Char.code 'Z')
  || (code >= Char.code '0' && code <= Char.code '9')
  || Char.equal c '_'
  || Char.equal c '$'
;;

(* Skip whitespace and commas, return the index of the next meaningful char. *)
let skip_ws text i len =
  let j = ref i in
  while !j < len && (Char.is_whitespace text.[!j] || Char.equal text.[!j] ',') do
    incr j
  done;
  !j
;;

(* Find the end of a string literal starting at [i] (positioned on the opening
   quote character).  Returns the index just past the closing quote. *)
let skip_string text i len =
  let quote = text.[i] in
  let j = ref (i + 1) in
  while !j < len && not (Char.equal text.[!j] quote && text.[!j - 1] <> '\\') do
    (* Handle escaped characters properly *)
    if Char.equal text.[!j] '\\' then j := !j + 2 else incr j
  done;
  if !j < len then !j + 1 else !j
;;

(* Find the extent of an unquoted value (number, boolean, null) starting at [i].
   Returns the index just past the last character. *)
let skip_unquoted_value text i len =
  let j = ref i in
  while
    !j < len
    &&
    let c = text.[!j] in
    (not (Char.is_whitespace c))
    && (not (Char.equal c ','))
    && (not (Char.equal c '}'))
    && not (Char.equal c ']')
  do
    incr j
  done;
  !j
;;

(* Find the matching closing delimiter for a brace/bracket opened at [i].
   Handles string literals and nesting.  Returns the index just past the
   closing delimiter. *)
let skip_balanced text i len =
  let open_ch = text.[i] in
  let close_ch = if Char.equal open_ch '{' then '}' else ']' in
  let depth = ref 1 in
  let ctx = ref Outside_string in
  let j = ref (i + 1) in
  while !j < len && !depth > 0 do
    let c = text.[!j] in
    (match !ctx with
     | In_double_quote_escaped -> ctx := In_double_quote
     | In_single_quote_escaped -> ctx := In_single_quote
     | In_double_quote ->
       if Char.equal c '\\'
       then ctx := In_double_quote_escaped
       else if Char.equal c '"'
       then ctx := Outside_string
     | In_single_quote ->
       if Char.equal c '\\'
       then ctx := In_single_quote_escaped
       else if Char.equal c '\''
       then ctx := Outside_string
     | Outside_string ->
       if Char.equal c '"'
       then ctx := In_double_quote
       else if Char.equal c '\''
       then ctx := In_single_quote
       else if Char.equal c open_ch
       then incr depth
       else if Char.equal c close_ch
       then decr depth);
    incr j
  done;
  !j
;;

(* Read a key at position [i]: either a quoted string or an unquoted
   identifier.  Returns (key_name, key_start, key_stop). *)
let read_key text i _len =
  if Char.equal text.[i] '"' || Char.equal text.[i] '\''
  then (
    let quote = text.[i] in
    let j = ref (i + 1) in
    while !j < _len && not (Char.equal text.[!j] quote) do
      if Char.equal text.[!j] '\\' then j := !j + 2 else incr j
    done;
    let key_name = String.sub text ~pos:(i + 1) ~len:(!j - i - 1) in
    let key_stop = if !j < _len then !j + 1 else !j in
    key_name, i, key_stop)
  else (
    let j = ref i in
    while !j < _len && is_ident_char text.[!j] do
      incr j
    done;
    let key_name = String.sub text ~pos:i ~len:(!j - i) in
    key_name, i, !j)
;;

(* Recursively index all keys and values in the JSON tree, walking the
   buffer text in parallel.  [assoc_fields] is the list of (key, value)
   from the parsed JSON; [text_start] is where the opening '{' is in the
   buffer. *)
let rec index_assoc ~accumulator ~file_cache ~key_acc ~node_acc ~text ~text_start fields =
  let len = String.length text in
  let i = ref (text_start + 1) in
  (* Walk through fields in order — they must match the text order. *)
  List.iter fields ~f:(fun (expected_key, value_node) ->
    (* Skip whitespace/commas to find the key *)
    i := skip_ws text !i len;
    if !i < len
    then (
      let key_name, key_start, key_stop = read_key text !i len in
      (* Record key position *)
      if String.equal key_name expected_key
      then (
        let file_start =
          Json5_accumulator.buffer_offset_to_file_offset
            accumulator
            ~buffer_offset:key_start
        in
        let file_stop =
          Json5_accumulator.buffer_offset_to_file_offset
            accumulator
            ~buffer_offset:key_stop
        in
        let loc =
          Loc.of_file_range ~file_cache ~range:{ start = file_start; stop = file_stop }
        in
        key_acc := (key_name, loc) :: !key_acc);
      (* Skip past the colon *)
      i := key_stop;
      i := skip_ws text !i len;
      if !i < len && Char.equal text.[!i] ':' then incr i;
      i := skip_ws text !i len;
      (* Now read the value and record its position *)
      if !i < len
      then (
        let val_start = !i in
        let val_stop =
          if Char.equal text.[!i] '{' || Char.equal text.[!i] '['
          then skip_balanced text !i len
          else if Char.equal text.[!i] '"' || Char.equal text.[!i] '\''
          then skip_string text !i len
          else skip_unquoted_value text !i len
        in
        let file_start =
          Json5_accumulator.buffer_offset_to_file_offset
            accumulator
            ~buffer_offset:val_start
        in
        let file_stop =
          Json5_accumulator.buffer_offset_to_file_offset
            accumulator
            ~buffer_offset:val_stop
        in
        let loc =
          Loc.of_file_range ~file_cache ~range:{ start = file_start; stop = file_stop }
        in
        node_acc := (value_node, loc) :: !node_acc;
        (* Recurse into nested objects *)
        (match value_node with
         | `Assoc nested_fields ->
           index_assoc
             ~accumulator
             ~file_cache
             ~key_acc
             ~node_acc
             ~text
             ~text_start:val_start
             nested_fields
         | _ -> ());
        i := val_stop)))
;;

let create ~file_cache ~accumulator ~json =
  let text = Json5_accumulator.buffer_contents accumulator in
  let key_acc = ref [] in
  let node_acc = ref [] in
  (match json with
   | `Assoc fields ->
     index_assoc ~accumulator ~file_cache ~key_acc ~node_acc ~text ~text_start:0 fields
   | _ -> ());
  { json; key_positions = List.rev !key_acc; node_positions = List.rev !node_acc }
;;
