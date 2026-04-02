Hello mdexp cli.

  $ mdexp --help | grep -m 1 Literate | sed 's/[[:space:]]*//'
  mdexp - Literate Programming with Embedded Snapshots

Extract prose from an OCaml file.

  $ cat > test.ml << 'EOF'
  > (* @mdexp *)
  > (* # Hello World *)
  > (* *)
  > (* This is a test. *)
  > (* @mdexp.end *)
  > EOF

  $ mdexp pp test.ml
  # Hello World
  
  This is a test.


Extract a code block.

  $ cat > test_code.ml << 'EOF'
  > (* @mdexp.code *)
  > (* let x = 42 *)
  > (* @mdexp.end *)
  > EOF

  $ mdexp pp test_code.ml
  ```ocaml
  let x = 42
  ```

Extract prose from a Zig file.

  $ cat > test.zig << 'EOF'
  > // @mdexp
  > // # Hello from Zig
  > //
  > // This is a Zig test.
  > // @mdexp.end
  > EOF

  $ mdexp pp test.zig
  # Hello from Zig
  
  This is a Zig test.


Extract a Zig snapshot with block mode.

  $ cat > test_snap.zig << 'EOF'
  > // @mdexp.snapshot { lang: "json" }
  > try snapshot.snap(@src(),
  >     \\{
  >     \\  "key": "value"
  >     \\}
  > ).diff(value);
  > EOF

  $ mdexp pp test_snap.zig
  ```json
  {
    "key": "value"
  }
  ```

Extract a Rust snapshot (expect-test style).

  $ cat > test_snap.rs << 'EOF'
  > // @mdexp.snapshot { lang: "text" }
  > expect![["Hello from Rust"]];
  > EOF

  $ mdexp pp test_snap.rs
  ```text
  Hello from Rust
  ```

Error on file with no extension.

  $ cat > noext << 'EOF'
  > some content
  > EOF

  $ mdexp pp noext
  Error: Unknown file extension "".
  Hint: did you mean ml or rs?
  [123]
