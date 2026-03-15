(********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                        *)
(*  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(********************************************************************************)

(* @mdexp # Prose *)

(* @mdexp
The `@mdexp` directive marks comments as documentation to extract.
There are several styles, each suited to different situations.

## Line-by-Line Comments

Wrap each line of prose in its own comment, bracketed by `@mdexp`
and `@mdexp.end`:
@mdexp.end *)

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

## Block Comments

For longer prose, use a multi-line block comment. Everything between
the opening `(* @mdexp` and the closing `*)` becomes documentation:
@mdexp.end *)

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
This avoids the repetitive comment wrapper on every line.

## Single-Line Directives

A single-line `(* @mdexp ... *)` is self-closing --- handy for
short notes between code sections:
@mdexp.end *)

(* @mdexp.snapshot { lang: "ocaml" } *)
let _ =
  {|
(* @mdexp A brief note between functions. *)

let x = 42

(* @mdexp Another note. *)
|}
;;

(* @mdexp Each produces a standalone paragraph in the output. *)
