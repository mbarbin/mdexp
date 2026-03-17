(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Parser = struct
  type t =
    | T :
        { state : 'a
        ; m : (module Snapshot_parser.S with type t = 'a)
        }
        -> t

  let feed (T { state; m }) ~line =
    let module M = (val m) in
    M.feed state ~line
  ;;

  let create ~snapshot_format =
    match (snapshot_format : Snapshot_format.t) with
    | Ocaml_block_string ->
      let module M = Ocaml_block_string_processor in
      T { state = M.create (); m = (module M) }
    | Zig_multiline_string ->
      let module M = Zig_multiline_string_processor in
      T { state = M.create (); m = (module M) }
    | Rust_string ->
      let module M = Rust_string_processor in
      T { state = M.create (); m = (module M) }
  ;;
end

module Phase = struct
  type t =
    | Searching of { candidates : Parser.t list }
    | Committed of { parser : Parser.t }
end

type t =
  { mutable phase : Phase.t
  ; mutable buffer : string list
  }

module Action = struct
  type t =
    | Consumed
    | Done of { lines : string list }
    | Done_not_consumed of { lines : string list }

  let to_dyn = function
    | Consumed -> Dyn.variant "Consumed" []
    | Done { lines } ->
      Dyn.variant "Done" [ Dyn.record [ "lines", lines |> Dyn.list Dyn.string ] ]
    | Done_not_consumed { lines } ->
      Dyn.variant
        "Done_not_consumed"
        [ Dyn.record [ "lines", lines |> Dyn.list Dyn.string ] ]
  ;;
end

let create ~snapshot_formats =
  let candidates =
    List.map snapshot_formats ~f:(fun snapshot_format -> Parser.create ~snapshot_format)
  in
  { phase = Searching { candidates }; buffer = [] }
;;

let feed_committed t ~parser ~line : Action.t =
  match Parser.feed parser ~line with
  | Skip -> Consumed
  | Continue { content } ->
    t.buffer <- content :: t.buffer;
    Consumed
  | Done { content } ->
    t.buffer <- content :: t.buffer;
    Done { lines = List.rev t.buffer }
  | End_not_consumed -> Done_not_consumed { lines = List.rev t.buffer }
;;

let feed t ~line : Action.t =
  match t.phase with
  | Committed { parser } -> feed_committed t ~parser ~line
  | Searching { candidates } ->
    let rec find_loop : _ -> Action.t = function
      | [] -> Consumed
      | parser :: rest ->
        (match Parser.feed parser ~line with
         | Skip -> find_loop rest
         | Continue { content } ->
           t.phase <- Committed { parser };
           t.buffer <- content :: t.buffer;
           Consumed
         | Done { content } ->
           t.buffer <- content :: t.buffer;
           Done { lines = List.rev t.buffer }
         | End_not_consumed -> Done_not_consumed { lines = List.rev t.buffer })
    in
    find_loop candidates
;;
