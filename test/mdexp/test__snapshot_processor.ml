(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Snapshot_processor = Mdexp.Private.Snapshot_processor

let%expect_test "Action.to_dyn" =
  List.iter
    [ Snapshot_processor.Action.Consumed
    ; Done { lines = [ "hello"; "world" ] }
    ; Done_not_consumed { lines = [ "first" ] }
    ]
    ~f:(fun t -> print_dyn (Snapshot_processor.Action.to_dyn t));
  [%expect
    {|
    Consumed
    Done { lines = [ "hello"; "world" ] }
    Done_not_consumed { lines = [ "first" ] }
    |}]
;;

let%expect_test "Zig: End_not_consumed when line does not continue multiline string" =
  let t = Snapshot_processor.create ~snapshot_formats:[ Zig_multiline_string ] in
  let feed line =
    print_dyn (Snapshot_processor.Action.to_dyn (Snapshot_processor.feed t ~line))
  in
  feed {|    \\First line|};
  feed {|    \\Second line|};
  feed {|).diff(value);|};
  [%expect
    {|
    Consumed
    Consumed
    Done_not_consumed { lines = [ "First line"; "Second line" ] }
    |}]
;;
