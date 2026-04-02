(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let extract file_contents =
  let file_cache = Loc.File_cache.create ~path:(Fpath.v "test.ml") ~file_contents in
  let file_processor = Mdexp.File_processor.create ~file_cache ~host_language:Ocaml in
  Mdexp.File_processor.process_file file_processor ~file_contents
;;

let%expect_test "extract prose from OCaml line-by-line comments" =
  let output =
    extract
      {|(* @mdexp *)
(* # Hello World *)
(* *)
(* This is a test. *)
(* @mdexp.end *)
|}
  in
  print_string output;
  [%expect
    {|
    # Hello World

    This is a test.
    |}]
;;

let%expect_test "extract code block from OCaml" =
  let output =
    extract
      {|(* @mdexp.code *)
(* let x = 42 *)
(* @mdexp.end *)
|}
  in
  print_string output;
  [%expect
    {|
    ```ocaml
    let x = 42
    ```
    |}]
;;

let%expect_test "extract code block with explicit language" =
  let output =
    extract
      {|(* @mdexp.code { lang: "bash" } *)
(* opam install mylib *)
(* @mdexp.end *)
|}
  in
  print_string output;
  [%expect
    {|
    ```bash
    opam install mylib
    ```
    |}]
;;

let%expect_test "mixed prose and code" =
  let output =
    extract
      {|(* @mdexp *)
(* # Documentation *)
(* *)
(* Here is an example: *)
(* @mdexp.end *)

(* @mdexp.code *)
(* let greet name = print_endline ("Hello, " ^ name) *)
(* @mdexp.end *)

(* @mdexp *)
(* That's it! *)
(* @mdexp.end *)
|}
  in
  print_string output;
  [%expect
    {|
    # Documentation

    Here is an example:

    ```ocaml
    let greet name = print_endline ("Hello, " ^ name)
    ```

    That's it!
    |}]
;;

let%expect_test "block comment prose" =
  let output =
    extract
      {|
(* @mdexp

   # Testing Block Comment

   This is prose inside a multi-line block comment.

   ## Section Two

   More text here. *)
(* This comment is not part of the output. *)
(* @mdexp.code *)
let (_ : int) = 1
|}
  in
  print_string output;
  [%expect
    {|
    # Testing Block Comment

    This is prose inside a multi-line block comment.

    ## Section Two

    More text here.

    ```ocaml
    let (_ : int) = 1
    ```
    |}]
;;

let%expect_test "single-line block comment directive with initial content" =
  let output =
    extract
      {|(* @mdexp # Title *)

let (_ : int) = 1

(* @mdexp This is inline prose. *)

let (_ : int) = 2
|}
  in
  print_string output;
  [%expect
    {|
    # Title

    This is inline prose.
    |}]
;;

let%expect_test "block comment with explicit end directive" =
  let output =
    extract
      {|(* @mdexp
## Explicit closing

This paragraph uses an explicit end directive.
@mdexp.end *)

let (_ : int) = 1
|}
  in
  print_string output;
  [%expect
    {|
    ## Explicit closing

    This paragraph uses an explicit end directive.
    |}]
;;

let%expect_test "implicit close and reopen" =
  let output =
    extract
      {|(* @mdexp
## Prose first

Some text.
@mdexp.code *)

let (_ : unit -> unit) = fun () -> print_endline "Hello, World!"

(* @mdexp.end *)
|}
  in
  print_string output;
  [%expect
    {|
    ## Prose first

    Some text.

    ```ocaml
    let (_ : unit -> unit) = fun () -> print_endline "Hello, World!"
    ```
    |}]
;;

let%expect_test "code block with blank comment lines" =
  let output =
    extract
      {|(* @mdexp.code *)
(* let calculate x y = *)
(*   let sum = x + y in *)
(*   *)
(*   let result = sum * 2 in *)
(*   result *)
(* @mdexp.end *)
|}
  in
  print_string output;
  [%expect
    {|
    ```ocaml
    let calculate x y =
      let sum = x + y in

      let result = sum * 2 in
      result
    ```
    |}]
;;

let%expect_test "actual code in code block (not wrapped in comments)" =
  let output =
    extract
      {|(* @mdexp.code { lang: "ocaml" } *)
let run_cmd cmd =
  Printf.printf "$ %s\n" cmd;
  (* In real usage, this would execute the command *)
  match cmd with
  | "myapp --version" -> print_endline "myapp 1.0.0"
  | _ -> print_endline "(unknown)"
;;
(* @mdexp.end *)
|}
  in
  print_string output;
  [%expect
    {|
    ```ocaml
    let run_cmd cmd =
      Printf.printf "$ %s\n" cmd;
      (* In real usage, this would execute the command *)
      match cmd with
      | "myapp --version" -> print_endline "myapp 1.0.0"
      | _ -> print_endline "(unknown)"
    ;;
    ```
    |}]
;;

let%expect_test "empty input" =
  let output = extract "" in
  print_string output;
  [%expect {||}]
;;

let%expect_test "no directives" =
  let output =
    extract
      {|let x = 42
let y = x + 1
|}
  in
  print_string output;
  [%expect {||}]
;;

let%expect_test "multi-line block comment with initial content" =
  let output =
    extract
      {|(* @mdexp
## Multi-Line Block with Initial Content

This block started with "## Multi-Line Block..." as initial content,
and continues on subsequent lines.
*)

let (_ : int) = 3
|}
  in
  print_string output;
  [%expect
    {|
    ## Multi-Line Block with Initial Content

    This block started with "## Multi-Line Block..." as initial content,
    and continues on subsequent lines.
    |}]
;;

(* -- Regression tests: indentation preservation -- *)

let%expect_test "prose preserves indentation for markdown list items" =
  let output =
    extract
      {|(* @mdexp
- **First item** spans
  multiple lines with indentation.
- **Second item** is on one line.

1. **Numbered** with
   a continuation line.

- **Nested list:**
  - Sub-item one.
  - Sub-item two.
*)
|}
  in
  print_string output;
  [%expect
    {|
    - **First item** spans
      multiple lines with indentation.
    - **Second item** is on one line.

    1. **Numbered** with
       a continuation line.

    - **Nested list:**
      - Sub-item one.
      - Sub-item two.
    |}]
;;

(* -- Snapshot tests -- *)

let%expect_test "single-line snapshot (no block mode)" =
  let output =
    extract
      {xxx|(* @mdexp
## Single-Line Snapshot

A simple single-line snapshot:
@mdexp.code *)
let%expect_test "single-line snapshot" =
  let greeting = "Hello, World!" in
  print_endline greeting;
  (* @mdexp.snapshot *)
  [%expect {| Hello, World! |}]
;;
|xxx}
  in
  print_string output;
  [%expect
    {|
    ## Single-Line Snapshot

    A simple single-line snapshot:

    ```ocaml
    let%expect_test "single-line snapshot" =
      let greeting = "Hello, World!" in
      print_endline greeting;
    ```

    Hello, World!
    |}]
;;

let%expect_test "multi-line snapshot (no block mode)" =
  let output =
    extract
      {xxx|(* @mdexp
## Multi-Line Snapshot

A multi-line snapshot with multiple lines:
@mdexp.code *)
let%expect_test "multi-line snapshot" =
  let lines = [ "First line"; "Second line"; "Third line" ] in
  List.iter ~f:print_endline lines;
  (* @mdexp.snapshot *)
  [%expect
    {|
    First line
    Second line
    Third line |}]
;;
|xxx}
  in
  print_string output;
  [%expect
    {|
    ## Multi-Line Snapshot

    A multi-line snapshot with multiple lines:

    ```ocaml
    let%expect_test "multi-line snapshot" =
      let lines = [ "First line"; "Second line"; "Third line" ] in
      List.iter ~f:print_endline lines;
    ```

    First line
    Second line
    Third line
    |}]
;;

let%expect_test "snapshot with block mode and language" =
  let output =
    extract
      {xxx|(* @mdexp.snapshot { lang: "json" } *)
[%expect {|
{
  "key": "value"
}
|}]
|xxx}
  in
  print_string output;
  [%expect
    {|
    ```json
    {
      "key": "value"
    }
    ```
    |}]
;;

let%expect_test "snapshot with nested code fences uses more backticks" =
  let output =
    extract
      {xxx|(* @mdexp.snapshot { lang: "markdown" } *)
[%expect {|
$ mdexp example.ml
Here is code:
```ocaml
let x = 1
```
|}]
|xxx}
  in
  print_string output;
  [%expect
    {|
    ````markdown
    $ mdexp example.ml
    Here is code:
    ```ocaml
    let x = 1
    ```
    ````
    |}]
;;

let%expect_test "snapshot with deeply nested fences" =
  let output =
    extract
      {xxx|(* @mdexp.snapshot { lang: "text" } *)
[%expect {|
Outer:
````markdown
Inner:
```ocaml
let x = 1
```
````
|}]
|xxx}
  in
  print_string output;
  [%expect
    {|
    `````text
    Outer:
    ````markdown
    Inner:
    ```ocaml
    let x = 1
    ```
    ````
    `````
    |}]
;;

let%expect_test "snapshot with block: true" =
  let output =
    extract
      {xxx|(* @mdexp.snapshot { block: true } *)
[%expect {| some text |}]
|xxx}
  in
  print_string output;
  [%expect
    {|
    ```
    some text
    ```
    |}]
;;

let%expect_test "snapshot without block mode outputs plain text" =
  let output =
    extract
      {xxx|(* @mdexp.snapshot *)
[%expect {| Hello, World! |}]
|xxx}
  in
  print_string output;
  [%expect {| Hello, World! |}]
;;

(* -- Regression tests -- *)

let%expect_test "snapshot should not match invalid block string delimiters" =
  let output =
    extract
      {xxx|(* @mdexp.snapshot *)
let x = { y | z }
[%expect {| correct |}]
|xxx}
  in
  print_string output;
  [%expect {| correct |}]
;;

let%expect_test "snapshot with custom delimiter {id|...|id}" =
  let output =
    extract
      {xxx|(* @mdexp.snapshot *)
[%expect {test|Hello from custom delimiter|test}]
|xxx}
  in
  print_string output;
  [%expect {| Hello from custom delimiter |}]
;;

let%expect_test "snapshot preserves blank lines in multi-line block strings" =
  let output =
    extract
      {xxx|(* @mdexp.snapshot { block: true } *)
[%expect
  {|
  line one

  line three
  |}]
|xxx}
  in
  print_string output;
  [%expect
    {|
    ```
    line one

    line three
    ```
    |}]
;;

let%expect_test "snapshot config with block: true key-value syntax" =
  let output =
    extract
      {xxx|(* @mdexp.snapshot { block: true } *)
[%expect {| some output |}]
|xxx}
  in
  print_string output;
  [%expect
    {|
    ```
    some output
    ```
    |}]
;;

(* -- Windtrap no-ppx expect tests -- *)

let%expect_test "windtrap: single-line expect with block string" =
  let output =
    extract
      {xxx|(* @mdexp
## Windtrap Example

Testing windtrap expect:
@mdexp.code *)
let () =
  run "Demo"
    [ test "greeting" (fun () ->
        greet "World";
        (* @mdexp.snapshot *)
        expect {|Hello, World!|}) ]
|xxx}
  in
  print_string output;
  [%expect
    {|
    ## Windtrap Example

    Testing windtrap expect:

    ```ocaml
    let () =
      run "Demo"
        [ test "greeting" (fun () ->
            greet "World";
    ```

    Hello, World!
    |}]
;;

let%expect_test "windtrap: multiline expect with block string" =
  let output =
    extract
      {xxx|(* @mdexp.code *)
let () =
  run "Demo"
    [ test "list" (fun () ->
        print_list [ "apple"; "banana"; "cherry" ];
        (* @mdexp.snapshot *)
        expect {|
- apple
- banana
- cherry
|})]
|xxx}
  in
  print_string output;
  [%expect
    {|
    ```ocaml
    let () =
      run "Demo"
        [ test "list" (fun () ->
            print_list [ "apple"; "banana"; "cherry" ];
    ```

    - apple
    - banana
    - cherry
    |}]
;;

let%expect_test "windtrap: snapshot with block mode and language" =
  let output =
    extract
      {xxx|(* @mdexp.snapshot { lang: "text" } *)
expect {|
Hello, World!
Goodbye, World!
|}
|xxx}
  in
  print_string output;
  [%expect
    {|
    ```text
    Hello, World!
    Goodbye, World!
    ```
    |}]
;;

let%expect_test "windtrap: expect_exact also uses block strings" =
  let output =
    extract
      {xxx|(* @mdexp.snapshot *)
expect_exact {|no trailing newline|}
|xxx}
  in
  print_string output;
  [%expect {|no trailing newline|}]
;;

(* -- Config: default snapshot settings -- *)

let%expect_test "config sets default lang for subsequent snapshots" =
  let output =
    extract
      {xxx|(* @mdexp.config { snapshot: { lang: "json" } } *)
(* @mdexp.snapshot *)
[%expect {|
{ "key": "value" }
|}]
|xxx}
  in
  print_string output;
  [%expect
    {|
    ```json
    { "key": "value" }
    ```
    |}]
;;

let%expect_test "config default lang applies to multiple snapshots" =
  let output =
    extract
      {xxx|(* @mdexp.config { snapshot: { lang: "text" } } *)
(* @mdexp.snapshot *)
[%expect {| first |}]
(* @mdexp.snapshot *)
[%expect {| second |}]
|xxx}
  in
  print_string output;
  [%expect
    {|
    ```text
    first
    ```

    ```text
    second
    ```
    |}]
;;

let%expect_test "snapshot explicit config overrides defaults" =
  let output =
    extract
      {xxx|(* @mdexp.config { snapshot: { lang: "json" } } *)
(* @mdexp.snapshot { lang: "text" } *)
[%expect {| overridden |}]
|xxx}
  in
  print_string output;
  [%expect
    {|
    ```text
    overridden
    ```
    |}]
;;

let%expect_test "snapshot with block: true inherits default lang" =
  let output =
    extract
      {xxx|(* @mdexp.config { snapshot: { lang: "json" } } *)
(* @mdexp.snapshot { block: true } *)
[%expect {| with lang from defaults |}]
|xxx}
  in
  print_string output;
  [%expect
    {|
    ```json
    with lang from defaults
    ```
    |}]
;;

let%expect_test "config without snapshot key does not affect snapshots" =
  let output =
    extract
      {xxx|(* @mdexp.config { other: "stuff" } *)
(* @mdexp.snapshot *)
[%expect {| plain |}]
|xxx}
  in
  print_string output;
  [%expect
    {|
    File "test.ml", line 1, characters 19-24:
    Error: Unknown field [other] in configuration.
    plain
    |}]
;;

(* -- Config: default code settings -- *)

let%expect_test "config sets default lang for subsequent code blocks" =
  let output =
    extract
      {xxx|(* @mdexp.config { code: { lang: "bash" } } *)
(* @mdexp.code *)
(* echo hello *)
(* @mdexp.end *)
|xxx}
  in
  print_string output;
  [%expect
    {|
    ```bash
    echo hello
    ```
    |}]
;;

let%expect_test "config default lang applies to multiple code blocks" =
  let output =
    extract
      {xxx|(* @mdexp.config { code: { lang: "text" } } *)
(* @mdexp.code *)
(* first *)
(* @mdexp.end *)
(* @mdexp.code *)
(* second *)
(* @mdexp.end *)
|xxx}
  in
  print_string output;
  [%expect
    {|
    ```text
    first
    ```

    ```text
    second
    ```
    |}]
;;

let%expect_test "code explicit config overrides defaults" =
  let output =
    extract
      {xxx|(* @mdexp.config { code: { lang: "text" } } *)
(* @mdexp.code { lang: "bash" } *)
(* echo overridden *)
(* @mdexp.end *)
|xxx}
  in
  print_string output;
  [%expect
    {|
    ```bash
    echo overridden
    ```
    |}]
;;

let%expect_test "config with both code and snapshot defaults" =
  let output =
    extract
      {xxx|(* @mdexp.config { code: { lang: "bash" }, snapshot: { lang: "json" } } *)
(* @mdexp.code *)
(* echo hello *)
(* @mdexp.end *)
(* @mdexp.snapshot *)
[%expect {| {"key": "value"} |}]
|xxx}
  in
  print_string output;
  [%expect
    {|
    ```bash
    echo hello
    ```

    ```json
    {"key": "value"}
    ```
    |}]
;;
