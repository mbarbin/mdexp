# ppx_expect

[ppx_expect](https://github.com/janestreet/ppx_expect) is Jane Street's
inline expect-test framework for OCaml. Tests are written as
`let%expect_test` with `[%expect {|...|}]` assertions.

## How it works

Place `@mdexp.snapshot` before the `[%expect]` block. mdexp
extracts the block string content and emits it in the document.
Here is what an annotated test looks like (the `+` lines highlight
the mdexp directives):

```diff
  let%expect_test "greeting" =
    print_endline "Hello, World!";
+   (* @mdexp.snapshot *)
    [%expect {| Hello, World! |}]
  ;;
```

The `let%expect_test` wrapper and `[%expect]` assertion are not
included in the output --- only the block string content appears.
In this case, the rendered document shows:

Hello, World!

## Multi-line output

Multi-line output works the same way. The block string content is
dedented automatically:

```diff
  let%expect_test "list" =
    List.iter ~f:print_endline [ "First"; "Second"; "Third" ];
+   (* @mdexp.snapshot { lang: "txt" } *)
    [%expect
      {|
      First
      Second
      Third |}]
  ;;
```

This produces:

```txt
First
Second
Third
```

## Snapshot configuration

By default, the snapshot content is emitted as plain text. As we've seen
above, an inline annotation can change this. Here is another example:

`{ lang: "json" }` wraps the content in a fenced code block with
the given language tag:

```diff
  let%expect_test "json output" =
    print_endline {|{ "name": "mdexp", "version": "1.0" }|};
+   (* @mdexp.snapshot { lang: "json" } *)
    [%expect {|{ "name": "mdexp", "version": "1.0" }|}]
  ;;
```

This produces:

```json
{ "name": "mdexp", "version": "1.0" }
```

`{ block: true }` wraps the content in a plain fence without a
language tag:

```diff
  let%expect_test "block mode" =
    print_endline "some output";
+   (* @mdexp.snapshot { block: true } *)
    [%expect {|some output|}]
  ;;
```

This produces:

```
some output
```
