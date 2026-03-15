# Expect tests without ppx

[Windtrap](https://github.com/invariant-hq/windtrap) is a no-ppx alternative
for writing expect tests in OCaml. Tests use plain function calls ---
`expect {|...|}` --- instead of ppx syntax.

Place `@mdexp.snapshot` before the `expect` call, and mdexp extracts
the block string content, just as it does with `[%expect]`.

## Example

The code block ends at `@mdexp.snapshot`, and the `expect` block
string content follows as plain text:

```ocaml
open Windtrap

let greet name = Printf.printf "Hello, %s!\n" name

let () =
  run
    "Windtrap Snapshots"
    [ test "greeting" (fun () ->
        greet "World";
```

Hello, World!
