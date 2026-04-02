(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

type t =
  { snapshot : Snapshot_config.t
  ; code : Code_config.t
  }

let fields_spec = [ "snapshot", `Snapshot; "code", `Code ]
let known_fields = List.map fields_spec ~f:fst

let classify_field key =
  match List.assoc_opt key fields_spec with
  | Some ((`Snapshot | `Code) as known) -> known
  | None -> `Unknown
;;

let of_located_json ~inherited (lj : Located_json.t) =
  let fields = Json_object.fields (Located_json.json lj) in
  let snapshot = ref inherited.snapshot in
  let code = ref inherited.code in
  List.iter fields ~f:(fun (key, value) ->
    match classify_field key with
    | `Unknown ->
      Err.error
        ?loc:(Located_json.key_loc lj key)
        ~hints:(Err.did_you_mean key ~candidates:known_fields)
        Pp.O.
          [ Pp.text "Unknown field "
            ++ Pp_tty.id (module String) key
            ++ Pp.text " in configuration."
          ]
    | `Snapshot ->
      (match value with
       | `Assoc _ as snapshot_json ->
         snapshot
         := Snapshot_config.of_located_json
              ~inherited:!snapshot
              (Located_json.with_json lj snapshot_json)
       | _ ->
         Err.error
           ?loc:(Located_json.value_loc lj value)
           Pp.O.
             [ Pp.text "Field "
               ++ Pp_tty.id (module String) "snapshot"
               ++ Pp.text " expects an object value."
             ])
    | `Code ->
      (match value with
       | `Assoc _ as code_json ->
         code
         := Code_config.of_located_json
              ~inherited:!code
              (Located_json.with_json lj code_json)
       | _ ->
         Err.error
           ?loc:(Located_json.value_loc lj value)
           Pp.O.
             [ Pp.text "Field "
               ++ Pp_tty.id (module String) "code"
               ++ Pp.text " expects an object value."
             ]));
  { snapshot = !snapshot; code = !code }
;;
