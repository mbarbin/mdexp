(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

(** Shared types for the Potion Brewery tutorial. *)

module Ingredient = struct
  type t =
    { name : string
    ; category : string
    ; potency : int (** 1-10 scale *)
    ; unit : string
    ; notes : string
    }

  let to_json t =
    `Assoc
      [ "name", `String t.name
      ; "category", `String t.category
      ; "potency", `Int t.potency
      ; "unit", `String t.unit
      ; "notes", `String t.notes
      ]
  ;;
end

module Effect = struct
  type t =
    { name : string
    ; description : string
    ; duration : string
    }

  let to_json t =
    `Assoc
      [ "name", `String t.name
      ; "description", `String t.description
      ; "duration", `String t.duration
      ]
  ;;
end

module Recipe = struct
  type ingredient_entry =
    { ingredient : Ingredient.t
    ; quantity : float
    }

  type t =
    { name : string
    ; description : string
    ; ingredients : ingredient_entry list
    ; effects : Effect.t list
    ; brewing_time : string
    ; difficulty : string
    }

  let to_json t =
    `Assoc
      [ "name", `String t.name
      ; "description", `String t.description
      ; ( "ingredients"
        , `List
            (List.map t.ingredients ~f:(fun entry ->
               `Assoc
                 [ "name", `String entry.ingredient.name
                 ; "quantity", `Float entry.quantity
                 ; "unit", `String entry.ingredient.unit
                 ])) )
      ; "effects", `List (List.map t.effects ~f:Effect.to_json)
      ; "brewing_time", `String t.brewing_time
      ; "difficulty", `String t.difficulty
      ]
  ;;
end

(* --- The Brewery Catalog --- *)

let strongly_typed_herbs =
  Ingredient.
    { name = "Strongly-Typed Herbs"
    ; category = "Flora"
    ; potency = 8
    ; unit = "sprigs"
    ; notes = "Must be freshly picked from a well-typed garden"
    }
;;

let pattern_match_petals =
  Ingredient.
    { name = "Pattern-Match Petals"
    ; category = "Flora"
    ; potency = 7
    ; unit = "petals"
    ; notes = "Each petal covers one variant — ensure exhaustive collection"
    }
;;

let compiler_checked_roots =
  Ingredient.
    { name = "Compiler-Checked Roots"
    ; category = "Underground"
    ; potency = 9
    ; unit = "grams"
    ; notes = "Will not dissolve if the solution contains errors"
    }
;;

let test_coverage_moss =
  Ingredient.
    { name = "Test-Coverage Moss"
    ; category = "Flora"
    ; potency = 6
    ; unit = "patches"
    ; notes = "Grows thicker in well-tested environments"
    }
;;

let fresh_mdexp_extract =
  Ingredient.
    { name = "Fresh mdexp Extract"
    ; category = "Distilled"
    ; potency = 10
    ; unit = "drops"
    ; notes = "Extracted from literate programs at build time"
    }
;;

let literate_programming_lichen =
  Ingredient.
    { name = "Literate-Programming Lichen"
    ; category = "Flora"
    ; potency = 7
    ; unit = "grams"
    ; notes = "Found growing on well-documented codebases"
    }
;;

let formulaic_fungi =
  Ingredient.
    { name = "Formulaic Fungi"
    ; category = "Mycology"
    ; potency = 5
    ; unit = "caps"
    ; notes = "Thrives in formulaic environments — pairs well with taps"
    }
;;

let cask_aged_oak_bark =
  Ingredient.
    { name = "Cask-Aged Oak Bark"
    ; category = "Arboreal"
    ; potency = 4
    ; unit = "strips"
    ; notes = "Aged in casks for at least one major version cycle"
    }
;;

let all_ingredients =
  [ strongly_typed_herbs
  ; pattern_match_petals
  ; compiler_checked_roots
  ; test_coverage_moss
  ; fresh_mdexp_extract
  ; literate_programming_lichen
  ; formulaic_fungi
  ; cask_aged_oak_bark
  ]
;;

let elixir_of_type_safety =
  Recipe.
    { name = "Elixir of Type Safety"
    ; description =
        "Grants the drinker the ability to see type errors before they happen. Side \
         effects may include an irresistible urge to add type annotations everywhere."
    ; ingredients =
        [ { ingredient = strongly_typed_herbs; quantity = 3.0 }
        ; { ingredient = pattern_match_petals; quantity = 7.0 }
        ; { ingredient = compiler_checked_roots; quantity = 15.0 }
        ]
    ; effects =
        [ { Effect.name = "Type Safety Vision"
          ; description = "See type mismatches highlighted in red before compilation"
          ; duration = "8 hours"
          }
        ; { name = "Exhaustive Intuition"
          ; description = "Instinctively know when a pattern match is incomplete"
          ; duration = "4 hours"
          }
        ]
    ; brewing_time = "2 hours at 350°F (the temperature of a warm build)"
    ; difficulty = "Intermediate"
    }
;;

let fearless_refactoring_draught =
  Recipe.
    { name = "Fearless Refactoring Draught"
    ; description =
        "Emboldens the drinker to restructure code without fear. Warning: may cause \
         spontaneous renaming of variables to more descriptive names."
    ; ingredients =
        [ { ingredient = compiler_checked_roots; quantity = 20.0 }
        ; { ingredient = test_coverage_moss; quantity = 5.0 }
        ; { ingredient = strongly_typed_herbs; quantity = 2.0 }
        ]
    ; effects =
        [ { Effect.name = "Fearless Refactoring"
          ; description =
              "Restructure code with complete confidence that nothing will break"
          ; duration = "6 hours"
          }
        ; { name = "Dependency Clarity"
          ; description = "See the full dependency graph of any function at a glance"
          ; duration = "3 hours"
          }
        ]
    ; brewing_time = "3 hours (stir every time a test passes)"
    ; difficulty = "Advanced"
    }
;;

let documentation_dew =
  Recipe.
    { name = "Documentation Dew"
    ; description =
        "Ensures that documentation never drifts from reality. Brewed exclusively from \
         mdexp-powered sources."
    ; ingredients =
        [ { ingredient = fresh_mdexp_extract; quantity = 5.0 }
        ; { ingredient = literate_programming_lichen; quantity = 10.0 }
        ; { ingredient = test_coverage_moss; quantity = 3.0 }
        ]
    ; effects =
        [ { Effect.name = "Living Documentation"
          ; description =
              "All documentation you write automatically stays in sync with the code"
          ; duration = "Until next build"
          }
        ; { name = "Snapshot Sight"
          ; description =
              "Instantly see when expected output has drifted from actual output"
          ; duration = "12 hours"
          }
        ]
    ; brewing_time = "1 hour (must be brewed during a successful build)"
    ; difficulty = "Beginner"
    }
;;

let homebrew_tonic =
  Recipe.
    { name = "Homebrew Tonic"
    ; description =
        "Lets you install anything with a single tap. Not to be confused with actual \
         homebrew, though the formula is similar."
    ; ingredients =
        [ { ingredient = formulaic_fungi; quantity = 4.0 }
        ; { ingredient = cask_aged_oak_bark; quantity = 6.0 }
        ; { ingredient = fresh_mdexp_extract; quantity = 2.0 }
        ]
    ; effects =
        [ { Effect.name = "One-Tap Install"
          ; description = "Install any tool with a single command — no dependency hell"
          ; duration = "Permanent (until next OS upgrade)"
          }
        ; { name = "Formula Intuition"
          ; description = "Instinctively know the right flags for any CLI tool"
          ; duration = "8 hours"
          }
        ]
    ; brewing_time = "45 minutes (brew in a clean environment)"
    ; difficulty = "Beginner"
    }
;;

let all_recipes =
  [ elixir_of_type_safety
  ; fearless_refactoring_draught
  ; documentation_dew
  ; homebrew_tonic
  ]
;;
