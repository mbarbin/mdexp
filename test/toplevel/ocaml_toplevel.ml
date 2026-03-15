(********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                        *)
(*  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(********************************************************************************)

(* @mdexp

# OCaml Toplevel Integration

This module provides a way to run OCaml code in a toplevel and capture the
output for documentation. This is useful for:

- Documenting code fragments that don't compile in isolation
- Showing REPL-style interactions with type information
- Demonstrating error messages
- Using libraries without requiring full compilation

## Why a Custom Toplevel?

mdexp supports running code blocks in a toplevel via ppx_expect that pipes code
to a dune-built toplevel.

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

(* @mdexp The test library depends on the toplevel executable: *)

(* @mdexp.code { lang: "dune" } *)
(*
(library
 (name mdexp_toplevel_test)
 (inline_tests
  (deps mdexp_toplevel.exe))
 ...)
*)

(* @mdexp

## Implementation

The wrapper creates a context with a temp directory, writes code to a file,
pipes it to the toplevel, and captures the output. *)

module Unix = UnixLabels

type t =
  { context : Shexp_process.Context.t
  ; temp_dir : string
  }

let create () =
  let temp_dir = Filename.temp_dir "ocaml_toplevel" "" in
  { context = Shexp_process.Context.create (); temp_dir }
;;

let rec remove_dir path =
  if Sys.is_directory path
  then (
    let entries = Sys.readdir path in
    Array.iter entries ~f:(fun name -> remove_dir (Filename.concat path name));
    Unix.rmdir path)
  else Unix.unlink path
;;

let dispose t =
  Shexp_process.Context.dispose t.context;
  if Sys.file_exists t.temp_dir then remove_dir t.temp_dir
;;

let run f =
  let t = create () in
  Exn.protect ~f:(fun () -> f t) ~finally:(fun () -> dispose t)
;;

(* The custom toplevel built by dune with project libraries preloaded.
   This is available because of the (deps mdexp_toplevel.exe) in dune. *)
let toplevel_exe = "./mdexp_toplevel.exe"

let is_toplevel_initialization_message line =
  let stripped = String.trim line in
  String.is_empty stripped
  || String.equal stripped "#"
  || List.exists
       [ ": added to search path"; ".cma: loaded"; ".cmo: loaded"; ".cmxs: loaded" ]
       ~f:(fun suffix -> String.ends_with stripped ~suffix)
  || List.exists
       [ "Findlib has been successfully loaded"
       ; {|#require "package"|}
       ; "#list;;"
       ; "#camlp4o;;"
       ; "#camlp4r;;"
       ; "#predicates"
       ; "Topfind.reset"
       ; "#thread;;"
       ]
       ~f:(fun prefix -> String.starts_with stripped ~prefix)
;;

(* Run OCaml code and print both the code and the toplevel output *)
let eval { context; temp_dir } ~code =
  (* Print the code block first *)
  print_endline "```ocaml";
  print_endline code;
  print_endline "```";
  print_endline "";
  print_endline "```terminal";
  let stdout_file = Filename.concat temp_dir "stdout.tmp" in
  let stderr_file = Filename.concat temp_dir "stderr.tmp" in
  Exn.protect
    ~f:(fun () ->
      let process =
        Shexp_process.pipe
          (Shexp_process.echo code)
          (Shexp_process.call_exit_code
             [ toplevel_exe; "-noprompt"; "-no-version"; "-color"; "always" ])
        |> Shexp_process.stdout_to stdout_file
        |> Shexp_process.stderr_to stderr_file
      in
      let exit_code = Shexp_process.eval ~context process in
      let stdout_content = In_channel.read_all stdout_file in
      let stderr_content = In_channel.read_all stderr_file in
      (* Print the output, skipping leading initialization messages *)
      let output = String.trim (stdout_content ^ stderr_content) in
      let lines = String.split_lines output in
      let rec skip_initialization_messages = function
        | line :: rest when is_toplevel_initialization_message line ->
          skip_initialization_messages rest
        | lines -> lines
      in
      List.iter (skip_initialization_messages lines) ~f:print_endline;
      if exit_code <> 0 then Printf.printf "[%d]\n" exit_code;
      print_endline "```")
    ~finally:(fun () ->
      if Sys.file_exists stdout_file then Unix.unlink stdout_file;
      if Sys.file_exists stderr_file then Unix.unlink stderr_file)
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
