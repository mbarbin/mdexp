# Table Examples (OCaml)

This file demonstrates creating markdown tables using the print-table library
with ppx_expect snapshot testing in OCaml.

## Basic Data Types

We'll use some simple data structures to demonstrate table rendering.

## Simple People Table

A basic table showing people with their ages and cities.

```ocaml
let%expect_test "people table - markdown format" =
  let open Print_table.O in
  let columns : person Column.t list =
    [ Column.make ~header:"Name" (fun p -> Cell.text p.person_name)
    ; Column.make ~header:"Age" ~align:Right (fun p -> Cell.text (Int.to_string p.age))
    ; Column.make ~header:"City" (fun p -> Cell.text p.city)
    ]
  in
  let rows =
    [ { person_name = "Alice"; age = 30; city = "New York" }
    ; { person_name = "Bob"; age = 25; city = "London" }
    ; { person_name = "Charlie"; age = 35; city = "Tokyo" }
    ]
  in
  let print_table = Print_table.make ~columns ~rows in
  let output = Print_table.to_string_markdown print_table in
  print_endline output;
```

| Name    | Age | City     |
|:--------|----:|:---------|
| Alice   |  30 | New York |
| Bob     |  25 | London   |
| Charlie |  35 | Tokyo    |

## Product Inventory Table

A table displaying product information with prices and stock levels.

```ocaml
let%expect_test "product inventory - markdown format" =
  let open Print_table.O in
  let columns =
    [ Column.make ~header:"Product" (fun p -> Cell.text p.product_name)
    ; Column.make ~header:"Price" ~align:Right (fun p ->
        Cell.text (Printf.sprintf "$%.2f" p.price))
    ; Column.make ~header:"Stock" ~align:Center (fun p ->
        Cell.text (Int.to_string p.stock))
    ]
  in
  let rows =
    [ { product_name = "Widget"; price = 19.99; stock = 150 }
    ; { product_name = "Gadget"; price = 29.50; stock = 75 }
    ; { product_name = "Doohickey"; price = 5.25; stock = 300 }
    ]
  in
  let print_table = Print_table.make ~columns ~rows in
  let output = Print_table.to_string_markdown print_table in
  print_endline output;
```

| Product   |  Price | Stock |
|:----------|-------:|:-----:|
| Widget    | $19.99 |  150  |
| Gadget    | $29.50 |  75   |
| Doohickey |  $5.25 |  300  |

## Alignment Examples

Demonstrating different column alignments (left, center, right).

```ocaml
type align_demo =
  { left : string
  ; center : string
  ; right : string
  }

let%expect_test "alignment demonstration - markdown format" =
  let open Print_table.O in
  let columns =
    [ Column.make ~header:"Left" ~align:Left (fun d -> Cell.text d.left)
    ; Column.make ~header:"Center" ~align:Center (fun d -> Cell.text d.center)
    ; Column.make ~header:"Right" ~align:Right (fun d -> Cell.text d.right)
    ]
  in
  let rows =
    [ { left = "A"; center = "B"; right = "C" }
    ; { left = "Short"; center = "Medium"; right = "Long text" }
    ; { left = "X"; center = "Y"; right = "Z" }
    ]
  in
  let print_table = Print_table.make ~columns ~rows in
  let output = Print_table.to_string_markdown print_table in
  print_endline output;
```

| Left  | Center |     Right |
|:------|:------:|----------:|
| A     |   B    |         C |
| Short | Medium | Long text |
| X     |   Y    |         Z |

## Edge Cases

Testing edge cases like single-row tables.

```ocaml
type single_row =
  { id : int
  ; value : string
  }

let%expect_test "single row table - markdown format" =
  let open Print_table.O in
  let columns =
    [ Column.make ~header:"ID" ~align:Right (fun r -> Cell.text (Int.to_string r.id))
    ; Column.make ~header:"Value" (fun r -> Cell.text r.value)
    ]
  in
  let rows = [ { id = 42; value = "The Answer" } ] in
  let print_table = Print_table.make ~columns ~rows in
  let output = Print_table.to_string_markdown print_table in
  print_endline output;
```

| ID | Value      |
|---:|:-----------|
| 42 | The Answer |
