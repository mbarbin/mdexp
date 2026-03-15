# Testing Block Comment Closing Behavior

This test demonstrates the various ways to end mdexp prose blocks in OCaml.

## Closing with standalone marker

This paragraph has the closing marker on its own line below.

## Explicit closing with @mdexp.end

This paragraph uses an explicit end directive.

## Directive followed by closing

This demonstrates the common pattern: end prose with a directive.

```ocaml
let (_ : unit -> unit) = fun () -> print_endline "Hello, World!"
```
