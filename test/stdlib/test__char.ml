(***************************************************************************************)
(*  mdexp-stdlib - Extending OCaml's Stdlib for Mdexp                                  *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>        *)
(*  SPDX-License-Identifier: MIT OR LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(***************************************************************************************)

let%expect_test "is_whitespace" =
  let test c =
    if Char.is_whitespace c then Printf.printf "%S => true\n" (Char.escaped c)
  in
  (* Test all 256 chars, only print those that are whitespace. *)
  for i = 0 to 255 do
    test (Stdlib.Char.chr i)
  done;
  [%expect
    {|"\\t" => true
"\\n" => true
"\\011" => true
"\\012" => true
"\\r" => true
" " => true|}];
  (* Verify non-whitespace characters return false. *)
  List.iter [ 'a'; 'Z'; '0'; '!'; '@'; '\000'; '\255' ] ~f:(fun c ->
    assert (not (Char.is_whitespace c)));
  ()
;;
