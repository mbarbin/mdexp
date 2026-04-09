# Prose

The `@mdexp` directive marks comments as documentation to extract.
There are several styles, each suited to different situations.

## Line-by-line comments

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

This line-by-line style is more natural in host languages like Zig,
where comments are single-line by nature. In OCaml, block comments
are usually more convenient (see below).

## Block comments

For longer prose, use a multi-line block comment. Everything between
the opening `(* @mdexp` and the closing `*)` becomes documentation.
No `@mdexp.end` is needed --- the end of the block comment
implicitly ends the directive:

```ocaml
(* @mdexp

## My Section

This is a paragraph inside a block comment.
It can span multiple lines naturally.
*)
```

This avoids the repetitive comment wrapper on every line and is the
most common style throughout this book.

## Single-line directives

A single-line `(* @mdexp ... *)` is self-closing --- handy for
short notes between code sections:

```ocaml
(* @mdexp A brief note between functions. *)

let x = 42

(* @mdexp Another note. *)
```

Each produces a standalone paragraph in the output.
