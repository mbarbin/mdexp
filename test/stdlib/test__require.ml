(***************************************************************************************)
(*  mdexp-stdlib - Extending OCaml's Stdlib for Mdexp                                  *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>        *)
(*  SPDX-License-Identifier: MIT OR LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(***************************************************************************************)

let%expect_test "require - passing" =
  require true;
  [%expect {||}]
;;

let%expect_test "require - failing" =
  require_does_raise (fun () -> require false);
  [%expect {| ("Require failed.", {}) |}]
;;

let%expect_test "require_does_raise - function that raises" =
  require_does_raise (fun () -> failwith "boom");
  [%expect {| Failure("boom") |}]
;;

let%expect_test "require_does_raise - function that does not raise" =
  require_does_raise (fun () -> require_does_raise (fun () -> ()));
  [%expect {| ("Did not raise.", {}) |}]
;;

module Int_with_dyn = struct
  type t = int

  let equal = Int.equal
  let to_dyn = Dyn.int
end

let%expect_test "require_equal - equal values" =
  require_equal (module Int_with_dyn) 42 42;
  [%expect {||}]
;;

let%expect_test "require_equal - unequal values" =
  require_does_raise (fun () -> require_equal (module Int_with_dyn) 1 2);
  [%expect {| ("Values are not equal.", { v1 = 1; v2 = 2 }) |}]
;;
