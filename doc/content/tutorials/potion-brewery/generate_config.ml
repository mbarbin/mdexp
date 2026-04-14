(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

(** A small generator that produces JSON config files from the shared
    [Potion] module. Called by dune rules to materialize configuration
    alongside the tutorial documentation. *)

open Potion_brewery_tutorial

let ingredients_cmd =
  Command.make
    ~summary:"Generate the ingredients catalog (JSON)"
    (let open Command.Std in
     let+ () = Arg.return () in
     let json =
       `Assoc
         [ ( "ingredients"
           , `List (List.map Potion.all_ingredients ~f:Potion.Ingredient.to_json) )
         ]
     in
     print_endline (Yojson.Basic.pretty_to_string json))
;;

let recipes_cmd =
  Command.make
    ~summary:"Generate the recipes manifest (JSON)"
    (let open Command.Std in
     let+ () = Arg.return () in
     let json =
       `Assoc [ "recipes", `List (List.map Potion.all_recipes ~f:Potion.Recipe.to_json) ]
     in
     print_endline (Yojson.Basic.pretty_to_string json))
;;

let main =
  Command.group
    ~summary:"Generate Potion Brewery configuration files"
    [ "ingredients", ingredients_cmd; "recipes", recipes_cmd ]
;;

let () = Cmdlang_cmdliner_err_runner.run main ~name:"generate_config" ~version:"dev"
