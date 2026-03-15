(********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                        *)
(*  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(********************************************************************************)

(* @mdexp
# Testing Block Comment Closing Behavior

This test demonstrates the various ways to end mdexp prose blocks in OCaml.

## Closing with standalone marker

This paragraph has the closing marker on its own line below.
*)

let (_ : int) = 1

(* @mdexp
## Explicit closing with @mdexp.end

This paragraph uses an explicit end directive.
@mdexp.end *)

let (_ : int) = 2

(* @mdexp
## Directive followed by closing

This demonstrates the common pattern: end prose with a directive.
@mdexp.code *)

let (_ : unit -> unit) = fun () -> print_endline "Hello, World!"

(* @mdexp.end *)

let (_ : int) = 3
