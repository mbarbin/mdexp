(***************************************************************************************)
(*  mdexp-stdlib - Extending OCaml's Stdlib for Mdexp                                  *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>        *)
(*  SPDX-License-Identifier: MIT OR LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(***************************************************************************************)

include Stdlib.In_channel

let read_all path =
  let ic = open_in path in
  Fun.protect ~finally:(fun () -> close_in ic) (fun () -> In_channel.input_all ic)
;;
