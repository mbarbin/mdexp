(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

(* @mdexp # Introduction *)

(* @mdexp
This book is a short, cover-to-cover introduction to **mdexp** ---
a documentation preprocessor for literate programming with embedded
snapshots. It is aimed at newcomers who want to understand what the
tool does and why it is useful. For installation, detailed reference,
and how-to guides, see the main documentation.

## What is mdexp?

Imagine writing a source file that contains everything a page of
documentation needs --- prose, code examples, and program output ---
all in one place. Lightweight directives tell mdexp which parts to
extract and how to assemble them. Some of those parts are plain text;
others are type-checked code or test output verified by the build
system.

You write the documentation you want, as a compilable source file.
mdexp extracts it. The compiler and test framework ensure it stays
accurate.

## A Quick Example

Consider a source file that documents a compression library. It defines
a type, shows it in the documentation, then generates a reference table
from the same type:
@mdexp.end *)

(* @mdexp.snapshot { lang: "ocaml" } *)
let _ =
  {xxx|
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
|xxx}
;;

(* @mdexp
Three directives drive the extraction: `@mdexp` marks prose,
`@mdexp.code` marks code to include, and `@mdexp.snapshot` captures
verified test output. Running `mdexp pp` on this file produces:
@mdexp.end *)

(* @mdexp.snapshot { lang: "markdown" } *)
let _ =
  {xxx|
## Compression

The library supports several compression formats.

```ocaml
type compression = None | Gzip | Zstd
```

Supported formats:

| none | - | fastest |
| gzip | ~70% | moderate |
| zstd | ~75% | fast |
|xxx}
;;

(* @mdexp
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

The tool is language-agnostic by design --- neither the input language
nor the output format is fixed. mdexp is still under active development;
more source languages and output formats will be added over time.

The examples in this book use **OCaml** as the source language and
**Markdown** as the output, since this is what we have focused on so far.
The concepts carry over to other languages.

## What's in This Book

- [Prose](prose.md) --- writing documentation text
- [Code Blocks](code_blocks.md) --- embedding code examples
- [Snapshots](snapshots.md) --- capturing verified program output
  - [ppx_expect](ppx_expect_snapshots.md)
  - [Expect tests without ppx](windtrap_snapshots.md)
*)
