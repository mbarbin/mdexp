# Code Blocks

Use `@mdexp.code` to include code examples in your documentation.
The extracted code is wrapped in a fenced code block, with `ocaml`
as the default language.

## Code in Comments

Write code inside comment wrappers. mdexp strips the markers:

```ocaml
(* @mdexp.code *)
(* let greeting = "Hello, World!" *)
(* let () = print_endline greeting *)
(* @mdexp.end *)
```

This produces:

```ocaml
let greeting = "Hello, World!"
let () = print_endline greeting
```

## Actual Code

Code between the directives can also be real, compilable OCaml ---
not wrapped in comments. This is useful when you want the compiler
to type-check your documentation examples:

```ocaml
(* @mdexp.code *)
let answer = 42
let question_of_life () = Printf.printf "The answer is %d\n" answer
(* @mdexp.end *)
```

The code is included as-is:

```ocaml
let answer = 42
let question_of_life () = Printf.printf "The answer is %d\n" answer
```

## Explicit Language

Override the default language tag with `@mdexp.code { lang: "<lang>" }`:

```ocaml
(* @mdexp.code { lang: "bash" } *)
(* opam install mdexp *)
(* @mdexp.end *)
```

This produces a `bash`-tagged code fence:

```bash
opam install mdexp
```

## Prose to Code Transition

A block comment can transition directly from prose into a code block
using `@mdexp.code` before the block comment closes:

```ocaml
(* @mdexp
Here is an example:
@mdexp.code *)
let hello () = print_endline "Hello!"
(* @mdexp.end *)
```

This outputs the prose followed by the code block, without needing
separate comments:

```ocaml
let (_ : string) = "Hello!"
```
