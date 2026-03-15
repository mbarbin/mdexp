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

```dune
(toplevel
 (name mdexp_toplevel)
 (libraries mdexp_stdlib))
```

The test library depends on the toplevel executable:

```dune
(library
 (name mdexp_toplevel_test)
 (inline_tests
  (deps mdexp_toplevel.exe))
 ...)
```

## Implementation

The wrapper creates a context with a temp directory, writes code to a file,
pipes it to the toplevel, and captures the output.

## Examples

### Basic Evaluation

Run simple OCaml expressions and see their values with type information:

```ocaml
let x = 1 + 1;;
```

```terminal
val x : int = 2
```

### Side Effects

Code with side effects shows both the output and the return value:

```ocaml
print_endline "Hello, World!";;
```

```terminal
Hello, World!
- : unit = ()
```

### Type Errors

Error messages include location information, useful for explaining
what goes wrong with invalid code:

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

### Using Preloaded Libraries

The custom toplevel has libraries preloaded. No `#require` needed:

```ocaml
open Mdexp_stdlib;;
List.map [1;2;3] ~f:(fun x -> x * 2);;
```

```terminal
- : int list = [2; 4; 6]
```

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

The toplevel will be rebuilt automatically when dependencies change.
