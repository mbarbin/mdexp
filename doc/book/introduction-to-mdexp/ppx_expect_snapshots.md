# ppx_expect

[ppx_expect](https://github.com/janestreet/ppx_expect) is Jane Street's
inline expect-test framework for OCaml. Tests are written as
`let%expect_test` with `[%expect {|...|}]` assertions.

Place `@mdexp.snapshot` before the `[%expect]` block. mdexp outputs
the code up to that point, then extracts the block string content.

## Inline Snapshot

Here, the code block ends at `@mdexp.snapshot` and the `[%expect]`
content follows as plain text:

```ocaml
let%expect_test "greeting" =
  print_endline "Hello, World!";
```

Hello, World!

## Multi-Line Snapshot

Multi-line output works the same way. The content is dedented
automatically:

```ocaml
let%expect_test "list" =
  List.iter ~f:print_endline [ "First"; "Second"; "Third" ];
```

First
Second
Third

## Snapshot in a Code Fence

Use `{ lang: "json" }` to wrap the snapshot content in a fenced
code block. Setting a language implies block mode:

```ocaml
let%expect_test "json output" =
  print_endline {|{ "name": "mdexp", "version": "1.0" }|};
```

```json
{ "name": "mdexp", "version": "1.0" }
```

Use `{ block }` for a plain fence without a language tag:

```ocaml
let%expect_test "block mode" =
  print_endline "some output";
```

```
some output
```
