(***************************************************************************************)
(*  mdexp-stdlib - Extending OCaml's Stdlib for Mdexp                                  *)
(*  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>                  *)
(*  SPDX-License-Identifier: MIT OR LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(***************************************************************************************)

module Char = Char0
include StringLabels

let to_string t = t
let equal = Stdlib.String.equal
let is_empty s = length s = 0
let concat l ~sep = Stdlib.StringLabels.concat ~sep l

let chop_prefix t ~prefix =
  if starts_with ~prefix t
  then (
    let prefix_len = length prefix in
    Some (sub t ~pos:prefix_len ~len:(length t - prefix_len)))
  else None
;;

let last_non_whitespace t =
  let rec loop i =
    if i < 0 then None else if Char.is_whitespace t.[i] then loop (i - 1) else Some i
  in
  loop (length t - 1)
;;

let first_non_whitespace t =
  let n = length t in
  let rec loop i =
    if i = n then None else if Char.is_whitespace t.[i] then loop (i + 1) else Some i
  in
  loop 0
;;

let rtrim t =
  match last_non_whitespace t with
  | None -> ""
  | Some i -> if i = length t - 1 then t else sub t ~pos:0 ~len:(i + 1)
;;

let ltrim t =
  match first_non_whitespace t with
  | None -> ""
  | Some 0 -> t
  | Some n -> sub t ~pos:n ~len:(length t - n)
;;

(* ---------------------------------------------------------------------------- *)

(* [split_lines] is copied from [Base] version [v0.17] which is released under
   MIT and may be found at [https://github.com/janestreet/base]. See
   [third-party-license/janestreet/base/LICENSE.md] for licensing information. *)

let split_lines =
  let back_up_at_newline ~t ~pos ~eol =
    pos := !pos - if !pos > 0 && Char.equal t.[!pos - 1] '\r' then 2 else 1;
    eol := !pos + 1
  in
  fun t ->
    let n = length t in
    if n = 0
    then []
    else (
      (* Invariant: [-1 <= pos < eol]. *)
      let pos = ref (n - 1) in
      let eol = ref n in
      let ac = ref [] in
      (* We treat the end of the string specially, because if the string ends with a
         newline, we don't want an extra empty string at the end of the output. *)
      if Char.equal t.[!pos] '\n' then back_up_at_newline ~t ~pos ~eol;
      while !pos >= 0 do
        if not (Char.equal t.[!pos] '\n')
        then decr pos
        else (
          (* Because [pos < eol], we know that [start <= eol]. *)
          let start = !pos + 1 in
          ac := sub t ~pos:start ~len:(!eol - start) :: !ac;
          back_up_at_newline ~t ~pos ~eol)
      done;
      sub t ~pos:0 ~len:!eol :: !ac)
;;

(* ---------------------------------------------------------------------------- *)
