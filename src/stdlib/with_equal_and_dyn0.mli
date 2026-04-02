(*_**************************************************************************************)
(*_  mdexp-stdlib - Extending OCaml's Stdlib for Mdexp                                  *)
(*_  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>        *)
(*_  SPDX-License-Identifier: MIT OR LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(*_**************************************************************************************)

module type S = sig
  type t

  val equal : t -> t -> bool
  val to_dyn : t -> Dyn.t
end
