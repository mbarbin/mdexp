# Snapshots

The `@mdexp.snapshot` directive captures verified program output and
includes it in the documentation. Place `@mdexp.snapshot` right
before the snapshot assertion. mdexp extracts the content of the
assertion's block string and emits it as part of the document.

Because the test framework verifies the assertion on every run, the
documented output cannot drift from reality.

## How it works

The directive does not depend on a particular testing library. It looks
for the next OCaml block string (`{|...|}`) after `@mdexp.snapshot`
and extracts its content. This means any framework whose assertions
contain a block string of the expected output is supported.

mdexp currently ships with support for two OCaml snapshot frameworks:

- [ppx_expect](ppx_expect_snapshots.md) --- Jane Street's inline
  expect tests, using `[%expect {|...|}]`
- [Expect tests without ppx](windtrap_snapshots.md) --- using
  Windtrap's `expect {|...|}` plain function calls

The sections that follow show each in action. The same
`@mdexp.snapshot` directive works with both --- only the surrounding
test syntax differs.

Beyond OCaml, we have done preliminary compatibility testing with
expect-test frameworks in **Rust** and **Zig**. These are not yet
used in production, but the directive syntax is designed to be
host-language agnostic --- the same `@mdexp.snapshot` mechanism
applies wherever a block string carries the expected output.

## Snapshot configuration

By default, snapshot content is emitted as plain text. You can
configure the output with a short inline annotation:

- `@mdexp.snapshot { lang: "json" }` --- wrap in a fenced code block
  with the given language tag
- `@mdexp.snapshot { block: true }` --- wrap in a plain fence (no language)
