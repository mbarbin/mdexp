# Expect tests without ppx

[Windtrap](https://github.com/invariant-hq/windtrap) is a no-ppx alternative
for writing expect tests in OCaml. Tests use plain function calls --- `expect
{|...|}` --- instead of ppx syntax.

Place `@mdexp.snapshot` before the `expect` call, and mdexp extracts the
block string content, just as it does with `[%expect]`.

## Example

```ocaml
open Windtrap

let greet name = Printf.printf "Hello, %s!\n" name
```

Let's add *mdexp* directives to a windtrap test:

```diff
  let () =
    let tests =
      [ test "greeting" (fun () ->
+         (* @mdexp When you greet the world, like so: *)
+         (* @mdexp.code *)
          greet "World";
+         (* @mdexp the following happens: *)
+         (* @mdexp.snapshot { lang: "text" } *)
          expect {|Hello, World!|})
      ]
    in
    (run "Windtrap Snapshots" tests [@coverage off])
  ;;
```

This would yield the following markdown:

When you greet the world, like so:

```ocaml
greet "World";
```

the following happens:

```text
Hello, World!
```
