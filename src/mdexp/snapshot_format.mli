(*_*******************************************************************************)
(*_  mdexp - Literate Programming with Embedded Snapshots                        *)
(*_  Copyright (C) 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>           *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception  *)
(*_*******************************************************************************)

(** Known snapshot string literal formats, partitioned by language.

    Each format corresponds to a distinct string literal syntax. Multiple
    expect-test frameworks may share the same format if they use the same
    underlying string literal (e.g., both [expect-test] and [insta] in Rust
    use regular or raw string literals; both [ppx_expect] and [windtrap] in
    OCaml use [{id|...|id}] block strings). *)

type t =
  | Ocaml_block_string (** [{id|...|id}] — ppx_expect, windtrap *)
  | Zig_multiline_string (** backslash-backslash-prefixed lines *)
  | Rust_string (** ["..."] and [r#"..."#] — expect-test, insta *)

val to_dyn : t -> Dyn.t
val for_host_language : Host_language.t -> t list
