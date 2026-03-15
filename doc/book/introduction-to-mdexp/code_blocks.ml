(********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                        *)
(*  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(********************************************************************************)

(* @mdexp # Code Blocks *)

(* @mdexp
Use `@mdexp.code` to include code examples in your documentation.
The extracted code is wrapped in a fenced code block, with `ocaml`
as the default language.

## Code in Comments

Write code inside comment wrappers. mdexp strips the markers:
@mdexp.end *)

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
to type-check your documentation examples:
@mdexp.end *)

(* @mdexp.snapshot { lang: "ocaml" } *)
let _ =
  {|
(* @mdexp.code *)
let meaning_of_life = 42
let () = Printf.printf "The answer is %d\n" meaning_of_life
(* @mdexp.end *)
|}
;;

(* @mdexp The code is included as-is: *)

(* @mdexp.code *)
let meaning_of_life = 42
let () = Printf.printf "The answer is %d\n" meaning_of_life
(* @mdexp.end *)

(* @mdexp
## Explicit Language

Override the default language tag with `@mdexp.code { lang: "<lang>" }`:
@mdexp.end *)

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

(* @mdexp *)
(* ## Prose to Code Transition *)
(* *)
(* A block comment can transition directly from prose into a code block *)
(* using `@mdexp.code` before the block comment closes: *)
(* @mdexp.end *)

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

let (_ : unit -> unit) = fun () -> print_endline "Hello!"

(* @mdexp.end *)
