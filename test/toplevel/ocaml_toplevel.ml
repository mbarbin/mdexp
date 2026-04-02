(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

(* @mdexp

# OCaml Toplevel Integration

This module provides a way to run OCaml code in a toplevel and capture the
output for documentation. This is useful for:

- Documenting code fragments that don't compile in isolation
- Showing REPL-style interactions with type information
- Demonstrating error messages
- Using libraries without requiring full compilation

## Why a Custom Toplevel?

mdexp supports running code blocks in a toplevel via ppx_expect. The toplevel
process is started with an empty environment (`env:[]`) which suppresses
initialization messages, and kept alive to allow sequential evaluations.

Features:

1. **Dune integration** - The toplevel rebuilds when dependencies change
2. **Watch mode** - Works with `dune build -w`
3. **Preloaded libraries** - Project libraries are available without `#require`
4. **Verified output** - Snapshots ensure examples stay correct

## Setup

The dune file defines a custom toplevel with preloaded libraries:
*)

(* @mdexp.code { lang: "dune" } *)
(*
(toplevel
 (name mdexp_toplevel)
 (libraries mdexp_stdlib))
*)

(* @mdexp The test library depends on the toplevel executable and uses unix: *)

(* @mdexp.code { lang: "dune" } *)
(*
(library
 (name mdexp_toplevel_test)
 (inline_tests
  (deps mdexp_toplevel.exe))
 (libraries mdexp_stdlib unix)
 ...)
*)

(* @mdexp

## Implementation

The wrapper starts a toplevel process with an empty environment, which
suppresses all initialization messages. The process is kept alive across
evaluations, allowing sequential code blocks to share definitions. *)

module Unix = UnixLabels

type t =
  { ic : in_channel
  ; oc : out_channel
  ; ec : in_channel
  }

(* The custom toplevel built by dune with project libraries preloaded.
   This is available because of the (deps mdexp_toplevel.exe) in dune. *)
let toplevel_exe = "./mdexp_toplevel.exe"
let sentinel = "__MDEXP_EVAL_SENTINEL_8f3a2b__"

let create () =
  let cmd = toplevel_exe ^ " -noprompt -no-version -color always" in
  let ic, oc, ec = Unix.open_process_full cmd ~env:[||] in
  { ic; oc; ec }
;;

let run f =
  let t = create () in
  let result = Exn.protect ~f:(fun () -> f t) ~finally:(fun () -> close_out t.oc) in
  let stderr_content = In_channel.input_all t.ec in
  let status = Unix.close_process_full (t.ic, t.oc, t.ec) in
  let stderr_trimmed = String.trim stderr_content in
  if not (String.is_empty stderr_trimmed)
  then print_endline stderr_trimmed [@coverage off];
  (match status with
   | WEXITED 0 -> ()
   | _ ->
     (match[@coverage off] status with
      | WEXITED n -> Printf.printf "[%d]\n" n
      | WSIGNALED n -> Printf.printf "[signal %d]\n" n
      | WSTOPPED n -> Printf.printf "[stopped %d]\n" n));
  result
;;

let read_stdout_until_sentinel ic =
  let buf = Buffer.create 256 in
  (try
     while true do
       let line = input_line ic in
       if String.equal (String.trim line) sentinel
       then (
         (* Consume the "- : unit = ()" response line *)
         ignore (input_line ic : string);
         raise_notrace Exit)
       else (
         if Buffer.length buf > 0 then Buffer.add_char buf '\n';
         Buffer.add_string buf line)
     done
   with
   | Exit -> ());
  Buffer.contents buf
;;

(* Run OCaml code and print both the code and the toplevel output *)
let eval t ~code =
  print_endline "```ocaml";
  print_endline code;
  print_endline "```";
  print_endline "";
  print_endline "```terminal";
  output_string t.oc code;
  output_char t.oc '\n';
  Printf.fprintf t.oc "print_endline %S;;\n" sentinel;
  flush t.oc;
  let stdout_content = read_stdout_until_sentinel t.ic in
  let stdout_trimmed = String.trim stdout_content in
  if not (String.is_empty stdout_trimmed) then print_endline stdout_trimmed;
  print_endline "```"
;;

(* @mdexp

## Examples

### Basic Evaluation

Run simple OCaml expressions and see their values with type information: *)

let%expect_test "basic eval" =
  run
  @@ fun t ->
  eval t ~code:"let x = 1 + 1;;";
  (* @mdexp.snapshot *)
  [%expect
    {|
    ```ocaml
    let x = 1 + 1;;
    ```

    ```terminal
    val x : int = 2
    ```
    |}]
;;

(* @mdexp

### Side Effects

Code with side effects shows both the output and the return value: *)

let%expect_test "eval with print" =
  run
  @@ fun t ->
  eval t ~code:{xxx|print_endline "Hello, World!";;|xxx};
  (* @mdexp.snapshot *)
  [%expect
    {|
    ```ocaml
    print_endline "Hello, World!";;
    ```

    ```terminal
    Hello, World!
    - : unit = ()
    ```
    |}]
;;

(* @mdexp

### Type Errors

Error messages include location information, useful for explaining
what goes wrong with invalid code: *)

let%expect_test "eval with error" =
  run
  @@ fun t ->
  eval t ~code:{xxx|let x = 1 + "hello";;|xxx};
  (* @mdexp.snapshot *)
  [%expect
    {|
    ```ocaml
    let x = 1 + "hello";;
    ```

    ```terminal
    [1mLine 1, characters 12-19[0m:
    1 | let x = 1 + "hello";;
                    [1;31m^^^^^^^[0m
    [1;31mError[0m: This constant has type [1mstring[0m but an expression was expected of type
             [1mint[0m
    ```
    |}]
;;

(* @mdexp

### Using Preloaded Libraries

The custom toplevel has libraries preloaded. No `#require` needed: *)

let%expect_test "eval with preloaded library" =
  run
  @@ fun t ->
  eval
    t
    ~code:
      {xxx|open Mdexp_stdlib;;
List.map [1;2;3] ~f:(fun x -> x * 2);;|xxx};
  (* @mdexp.snapshot *)
  [%expect
    {|
    ```ocaml
    open Mdexp_stdlib;;
    List.map [1;2;3] ~f:(fun x -> x * 2);;
    ```

    ```terminal
    - : int list = [2; 4; 6]
    ```
    |}]
;;

(* @mdexp

### Sequential Evaluations

Definitions from earlier evaluations are available in later ones, since
the toplevel process is kept alive: *)

let%expect_test "sequential eval" =
  run
  @@ fun t ->
  eval t ~code:"let x = 21;;";
  [%expect
    {|
    ```ocaml
    let x = 21;;
    ```

    ```terminal
    val x : int = 21
    ```
    |}];
  eval t ~code:"let y = x * 2;;";
  [%expect
    {|
    ```ocaml
    let y = x * 2;;
    ```

    ```terminal
    val y : int = 42
    ```
    |}]
;;

(* @mdexp

### Type Errors on Stdout

Type errors are reported on stdout by the toplevel, not stderr: *)

let%expect_test "type error on stdout" =
  run
  @@ fun t ->
  eval t ~code:{xxx|let x = 1 + "hello";;|xxx};
  [%expect
    {|
    ```ocaml
    let x = 1 + "hello";;
    ```

    ```terminal
    [1mLine 1, characters 12-19[0m:
    1 | let x = 1 + "hello";;
                    [1;31m^^^^^^^[0m
    [1;31mError[0m: This constant has type [1mstring[0m but an expression was expected of type
             [1mint[0m
    ```
    |}]
;;

(* @mdexp

## Integration with mdexp

The `@mdexp.snapshot` directive extracts the output above into the
generated markdown. This creates documentation with verified,
reproducible REPL examples.

To add more libraries to the toplevel, update the dune stanza:

```dune
(toplevel
 (name my_toplevel)
 (libraries my_project_lib))
```

The toplevel will be rebuilt automatically when dependencies change. *)
