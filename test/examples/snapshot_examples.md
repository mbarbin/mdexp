# Snapshot Examples

This file demonstrates snapshot extraction with both single-line and multi-line formats.

## Single-Line Snapshot

A simple single-line snapshot:

```ocaml
let%expect_test "single-line snapshot" =
  let greeting = "Hello, World!" in
  print_endline greeting;
```

Hello, World!

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
