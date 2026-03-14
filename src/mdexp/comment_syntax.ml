(********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                        *)
(*  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(********************************************************************************)

module Block = struct
  type t =
    { start_ : string
    ; end_ : string
    }

  let to_dyn { start_; end_ } =
    Dyn.record [ "start_", Dyn.string start_; "end_", Dyn.string end_ ]
  ;;
end

type t =
  { line_prefix : string option
  ; block : Block.t option
  }

let to_dyn { line_prefix; block } =
  Dyn.record
    [ "line_prefix", Dyn.option Dyn.string line_prefix
    ; "block", Dyn.option Block.to_dyn block
    ]
;;

let of_host_language : Host_language.t -> t = function
  | Ocaml -> { line_prefix = None; block = Some { start_ = "(*"; end_ = "*)" } }
  | Rust -> { line_prefix = Some "//"; block = Some { start_ = "/*"; end_ = "*/" } }
  | Zig -> { line_prefix = Some "//"; block = None }
;;
