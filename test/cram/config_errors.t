Error detection in snapshot and config JSON.

Unknown field in snapshot config.

  $ cat > test.ml << 'EOF'
  > (* @mdexp.snapshot { blck: true } *)
  > [%expect {| some output |}]
  > EOF

  $ mdexp pp test.ml
  File "test.ml", line 1, characters 21-25:
  1 | (* @mdexp.snapshot { blck: true } *)
                           ^^^^
  Error: Unknown field "blck" in snapshot configuration.
  Hint: did you mean block?
  some output
  [123]

Unknown field "language" (should be "lang").

  $ cat > test.ml << 'EOF'
  > (* @mdexp.snapshot { language: "json" } *)
  > [%expect {| data |}]
  > EOF

  $ mdexp pp test.ml
  File "test.ml", line 1, characters 21-29:
  1 | (* @mdexp.snapshot { language: "json" } *)
                           ^^^^^^^^
  Error: Unknown field "language" in snapshot configuration.
  data
  [123]

Wrong type for "block": string instead of bool.

  $ cat > test.ml << 'EOF'
  > (* @mdexp.snapshot { block: "yes" } *)
  > [%expect {| output |}]
  > EOF

  $ mdexp pp test.ml
  File "test.ml", line 1, characters 28-33:
  1 | (* @mdexp.snapshot { block: "yes" } *)
                                  ^^^^^
  Error: Field "block" expects a boolean value.
  output
  [123]

Wrong type for "block": integer instead of bool.

  $ cat > test.ml << 'EOF'
  > (* @mdexp.snapshot { block: 42 } *)
  > [%expect {| output |}]
  > EOF

  $ mdexp pp test.ml
  File "test.ml", line 1, characters 28-30:
  1 | (* @mdexp.snapshot { block: 42 } *)
                                  ^^
  Error: Field "block" expects a boolean value.
  output
  [123]

Wrong type for "lang": integer instead of string.

  $ cat > test.ml << 'EOF'
  > (* @mdexp.snapshot { lang: 99 } *)
  > [%expect {| output |}]
  > EOF

  $ mdexp pp test.ml
  File "test.ml", line 1, characters 27-29:
  1 | (* @mdexp.snapshot { lang: 99 } *)
                                 ^^
  Error: Field "lang" expects a string value.
  output
  [123]

Wrong type for "lang": bool instead of string.

  $ cat > test.ml << 'EOF'
  > (* @mdexp.snapshot { lang: true } *)
  > [%expect {| output |}]
  > EOF

  $ mdexp pp test.ml
  File "test.ml", line 1, characters 27-31:
  1 | (* @mdexp.snapshot { lang: true } *)
                                 ^^^^
  Error: Field "lang" expects a string value.
  output
  [123]

Multiple errors in one config (unknown field + wrong type).

  $ cat > test.ml << 'EOF'
  > (* @mdexp.snapshot { blck: "yes", lang: 42 } *)
  > [%expect {| output |}]
  > EOF

  $ mdexp pp test.ml
  File "test.ml", line 1, characters 21-25:
  1 | (* @mdexp.snapshot { blck: "yes", lang: 42 } *)
                           ^^^^
  Error: Unknown field "blck" in snapshot configuration.
  Hint: did you mean block?
  
  File "test.ml", line 1, characters 40-42:
  1 | (* @mdexp.snapshot { blck: "yes", lang: 42 } *)
                                              ^^
  Error: Field "lang" expects a string value.
  output
  [123]


Unknown field in @mdexp.config snapshot sub-object.

  $ cat > test.ml << 'EOF'
  > (* @mdexp.config { snapshot: { bloc: true } } *)
  > (* @mdexp.snapshot *)
  > [%expect {| output |}]
  > EOF

  $ mdexp pp test.ml
  File "test.ml", line 1, characters 31-35:
  1 | (* @mdexp.config { snapshot: { bloc: true } } *)
                                     ^^^^
  Error: Unknown field "bloc" in snapshot configuration.
  Hint: did you mean block?
  output
  [123]

Wrong type in @mdexp.config snapshot sub-object.

  $ cat > test.ml << 'EOF'
  > (* @mdexp.config { snapshot: { block: "nope" } } *)
  > (* @mdexp.snapshot *)
  > [%expect {| output |}]
  > EOF

  $ mdexp pp test.ml
  File "test.ml", line 1, characters 38-44:
  1 | (* @mdexp.config { snapshot: { block: "nope" } } *)
                                            ^^^^^^
  Error: Field "block" expects a boolean value.
  output
  [123]

Unknown field in code config.

  $ cat > test.ml << 'EOF'
  > (* @mdexp.code { language: "bash" } *)
  > (* echo hello *)
  > (* @mdexp.end *)
  > EOF

  $ mdexp pp test.ml
  File "test.ml", line 1, characters 17-25:
  1 | (* @mdexp.code { language: "bash" } *)
                       ^^^^^^^^
  Error: Unknown field "language" in code configuration.
  ```ocaml
  echo hello
  ```
  [123]

Wrong type for "lang" in code config: integer instead of string.

  $ cat > test.ml << 'EOF'
  > (* @mdexp.code { lang: 42 } *)
  > (* echo hello *)
  > (* @mdexp.end *)
  > EOF

  $ mdexp pp test.ml
  File "test.ml", line 1, characters 23-25:
  1 | (* @mdexp.code { lang: 42 } *)
                             ^^
  Error: Field "lang" expects a string value.
  ```ocaml
  echo hello
  ```
  [123]

Unknown field in @mdexp.config code sub-object.

  $ cat > test.ml << 'EOF'
  > (* @mdexp.config { code: { language: "bash" } } *)
  > (* @mdexp.code *)
  > (* echo hello *)
  > (* @mdexp.end *)
  > EOF

  $ mdexp pp test.ml
  File "test.ml", line 1, characters 27-35:
  1 | (* @mdexp.config { code: { language: "bash" } } *)
                                 ^^^^^^^^
  Error: Unknown field "language" in code configuration.
  ```ocaml
  echo hello
  ```
  [123]

Valid configs produce no errors.

  $ cat > test.ml << 'EOF'
  > (* @mdexp.snapshot { lang: "json", block: true } *)
  > [%expect {| {"key": "value"} |}]
  > EOF

  $ mdexp pp test.ml
  ```json
  {"key": "value"}
  ```

  $ cat > test.ml << 'EOF'
  > (* @mdexp.snapshot { block: true } *)
  > [%expect {| output |}]
  > EOF

  $ mdexp pp test.ml
  ```
  output
  ```

  $ cat > test.ml << 'EOF'
  > (* @mdexp.snapshot { lang: "text" } *)
  > [%expect {| output |}]
  > EOF

  $ mdexp pp test.ml
  ```text
  output
  ```

  $ cat > test.ml << 'EOF'
  > (* @mdexp.config { snapshot: { lang: "json" } } *)
  > (* @mdexp.snapshot *)
  > [%expect {| data |}]
  > EOF

  $ mdexp pp test.ml
  ```json
  data
  ```

  $ cat > test.ml << 'EOF'
  > (* @mdexp.code { lang: "bash" } *)
  > (* echo hello *)
  > (* @mdexp.end *)
  > EOF

  $ mdexp pp test.ml
  ```bash
  echo hello
  ```

  $ cat > test.ml << 'EOF'
  > (* @mdexp.config { code: { lang: "bash" } } *)
  > (* @mdexp.code *)
  > (* echo hello *)
  > (* @mdexp.end *)
  > EOF

  $ mdexp pp test.ml
  ```bash
  echo hello
  ```
