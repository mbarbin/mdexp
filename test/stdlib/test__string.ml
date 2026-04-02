(***************************************************************************************)
(*  mdexp-stdlib - Extending OCaml's Stdlib for Mdexp                                  *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>        *)
(*  SPDX-License-Identifier: MIT OR LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(***************************************************************************************)

let%expect_test "to_string" =
  let test s = Printf.printf "%S => %S\n" s (String.to_string s) in
  test "";
  test "hello";
  [%expect
    {|
    "" => ""
    "hello" => "hello"
    |}]
;;

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

let%expect_test "split_lines" =
  let test s =
    let lines = String.split_lines s in
    Printf.printf "%S => [%s]\n" s (String.concat lines ~sep:"; ")
  in
  test "";
  test "hello";
  test "hello\n";
  test "hello\nworld";
  test "hello\nworld\n";
  test "hello\r\nworld";
  test "hello\r\nworld\r\n";
  test "\r\n";
  [%expect
    {|
    "" => []
    "hello" => [hello]
    "hello\n" => [hello]
    "hello\nworld" => [hello; world]
    "hello\nworld\n" => [hello; world]
    "hello\r\nworld" => [hello; world]
    "hello\r\nworld\r\n" => [hello; world]
    "\r\n" => []
    |}]
;;

let%expect_test "ltrim and rtrim preserve identity when no trimming needed" =
  let s = "no_whitespace" in
  require (phys_equal (String.ltrim s) s);
  require (phys_equal (String.rtrim s) s);
  [%expect {||}]
;;
