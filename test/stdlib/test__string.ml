(***************************************************************************************)
(*  mdexp-stdlib - Extending OCaml's Stdlib for Mdexp                                  *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>        *)
(*  SPDX-License-Identifier: MIT OR LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(***************************************************************************************)

let%expect_test "equal" =
  let test a b = Printf.printf "%S = %S => %b\n" a b (String.equal a b) in
  test "" "";
  test "abc" "abc";
  test "abc" "abd";
  test "abc" "ab";
  test "" "a";
  [%expect
    {|
    "" = "" => true
    "abc" = "abc" => true
    "abc" = "abd" => false
    "abc" = "ab" => false
    "" = "a" => false
    |}]
;;

let%expect_test "ltrim" =
  let test s = Printf.printf "%S => %S\n" s (String.ltrim s) in
  test "";
  test "   ";
  test "hello";
  test "  hello";
  test "  hello  ";
  test "\t\n hello";
  test "hello  ";
  [%expect
    {|
    "" => ""
    "   " => ""
    "hello" => "hello"
    "  hello" => "hello"
    "  hello  " => "hello  "
    "\t\n hello" => "hello"
    "hello  " => "hello  "
    |}]
;;

let%expect_test "rtrim" =
  let test s = Printf.printf "%S => %S\n" s (String.rtrim s) in
  test "";
  test "   ";
  test "hello";
  test "hello  ";
  test "  hello  ";
  test "hello \t\n";
  test "  hello";
  [%expect
    {|
    "" => ""
    "   " => ""
    "hello" => "hello"
    "hello  " => "hello"
    "  hello  " => "  hello"
    "hello \t\n" => "hello"
    "  hello" => "  hello"
    |}]
;;

let%expect_test "ltrim and rtrim preserve identity when no trimming needed" =
  let s = "no_whitespace" in
  assert (String.ltrim s == s);
  assert (String.rtrim s == s);
  [%expect {||}]
;;
