(********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                        *)
(*  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(********************************************************************************)

module Action = struct
  type t =
    | Emit_prose_line of string
    | Emit_code_line of string
    | Open_code_fence of { language : Markdown_lang_id.t }
    | Close_code_fence
    | Flush_prose
    | Flush_code
    | Blank_separator
    | Enter_snapshot of Located_json.t option
    | Configure of Located_json.t

  let json_to_dyn json = Dyn.string (Yojson.Basic.to_string json)
  let located_json_to_dyn lj = json_to_dyn (Located_json.json lj)

  let to_dyn = function
    | Emit_prose_line s -> Dyn.variant "Emit_prose_line" [ Dyn.string s ]
    | Emit_code_line s -> Dyn.variant "Emit_code_line" [ Dyn.string s ]
    | Open_code_fence { language } ->
      Dyn.variant "Open_code_fence" [ Markdown_lang_id.to_dyn language ]
    | Close_code_fence -> Dyn.variant "Close_code_fence" []
    | Flush_prose -> Dyn.variant "Flush_prose" []
    | Flush_code -> Dyn.variant "Flush_code" []
    | Blank_separator -> Dyn.variant "Blank_separator" []
    | Enter_snapshot lj_opt ->
      Dyn.variant "Enter_snapshot" [ Dyn.option located_json_to_dyn lj_opt ]
    | Configure lj -> Dyn.variant "Configure" [ located_json_to_dyn lj ]
  ;;
end

(* -- Comment stripping internals -- *)

module Strip_result = struct
  type t =
    | Not_a_comment
    | Content of
        { content : string
        ; col : int
        }
    | Block_closer
end

let is_block_comment_opening line ~(comment_syntax : Comment_syntax.t) =
  match comment_syntax.block with
  | None -> false
  | Some block ->
    let trimmed = String.ltrim line in
    String.starts_with ~prefix:block.start_ trimmed
;;

let is_single_line_block_comment line ~(comment_syntax : Comment_syntax.t) =
  match comment_syntax.block with
  | Some block ->
    let trimmed = String.trim line in
    String.starts_with ~prefix:block.start_ trimmed
    && String.ends_with ~suffix:block.end_ trimmed
  | None -> false
;;

let is_standalone_block_closer line ~(comment_syntax : Comment_syntax.t) =
  match comment_syntax.block with
  | None -> false
  | Some block ->
    let trimmed = String.trim line in
    String.equal trimmed block.end_ || String.equal trimmed ("@" ^ block.end_)
;;

let ends_with_block_closer line ~(comment_syntax : Comment_syntax.t) =
  match comment_syntax.block with
  | None -> false
  | Some block ->
    let trimmed = String.rtrim line in
    String.ends_with ~suffix:block.end_ trimmed
;;

let strip_line_comment ~prefix line =
  let trimmed = String.ltrim line in
  let leading_ws = String.length line - String.length trimmed in
  if String.starts_with ~prefix trimmed
  then (
    let len = String.length prefix in
    let rest = String.sub trimmed ~pos:len ~len:(String.length trimmed - len) in
    if String.length rest > 0 && Char.equal rest.[0] ' '
    then Some (String.sub rest ~pos:1 ~len:(String.length rest - 1), leading_ws + len + 1)
    else Some (rest, leading_ws + len))
  else None
;;

let strip_block_comment ~block_start ~block_end ~in_block_comment line =
  let trimmed = String.ltrim line in
  let leading_ws = String.length line - String.length trimmed in
  let trimmed_all = String.trim trimmed in
  if
    (not (String.starts_with ~prefix:block_start trimmed))
    && (String.equal trimmed_all block_end || String.equal trimmed_all ("@" ^ block_end))
  then Strip_result.Block_closer
  else (
    let found_opening, after_opening, col =
      if String.starts_with ~prefix:block_start trimmed
      then (
        let len = String.length block_start in
        let rest = String.sub trimmed ~pos:len ~len:(String.length trimmed - len) in
        let has_space = String.length rest > 0 && Char.equal rest.[0] ' ' in
        let rest =
          if has_space then String.sub rest ~pos:1 ~len:(String.length rest - 1) else rest
        in
        let col = leading_ws + len + if has_space then 1 else 0 in
        true, rest, col)
      else false, trimmed, leading_ws
    in
    if found_opening
    then (
      let trimmed_end = String.rtrim after_opening in
      if String.ends_with ~suffix:block_end trimmed_end
      then (
        let len = String.length block_end in
        let content =
          String.sub trimmed_end ~pos:0 ~len:(String.length trimmed_end - len)
        in
        Content { content = String.rtrim content; col })
      else Content { content = trimmed_end; col })
    else if in_block_comment
    then (
      let trimmed_end = String.rtrim line in
      if String.ends_with ~suffix:block_end trimmed_end
      then (
        let len = String.length block_end in
        let content =
          String.sub trimmed_end ~pos:0 ~len:(String.length trimmed_end - len)
        in
        Content { content = String.rtrim content; col = 0 })
      else Content { content = String.rtrim line; col = 0 })
    else Not_a_comment)
;;

let strip line ~(comment_syntax : Comment_syntax.t) ~in_block_comment =
  let line_result =
    match comment_syntax.line_prefix with
    | Some prefix ->
      (match strip_line_comment ~prefix line with
       | Some (content, col) -> Some (Strip_result.Content { content; col })
       | None -> None)
    | None -> None
  in
  let block_result () =
    match comment_syntax.block with
    | Some block ->
      strip_block_comment
        ~block_start:block.start_
        ~block_end:block.end_
        ~in_block_comment
        line
    | None -> Not_a_comment
  in
  match line_result with
  | Some r when not in_block_comment -> r
  | _ -> block_result ()
;;

(* -- Classified line (internal intermediate representation) -- *)

module Classified_line = struct
  type t =
    | Directive of
        { directive : Directive.t
        ; trailing : string option
        ; is_single_line_block : bool
        ; loc : Loc.t
        ; col : int
        }
    | Comment_content of
        { content : string
        ; raw_line : string
        ; ends_block : bool
        ; from_line_comment : bool
        ; col : int
        }
    | Block_closer
    | Non_comment of { content : string }
end

let classify_line ~file_cache ~line_number ~comment_syntax ~in_block_comment line =
  let is_block_closer = is_standalone_block_closer line ~comment_syntax in
  let has_trailing_closer = ends_with_block_closer line ~comment_syntax in
  let result = strip line ~comment_syntax ~in_block_comment in
  let new_in_block_comment = ref in_block_comment in
  let parse_directive content ~col =
    Directive.parse_line ~content ~file_cache ~line:line_number ~col
  in
  let classified =
    match result with
    | Block_closer ->
      new_in_block_comment := false;
      Classified_line.Block_closer
    | Not_a_comment -> Non_comment { content = line }
    | Content { content = comment_content; col } when is_block_closer ->
      new_in_block_comment := false;
      (match parse_directive comment_content ~col with
       | Some { directive; trailing; loc } ->
         Directive { directive; trailing; is_single_line_block = false; loc; col }
       | None -> Block_closer)
    | Content { content = comment_content; col } ->
      (match parse_directive comment_content ~col with
       | Some { directive; trailing; loc } ->
         let is_single_line = is_single_line_block_comment line ~comment_syntax in
         let is_opening = is_block_comment_opening line ~comment_syntax in
         new_in_block_comment := is_opening && not is_single_line;
         Directive
           { directive; trailing; is_single_line_block = is_single_line; loc; col }
       | None ->
         let ends_block = has_trailing_closer && in_block_comment in
         if ends_block then new_in_block_comment := false;
         let from_line_comment =
           Option.is_some comment_syntax.line_prefix && not !new_in_block_comment
         in
         Comment_content
           { content = comment_content
           ; raw_line = line
           ; ends_block
           ; from_line_comment
           ; col
           })
  in
  classified, !new_in_block_comment
;;

(* -- State machine (internal) -- *)

type inline_config_origin =
  | Snapshot
  | Config

module Mode = struct
  type t =
    | Ignore
    | Prose
    | Code_block of { language : Markdown_lang_id.t }
    | Accumulating_inline_config of
        { origin : inline_config_origin
        ; accumulator : Json5_accumulator.t
        }
end

let try_parse_located_json5 ~file_cache ~accumulator text =
  match Yojson_five.Basic.from_string text |> Result.to_option with
  | None -> None
  | Some json -> Some (Located_json.create ~file_cache ~accumulator ~json)
;;

let emit_inline_config_action origin located_json =
  match origin with
  | Snapshot -> Action.Enter_snapshot (Some located_json)
  | Config -> Action.Configure located_json
;;

let finalize_accumulator ~file_cache origin accumulator =
  let contents = Json5_accumulator.buffer_contents accumulator in
  if String.is_empty (String.trim contents)
  then (
    match origin with
    | Snapshot -> [ Action.Enter_snapshot None ]
    | Config -> [])
  else (
    match try_parse_located_json5 ~file_cache ~accumulator contents with
    | Some lj -> [ emit_inline_config_action origin lj ]
    | None ->
      (match origin with
       | Snapshot -> [ Enter_snapshot None ]
       | Config -> []))
;;

let close_current_block ~file_cache (mode : Mode.t) =
  match mode with
  | Ignore -> []
  | Accumulating_inline_config { origin; accumulator } ->
    finalize_accumulator ~file_cache origin accumulator
  | Prose -> [ Action.Flush_prose; Blank_separator ]
  | Code_block _ -> [ Flush_code; Close_code_fence; Blank_separator ]
;;

let start_inline_config ~file_cache ~file_offset ~origin ~inline ~close_actions =
  match inline with
  | None ->
    (match origin with
     | Snapshot -> Mode.Ignore, close_actions @ [ Action.Enter_snapshot None ]
     | Config ->
       let acc = Json5_accumulator.create () in
       Accumulating_inline_config { origin; accumulator = acc }, close_actions)
  | Some s ->
    let acc = Json5_accumulator.create () in
    (match Json5_accumulator.feed acc ~file_offset ~line:s with
     | Done { json_text } ->
       (match try_parse_located_json5 ~file_cache ~accumulator:acc json_text with
        | Some lj -> Mode.Ignore, close_actions @ [ emit_inline_config_action origin lj ]
        | None ->
          (match origin with
           | Snapshot -> Ignore, close_actions @ [ Enter_snapshot None ]
           | Config -> Ignore, close_actions))
     | Need_more ->
       Accumulating_inline_config { origin; accumulator = acc }, close_actions
     | Error ->
       (match origin with
        | Snapshot -> Ignore, close_actions @ [ Enter_snapshot None ]
        | Config -> Ignore, close_actions))
;;

let parse_language_trailing trailing ~default_code_lang =
  match trailing with
  | None -> default_code_lang
  | Some rest ->
    let first_word =
      match String.index_opt rest ' ' with
      | Some i -> String.sub rest ~pos:0 ~len:i
      | None -> rest
    in
    Markdown_lang_id.of_string first_word
;;

let compute_file_offset ~file_cache ~line_number ~col =
  let line_loc = Loc.of_file_line ~file_cache ~line:line_number in
  Loc.start_offset line_loc + col
;;

let transition
      ~file_cache
      ~line_number
      ~(mode : Mode.t)
      ~default_code_lang
      (input : Classified_line.t)
  =
  match input with
  | Directive { directive = Prose; trailing; is_single_line_block; loc = _; col = _ } ->
    let close_actions = close_current_block ~file_cache mode in
    let enter_actions =
      match trailing with
      | Some content -> [ Action.Emit_prose_line content ]
      | None -> []
    in
    let flush_actions =
      if is_single_line_block && Option.is_some trailing
      then [ Action.Flush_prose; Blank_separator ]
      else []
    in
    let new_mode =
      if is_single_line_block && Option.is_some trailing then Mode.Ignore else Prose
    in
    new_mode, close_actions @ enter_actions @ flush_actions
  | Directive { directive = Code; trailing; is_single_line_block = _; loc = _; col = _ }
    ->
    let close_actions = close_current_block ~file_cache mode in
    let lang = parse_language_trailing trailing ~default_code_lang in
    ( Code_block { language = lang }
    , close_actions @ [ Open_code_fence { language = lang } ] )
  | Directive { directive = Snapshot; trailing; is_single_line_block = _; loc; col = _ }
    ->
    let close_actions = close_current_block ~file_cache mode in
    let trailing_len =
      match trailing with
      | None -> 0
      | Some s -> String.length s
    in
    let file_offset = Loc.stop_offset loc - trailing_len in
    start_inline_config
      ~file_cache
      ~file_offset
      ~origin:Snapshot
      ~inline:trailing
      ~close_actions
  | Directive { directive = Config; trailing; is_single_line_block = _; loc; col = _ } ->
    let close_actions = close_current_block ~file_cache mode in
    let trailing_len =
      match trailing with
      | None -> 0
      | Some s -> String.length s
    in
    let file_offset = Loc.stop_offset loc - trailing_len in
    start_inline_config
      ~file_cache
      ~file_offset
      ~origin:Config
      ~inline:trailing
      ~close_actions
  | Directive
      { directive = End; is_single_line_block = _; trailing = _; loc = _; col = _ } ->
    let close_actions = close_current_block ~file_cache mode in
    Ignore, close_actions
  | Block_closer ->
    (match mode with
     | Accumulating_inline_config { origin; accumulator } ->
       Ignore, finalize_accumulator ~file_cache origin accumulator
     | _ ->
       let close_actions = close_current_block ~file_cache mode in
       Ignore, close_actions)
  | Comment_content { content; raw_line; ends_block; from_line_comment; col } ->
    (match mode with
     | Ignore -> Ignore, []
     | Accumulating_inline_config { origin; accumulator } ->
       let file_offset = compute_file_offset ~file_cache ~line_number ~col in
       (match Json5_accumulator.feed accumulator ~file_offset ~line:content with
        | Done { json_text } ->
          (match try_parse_located_json5 ~file_cache ~accumulator json_text with
           | Some lj -> Ignore, [ emit_inline_config_action origin lj ]
           | None -> Ignore, [])
        | Need_more ->
          if ends_block
          then Ignore, finalize_accumulator ~file_cache origin accumulator
          else mode, []
        | Error ->
          if ends_block
          then Ignore, finalize_accumulator ~file_cache origin accumulator
          else mode, [])
     | Prose ->
       let actions = [ Action.Emit_prose_line content ] in
       if ends_block
       then Ignore, actions @ [ Flush_prose; Blank_separator ]
       else Prose, actions
     | Code_block _ ->
       let content_to_use =
         if from_line_comment
         then raw_line
         else (
           let has_leading_whitespace =
             String.length raw_line > 0
             && (Char.equal (String.get raw_line 0) ' '
                 || Char.equal (String.get raw_line 0) '\t')
           in
           if has_leading_whitespace then raw_line else content)
       in
       let actions = [ Action.Emit_code_line content_to_use ] in
       if ends_block
       then Ignore, actions @ [ Flush_code; Close_code_fence; Blank_separator ]
       else mode, actions)
  | Non_comment { content } ->
    (match mode with
     | Code_block _ -> mode, [ Action.Emit_code_line content ]
     | Accumulating_inline_config { origin; accumulator } ->
       Ignore, finalize_accumulator ~file_cache origin accumulator
     | _ -> mode, [])
;;

(* -- Public interface -- *)

type t =
  { file_cache : Loc.File_cache.t
  ; comment_syntax : Comment_syntax.t
  ; default_code_lang : Markdown_lang_id.t
  ; mutable line_number : int
  ; mutable in_block_comment : bool
  ; mutable mode : Mode.t
  }

let create ~file_cache ~comment_syntax ~default_code_lang =
  { file_cache
  ; comment_syntax
  ; default_code_lang
  ; line_number = 0
  ; in_block_comment = false
  ; mode = Ignore
  }
;;

let feed t ~line =
  t.line_number <- t.line_number + 1;
  let classified, new_in_block_comment =
    classify_line
      ~file_cache:t.file_cache
      ~line_number:t.line_number
      ~comment_syntax:t.comment_syntax
      ~in_block_comment:t.in_block_comment
      line
  in
  t.in_block_comment <- new_in_block_comment;
  let new_mode, actions =
    transition
      ~file_cache:t.file_cache
      ~line_number:t.line_number
      ~mode:t.mode
      ~default_code_lang:t.default_code_lang
      classified
  in
  t.mode <- new_mode;
  actions
;;

let flush t =
  match t.mode with
  | Ignore -> []
  | Prose -> [ Action.Flush_prose ]
  | Code_block _ -> [ Flush_code; Close_code_fence ]
  | Accumulating_inline_config { origin; accumulator } ->
    finalize_accumulator ~file_cache:t.file_cache origin accumulator
;;
