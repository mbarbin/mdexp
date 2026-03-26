(*_********************************************************************************)
(*_  mdexp - Literate Programming with Embedded Snapshots                         *)
(*_  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

val trim_blank_lines : string list -> string list
val dedent_lines : first_line_is_inline:bool -> string list -> string list

val render_snapshot
  :  output:Buffer.t
  -> snapshot_config:Snapshot_config.t
  -> lines:string list
  -> unit
