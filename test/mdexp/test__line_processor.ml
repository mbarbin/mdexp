(********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                        *)
(*  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(********************************************************************************)

module Line_processor = Mdexp.Private.Line_processor
module Comment_syntax = Mdexp.Private.Comment_syntax

let dummy_file_cache =
  let line = String.make 1000 ' ' in
  let contents = String.concat (List.init ~len:1000 ~f:(fun _ -> line)) ~sep:"\n" in
  Loc.File_cache.create ~path:(Fpath.v "test.ml") ~file_contents:contents
;;

let with_parser ~lang f =
  let t =
    Line_processor.create
      ~file_cache:dummy_file_cache
      ~comment_syntax:(Comment_syntax.of_host_language lang)
      ~default_code_lang:(Host_language.markdown_lang_id lang)
  in
  f t
;;

let print_actions actions =
  List.iter actions ~f:(fun action -> Line_processor.Action.to_dyn action |> print_dyn)
;;

let feed t line = Line_processor.feed t ~line |> print_actions
let flush t = Line_processor.flush t |> print_actions

(* -- OCaml -- *)

let%expect_test "OCaml: non-comment lines are ignored" =
  with_parser ~lang:Ocaml (fun t ->
    feed t "let x = 42";
    [%expect {| |}];
    feed t "";
    [%expect {| |}];
    feed t "   ";
    [%expect {| |}];
    flush t;
    [%expect {| |}])
;;

let%expect_test "OCaml: single-line prose directive" =
  with_parser ~lang:Ocaml (fun t ->
    feed t "(* @mdexp # Title *)";
    [%expect
      {|
      Emit_prose_line "# Title"
      Flush_prose
      Blank_separator
      |}];
    flush t;
    [%expect {| |}])
;;

let%expect_test "OCaml: multi-line prose block" =
  with_parser ~lang:Ocaml (fun t ->
    feed t "(* @mdexp";
    [%expect {| |}];
    feed t "Some prose content";
    [%expect {| Emit_prose_line "Some prose content" |}];
    feed t "More content *)";
    [%expect
      {|
      Emit_prose_line "More content"
      Flush_prose
      Blank_separator
      |}];
    feed t "let x = 42";
    [%expect {| |}];
    flush t;
    [%expect {| |}])
;;

let%expect_test "OCaml: prose with standalone block closer" =
  with_parser ~lang:Ocaml (fun t ->
    feed t "(* @mdexp";
    [%expect {| |}];
    feed t "content";
    [%expect {| Emit_prose_line "content" |}];
    feed t "*)";
    [%expect
      {|
      Flush_prose
      Blank_separator
      |}];
    flush t;
    [%expect {| |}])
;;

let%expect_test "OCaml: prose with @ block closer" =
  with_parser ~lang:Ocaml (fun t ->
    feed t "(* @mdexp";
    [%expect {| |}];
    feed t "content";
    [%expect {| Emit_prose_line "content" |}];
    feed t "@*)";
    [%expect
      {|
      Flush_prose
      Blank_separator
      |}];
    flush t;
    [%expect {| |}])
;;

let%expect_test "OCaml: code directive opens fence" =
  with_parser ~lang:Ocaml (fun t ->
    feed t "(* @mdexp.code *)";
    [%expect {| Open_code_fence "ocaml" |}];
    feed t "let x = 42";
    [%expect {| Emit_code_line "let x = 42" |}];
    feed t "(* @mdexp.end *)";
    [%expect
      {|
      Flush_code
      Close_code_fence
      Blank_separator
      |}];
    flush t;
    [%expect {| |}])
;;

let%expect_test "OCaml: code directive with explicit language" =
  with_parser ~lang:Ocaml (fun t ->
    feed t "(* @mdexp.code bash *)";
    [%expect {| Open_code_fence "bash" |}];
    feed t "echo hello";
    [%expect {| Emit_code_line "echo hello" |}];
    flush t;
    [%expect
      {|
      Flush_code
      Close_code_fence
      |}])
;;

let%expect_test "OCaml: prose then code transition" =
  with_parser ~lang:Ocaml (fun t ->
    feed t "(* @mdexp";
    [%expect {| |}];
    feed t "Some prose";
    [%expect {| Emit_prose_line "Some prose" |}];
    feed t "(* @mdexp.code *)";
    [%expect
      {|
      Flush_prose
      Blank_separator
      Open_code_fence "ocaml"
      |}];
    feed t "let x = 42";
    [%expect {| Emit_code_line "let x = 42" |}];
    feed t "(* @mdexp.end *)";
    [%expect
      {|
      Flush_code
      Close_code_fence
      Blank_separator
      |}];
    flush t;
    [%expect {| |}])
;;

let%expect_test "OCaml: end directive from code block" =
  with_parser ~lang:Ocaml (fun t ->
    feed t "(* @mdexp.code *)";
    [%expect {| Open_code_fence "ocaml" |}];
    feed t "code";
    [%expect {| Emit_code_line "code" |}];
    feed t "(* @mdexp.end *)";
    [%expect
      {|
      Flush_code
      Close_code_fence
      Blank_separator
      |}];
    flush t;
    [%expect {| |}])
;;

let%expect_test "OCaml: block closer from prose flushes" =
  with_parser ~lang:Ocaml (fun t ->
    feed t "(* @mdexp";
    [%expect {| |}];
    feed t "content";
    [%expect {| Emit_prose_line "content" |}];
    feed t "*)";
    [%expect
      {|
      Flush_prose
      Blank_separator
      |}];
    flush t;
    [%expect {| |}])
;;

let%expect_test "OCaml: comment content ignored in Ignore mode" =
  with_parser ~lang:Ocaml (fun t ->
    feed t "(* not a directive *)";
    [%expect {| |}];
    flush t;
    [%expect {| |}])
;;

let%expect_test "OCaml: directive on block closer line" =
  with_parser ~lang:Ocaml (fun t ->
    feed t "(* @mdexp";
    [%expect {| |}];
    feed t "@mdexp.code *)";
    [%expect
      {|
      Flush_prose
      Blank_separator
      Open_code_fence "ocaml"
      |}];
    flush t;
    [%expect
      {|
      Flush_code
      Close_code_fence
      |}])
;;

let%expect_test "OCaml: empty block comment" =
  with_parser ~lang:Ocaml (fun t ->
    feed t "(**)";
    [%expect {| |}];
    flush t;
    [%expect {| |}])
;;

let%expect_test "OCaml: block comment no space after opener" =
  with_parser ~lang:Ocaml (fun t ->
    feed t "(*no space*)";
    [%expect {| |}];
    flush t;
    [%expect {| |}])
;;

let%expect_test "OCaml: indented block comment" =
  with_parser ~lang:Ocaml (fun t ->
    feed t "  (* hello world *)  ";
    [%expect {| |}];
    flush t;
    [%expect {| |}])
;;

let%expect_test "OCaml: code block with indented raw lines" =
  with_parser ~lang:Ocaml (fun t ->
    feed t "(* @mdexp.code *)";
    [%expect {| Open_code_fence "ocaml" |}];
    feed t "  (* let x = 42 *)";
    [%expect {| Emit_code_line "  (* let x = 42 *)" |}];
    feed t "(* @mdexp.end *)";
    [%expect
      {|
      Flush_code
      Close_code_fence
      Blank_separator
      |}];
    flush t;
    [%expect {| |}])
;;

let%expect_test "OCaml: flush pending prose" =
  with_parser ~lang:Ocaml (fun t ->
    feed t "(* @mdexp";
    [%expect {| |}];
    feed t "unflushed prose";
    [%expect {| Emit_prose_line "unflushed prose" |}];
    flush t;
    [%expect {| Flush_prose |}])
;;

let%expect_test "OCaml: flush pending code" =
  with_parser ~lang:Ocaml (fun t ->
    feed t "(* @mdexp.code *)";
    [%expect {| Open_code_fence "ocaml" |}];
    feed t "unflushed code";
    [%expect {| Emit_code_line "unflushed code" |}];
    flush t;
    [%expect
      {|
      Flush_code
      Close_code_fence
      |}])
;;

(* -- Rust -- *)

let%expect_test "Rust: line comments with directive" =
  with_parser ~lang:Rust (fun t ->
    feed t "// @mdexp";
    [%expect {| |}];
    feed t "// some prose";
    [%expect {| Emit_prose_line "some prose" |}];
    feed t "// @mdexp.end";
    [%expect
      {|
      Flush_prose
      Blank_separator
      |}];
    flush t;
    [%expect {| |}])
;;

let%expect_test "Rust: line comments in code block preserve raw line" =
  with_parser ~lang:Rust (fun t ->
    feed t "// @mdexp.code";
    [%expect {| Open_code_fence "rust" |}];
    feed t "// let x = 42";
    [%expect {| Emit_code_line "// let x = 42" |}];
    feed t "// @mdexp.end";
    [%expect
      {|
      Flush_code
      Close_code_fence
      Blank_separator
      |}];
    flush t;
    [%expect {| |}])
;;

let%expect_test "Rust: block comments with directive" =
  with_parser ~lang:Rust (fun t ->
    feed t "/* @mdexp";
    [%expect {| |}];
    feed t "continuation */";
    [%expect
      {|
      Emit_prose_line "continuation"
      Flush_prose
      Blank_separator
      |}];
    feed t "*/";
    [%expect {| |}];
    flush t;
    [%expect {| |}])
;;

let%expect_test "Rust: line comment inside block falls back to block content" =
  with_parser ~lang:Rust (fun t ->
    feed t "/* @mdexp";
    [%expect {| |}];
    feed t "// block content";
    [%expect {| Emit_prose_line "// block content" |}];
    feed t "*/";
    [%expect
      {|
      Flush_prose
      Blank_separator
      |}];
    flush t;
    [%expect {| |}])
;;

let%expect_test "Rust: non-comment lines" =
  with_parser ~lang:Rust (fun t ->
    feed t "let x = 42";
    [%expect {| |}];
    feed t "not a comment";
    [%expect {| |}];
    flush t;
    [%expect {| |}])
;;

(* -- Zig -- *)

let%expect_test "Zig: line comments with directive" =
  with_parser ~lang:Zig (fun t ->
    feed t "// @mdexp";
    [%expect {| |}];
    feed t "// some prose";
    [%expect {| Emit_prose_line "some prose" |}];
    feed t "// @mdexp.end";
    [%expect
      {|
      Flush_prose
      Blank_separator
      |}];
    flush t;
    [%expect {| |}])
;;

let%expect_test "Zig: no block comments" =
  with_parser ~lang:Zig (fun t ->
    feed t "(* not block *)";
    [%expect {| |}];
    feed t "some text";
    [%expect {| |}];
    flush t;
    [%expect {| |}])
;;

(* -- Config directive tests -- *)

let%expect_test "OCaml: single-line config" =
  with_parser ~lang:Ocaml (fun t ->
    feed t {|(* @mdexp.config { "key": "value" } *)|};
    [%expect {| Configure "{\"key\":\"value\"}" |}];
    feed t "(* @mdexp *)";
    [%expect {| |}];
    feed t "(* hello *)";
    [%expect {| Emit_prose_line "hello" |}];
    flush t;
    [%expect {| Flush_prose |}])
;;

let%expect_test "OCaml: multi-line config in block comment" =
  with_parser ~lang:Ocaml (fun t ->
    feed t "(* @mdexp.config";
    [%expect {| |}];
    feed t {|   { "key": "value"|};
    [%expect {| |}];
    feed t {|   , "other": 42|};
    [%expect {| |}];
    feed t "   }";
    [%expect {| Configure "{\"key\":\"value\",\"other\":42}" |}];
    feed t "*)";
    [%expect {| |}];
    flush t;
    [%expect {| |}])
;;

let%expect_test "OCaml: config with no inline starts accumulating" =
  with_parser ~lang:Ocaml (fun t ->
    feed t "(* @mdexp.config";
    [%expect {| |}];
    feed t {|   { "x": 1 } *)|};
    [%expect {| Configure "{\"x\":1}" |}];
    feed t "(* @mdexp *)";
    [%expect {| |}];
    feed t "(* text *)";
    [%expect {| Emit_prose_line "text" |}];
    feed t "(* @mdexp.end *)";
    [%expect
      {|
      Flush_prose
      Blank_separator
      |}];
    flush t;
    [%expect {| |}])
;;

let%expect_test "Rust: config with line comments" =
  with_parser ~lang:Rust (fun t ->
    feed t {|// @mdexp.config { "lang": "rust" }|};
    [%expect {| Configure "{\"lang\":\"rust\"}" |}];
    feed t "// @mdexp";
    [%expect {| |}];
    feed t "// hello";
    [%expect {| Emit_prose_line "hello" |}];
    feed t "// @mdexp.end";
    [%expect
      {|
      Flush_prose
      Blank_separator
      |}];
    flush t;
    [%expect {| |}])
;;

let%expect_test "Rust: multi-line config with line comments" =
  with_parser ~lang:Rust (fun t ->
    feed t "// @mdexp.config";
    [%expect {| |}];
    feed t {|// { "key": "value"|};
    [%expect {| |}];
    feed t {|// , "num": 99 }|};
    [%expect {| Configure "{\"key\":\"value\",\"num\":99}" |}];
    feed t "// @mdexp";
    [%expect {| |}];
    feed t "// done";
    [%expect {| Emit_prose_line "done" |}];
    feed t "// @mdexp.end";
    [%expect
      {|
      Flush_prose
      Blank_separator
      |}];
    flush t;
    [%expect {| |}])
;;

let%expect_test "OCaml: config with quoted braces in string values" =
  with_parser ~lang:Ocaml (fun t ->
    feed t {|(* @mdexp.config { "pattern": "a{b}c", "ok": true } *)|};
    [%expect {| Configure "{\"pattern\":\"a{b}c\",\"ok\":true}" |}];
    feed t "(* @mdexp *)";
    [%expect {| |}];
    feed t "(* test *)";
    [%expect {| Emit_prose_line "test" |}];
    flush t;
    [%expect {| Flush_prose |}])
;;

let%expect_test "OCaml: snapshot with inline JSON5 config" =
  with_parser ~lang:Ocaml (fun t ->
    feed t {|(* @mdexp.snapshot { lang: "json", block: true } *)|};
    [%expect {| Enter_snapshot (Some "{\"lang\":\"json\",\"block\":true}") |}];
    feed t "let x = 42";
    [%expect {| |}];
    flush t;
    [%expect {| |}])
;;

let%expect_test "OCaml: snapshot without config emits None" =
  with_parser ~lang:Ocaml (fun t ->
    feed t "(* @mdexp.snapshot *)";
    [%expect {| Enter_snapshot None |}];
    feed t "let x = 42";
    [%expect {| |}];
    flush t;
    [%expect {| |}])
;;

let%expect_test "OCaml: snapshot with multi-line JSON5 config" =
  with_parser ~lang:Ocaml (fun t ->
    feed t {|(* @mdexp.snapshot {|};
    [%expect {| |}];
    feed t {|   lang: "text"|};
    [%expect {| |}];
    feed t {|   , block: true }|};
    [%expect {| Enter_snapshot (Some "{\"lang\":\"text\",\"block\":true}") |}];
    feed t "*)";
    [%expect {| |}];
    feed t "let x = 42";
    [%expect {| |}];
    flush t;
    [%expect {| |}])
;;
