# Code Block with Blank Comment Lines Test (OCaml)

This test verifies that blank comment lines within code blocks don't
prematurely end the block in OCaml files.

## Function with blank lines in comments

The following code has blank comment lines that should be preserved:

```ocaml
let calculate x y =
  let sum = x + y in

  let result = sum * 2 in
  result
```

## Multiple functions with blank lines

```ocaml
let first () =
  let a = 1 in

  let b = 2 in
  a + b

let second () =
  let c = 3 in
  c
```
