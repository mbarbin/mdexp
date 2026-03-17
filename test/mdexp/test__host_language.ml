(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "of_file_extension" =
  List.iter [ "ml"; "mli"; "rs"; "zig"; "py"; "txt"; "" ] ~f:(fun ext ->
    print_dyn
      (Dyn.record
         [ "file_extension", Dyn.string ext
         ; ( "host_language"
           , Dyn.option Host_language.to_dyn (Host_language.of_file_extension ext) )
         ]));
  [%expect
    {|{ file_extension = "ml"; host_language = Some Ocaml }
{ file_extension = "mli"; host_language = Some Ocaml }
{ file_extension = "rs"; host_language = Some Rust }
{ file_extension = "zig"; host_language = Some Zig }
{ file_extension = "py"; host_language = None }
{ file_extension = "txt"; host_language = None }
{ file_extension = ""; host_language = None }|}];
  ()
;;
