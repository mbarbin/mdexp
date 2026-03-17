(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

(* @mdexp # Expect tests without ppx *)

(* @mdexp
[Windtrap](https://github.com/invariant-hq/windtrap) is a no-ppx alternative
for writing expect tests in OCaml. Tests use plain function calls ---
`expect {|...|}` --- instead of ppx syntax.

Place `@mdexp.snapshot` before the `expect` call, and mdexp extracts
the block string content, just as it does with `[%expect]`.

## Example

The code block ends at `@mdexp.snapshot`, and the `expect` block
string content follows as plain text:
@mdexp.code *)

open Windtrap

let greet name = Printf.printf "Hello, %s!\n" name

let () =
  run
    "Windtrap Snapshots"
    [ test "greeting" (fun () ->
        greet "World";
        (* @mdexp.snapshot *)
        expect {|Hello, World!|})
    ]
;;
