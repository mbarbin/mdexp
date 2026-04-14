(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let (_ : string) =
  (* @mdexp.snapshot *)
  {|
+++
title = "The Potion Brewery"
date = 2026-04-13
weight = 1
[taxonomies]
tags = ["tutorial", "config-as-code"]
+++
|}
;;

(* @mdexp

*By Mathieu Barbin and Claude Opus 4.6*
[![AI-DECLARATION: copilot](https://img.shields.io/badge/䷼%20AI--DECLARATION-copilot-fee2e2?labelColor=fee2e2)](https://ai-declaration.md)

Welcome to the Potion Brewery — a tutorial demonstrating a config-as-code
approach where both documentation and configuration files are generated from
the same shared OCaml values.

Instead of hand-writing JSON config files and separately documenting them,
we define everything as OCaml values in a shared module. mdexp generates this
tutorial page, while a small generator executable produces JSON manifests —
both from the same source of truth, ensuring they never drift apart.

## Config as Code

Using your host language to generate configuration files is a well-established
pattern. It lets you leverage a real type system, write tests against your
config values, and avoid the pitfalls of hand-editing complex or error-prone
file formats. Many teams already do this — generating JSON, YAML, or TOML
from typed values rather than maintaining fragile config files by hand.

By adding mdexp to the mix, we can now fully *document* these configurations
too, using a literate programming approach. The same values that produce the
config files also produce rich, readable documentation — tables, prose,
cross-referenced examples — all generated from the same source of truth and
verified by the build.

## The Potion Brewery

To illustrate this approach, we will build a fictional Potion Brewery
catalog. The page you are reading right now *is* the generated documentation:
every table and recipe below is produced from OCaml values defined in a
shared `Potion` module. Alongside this page, the same values also produce
real JSON configuration files.

As we go, we will occasionally show the OCaml functions that render the
content — so you can see both the result and the code that produces it.
For a deeper understanding of how everything connects, we encourage you to
read the source file
[`potion_brewery.ml`](https://github.com/mbarbin/mdexp/blob/main/doc/content/tutorials/potion-brewery/potion_brewery.ml)
alongside this page — seeing how mdexp directives, prose, and snapshots
interleave gives a much richer picture than the rendered output alone.

### The Ingredients Catalog

Every good brewery starts with quality ingredients. Ours are a bit... unusual.
The following function renders the full catalog as a markdown table from
the list of `Potion.Ingredient.t` values, using the `print-table` library:

@mdexp.code *)

let print_ingredients_table () =
  let open Print_table.O in
  let columns : Potion.Ingredient.t Column.t list =
    [ Column.make ~header:"Ingredient" (fun (i : Potion.Ingredient.t) -> Cell.text i.name)
    ; Column.make ~header:"Category" (fun (i : Potion.Ingredient.t) ->
        Cell.text i.category)
    ; Column.make ~header:"Potency" ~align:Right (fun (i : Potion.Ingredient.t) ->
        Cell.text (Int.to_string i.potency))
    ; Column.make ~header:"Unit" (fun (i : Potion.Ingredient.t) -> Cell.text i.unit)
    ]
  in
  let print_table = Print_table.make ~columns ~rows:Potion.all_ingredients in
  print_endline (Print_table.to_string_markdown print_table)
;;

(* @mdexp

Here are the ingredients available to our brewmasters (rendered with the
function above): *)

let%expect_test "ingredients catalog" =
  print_ingredients_table ();
  (* @mdexp.snapshot *)
  [%expect
    {|
    | Ingredient                  | Category    | Potency | Unit    |
    |:----------------------------|:------------|--------:|:--------|
    | Strongly-Typed Herbs        | Flora       |       8 | sprigs  |
    | Pattern-Match Petals        | Flora       |       7 | petals  |
    | Compiler-Checked Roots      | Underground |       9 | grams   |
    | Test-Coverage Moss          | Flora       |       6 | patches |
    | Fresh mdexp Extract         | Distilled   |      10 | drops   |
    | Literate-Programming Lichen | Flora       |       7 | grams   |
    | Formulaic Fungi             | Mycology    |       5 | caps    |
    | Cask-Aged Oak Bark          | Arboreal    |       4 | strips  | |}]
;;

(* @mdexp

> *Note: All ingredients are ethically sourced from well-maintained codebases.*

### The Recipe Book

Now for the main attraction — our potions! Each recipe combines ingredients
to produce magical effects that enhance a developer's abilities.

Here is the function that renders any recipe as a formatted markdown block —
title, description, ingredient table, and effects list:

@mdexp.code *)

let print_recipe (r : Potion.Recipe.t) =
  Printf.printf "#### %s\n\n" r.name;
  Printf.printf "> *%s*\n\n" r.description;
  Printf.printf "Difficulty: %s | Brewing time: %s\n\n" r.difficulty r.brewing_time;
  let open Print_table.O in
  let columns : Potion.Recipe.ingredient_entry Column.t list =
    [ Column.make ~header:"Ingredient" (fun (e : Potion.Recipe.ingredient_entry) ->
        Cell.text e.ingredient.name)
    ; Column.make
        ~header:"Quantity"
        ~align:Right
        (fun (e : Potion.Recipe.ingredient_entry) ->
           Cell.text (Printf.sprintf "%.0f %s" e.quantity e.ingredient.unit))
    ]
  in
  let print_table = Print_table.make ~columns ~rows:r.ingredients in
  print_endline (Print_table.to_string_markdown print_table);
  Printf.printf "\nEffects:\n";
  List.iter r.effects ~f:(fun (e : Potion.Effect.t) ->
    Printf.printf "- **%s**: %s (%s)\n" e.name e.description e.duration)
;;

(* @mdexp

Applied to each recipe from the shared catalog, here is our full collection: *)

let%expect_test "elixir of type safety" =
  print_recipe Potion.elixir_of_type_safety;
  (* @mdexp.snapshot *)
  [%expect
    {|
    #### Elixir of Type Safety

    > *Grants the drinker the ability to see type errors before they happen. Side effects may include an irresistible urge to add type annotations everywhere.*

    Difficulty: Intermediate | Brewing time: 2 hours at 350°F (the temperature of a warm build)

    | Ingredient             | Quantity |
    |:-----------------------|---------:|
    | Strongly-Typed Herbs   | 3 sprigs |
    | Pattern-Match Petals   | 7 petals |
    | Compiler-Checked Roots | 15 grams |


    Effects:
    - **Type Safety Vision**: See type mismatches highlighted in red before compilation (8 hours)
    - **Exhaustive Intuition**: Instinctively know when a pattern match is incomplete (4 hours)
    |}]
;;

let%expect_test "fearless refactoring draught" =
  print_recipe Potion.fearless_refactoring_draught;
  (* @mdexp.snapshot *)
  [%expect
    {|
    #### Fearless Refactoring Draught

    > *Emboldens the drinker to restructure code without fear. Warning: may cause spontaneous renaming of variables to more descriptive names.*

    Difficulty: Advanced | Brewing time: 3 hours (stir every time a test passes)

    | Ingredient             |  Quantity |
    |:-----------------------|----------:|
    | Compiler-Checked Roots |  20 grams |
    | Test-Coverage Moss     | 5 patches |
    | Strongly-Typed Herbs   |  2 sprigs |


    Effects:
    - **Fearless Refactoring**: Restructure code with complete confidence that nothing will break (6 hours)
    - **Dependency Clarity**: See the full dependency graph of any function at a glance (3 hours)
    |}]
;;

let%expect_test "documentation dew" =
  print_recipe Potion.documentation_dew;
  (* @mdexp.snapshot *)
  [%expect
    {|
    #### Documentation Dew

    > *Ensures that documentation never drifts from reality. Brewed exclusively from mdexp-powered sources.*

    Difficulty: Beginner | Brewing time: 1 hour (must be brewed during a successful build)

    | Ingredient                  |  Quantity |
    |:----------------------------|----------:|
    | Fresh mdexp Extract         |   5 drops |
    | Literate-Programming Lichen |  10 grams |
    | Test-Coverage Moss          | 3 patches |


    Effects:
    - **Living Documentation**: All documentation you write automatically stays in sync with the code (Until next build)
    - **Snapshot Sight**: Instantly see when expected output has drifted from actual output (12 hours)
    |}]
;;

let%expect_test "homebrew tonic" =
  print_recipe Potion.homebrew_tonic;
  (* @mdexp.snapshot *)
  [%expect
    {|
    #### Homebrew Tonic

    > *Lets you install anything with a single tap. Not to be confused with actual homebrew, though the formula is similar.*

    Difficulty: Beginner | Brewing time: 45 minutes (brew in a clean environment)

    | Ingredient          | Quantity |
    |:--------------------|---------:|
    | Formulaic Fungi     |   4 caps |
    | Cask-Aged Oak Bark  | 6 strips |
    | Fresh mdexp Extract |  2 drops |


    Effects:
    - **One-Tap Install**: Install any tool with a single command — no dependency hell (Permanent (until next OS upgrade))
    - **Formula Intuition**: Instinctively know the right flags for any CLI tool (8 hours)
    |}]
;;

(* @mdexp

### Generating Configuration Files

The same values that produced the recipe book above can also generate
structured configuration files. A small OCaml executable
(`generate_config.ml`) consumes the `Potion` module and produces JSON
manifests. Dune rules call this executable to materialize `ingredients.json`
and `recipes.json` as actual files alongside this tutorial.

Here is a preview of what they contain:

#### Ingredients Manifest *)

let print_json_details ~filename json =
  print_endline "<details>";
  Printf.printf "<summary>%s</summary>\n" filename;
  print_endline "";
  print_endline "```json";
  print_endline (Yojson.Basic.pretty_to_string json);
  print_endline "```";
  print_endline "";
  print_endline "</details>"
;;

let%expect_test "ingredients manifest (JSON)" =
  `Assoc
    [ "ingredients", `List (List.map Potion.all_ingredients ~f:Potion.Ingredient.to_json)
    ]
  |> print_json_details ~filename:"ingredients.json";
  (* @mdexp.snapshot *)
  [%expect
    {|
    <details>
    <summary>ingredients.json</summary>

    ```json
    {
      "ingredients": [
        {
          "name": "Strongly-Typed Herbs",
          "category": "Flora",
          "potency": 8,
          "unit": "sprigs",
          "notes": "Must be freshly picked from a well-typed garden"
        },
        {
          "name": "Pattern-Match Petals",
          "category": "Flora",
          "potency": 7,
          "unit": "petals",
          "notes": "Each petal covers one variant — ensure exhaustive collection"
        },
        {
          "name": "Compiler-Checked Roots",
          "category": "Underground",
          "potency": 9,
          "unit": "grams",
          "notes": "Will not dissolve if the solution contains errors"
        },
        {
          "name": "Test-Coverage Moss",
          "category": "Flora",
          "potency": 6,
          "unit": "patches",
          "notes": "Grows thicker in well-tested environments"
        },
        {
          "name": "Fresh mdexp Extract",
          "category": "Distilled",
          "potency": 10,
          "unit": "drops",
          "notes": "Extracted from literate programs at build time"
        },
        {
          "name": "Literate-Programming Lichen",
          "category": "Flora",
          "potency": 7,
          "unit": "grams",
          "notes": "Found growing on well-documented codebases"
        },
        {
          "name": "Formulaic Fungi",
          "category": "Mycology",
          "potency": 5,
          "unit": "caps",
          "notes": "Thrives in formulaic environments — pairs well with taps"
        },
        {
          "name": "Cask-Aged Oak Bark",
          "category": "Arboreal",
          "potency": 4,
          "unit": "strips",
          "notes": "Aged in casks for at least one major version cycle"
        }
      ]
    }
    ```

    </details> |}]
;;

(* @mdexp #### Recipes Manifest *)

let%expect_test "recipes manifest (JSON)" =
  `Assoc [ "recipes", `List (List.map Potion.all_recipes ~f:Potion.Recipe.to_json) ]
  |> print_json_details ~filename:"recipes.json";
  (* @mdexp.snapshot *)
  [%expect
    {|
    <details>
    <summary>recipes.json</summary>

    ```json
    {
      "recipes": [
        {
          "name": "Elixir of Type Safety",
          "description": "Grants the drinker the ability to see type errors before they happen. Side effects may include an irresistible urge to add type annotations everywhere.",
          "ingredients": [
            { "name": "Strongly-Typed Herbs", "quantity": 3.0, "unit": "sprigs" },
            { "name": "Pattern-Match Petals", "quantity": 7.0, "unit": "petals" },
            {
              "name": "Compiler-Checked Roots",
              "quantity": 15.0,
              "unit": "grams"
            }
          ],
          "effects": [
            {
              "name": "Type Safety Vision",
              "description": "See type mismatches highlighted in red before compilation",
              "duration": "8 hours"
            },
            {
              "name": "Exhaustive Intuition",
              "description": "Instinctively know when a pattern match is incomplete",
              "duration": "4 hours"
            }
          ],
          "brewing_time": "2 hours at 350°F (the temperature of a warm build)",
          "difficulty": "Intermediate"
        },
        {
          "name": "Fearless Refactoring Draught",
          "description": "Emboldens the drinker to restructure code without fear. Warning: may cause spontaneous renaming of variables to more descriptive names.",
          "ingredients": [
            {
              "name": "Compiler-Checked Roots",
              "quantity": 20.0,
              "unit": "grams"
            },
            { "name": "Test-Coverage Moss", "quantity": 5.0, "unit": "patches" },
            { "name": "Strongly-Typed Herbs", "quantity": 2.0, "unit": "sprigs" }
          ],
          "effects": [
            {
              "name": "Fearless Refactoring",
              "description": "Restructure code with complete confidence that nothing will break",
              "duration": "6 hours"
            },
            {
              "name": "Dependency Clarity",
              "description": "See the full dependency graph of any function at a glance",
              "duration": "3 hours"
            }
          ],
          "brewing_time": "3 hours (stir every time a test passes)",
          "difficulty": "Advanced"
        },
        {
          "name": "Documentation Dew",
          "description": "Ensures that documentation never drifts from reality. Brewed exclusively from mdexp-powered sources.",
          "ingredients": [
            { "name": "Fresh mdexp Extract", "quantity": 5.0, "unit": "drops" },
            {
              "name": "Literate-Programming Lichen",
              "quantity": 10.0,
              "unit": "grams"
            },
            { "name": "Test-Coverage Moss", "quantity": 3.0, "unit": "patches" }
          ],
          "effects": [
            {
              "name": "Living Documentation",
              "description": "All documentation you write automatically stays in sync with the code",
              "duration": "Until next build"
            },
            {
              "name": "Snapshot Sight",
              "description": "Instantly see when expected output has drifted from actual output",
              "duration": "12 hours"
            }
          ],
          "brewing_time": "1 hour (must be brewed during a successful build)",
          "difficulty": "Beginner"
        },
        {
          "name": "Homebrew Tonic",
          "description": "Lets you install anything with a single tap. Not to be confused with actual homebrew, though the formula is similar.",
          "ingredients": [
            { "name": "Formulaic Fungi", "quantity": 4.0, "unit": "caps" },
            { "name": "Cask-Aged Oak Bark", "quantity": 6.0, "unit": "strips" },
            { "name": "Fresh mdexp Extract", "quantity": 2.0, "unit": "drops" }
          ],
          "effects": [
            {
              "name": "One-Tap Install",
              "description": "Install any tool with a single command — no dependency hell",
              "duration": "Permanent (until next OS upgrade)"
            },
            {
              "name": "Formula Intuition",
              "description": "Instinctively know the right flags for any CLI tool",
              "duration": "8 hours"
            }
          ],
          "brewing_time": "45 minutes (brew in a clean environment)",
          "difficulty": "Beginner"
        }
      ]
    }
    ```

    </details> |}]
;;

(* @mdexp

## How It Works

The key insight is that both outputs — this tutorial page and the JSON
manifests — are generated from the same `Potion` module. The types and
values are defined once, and the build ensures that everything stays in sync:

1. **Shared values** (`potion.ml`): Defines `Ingredient.t`, `Effect.t`, and
   `Recipe.t` with both display and serialization functions, and all the
   ingredient and recipe values used throughout.

2. **This document** (`potion_brewery.ml`): Uses mdexp directives to produce
   the tutorial page, with `ppx_expect` snapshots rendering tables and JSON
   inline.

3. **Config generator** (`generate_config.ml`): A small executable that
   consumes the same `Potion` module to produce `ingredients.json` and
   `recipes.json` as standalone files.

4. **Dune rules**: Wire `mdexp pp` to generate the markdown page, run
   the generator to produce JSON files, and use `diff` rules to verify
   all outputs are up to date.

If someone adds a new ingredient or changes a recipe, the build will catch
any inconsistency — the tables, the JSON, and the values all move together.

## Try It Yourself

To experiment with this tutorial:

```bash
# Build and run the tests
dune runtest

# If snapshots need updating after a change
dune runtest --auto-promote

# Generate just the markdown output
dune exec mdexp -- pp doc/content/tutorials/potion-brewery/potion_brewery.ml
```

Happy brewing! *)
