(*_**************************************************************************************)
(*_  mdexp-stdlib - Extending OCaml's Stdlib for Mdexp                                  *)
(*_  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>        *)
(*_  SPDX-License-Identifier: MIT OR LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(*_**************************************************************************************)

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

val phys_equal : 'a -> 'a -> bool
val print_dyn : Dyn.t -> unit

module With_equal_and_dyn = With_equal_and_dyn0

(** [require cond] raises if [cond] is false. *)
val require : bool -> unit

(** [require_does_raise f] raises if [f ()] does not raise, and prints the
    exception if it does. *)
val require_does_raise : (unit -> 'a) -> unit

(** [require_equal (module M) v1 v2] raises if [v1] and [v2] are not equal. *)
val require_equal : (module With_equal_and_dyn.S with type t = 'a) -> 'a -> 'a -> unit

val ( == ) : [> `Use_phys_equal_instead ]
[@@ocaml.deprecated "[since 2026-04] Use [phys_equal] instead"]
