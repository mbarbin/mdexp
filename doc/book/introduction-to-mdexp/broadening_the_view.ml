(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

(* @mdexp

# Broadening the View

Now that you have a feel for how mdexp works, let's step back and
consider where the approach leads and where you might take it.

The previous chapters focused on mechanics: directives, snapshots,
and the EDSL pattern. Here we broaden the view to explore
additional use cases, discuss design choices, and invite you to
think about how this pattern of *compilable, verified documentation*
might apply to your own projects, whether or not you use mdexp
itself.

## Cram-style tests in OCaml

OCaml's ecosystem uses `.t` cram files to test command-line tools:
you write a shell session with expected output and the test runner
checks it. mdexp offers a path to express the same tests in OCaml
and we are experimenting with a `Mdexp_cram` library (wip, unpublished).
The "background" part of the process becomes the evaluation environment
(setting up state, running commands, capturing output) while the visible
part reads as a tutorial showing the session step by step.

This means the same file can serve as both a functional test and a
user-facing walkthrough: the test runner verifies correctness, and
mdexp extracts the narrative.

## Client/server application testing

The pattern extends naturally to networked applications. The
background spins up a running server, and the visible part scripts a
series of CLI client calls that exercise the service. Each call and
its output become a snapshot in the document; the full session builds
up an end-to-end functional test.

The reader sees a coherent tutorial --- "first create a resource, then
query it, then update it" --- while the build system verifies that
every response matches expectations. The documentation becomes a live
integration test.

## Your own EDSLs

The [EDSL chapter](edsl.md) showed a math expression language and a
toy proof assistant. But there is nothing special about math --- the
same pattern applies wherever you want to both **render** and **verify**
structured content.

The key point is that mdexp does not provide or prescribe any of
these EDSLs. It provides the infrastructure --- directives, snapshot
capture, the `pp` pipeline --- and you build whatever domain-specific
layer makes sense for your project. It is just OCaml; there is no
plugin architecture to learn. Your EDSL lives in your codebase, uses
your types, and evolves with your project.

## Host and output languages

Neither the host language nor the output format is a hard constraint
of the system. mdexp's directive syntax is designed to work with
any language that has block comments, and we have prepared support
for host-language expect-test frameworks written in **Zig** and
**Rust** alongside OCaml. Similarly, the output is not limited to
Markdown --- it could just as well be Typst, reStructuredText, or
any other text format.

That said, we have focused our effort on the **OCaml + Markdown**
combination for practical reasons:

- **OCaml** is well suited to the kind of work mdexp encourages.
  The examples in this book --- symbolic computation, algebraic
  rewriting, proof construction --- benefit from a language where
  you can manipulate structured data at a high level without
  worrying about memory management. Rust and Zig are equally
  appealing here --- each handles memory in its own way without
  burdening documentation-oriented code. Which language fits best
  may depend on the libraries you need to pull into your document.
  We would not be surprised if mdexp found a place in
  multi-language codebases, with different chapters written in
  different host languages.
- **Markdown** integrates well with the rest of our tooling: static
  site generators, mdbook, slipshow, and the broader ecosystem of
  tools that consume Markdown as input.

Other combinations are possible and welcome; the architecture does
not privilege any particular pairing.

## Closing thoughts

Beyond the specific tool, the underlying pattern is worth
reflecting on: write documentation as a compilable source file,
use the type system and test framework to keep it honest, and let
a thin preprocessor extract the readable output. This is not a new
idea --- literate programming is decades old --- but the combination
with snapshot testing and embedded DSLs gives it a practical edge
that we believe makes it click in interesting ways.

mdexp is one implementation of this pattern, intentionally minimal.
It reads directives, extracts content, and produces output.
Everything else --- the types, the tests, the rendering logic, the
EDSLs --- is ordinary code in your project. The tool stays small
and predictable; the power comes from what you build on top of it.

We hope this introductory book has given you both a working
understanding of mdexp and a sense of the broader possibilities.
For deeper coverage --- reference material, how-to guides, and
additional examples --- see the main documentation site. *)
