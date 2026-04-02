(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

type t = { lang : Markdown_lang_id.t option }

let equal a b =
  phys_equal a b
  ||
  let { lang } = a in
  Option.equal Markdown_lang_id.equal lang b.lang
;;

let to_dyn { lang } = Dyn.record [ "lang", Dyn.option Markdown_lang_id.to_dyn lang ]
let default = { lang = None }
let fields_spec = [ "lang", `Lang ]
let known_fields = List.map fields_spec ~f:fst

let classify_field key =
  match List.assoc_opt key fields_spec with
  | Some (`Lang as known) -> known
  | None -> `Unknown
;;

let of_located_json ~inherited (lj : Located_json.t) =
  let fields = Json_object.fields (Located_json.json lj) in
  let lang = ref inherited.lang in
  List.iter fields ~f:(fun (key, value) ->
    match classify_field key with
    | `Unknown ->
      Err.error
        ?loc:(Located_json.key_loc lj key)
        ~hints:(Err.did_you_mean key ~candidates:known_fields)
        Pp.O.
          [ Pp.text "Unknown field "
            ++ Pp_tty.id (module String) key
            ++ Pp.text " in code configuration."
          ]
    | `Lang ->
      (match value with
       | `String s when not (String.is_empty s) ->
         lang := Some (Markdown_lang_id.of_string s)
       | _ ->
         Err.error
           ?loc:(Located_json.value_loc lj value)
           Pp.O.
             [ Pp.text "Field "
               ++ Pp_tty.id (module String) "lang"
               ++ Pp.text " expects a non-empty string value."
             ]));
  { lang = !lang }
;;
