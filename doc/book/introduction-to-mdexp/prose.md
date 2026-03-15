# Prose

The `@mdexp` directive marks comments as documentation to extract.
There are several styles, each suited to different situations.

## Line-by-Line Comments

Wrap each line of prose in its own comment, bracketed by `@mdexp`
and `@mdexp.end`:

```ocaml
(* @mdexp *)
(* This is the first line of prose. *)
(* *)
(* This is after a blank line. *)
(* @mdexp.end *)
```

mdexp strips the comment markers and outputs the text. A blank
comment line `(* *)` becomes a blank line in the output, useful
for separating paragraphs.

## Block Comments

For longer prose, use a multi-line block comment. Everything between
the opening `(* @mdexp` and the closing `*)` becomes documentation:

```ocaml
(* @mdexp
## My Section

This is a paragraph inside a block comment.
It can span multiple lines naturally.
*)
```

This avoids the repetitive comment wrapper on every line.

## Single-Line Directives

A single-line `(* @mdexp ... *)` is self-closing --- handy for
short notes between code sections:

```ocaml
(* @mdexp A brief note between functions. *)

let x = 42

(* @mdexp Another note. *)
```

Each produces a standalone paragraph in the output.
