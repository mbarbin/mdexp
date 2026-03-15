(********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                        *)
(*  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(********************************************************************************)

(* @mdexp # ppx_expect *)

(* @mdexp
[ppx_expect](https://github.com/janestreet/ppx_expect) is Jane Street's
inline expect-test framework for OCaml. Tests are written as
`let%expect_test` with `[%expect {|...|}]` assertions.

Place `@mdexp.snapshot` before the `[%expect]` block. mdexp outputs
the code up to that point, then extracts the block string content.

## Inline Snapshot

Here, the code block ends at `@mdexp.snapshot` and the `[%expect]`
content follows as plain text:
@mdexp.code *)
let%expect_test "greeting" =
  print_endline "Hello, World!";
  (* @mdexp.snapshot *)
  [%expect {|Hello, World!|}]
;;

(* @mdexp
## Multi-Line Snapshot

Multi-line output works the same way. The content is dedented
automatically:
@mdexp.code *)
let%expect_test "list" =
  List.iter ~f:print_endline [ "First"; "Second"; "Third" ];
  (* @mdexp.snapshot *)
  [%expect
    {|
    First
    Second
    Third |}]
;;

(* @mdexp
## Snapshot in a Code Fence

Use `{ lang: "json" }` to wrap the snapshot content in a fenced
code block. Setting a language implies block mode:
@mdexp.code *)
let%expect_test "json output" =
  print_endline {|{ "name": "mdexp", "version": "1.0" }|};
  (* @mdexp.snapshot { lang: "json" } *)
  [%expect {|{ "name": "mdexp", "version": "1.0" }|}]
;;

(* @mdexp
Use `{ block }` for a plain fence without a language tag:
@mdexp.code *)
let%expect_test "block mode" =
  print_endline "some output";
  (* @mdexp.snapshot { block: true } *)
  [%expect {|some output|}]
;;
