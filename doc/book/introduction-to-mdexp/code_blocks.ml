(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

(* @mdexp

# Code Blocks

Use `@mdexp.code` to include code examples in your documentation.
The extracted code is wrapped in a fenced code block, with `ocaml`
as the default language.

## Code in Comments

Write code inside comment wrappers. mdexp strips the markers: *)

(* @mdexp.snapshot { lang: "ocaml" } *)
let _ =
  {|
(* @mdexp.code *)
(* let greeting = "Hello, World!" *)
(* let () = print_endline greeting *)
(* @mdexp.end *)
|}
;;

(* @mdexp This produces: *)

(* @mdexp.code *)
(* let greeting = "Hello, World!" *)
(* let () = print_endline greeting *)
(* @mdexp.end *)

(* @mdexp

## Actual Code

Code between the directives can also be real, compilable OCaml ---
not wrapped in comments. This is useful when you want the compiler
to type-check your documentation examples: *)

(* @mdexp.snapshot { lang: "ocaml" } *)
let _ =
  {|
(* @mdexp.code *)
let answer = 42
let question_of_life () = Printf.printf "The answer is %d\n" answer
(* @mdexp.end *)
|}
;;

(* @mdexp The code is included as-is: *)

(* @mdexp.code *)
let answer = 42
let question_of_life () = Printf.printf "The answer is %d\n" answer
(* @mdexp.end *)

(* Here we are in a part of the code that is not exported to the resulting
   markdown. This can include contents like in any other ml file, including
   expect tests. *)

let%expect_test "code can be executed" =
  question_of_life ();
  [%expect {| The answer is 42 |}]
;;

(* @mdexp

## Explicit Language

Override the default language tag with `@mdexp.code { lang: "<lang>" }`: *)

(* @mdexp.snapshot { lang: "ocaml" } *)
let _ =
  {|
(* @mdexp.code { lang: "bash" } *)
(* opam install mdexp *)
(* @mdexp.end *)
|}
;;

(* @mdexp This produces a `bash`-tagged code fence: *)

(* @mdexp.code { lang: "bash" } *)
(* opam install mdexp *)
(* @mdexp.end *)

(* @mdexp

## Prose to Code Transition

A block comment can transition directly from prose into a code block
using `@mdexp.code` before the block comment closes: *)

(* @mdexp.snapshot { lang: "ocaml" } *)
let _ =
  {|
(* @mdexp
Here is an example:
@mdexp.code *)
let hello () = print_endline "Hello!"
(* @mdexp.end *)
|}
;;

(* @mdexp

This outputs the prose followed by the code block, without needing
separate comments:

@mdexp.code *)

let (_ : string) = "Hello!"

(* @mdexp.end *)
