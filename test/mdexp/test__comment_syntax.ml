(********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                        *)
(*  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(********************************************************************************)

module Comment_syntax = Mdexp.Private.Comment_syntax

let%expect_test "of_host_language" =
  List.iter Host_language.all ~f:(fun host_language ->
    let comment_syntax = Comment_syntax.of_host_language host_language in
    print_dyn
      (Dyn.record
         [ "host_language", Host_language.to_dyn host_language
         ; "comment_syntax", Comment_syntax.to_dyn comment_syntax
         ]));
  [%expect
    {|
    { host_language = Ocaml
    ; comment_syntax =
        { line_prefix = None; block = Some { start_ = "(*"; end_ = "*)" } }
    }
    { host_language = Rust
    ; comment_syntax =
        { line_prefix = Some "//"; block = Some { start_ = "/*"; end_ = "*/" } }
    }
    { host_language = Zig
    ; comment_syntax = { line_prefix = Some "//"; block = None }
    }
    |}]
;;
