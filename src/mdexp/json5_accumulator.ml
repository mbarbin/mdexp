(********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                        *)
(*  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(********************************************************************************)

module Phase = struct
  type string_context =
    | No_string
    | Double_quote
    | Double_quote_escaped
    | Single_quote
    | Single_quote_escaped

  type inside_state =
    { mutable depth : int
    ; mutable string_ctx : string_context
    }

  type t =
    | Before_open
    | Inside of inside_state
end

module Chunk = struct
  (* A recorded chunk mapping a contiguous run of text from one [feed_line] call
     to its position in the original file. *)
  type t =
    { buffer_offset : int (* Byte offset within the accumulator buffer. *)
    ; file_offset : int (* Byte offset within the original file. *)
    ; length : int (* Number of bytes in this chunk. *)
    }
end

type t =
  { mutable phase : Phase.t
  ; buffer : Buffer.t
  ; mutable chunks : Chunk.t list
  }

module Action = struct
  type t =
    | Need_more
    | Done of { json_text : string }
    | Error

  let to_dyn = function
    | Done { json_text } -> Dyn.variant "Done" [ Dyn.string json_text ]
    | Need_more -> Dyn.variant "Need_more" []
    | Error -> Dyn.variant "Error" []
  ;;
end

let create () = { phase = Before_open; buffer = Buffer.create 256; chunks = [] }
let buffer_contents t = Buffer.contents t.buffer
let chunks t = List.rev t.chunks

let buffer_offset_to_file_offset t ~buffer_offset =
  let chunks = chunks t in
  let rec find : Chunk.t list -> _ = function
    | [] ->
      (* Fallback: return buffer_offset as-is if no chunk found *)
      buffer_offset
    | [ chunk ] ->
      (* Last chunk: clamp to it *)
      chunk.file_offset + (buffer_offset - chunk.buffer_offset)
    | chunk :: rest ->
      if buffer_offset < chunk.buffer_offset + chunk.length
      then chunk.file_offset + (buffer_offset - chunk.buffer_offset)
      else find rest
  in
  find chunks
;;

let feed t ~file_offset ~line =
  let len = String.length line in
  let result : Action.t option ref = ref None in
  let i = ref 0 in
  (* Record the buffer position before we start adding characters *)
  let buffer_start = Buffer.length t.buffer in
  let chunk_file_offset = ref file_offset in
  let chunk_started = ref false in
  while !i < len && Option.is_none !result do
    let c = String.get line !i in
    (match t.phase with
     | Before_open ->
       if Char.equal c '{'
       then (
         (* The '{' starts at file_offset + !i; record the chunk from here *)
         chunk_file_offset := file_offset + !i;
         chunk_started := true;
         Buffer.add_char t.buffer '{';
         t.phase <- Inside { depth = 1; string_ctx = No_string })
       else if not (Char.is_whitespace c)
       then result := Some Error
     | Inside s ->
       if not !chunk_started
       then (
         chunk_file_offset := file_offset + !i;
         chunk_started := true);
       Buffer.add_char t.buffer c;
       (match s.string_ctx with
        | Double_quote_escaped -> s.string_ctx <- Double_quote
        | Single_quote_escaped -> s.string_ctx <- Single_quote
        | Double_quote ->
          if Char.equal c '\\'
          then s.string_ctx <- Double_quote_escaped
          else if Char.equal c '"'
          then s.string_ctx <- No_string
        | Single_quote ->
          if Char.equal c '\\'
          then s.string_ctx <- Single_quote_escaped
          else if Char.equal c '\''
          then s.string_ctx <- No_string
        | No_string ->
          if Char.equal c '"'
          then s.string_ctx <- Double_quote
          else if Char.equal c '\''
          then s.string_ctx <- Single_quote
          else if Char.equal c '{'
          then s.depth <- s.depth + 1
          else if Char.equal c '}'
          then (
            s.depth <- s.depth - 1;
            if s.depth = 0
            then result := Some (Done { json_text = Buffer.contents t.buffer }))));
    incr i
  done;
  (* Record chunk for whatever was added to the buffer *)
  let buffer_end = Buffer.length t.buffer in
  let chunk_len = buffer_end - buffer_start in
  if chunk_len > 0
  then
    t.chunks
    <- { buffer_offset = buffer_start
       ; file_offset = !chunk_file_offset
       ; length = chunk_len
       }
       :: t.chunks;
  match !result with
  | Some r -> r
  | None ->
    (match t.phase with
     | Inside _ -> Buffer.add_char t.buffer '\n'
     | Before_open -> ());
    Need_more
;;
