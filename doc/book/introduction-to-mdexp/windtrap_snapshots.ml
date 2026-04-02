(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

(* @mdexp

   # Expect tests without ppx

   [Windtrap](https://github.com/invariant-hq/windtrap) is a no-ppx alternative
   for writing expect tests in OCaml. Tests use plain function calls --- `expect
   {|...|}` --- instead of ppx syntax.

   Place `@mdexp.snapshot` before the `expect` call, and mdexp extracts the
   block string content, just as it does with `[%expect]`.

   ## Example

   @mdexp.code *)

open Windtrap

let greet name = Printf.printf "Hello, %s!\n" name

(* @mdexp

   Let's add *mdexp* directives to a windtrap test: *)

let (_ : string) =
  (* @mdexp.snapshot { lang: "diff" } *)
  {diff|
    let () =
      let tests =
        [ test "greeting" (fun () ->
  +         (* @mdexp When you greet the world, like so: *)
  +         (* @mdexp.code *)
            greet "World";
  +         (* @mdexp the following happens: *)
  +         (* @mdexp.snapshot { lang: "text" } *)
            expect {|Hello, World!|})
        ]
      in
      (run "Windtrap Snapshots" tests [@coverage off])
    ;;
  |diff}
;;

(* @mdexp

   This would yield the following markdown: *)

let () =
  let tests =
    [ test "greeting" (fun () ->
        (* @mdexp When you greet the world, like so: *)
        (* @mdexp.code *)
        greet "World";
        (* @mdexp the following happens: *)
        (* @mdexp.snapshot { lang: "text" } *)
        expect {|Hello, World!|})
    ]
  in
  (run "Windtrap Snapshots" tests [@coverage off])
;;
