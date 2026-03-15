# String Utilities for OCaml

A collection of common string manipulation functions.

## Core Functions

### capitalize

Capitalize the first character of a string:

```ocaml
let capitalize s =
  if String.length s = 0
  then s
  else (
    let first = String.uppercase_ascii (String.sub s ~pos:0 ~len:1) in
    let rest = String.sub s ~pos:1 ~len:(String.length s - 1) in
    first ^ rest)
;;
```

### split_on_char

Split a string on a given character:

```ocaml
let split_on_char sep s =
  let rec aux acc start len =
    if start >= String.length s
    then if len > 0 then String.sub s ~pos:(start - len) ~len :: acc else acc
    else if s.[start] = sep
    then (
      let word = if len > 0 then [ String.sub s ~pos:(start - len) ~len ] else [] in
      aux (word @ acc) (start + 1) 0)
    else aux acc (start + 1) (len + 1)
  in
  List.rev (aux [] 0 0)
;;
```

## Usage Examples

Let's see how these functions work in practice.

### Testing capitalize

First, we test the basic case of capitalizing a lowercase word:

```ocaml
let%expect_test "capitalize - basic case" =
  let result = capitalize "hello" in
  print_endline result;
  [%expect {| Hello |}]
;;
```

Empty strings should be handled gracefully:

```ocaml
let%expect_test "capitalize - empty string" =
  let result = capitalize "" in
  print_endline result;
  [%expect {|  |}]
;;
```

Already capitalized strings should remain unchanged:

```ocaml
let%expect_test "capitalize - already capitalized" =
  let result = capitalize "WORLD" in
  print_endline result;
  [%expect {| WORLD |}]
;;
```

### Testing split_on_char

The function correctly splits comma-separated values:

```ocaml
let%expect_test "split_on_char - comma separated" =
  let words = split_on_char ',' "a,b,c" in
  List.iter words ~f:print_endline;
  [%expect
    {|
    a
    b
    c |}]
;;
```

Splitting an empty string returns an empty list:

```ocaml
let%expect_test "split_on_char - empty string" =
  let words = split_on_char ',' "" in
  print_endline (string_of_int (List.length words));
  [%expect {| 0 |}]
;;
```

It works with different separators like spaces:

```ocaml
let%expect_test "split_on_char - space separated" =
  let words = split_on_char ' ' "hello world" in
  List.iter words ~f:print_endline;
  [%expect
    {|
    hello
    world |}]
;;
```

## Literate Example: Complex String Processing

This example demonstrates a more complex use case where we combine both
functions to process a formatted string. We'll alternate between explanation and
code to create a narrative flow.

First, let's start with a comma-separated list that needs processing:

```ocaml
let input = "alice,bob,charlie" in
print_endline ("Input: " ^ input);
[%expect {| Input: alice,bob,charlie |}];
```

Now we split the string into individual names:

```ocaml
let names = split_on_char ',' input in
print_endline ("Found " ^ string_of_int (List.length names) ^ " names");
[%expect {| Found 3 names |}];
```

Next, we capitalize each name to ensure proper formatting:

```ocaml
let capitalized_names = List.map names ~f:capitalize in
List.iter capitalized_names ~f:(fun name -> print_endline ("- " ^ name));
[%expect
  {|
  - Alice
  - Bob
  - Charlie |}];
```

Finally, let's verify that our processing worked correctly by checking the
first and last names:

```ocaml
let first_name = List.hd capitalized_names in
let last_name = List.hd (List.rev capitalized_names) in
print_endline ("First: " ^ first_name ^ ", Last: " ^ last_name);
[%expect {| First: Alice, Last: Charlie |}];
```
