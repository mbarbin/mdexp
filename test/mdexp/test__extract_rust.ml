(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let extract file_contents =
  let file_cache = Loc.File_cache.create ~path:(Fpath.v "test.rs") ~file_contents in
  let file_processor = Mdexp.File_processor.create ~file_cache ~host_language:Rust in
  Mdexp.File_processor.process_file file_processor ~file_contents
;;

let%expect_test "extract prose from Rust line comments" =
  let output =
    extract
      {|// @mdexp
// # Hello from Rust
//
// This is a test.
// @mdexp.end
|}
  in
  print_string output;
  [%expect
    {|
    # Hello from Rust

    This is a test.
    |}]
;;

let%expect_test "extract code block from Rust (comment-wrapped preserves //)" =
  let output =
    extract
      {|// @mdexp.code
// let x: i32 = 42;
// @mdexp.end
|}
  in
  print_string output;
  [%expect
    {|
    ```rust
    // let x: i32 = 42;
    ```
    |}]
;;

let%expect_test "mixed prose and code" =
  let output =
    extract
      {|// @mdexp
// # Documentation
//
// Here is an example:
// @mdexp.end

// @mdexp.code
// let greeting = "Hello";
// @mdexp.end

// @mdexp
// That's it!
// @mdexp.end
|}
  in
  print_string output;
  [%expect
    {|
    # Documentation

    Here is an example:

    ```rust
    // let greeting = "Hello";
    ```

    That's it!
    |}]
;;

(* -- block comment support -- *)

let%expect_test "block comment prose" =
  let output =
    extract
      {|/* @mdexp
# Block Comment Prose

- **First item** spans
  multiple lines.
- **Second item** is simple.

More prose here.
*/

fn main() {}
|}
  in
  print_string output;
  [%expect
    {|
    # Block Comment Prose

    - **First item** spans
      multiple lines.
    - **Second item** is simple.

    More prose here.
    |}]
;;

let%expect_test "block comment code" =
  let output =
    extract
      {|/* @mdexp.code */
fn greet(name: &str) {
    println!("Hello, {}!", name);
}
/* @mdexp.end */
|}
  in
  print_string output;
  [%expect
    {|
    ```rust
    fn greet(name: &str) {
        println!("Hello, {}!", name);
    }
    ```
    |}]
;;

let%expect_test "mixed line and block comments" =
  let output =
    extract
      {|// @mdexp
// # Line Comment Section
// @mdexp.end

/* @mdexp
# Block Comment Section

With multi-line prose.
*/
|}
  in
  print_string output;
  [%expect
    {|
    # Line Comment Section

    # Block Comment Section

    With multi-line prose.
    |}]
;;

(* -- expect-test framework snapshots -- *)

let%expect_test "expect-test: single-line snapshot" =
  let output =
    extract
      {|// @mdexp.snapshot
expect![["Hello, World!"]];
|}
  in
  print_string output;
  [%expect {| Hello, World! |}]
;;

let%expect_test "expect-test: multi-line snapshot" =
  let output =
    extract
      {xxx|// @mdexp.snapshot
expect![["
    First line
    Second line
    Third line
"]];
|xxx}
  in
  print_string output;
  [%expect
    {|
    First line
    Second line
    Third line
    |}]
;;

let%expect_test "expect-test: raw string snapshot" =
  let output =
    extract
      {xxx|// @mdexp.snapshot { lang: "json" }
expect![[r#"
{
  "key": "value"
}
"#]];
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

let%expect_test "expect-test: raw string with multiple hashes" =
  let output =
    extract
      {xxx|// @mdexp.snapshot { block: true }
expect![[r##"
content with "quotes" and r#"raw"#
"##]];
|xxx}
  in
  print_string output;
  [%expect
    {|
    ```
    content with "quotes" and r#"raw"#
    ```
    |}]
;;

(* -- insta framework snapshots -- *)

let%expect_test "insta: inline snapshot with @" =
  let output =
    extract
      {|// @mdexp.snapshot
assert_snapshot!(value, @"Hello from insta");
|}
  in
  print_string output;
  [%expect {| Hello from insta |}]
;;

let%expect_test "insta: multi-line inline snapshot" =
  let output =
    extract
      {xxx|// @mdexp.snapshot { block: true }
assert_snapshot!(value, @r#"
line one
line two
"#);
|xxx}
  in
  print_string output;
  [%expect
    {|
    ```
    line one
    line two
    ```
    |}]
;;

(* -- Edge cases -- *)

let%expect_test "empty input" =
  let output = extract "" in
  print_string output;
  [%expect {||}]
;;

let%expect_test "no directives" =
  let output =
    extract
      {|fn main() {
    println!("Hello, World!");
}
|}
  in
  print_string output;
  [%expect {||}]
;;

let%expect_test "snapshot skips lines with no string literal" =
  let output =
    extract
      {xxx|// @mdexp.snapshot
let x = 42;
expect![["found it"]];
|xxx}
  in
  print_string output;
  [%expect {| found it |}]
;;

let%expect_test "snapshot with block mode and code context" =
  let output =
    extract
      {xxx|// @mdexp
// # Testing Snapshots
//
// Output:
// @mdexp.end

// @mdexp.code { lang: "rust" }
fn greet(name: &str) -> String {
    format!("Hello, {}!", name)
}

#[test]
fn test_greet() {
    let result = greet("World");
    // @mdexp.snapshot
    expect![["Hello, World!"]];
}
// @mdexp.end
|xxx}
  in
  print_string output;
  [%expect
    {|
    # Testing Snapshots

    Output:

    ```rust
    fn greet(name: &str) -> String {
        format!("Hello, {}!", name)
    }

    #[test]
    fn test_greet() {
        let result = greet("World");
    ```

    Hello, World!
    |}]
;;
