(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

type t =
  | Prose
  | Code
  | End
  | Snapshot
  | Config

let all = [ Prose; Code; End; Snapshot; Config ]

let to_variant_constructor_name = function
  | Prose -> "Prose"
  | Code -> "Code"
  | End -> "End"
  | Snapshot -> "Snapshot"
  | Config -> "Config"
;;

let to_lowercase_syntax t = String.lowercase_ascii (to_variant_constructor_name t)

let to_dyn = function
  | (Prose | Code | End | Snapshot | Config) as t ->
    Dyn.variant (to_variant_constructor_name t) []
;;

module With_trailing = struct
  type nonrec t =
    { directive : t
    ; trailing : string option
    ; loc : Loc.t
    }

  let to_dyn { directive; trailing; loc } =
    Dyn.record
      [ "directive", to_dyn directive
      ; "trailing", Dyn.option Dyn.string trailing
      ; "loc", Loc.to_dyn loc
      ]
  ;;
end

let trailing_of_rest rest =
  let trimmed = String.ltrim rest in
  if String.is_empty trimmed then None else Some trimmed
;;

let compute_loc ~file_cache ~line ~col ~leading_ws ~len =
  let line_loc = Loc.of_file_line ~file_cache ~line in
  let line_start = Loc.start_offset line_loc in
  let start = line_start + col + leading_ws in
  let stop = start + len in
  Loc.of_file_range ~file_cache ~range:{ start; stop }
;;

let make ~loc directive rest =
  Some { With_trailing.directive; trailing = trailing_of_rest rest; loc }
;;

let dot_assoc = lazy (List.map all ~f:(fun t -> t, "." ^ to_lowercase_syntax t))

let parse_line ~content ~file_cache ~line ~col =
  let ltrimmed = String.ltrim content in
  let leading_ws = String.length content - String.length ltrimmed in
  let trimmed = String.rtrim ltrimmed in
  let loc = compute_loc ~file_cache ~line ~col ~leading_ws ~len:(String.length trimmed) in
  match String.chop_prefix trimmed ~prefix:"@mdexp" with
  | None -> None
  | Some rest ->
    if String.length rest = 0 || Char.is_whitespace rest.[0]
    then make ~loc Prose rest
    else
      List.find_map (Lazy.force dot_assoc) ~f:(fun (directive, dot_dir) ->
        match String.chop_prefix rest ~prefix:dot_dir with
        | Some rest -> make ~loc directive rest
        | None -> None)
;;
