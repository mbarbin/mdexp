# mdexp

## Introduction

Welcome to **mdexp**, a literate programming tool to assist in maintaining
documentation files where part of the content is generated and checked during
compilation via embedded snapshots.

## Current State

:construction: This project is currently under construction and is very
experimental and unstable. It is not documented and has some significant
limitations and issues at the moment. Come back in a little while!

## Acknowledgements

mdexp is rooted in the tradition of [literate programming](https://en.wikipedia.org/wiki/Literate_programming), where documentation and executable code coexist in a single source.

### Documentation framework

The documentation for this project is organized following the **[Diátaxis](https://diataxis.fr/)** framework by Daniele Procida.

### Expect-test frameworks

The expect-test paradigm — where expected output is captured inline and updated via snapshot — is central to mdexp's design. We are grateful to the following projects:

- **[Cram](https://bitheap.org/cram/)** by Brodie Rao -- literate style of interleaving commands and expected output
- **[ppx_expect](https://github.com/janestreet/ppx_expect)** by Jane Street -- inline expect-test framework and snapshot paradigm for OCaml
- **[Windtrap](https://github.com/invariant-hq/windtrap)** by Thibaut Mattio -- testing library for OCaml with support for embedded snapshots

We also studied some snapshot-testing frameworks in other languages while designing mdexp's parser, in particular **[insta](https://insta.rs/)** and **[expect-test](https://crates.io/crates/expect-test)** in Rust, and **[snaptest](https://tigerbeetle.com/blog/2024-05-14-snapshot-testing-for-the-masses/)** by TigerBeetle and **[Oh Snap!](https://github.com/mnemnion/ohsnap)** in Zig.

### Related tools combining documentation and executable code

We also acknowledge the following projects that share the goal of mixing prose with executable code and verified output. We list them here without attempting a detailed comparison.

- **[mlt_parser](https://github.com/janestreet/mlt_parser)** by Jane Street -- parses `.mlt` files that interleave org-mode markup, OCaml toplevel sessions, and expect-test output.
- **[mdx](https://github.com/realworldocaml/mdx)** (ocaml-mdx) -- a widely used tool in the OCaml ecosystem for executing code blocks in markdown and validating their output, including code snippets embedded in odoc documentation (mli and mld files).
- **[Jupyter](https://jupyter.org/)** -- widely used notebook environment for interactive computing across many languages, combining documentation with executable code cells and inline output. See also **[ocaml-jupyter](https://github.com/akabe/ocaml-jupyter)** for an OCaml kernel.
- **[mdBook](https://rust-lang.github.io/mdBook/)** -- Rust's book-authoring tool, with built-in support for testing Rust code samples and integration with the Rust Playground for browser-executable examples.
- **[zig-doctest](https://github.com/kristoff-it/zig-doctest)** by Loris Cro -- a tool for testing code snippets embedded in Zig documentation and books, with support for expected-failure scenarios.
