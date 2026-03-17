(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

type t =
  { block : bool
  ; lang : Markdown_lang_id.t option
  }

let to_dyn { block; lang } =
  Dyn.record [ "block", Dyn.bool block; "lang", Dyn.option Markdown_lang_id.to_dyn lang ]
;;

let default = { block = false; lang = None }

let of_json ?(defaults = default) (json : Yojson.Basic.t) =
  match json with
  | `Assoc fields ->
    let block =
      match List.assoc_opt "block" fields with
      | Some (`Bool b) -> b
      | _ -> defaults.block
    in
    let lang =
      match List.assoc_opt "lang" fields with
      | Some (`String s) when not (String.is_empty s) ->
        Some (Markdown_lang_id.of_string s)
      | _ -> defaults.lang
    in
    let block = if Option.is_some lang then true else block in
    { block; lang }
  | _ -> defaults
;;

let known_fields = [ "block"; "lang" ]

let of_located_json ?(defaults = default) (lj : Located_json.t) =
  let json = Located_json.json lj in
  match json with
  | `Assoc fields ->
    List.iter fields ~f:(fun (key, value) ->
      let is_known =
        List.fold_left known_fields ~init:false ~f:(fun acc k ->
          acc || String.equal key k)
      in
      if not is_known
      then
        Err.error
          ?loc:(Located_json.key_loc lj key)
          ~hints:(Err.did_you_mean key ~candidates:known_fields)
          [ Pp.textf "Unknown field %S in snapshot configuration." key ]
      else (
        match key with
        | "block" ->
          (match value with
           | `Bool _ -> ()
           | _ ->
             Err.error
               ?loc:(Located_json.value_loc lj value)
               [ Pp.text "Field \"block\" expects a boolean value." ])
        | "lang" ->
          (match value with
           | `String _ -> ()
           | _ ->
             Err.error
               ?loc:(Located_json.value_loc lj value)
               [ Pp.text "Field \"lang\" expects a string value." ])
        | _ -> ()));
    of_json ~defaults json
  | _ -> defaults
;;
