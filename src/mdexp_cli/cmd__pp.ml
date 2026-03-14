(********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                        *)
(*  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(********************************************************************************)

let main =
  Command.make
    ~summary:"Extract documentation from a source file"
    (let open Command.Std in
     let+ input_file =
       Arg.pos ~pos:0 Param.string ~doc:"Source file to extract documentation from"
     in
     let extension =
       let ext = Filename.extension input_file in
       if String.length ext > 0 && Char.equal ext.[0] '.'
       then String.sub ext ~pos:1 ~len:(String.length ext - 1)
       else ext
     in
     let host_language =
       match Host_language.of_file_extension extension with
       | Some host_language -> host_language
       | None ->
         Err.raise
           [ Pp.textf "Unknown file extension %S." extension ]
           ~hints:(Err.did_you_mean extension ~candidates:[ "ml"; "mli"; "rs"; "zig" ])
         [@coverage off]
     in
     let file_contents = In_channel.with_open_text input_file In_channel.input_all in
     let file_cache = Loc.File_cache.create ~path:(Fpath.v input_file) ~file_contents in
     let file_processor = Mdexp.File_processor.create ~file_cache ~host_language in
     let output = Mdexp.File_processor.process_file file_processor ~file_contents in
     print_string output)
;;
