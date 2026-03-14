(********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                        *)
(*  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(********************************************************************************)

module Processing_state = struct
  (* A processing state indicating what are currently parsing. *)
  type t =
    | Lines
    | Snapshot of
        { snapshot_config : Snapshot_config.t
        ; state : Snapshot_processor.t
        }
end

type t =
  { snapshot_formats : Snapshot_format.t list
  ; line_processor : Line_processor.t
  ; mutable snapshot_defaults : Snapshot_config.t
  ; mutable processing_state : Processing_state.t
  ; output : Buffer.t
  ; mutable prose_buffer : string list
  ; mutable code_buffer : string list
  }

let create ~file_cache ~host_language =
  let comment_syntax = Comment_syntax.of_host_language host_language in
  let default_code_lang = Host_language.markdown_lang_id host_language in
  let snapshot_formats = Snapshot_format.for_host_language host_language in
  let line_processor =
    Line_processor.create ~file_cache ~comment_syntax ~default_code_lang
  in
  let output = Buffer.create 4096 in
  { snapshot_formats
  ; line_processor
  ; snapshot_defaults = Snapshot_config.default
  ; processing_state = Lines
  ; output
  ; prose_buffer = []
  ; code_buffer = []
  }
;;

let flush_prose (t : t) =
  let lines = List.rev t.prose_buffer |> Render_engine.trim_blank_lines in
  List.iter lines ~f:(fun line ->
    Buffer.add_string t.output line;
    Buffer.add_char t.output '\n');
  t.prose_buffer <- []
;;

let flush_code (t : t) =
  let lines =
    List.rev t.code_buffer |> Render_engine.trim_blank_lines |> Render_engine.dedent_lines
  in
  List.iter lines ~f:(fun line ->
    Buffer.add_string t.output line;
    Buffer.add_char t.output '\n');
  t.code_buffer <- []
;;

let feed_line_action (t : t) ~(action : Line_processor.Action.t) =
  match action with
  | Emit_prose_line line -> t.prose_buffer <- line :: t.prose_buffer
  | Emit_code_line line -> t.code_buffer <- line :: t.code_buffer
  | Open_code_fence { language } ->
    Buffer.add_string t.output "```";
    Buffer.add_string t.output (Markdown_lang_id.to_string language);
    Buffer.add_char t.output '\n'
  | Close_code_fence -> Buffer.add_string t.output "```\n"
  | Flush_prose -> flush_prose t
  | Flush_code -> flush_code t
  | Blank_separator -> Buffer.add_char t.output '\n'
  | Enter_snapshot lj_opt ->
    let snapshot_config =
      match lj_opt with
      | None -> t.snapshot_defaults
      | Some lj -> Snapshot_config.of_located_json ~defaults:t.snapshot_defaults lj
    in
    t.processing_state
    <- Snapshot
         { snapshot_config
         ; state = Snapshot_processor.create ~snapshot_formats:t.snapshot_formats
         }
  | Configure lj ->
    let json = Located_json.json lj in
    (match json with
     | `Assoc fields ->
       (match List.assoc_opt "snapshot" fields with
        | Some (`Assoc _ as snapshot_json) ->
          t.snapshot_defaults
          <- Snapshot_config.of_located_json
               ~defaults:t.snapshot_defaults
               (Located_json.with_json lj snapshot_json)
        | Some _ | None -> ())
     | _ -> ())
;;

let process_line t ~line =
  let actions = Line_processor.feed t.line_processor ~line in
  List.iter actions ~f:(fun action -> feed_line_action t ~action)
;;

let feed (t : t) ~line =
  match t.processing_state with
  | Lines -> process_line t ~line
  | Snapshot { snapshot_config; state } ->
    (match Snapshot_processor.feed state ~line with
     | Consumed -> ()
     | Done { lines } ->
       Render_engine.render_snapshot ~output:t.output ~snapshot_config ~lines;
       t.processing_state <- Lines
     | Done_not_consumed { lines } ->
       Render_engine.render_snapshot ~output:t.output ~snapshot_config ~lines;
       t.processing_state <- Lines;
       process_line t ~line)
;;

let flush (t : t) =
  let final_actions = Line_processor.flush t.line_processor in
  List.iter final_actions ~f:(fun action -> feed_line_action t ~action);
  let result = Buffer.contents t.output in
  let result = String.rtrim result in
  if String.is_empty result then "" else result ^ "\n"
;;

let process_file (t : t) ~file_contents =
  let lines = String.split_lines file_contents in
  List.iter lines ~f:(fun line -> feed t ~line);
  flush t
;;
