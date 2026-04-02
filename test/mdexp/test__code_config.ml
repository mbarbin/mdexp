(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Code_config = Mdexp.Private.Code_config

let%expect_test "to_dyn" =
  print_dyn (Code_config.to_dyn { lang = None });
  print_dyn (Code_config.to_dyn { lang = Some (Markdown_lang_id.of_string "bash") });
  [%expect
    {|
    { lang = None }
    { lang = Some "bash" }
    |}]
;;

let%expect_test "equal" =
  let a = Code_config.default in
  let b = { Code_config.lang = Some (Markdown_lang_id.of_string "bash") } in
  require (Code_config.equal a a);
  require (not (Code_config.equal a b));
  require_equal (module Code_config) a { lang = None };
  [%expect {||}]
;;
