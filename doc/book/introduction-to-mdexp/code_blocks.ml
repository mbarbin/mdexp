(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

(* @mdexp

# Code Blocks

The `@mdexp.code` directive marks a region of code for inclusion in
the documentation. The extracted code is wrapped in a fenced code
block, tagged with the host language detected from the file
extension (e.g. `.ml` → `ocaml`).

## Including compilable code

Code between `@mdexp.code` and the next directive is real,
compilable OCaml. The compiler type-checks it along with the
rest of the file. Here is what the source looks like: *)

(* @mdexp.snapshot { lang: "ocaml" } *)
let _ =
  {|
(* @mdexp.code *)
let answer = 42
let question_of_life () = Printf.printf "The answer is %d\n" answer
(* @mdexp.end *)
|}
;;

(* @mdexp

And here is the markdown that mdexp produces from it: *)

(* @mdexp.code *)
let answer = 42
let question_of_life () = Printf.printf "The answer is %d\n" answer
(* @mdexp.end *)

(* @mdexp

Code outside the directives is invisible to the document but still
compiled and tested. For instance, the function above is
exercised in an expect test that does not appear in the output. *)

let%expect_test "code can be executed" =
  question_of_life ();
  [%expect {| The answer is 42 |}]
;;

(* @mdexp

## Prose to code transition

A block comment can transition directly from prose into a code
block by placing `@mdexp.code` before the closing comment marker.
This avoids the need for a separate comment: *)

(* @mdexp.snapshot { lang: "ocaml" } *)
let _ =
  {|
(* @mdexp
Here is an example:
@mdexp.code *)
let greet name = Printf.printf "Hello, %s!\n" name
(* @mdexp.end *)
|}
;;

(* @mdexp

This produces the prose paragraph followed by the code block in a
single, natural flow:

Here is an example:
@mdexp.code *)

let greet name = Printf.printf "Hello, %s!\n" name
(* @mdexp.end *)

let%expect_test "greet" =
  greet "World";
  [%expect {| Hello, World! |}]
;;

(* @mdexp

## Explicit language

The language tag is inferred from the file extension. You can override it
with `@mdexp.code { lang: "<lang>" }`: *)

(* @mdexp.snapshot { lang: "ocaml" } *)
let _ =
  {|
(* @mdexp.code { lang: "bash" } *)
(* opam install mdexp *)
(* @mdexp.end *)
|}
;;

(* @mdexp

This produces a `bash`-tagged code fence: *)

(* @mdexp.code { lang: "bash" } *)
(* opam install mdexp *)
(* @mdexp.end *)

(* @mdexp

Note that the bash command is written inside OCaml comments. This is
one case where commented code makes sense, since the content is not
OCaml and cannot be compiled. *)
