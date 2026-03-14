## Use of AI

:warning: As we are prototyping the project we use the help of gen-AI to iter on
the code. Almost all AI content was already reviewed by the original author, and
heavily iterated on and rewritten manually, however there persists areas where
that manual rewrite isn't finished yet, and we'll need more time to ajust the
code further.

Our goal is to reach a state where all the code is documented, tested, and has
been reviewed / adjusted / rewritten by the author and maintainers as they see
fit. We'll update this section when we are done with that.

The files where we are still conducting that review process are listed below.
We'll remove them from this list as we progress with the project.

```text
src/mdexp/file_processor.ml
src/mdexp/file_processor.mli
src/mdexp/json5_accumulator.ml
src/mdexp/json5_accumulator.mli
src/mdexp/line_processor.ml
src/mdexp/line_processor.mli
src/mdexp/located_json.ml
src/mdexp/located_json.mli
src/mdexp/render_engine.ml
src/mdexp/render_engine.mli
src/stdlib/string0.ml
src/stdlib/string0.mli
test/cram/config_errors.t
test/cram/run.t
test/mdexp/dune
test/mdexp/test__comment_syntax.ml
test/mdexp/test__directive.ml
test/mdexp/test__directive_loc.ml
test/mdexp/test__extract.ml
test/mdexp/test__extract_rust.ml
test/mdexp/test__extract_zig.ml
test/mdexp/test__host_language.ml
test/mdexp/test__json5_accumulator.ml
test/mdexp/test__line_processor.ml
test/mdexp/test__located_json.ml
test/mdexp/test__markdown_lang_id.ml
test/stdlib/test__char.ml
test/stdlib/test__string.ml
```
