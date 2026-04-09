(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

(* @mdexp # Prose *)

(* @mdexp

The `@mdexp` directive marks comments as documentation to extract.
There are several styles, each suited to different situations.

## Line-by-line comments

Wrap each line of prose in its own comment, bracketed by `@mdexp`
and `@mdexp.end`: *)

(* @mdexp.snapshot { lang: "ocaml" } *)
let _ =
  {|
(* @mdexp *)
(* This is the first line of prose. *)
(* *)
(* This is after a blank line. *)
(* @mdexp.end *)
|}
;;

(* @mdexp

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
implicitly ends the directive: *)

(* @mdexp.snapshot { lang: "ocaml" } *)
let _ =
  {|
(* @mdexp

## My Section

This is a paragraph inside a block comment.
It can span multiple lines naturally.
*)
|}
;;

(* @mdexp

This avoids the repetitive comment wrapper on every line and is the
most common style throughout this book.

## Single-line directives

A single-line `(* @mdexp ... *)` is self-closing --- handy for
short notes between code sections: *)

(* @mdexp.snapshot { lang: "ocaml" } *)
let _ =
  {|
(* @mdexp A brief note between functions. *)

let x = 42

(* @mdexp Another note. *)
|}
;;

(* @mdexp Each produces a standalone paragraph in the output. *)
