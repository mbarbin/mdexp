# Code Blocks

The `@mdexp.code` directive marks a region of code for inclusion in
the documentation. The extracted code is wrapped in a fenced code
block, tagged with the host language detected from the file
extension (e.g. `.ml` → `ocaml`).

## Including compilable code

Code between `@mdexp.code` and the next directive is real,
compilable OCaml. The compiler type-checks it along with the
rest of the file. Here is what the source looks like:

```ocaml
(* @mdexp.code *)
let answer = 42
let question_of_life () = Printf.printf "The answer is %d\n" answer
(* @mdexp.end *)
```

And here is the markdown that mdexp produces from it:

```ocaml
let answer = 42
let question_of_life () = Printf.printf "The answer is %d\n" answer
```

Code outside the directives is invisible to the document but still
compiled and tested. For instance, the function above is
exercised in an expect test that does not appear in the output.

## Prose to code transition

A block comment can transition directly from prose into a code
block by placing `@mdexp.code` before the closing comment marker.
This avoids the need for a separate comment:

```ocaml
(* @mdexp
Here is an example:
@mdexp.code *)
let greet name = Printf.printf "Hello, %s!\n" name
(* @mdexp.end *)
```

This produces the prose paragraph followed by the code block in a
single, natural flow:

Here is an example:

```ocaml
let greet name = Printf.printf "Hello, %s!\n" name
```

## Explicit language

The language tag is inferred from the file extension. You can override it
with `@mdexp.code { lang: "<lang>" }`:

```ocaml
(* @mdexp.code { lang: "bash" } *)
(* opam install mdexp *)
(* @mdexp.end *)
```

This produces a `bash`-tagged code fence:

```bash
opam install mdexp
```

Note that the bash command is written inside OCaml comments. This is
one case where commented code makes sense, since the content is not
OCaml and cannot be compiled.
