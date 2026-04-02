(***************************************************************************************)
(*  mdexp-stdlib - Extending OCaml's Stdlib for Mdexp                                  *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>        *)
(*  SPDX-License-Identifier: MIT OR LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(***************************************************************************************)

module Array = Array0
module Char = Char0
module Code_error = Code_error0
module Command = Command0
module Dyn = Dyn0
module Err = Err0
module Exn = Exn0
module Fpath = Fpath0
module In_channel = In_channel0
module List = List0
module Loc = Loc0
module Option = Option0
module Ordering = Ordering0
module Out_channel = Out_channel0
module Pp = Pp0
module Pp_tty = Pp_tty0
module Sexp = Sexp0
module String = String0

let phys_equal = ( == )
let ( == ) = `Use_phys_equal_instead
let print pp = Format.printf "%a@." Pp.to_fmt pp
let print_dyn dyn = print (Dyn.pp dyn)

module With_equal_and_dyn = With_equal_and_dyn0

let require cond = if not cond then Code_error.raise "Require failed." []

let require_does_raise f =
  match f () with
  | _ -> Code_error.raise "Did not raise." []
  | exception e -> print_endline (Printexc.to_string e)
;;

let require_equal
      (type a)
      (module M : With_equal_and_dyn.S with type t = a)
      (v1 : a)
      (v2 : a)
  =
  if not (M.equal v1 v2)
  then Code_error.raise "Values are not equal." [ "v1", M.to_dyn v1; "v2", M.to_dyn v2 ]
;;
