(********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                        *)
(*  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(********************************************************************************)

let extract file_contents =
  let file_cache = Loc.File_cache.create ~path:(Fpath.v "test.zig") ~file_contents in
  let file_processor = Mdexp.File_processor.create ~file_cache ~host_language:Zig in
  Mdexp.File_processor.process_file file_processor ~file_contents
;;

let%expect_test "extract prose from Zig line comments" =
  let output =
    extract
      {|// @mdexp
// # Hello from Zig
//
// This is a test.
// @mdexp.end
|}
  in
  print_string output;
  [%expect
    {|
    # Hello from Zig

    This is a test.
    |}]
;;

let%expect_test "extract code block from Zig (comment-wrapped preserves //)" =
  let output =
    extract
      {|// @mdexp.code
// const x: i32 = 42;
// @mdexp.end
|}
  in
  print_string output;
  [%expect
    {|
    ```zig
    // const x: i32 = 42;
    ```
    |}]
;;

let%expect_test "extract code block with actual Zig code" =
  let output =
    extract
      {|// @mdexp.code { lang: "zig" }
const std = @import("std");
pub fn main() void {
    std.debug.print("Hello\n", .{});
}
// @mdexp.end
|}
  in
  print_string output;
  [%expect
    {|
    ```zig
    const std = @import("std");
    pub fn main() void {
        std.debug.print("Hello\n", .{});
    }
    ```
    |}]
;;

let%expect_test "code block preserves // comments in source code" =
  let output =
    extract
      {|// @mdexp.code { lang: "zig" }
const std = @import("std");
// Helper to create person columns
pub fn create_columns() void {
    // Initialize the column list
    std.debug.print("creating columns\n", .{});
}
// @mdexp.end
|}
  in
  print_string output;
  [%expect
    {|
    ```zig
    const std = @import("std");
    // Helper to create person columns
    pub fn create_columns() void {
        // Initialize the column list
        std.debug.print("creating columns\n", .{});
    }
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
// const greeting = "Hello";
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

    ```zig
    // const greeting = "Hello";
    ```

    That's it!
    |}]
;;

let%expect_test "snapshot: single-line multiline string" =
  let output =
    extract
      {|// @mdexp.snapshot
try snapshot.snap(@src(),
    \\Hello, World!
).diff(greeting);
|}
  in
  print_string output;
  [%expect {| Hello, World! |}]
;;

let%expect_test "snapshot: multi-line multiline string" =
  let output =
    extract
      {|// @mdexp.snapshot
try snapshot.snap(@src(),
    \\First line
    \\Second line
    \\Third line
).diff(lines);
|}
  in
  print_string output;
  [%expect
    {|
    First line
    Second line
    Third line
    |}]
;;

let%expect_test "snapshot with block mode and language" =
  let output =
    extract
      {|// @mdexp.snapshot { lang: "json" }
try snapshot.snap(@src(),
    \\{
    \\  "key": "value"
    \\}
).diff(value);
|}
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

let%expect_test "snapshot with block flag only" =
  let output =
    extract
      {|// @mdexp.snapshot { block: true }
try snapshot.snap(@src(),
    \\some text
).diff(value);
|}
  in
  print_string output;
  [%expect
    {|
    ```
    some text
    ```
    |}]
;;

let%expect_test "snapshot followed by code that must be re-processed" =
  let output =
    extract
      {|// @mdexp
// # Snapshot then code
//
// Result:
// @mdexp.end

// @mdexp.code { lang: "zig" }
const std = @import("std");
fn greet() void {
    std.debug.print("Hello\n", .{});
    // @mdexp.snapshot
    try snapshot.snap(@src(),
        \\Hello
    ).diff(greeting);
}
// @mdexp.end
|}
  in
  print_string output;
  [%expect
    {|# Snapshot then code

Result:

```zig
const std = @import("std");
fn greet() void {
    std.debug.print("Hello\n", .{});
```

Hello|}]
;;

let%expect_test "empty input" =
  let output = extract "" in
  print_string output;
  [%expect {||}]
;;

let%expect_test "no directives" =
  let output =
    extract
      {|const x: i32 = 42;
const y = x + 1;
|}
  in
  print_string output;
  [%expect {||}]
;;
