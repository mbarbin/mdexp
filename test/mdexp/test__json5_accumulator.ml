(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Json5_accumulator = Mdexp.Private.Json5_accumulator

let feed acc line =
  Json5_accumulator.feed acc ~file_offset:0 ~line
  |> Json5_accumulator.Action.to_dyn
  |> print_dyn
;;

let%expect_test "simple object on one line" =
  let acc = Json5_accumulator.create () in
  feed acc {|{ "key": "value" }|};
  [%expect {|Done "{ \"key\": \"value\" }"|}]
;;

let%expect_test "multi-line object" =
  let acc = Json5_accumulator.create () in
  feed acc {|{ "key": "value"|};
  [%expect {|Need_more|}];
  feed acc {|, "num": 42 }|};
  [%expect
    {|Done "{ \"key\": \"value\"\n\
      , \"num\": 42 }"|}]
;;

let%expect_test "handles quoted braces" =
  let acc = Json5_accumulator.create () in
  feed acc {|{ "pat": "a{b}c" }|};
  [%expect {|Done "{ \"pat\": \"a{b}c\" }"|}]
;;

let%expect_test "handles escaped quotes" =
  let acc = Json5_accumulator.create () in
  feed acc {|{ "val": "he said \"hi\"" }|};
  [%expect {|Done "{ \"val\": \"he said \\\"hi\\\"\" }"|}]
;;

let%expect_test "nested objects" =
  let acc = Json5_accumulator.create () in
  feed acc {|{ "a": { "b": 1 } }|};
  [%expect {|Done "{ \"a\": { \"b\": 1 } }"|}]
;;

let%expect_test "leading whitespace before {" =
  let acc = Json5_accumulator.create () in
  feed acc {|   { "x": 1 }|};
  [%expect {|Done "{ \"x\": 1 }"|}]
;;

let%expect_test "error on non-brace start" =
  let acc = Json5_accumulator.create () in
  feed acc "not json";
  [%expect {|Error|}]
;;

let%expect_test "single-quoted strings" =
  let acc = Json5_accumulator.create () in
  feed acc {|{ 'key': 'val{ue}' }|};
  [%expect {|Done "{ 'key': 'val{ue}' }"|}]
;;
