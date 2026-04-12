# Introduction

*By Mathieu Barbin and Claude Opus 4.6*

This book introduces **mdexp** --- a documentation preprocessor for
literate programming with embedded snapshots. It is aimed at newcomers
who want to understand what the tool does, why it is useful, and what
kind of workflows it enables.

> This book is meant to be a short introductory read --- not the
> full documentation. The content is intentionally concise: our goal
> is to give a clear picture of the approach and what it makes
> possible. For installation, detailed reference, and how-to guides,
> see the main documentation site.

## What is mdexp?

mdexp is a native binary that preprocesses annotated source files
into readable documents. You write a compilable program whose
comments contain lightweight directives marking which parts are
prose, which are code examples, and which are program output to
capture. Running `mdexp pp` on that file extracts these parts and
assembles them into the output document.

Because the source file is compiled and tested in the usual way,
code examples are type-checked and program output is verified by
the test framework on every build. The documentation cannot drift
from the code.

## A quick example

Consider a source file that documents a compression library. It defines
a type, shows it in the documentation, then generates a reference table
from the same type:

```ocaml
(* @mdexp

## Compression

The library supports several compression formats.

@mdexp.code *)

type compression = None | Gzip | Zstd

(* @mdexp Supported formats: *)

let%expect_test "compression table" =
  List.iter
    (fun (name, ratio, speed) ->
       Printf.printf "| %s | %s | %s |\n" name ratio speed)
    [ "none", "-", "fastest"
    ; "gzip", "~70%", "moderate"
    ; "zstd", "~75%", "fast"
    ];
  (* @mdexp.snapshot *)
  [%expect {|
    | none | - | fastest |
    | gzip | ~70% | moderate |
    | zstd | ~75% | fast | |}]
;;
```

Three directives drive the extraction: `@mdexp` marks prose,
`@mdexp.code` marks code to include, and `@mdexp.snapshot` captures
verified test output. Running `mdexp pp` on this file produces:

````markdown
## Compression

The library supports several compression formats.

```ocaml
type compression = None | Gzip | Zstd
```

Supported formats:

| none | - | fastest |
| gzip | ~70% | moderate |
| zstd | ~75% | fast |
````

The table is not hand-written markdown --- it is printed by a test that
the build system verifies on every run. Add a variant to the type and
the compiler reminds you to update the match; change the output and the
test runner catches the drift. The documentation cannot fall out of sync.

## How it fits together

The documentation is **type-driven**: code examples are real code that
the compiler type-checks, and program output is captured by snapshot
assertions that the test framework verifies on every build.

The host language compiler, the snapshot framework, mdexp, and the
rendering tool each handle one concern. You get full editor support
(LSP, type hints) while writing, and the build catches any drift.

The tool is language-agnostic by design --- neither the host language
nor the output format is fixed. The examples in this book use
**OCaml** and **Markdown**, but the snapshot mechanism also works
with other host languages (see [Snapshots](snapshots.md)), and
the broader design space is discussed in
[Broadening the View](broadening_the_view.md).

## What's in this book

The first three chapters cover the building blocks --- the directives
that make mdexp work:

- [Prose](prose.md) --- writing documentation text
- [Code Blocks](code_blocks.md) --- embedding type-checked code examples
- [Snapshots](snapshots.md) --- capturing verified program output,
  with a note on other host languages
  - [ppx_expect](ppx_expect_snapshots.md)
  - [Expect tests without ppx](windtrap_snapshots.md)

From there, we explore what becomes possible when you combine these
building blocks with the host language's type system:

- [EDSL](edsl.md) --- building embedded DSLs that both render
  documentation and verify its content
- [Broadening the View](broadening_the_view.md) --- further use
  cases, design choices, and the broader pattern

## Acknowledgements

This book was created through detailed iteration and review,
combining hand-written content with assistance from
[Claude Code](https://claude.ai/claude-code) (Claude Opus 4.6).
The conceptual content, structure, and table of contents were
designed and directed by the human author; every section was
manually reviewed. We benefited from LLM assistance for drafting
prose, catching mistakes, and iterating on the code examples.
In practice the process is fluid --- prompting shapes output,
output shapes the next prompt --- and the final result resists
clean attribution, which is why both contributors are listed as
authors.
