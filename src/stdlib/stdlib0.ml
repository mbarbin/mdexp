(***************************************************************************************)
(*  mdexp-stdlib - Extending OCaml's Stdlib for Mdexp                                  *)
(*  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>                  *)
(*  SPDX-License-Identifier: MIT OR LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(***************************************************************************************)

module Char = Char0
module Command = Command0
module Dyn = Dyn0
module Err = Err0
module Fpath = Fpath0
module List = List0
module Loc = Loc0
module Option = Option0
module Ordering = Ordering0
module Pp = Pp0
module Pp_tty = Pp_tty0
module Sexp = Sexp0
module String = String0

let print pp = Format.printf "%a@." Pp.to_fmt pp
let print_dyn dyn = print (Dyn.pp dyn)
