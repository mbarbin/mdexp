(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Action = struct
  type t =
    | Skip
    | Continue of { content : string }
    | Done of { content : string }
    | End_not_consumed
end

module type S = sig
  type t

  val feed : t -> line:string -> Action.t
end
