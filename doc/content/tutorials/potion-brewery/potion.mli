(*_********************************************************************************)
(*_  mdexp - Literate Programming with Embedded Snapshots                         *)
(*_  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

module Ingredient : sig
  type t =
    { name : string
    ; category : string
    ; potency : int
    ; unit : string
    ; notes : string
    }

  val to_json : t -> Yojson.Basic.t
end

module Effect : sig
  type t =
    { name : string
    ; description : string
    ; duration : string
    }

  val to_json : t -> Yojson.Basic.t
end

module Recipe : sig
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

  val to_json : t -> Yojson.Basic.t
end

val all_ingredients : Ingredient.t list
val all_recipes : Recipe.t list
val elixir_of_type_safety : Recipe.t
val fearless_refactoring_draught : Recipe.t
val documentation_dew : Recipe.t
val homebrew_tonic : Recipe.t
