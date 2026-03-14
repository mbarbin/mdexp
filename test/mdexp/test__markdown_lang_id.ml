(********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                        *)
(*  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(********************************************************************************)

let%expect_test "to_string" =
  List.iter Host_language.all ~f:(fun host_language ->
    let markdown_lang_id = Host_language.markdown_lang_id host_language in
    print_dyn
      (Dyn.record
         [ "host_language", Host_language.to_dyn host_language
         ; "markdown_lang_id", Markdown_lang_id.to_dyn markdown_lang_id
         ]));
  [%expect
    {|{ host_language = Ocaml; markdown_lang_id = "ocaml" }
{ host_language = Rust; markdown_lang_id = "rust" }
{ host_language = Zig; markdown_lang_id = "zig" }|}];
  ()
;;
