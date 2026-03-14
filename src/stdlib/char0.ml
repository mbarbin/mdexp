(***************************************************************************************)
(*  mdexp-stdlib - Extending OCaml's Stdlib for Mdexp                                  *)
(*  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>                  *)
(*  SPDX-License-Identifier: MIT OR LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(***************************************************************************************)

(* Some functions are copied from [Base] version [v0.17] which is released under
   MIT and may be found at [https://github.com/janestreet/base]. See
   [third-party-license/janestreet/base/LICENSE.md] for licensing information.

   When this is the case, we clearly indicate it next to the copied function. *)

include Stdlib.Char

(* [is_whitespace] is copied from [Base] (MIT). *)
let is_whitespace = function
  | '\t' | '\n' | '\011' (* vertical tab *) | '\012' (* form feed *) | '\r' | ' ' -> true
  | _ -> false
;;
