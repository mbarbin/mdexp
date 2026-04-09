(*********************************************************************************)
(*  mdexp - Literate Programming with Embedded Snapshots                         *)
(*  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

(* @mdexp

# EDSL

The previous chapters covered the three directives that drive mdexp:
prose, code blocks, and snapshots. With those building blocks in
hand, we can now explore what becomes possible when you combine them
with the host language's type system.

A powerful use case is building small **embedded domain-specific
languages** (EDSLs). The idea is to write OCaml code that serves
two purposes at once:

1. **Render** human-readable content for the document (tables, math, diagrams).
2. **Evaluate** and **verify** the same content programmatically.

Because both the rendering and the verification live in the same
compilable source file, the documentation cannot drift from reality.

## Tables as generated content

As a warm-up, consider generating a markdown table from typed data.
Rather than writing the table by hand, we define the data as typed
OCaml values:

@mdexp.code *)

type planet =
  { name : string
  ; distance_au : float
  ; moons : int
  }

let planets =
  [ { name = "Mercury"; distance_au = 0.39; moons = 0 }
  ; { name = "Venus"; distance_au = 0.72; moons = 0 }
  ; { name = "Earth"; distance_au = 1.00; moons = 1 }
  ; { name = "Mars"; distance_au = 1.52; moons = 2 }
  ]
;;

(* @mdexp

Then we use the `print-table` library to produce the markdown table
from this data. The snapshot captures the output, so the table is
verified on every test run: *)

let%expect_test "inner planets" =
  let open Print_table.O in
  let columns =
    [ Column.make ~header:"Planet" (fun p -> Cell.text p.name)
    ; Column.make ~header:"Distance (AU)" ~align:Right (fun p ->
        Cell.text (Printf.sprintf "%.2f" p.distance_au))
    ; Column.make ~header:"Moons" ~align:Right (fun p ->
        Cell.text (Int.to_string p.moons))
    ]
  in
  let print_table = Print_table.make ~columns ~rows:planets in
  print_endline (Print_table.to_string_markdown print_table);
  (* @mdexp.snapshot *)
  [%expect
    {|
    | Planet  | Distance (AU) | Moons |
    |:--------|--------------:|------:|
    | Mercury |          0.39 |     0 |
    | Venus   |          0.72 |     0 |
    | Earth   |          1.00 |     1 |
    | Mars    |          1.52 |     2 | |}]
;;

(* @mdexp

## Background invariants

The table above is generated from the `planets` list. But we can also
**assert properties** of that same data --- checks that run during
testing but do not appear in the rendered document. This is the
"dual interpretation" idea: the same data is both rendered (for the
reader) and verified (for correctness).

In the documentation source, we check that distances are positive and
sorted. This test has no `@mdexp` directives, so it is invisible to the
document, yet it runs on every build. *)

(* This comment is not part of the rendered document, and neither is the
   following expect test section: *)

let%expect_test "distances are positive and sorted" =
  let distances = List.map planets ~f:(fun p -> p.distance_au) in
  List.iter distances ~f:(fun d -> require (Float.compare d 0.0 > 0));
  let rec is_sorted = function
    | [] | [ _ ] -> true
    | a :: (b :: _ as rest) -> Float.compare a b <= 0 && is_sorted rest
  in
  require (is_sorted distances);
  [%expect {||}]
;;

(* @mdexp

If a change reorders the rows or introduces a negative distance, the
test fails --- even though the reader never sees it. The document
stays correct because the code enforces it.

## A math EDSL

Now for a more ambitious example, let's build a small EDSL for
mathematical expressions. The same OCaml value can be:

- **rendered** to LaTeX syntax (for the document), and
- **evaluated** to an integer (for verification).

### The expression type

@mdexp.code *)

type expr =
  | Int of int
  | Var of string
  | Add of expr * expr
  | Mul of expr * expr
  | Frac of
      { num : expr
      ; den : expr
      }
  | Sum of
      { var : string
      ; from : expr
      ; to_ : expr
      ; body : expr
      }

(* @mdexp

### Rendering to LaTeX

The `to_latex` function turns an expression into a LaTeX string.
Parentheses are inserted automatically based on operator
precedence --- there is no `Paren` constructor in the type:

@mdexp.code *)

let rec to_latex_prec prec = function
  | Int n -> Int.to_string n
  | Var x -> x
  | Add (a, b) ->
    let s = to_latex_prec 1 a ^ " + " ^ to_latex_prec 1 b in
    if prec > 1 then "(" ^ s ^ ")" else s
  | Mul (a, b) ->
    let s = to_latex_prec 2 a ^ " \\cdot " ^ to_latex_prec 2 b in
    if prec > 2 then "(" ^ s ^ ")" else s
  | Frac { num; den } ->
    "\\frac{" ^ to_latex_prec 0 num ^ "}{" ^ to_latex_prec 0 den ^ "}"
  | Sum { var; from; to_; body } ->
    Printf.sprintf
      "\\sum_{%s=%s}^{%s} %s"
      var
      (to_latex_prec 0 from)
      (to_latex_prec 0 to_)
      (to_latex_prec 0 body)
;;

let to_latex e = to_latex_prec 0 e

(* @mdexp

### Evaluation

The `eval` function computes the integer value of an expression given
variable bindings:

@mdexp.code *)

let rec eval env = function
  | Int n -> n
  | Var x -> List.assoc x env
  | Add (a, b) -> eval env a + eval env b
  | Mul (a, b) -> eval env a * eval env b
  | Frac { num; den } -> eval env num / eval env den
  | Sum { var; from; to_; body } ->
    let lo = eval env from in
    let hi = eval env to_ in
    let rec loop i acc =
      if i > hi then acc else loop (i + 1) (acc + eval ((var, i) :: env) body)
    in
    loop lo 0
;;

(* @mdexp

### Stating and checking an identity

We can now state the classic identity:

\\[ \sum_{i=1}^{n} i = \frac{n \cdot \left(n + 1\right)}{2} \\]

Both sides are encoded as `expr` values:

@mdexp.code *)

let sum_expr = Sum { var = "i"; from = Int 1; to_ = Var "n"; body = Var "i" }
let closed_form = Frac { num = Mul (Var "n", Add (Var "n", Int 1)); den = Int 2 }

(* @mdexp

The EDSL renders them to the LaTeX shown above: *)

let%expect_test "render the identity" =
  Printf.printf "\\\\[ %s = %s \\\\]\n" (to_latex sum_expr) (to_latex closed_form);
  (* @mdexp.snapshot *)
  [%expect {|\\[ \sum_{i=1}^{n} i = \frac{n \cdot (n + 1)}{2} \\]|}]
;;

(* @mdexp

We can verify the identity by evaluating both sides for concrete
values of *n*: *)

let%expect_test "verification table" =
  let open Print_table.O in
  let test_values = [ 0; 1; 5; 10; 100 ] in
  let rows =
    List.map test_values ~f:(fun n ->
      let env = [ "n", n ] in
      let lhs = eval env sum_expr in
      let rhs = eval env closed_form in
      n, lhs, rhs)
  in
  let columns =
    [ Column.make ~header:"n" ~align:Right (fun (n, _, _) -> Cell.text (Int.to_string n))
    ; Column.make ~header:"Sum" ~align:Right (fun (_, lhs, _) ->
        Cell.text (Int.to_string lhs))
    ; Column.make ~header:"Formula" ~align:Right (fun (_, _, rhs) ->
        Cell.text (Int.to_string rhs))
    ]
  in
  let print_table = Print_table.make ~columns ~rows in
  print_endline (Print_table.to_string_markdown print_table);
  (* @mdexp.snapshot *)
  [%expect
    {|
    |   n |  Sum | Formula |
    |----:|-----:|--------:|
    |   0 |    0 |       0 |
    |   1 |    1 |       1 |
    |   5 |   15 |      15 |
    |  10 |   55 |      55 |
    | 100 | 5050 |    5050 | |}]
;;

(* @mdexp

Every row shows that the sum and the closed-form formula agree. But
we can do better: a background test exhaustively checks all values
up to 1000, without cluttering the document: *)

let%expect_test "exhaustive verification" =
  for n = 0 to 1000 do
    let env = [ "n", n ] in
    require (eval env sum_expr = eval env closed_form)
  done;
  [%expect {||}]
;;

(* @mdexp

The key insight is that the **same `expr` values** drove both the
rendered LaTeX and the numerical verification. There is no separate,
hand-maintained formula that could go out of sync --- the EDSL is the
single source of truth.

## An embedded proof assistant

We now push the idea further. Instead of just checking the final
result, we build a small proof assistant that verifies each **step**
of a mathematical derivation. Each step is a named algebraic rule ---
"commutativity of multiplication", "factor a common term" --- applied
at a specific location in the expression tree. The system **computes**
the result of each rule application, and verification is
**structural**: expressions are compared for exact equality, not
evaluated numerically.

### Structural equality

First we need a function that compares two expressions for exact
structural equality:

@mdexp.code *)

let rec equal_expr a b =
  match a, b with
  | Int x, Int y -> x = y
  | Var x, Var y -> String.equal x y
  | Add (a1, a2), Add (b1, b2) | Mul (a1, a2), Mul (b1, b2) ->
    equal_expr a1 b1 && equal_expr a2 b2
  | Frac { num = n1; den = d1 }, Frac { num = n2; den = d2 } ->
    equal_expr n1 n2 && equal_expr d1 d2
  | ( Sum { var = v1; from = f1; to_ = t1; body = b1 }
    , Sum { var = v2; from = f2; to_ = t2; body = b2 } ) ->
    String.equal v1 v2 && equal_expr f1 f2 && equal_expr t1 t2 && equal_expr b1 b2
  | (Int _ | Var _ | Add _ | Mul _ | Frac _ | Sum _), _ -> false
;;

(* @mdexp

### Variable substitution

We also need a function to substitute a variable with an expression
throughout a term. This implementation does not perform full
capture-avoiding substitution (a general solution would require
alpha-conversion) and raises if a `Sum` binder shadows the target
variable. This is sufficient for the current usage, where
replacements are either closed terms or variables that do not
collide with inner binders.

@mdexp.code *)

let rec subst_var ~var ~by = function
  | Int _ as e -> e
  | Var x -> if String.equal x var then by else Var x
  | Add (a, b) -> Add (subst_var ~var ~by a, subst_var ~var ~by b)
  | Mul (a, b) -> Mul (subst_var ~var ~by a, subst_var ~var ~by b)
  | Frac { num; den } ->
    Frac { num = subst_var ~var ~by num; den = subst_var ~var ~by den }
  | Sum { var = v; from; to_; body } ->
    if String.equal v var
    then Code_error.raise "subst_var: variable shadowed by Sum binder" []
    else
      Sum
        { var = v
        ; from = subst_var ~var ~by from
        ; to_ = subst_var ~var ~by to_
        ; body = subst_var ~var ~by body
        }
;;

(* @mdexp

### Algebraic rules

Each rule is a small, self-contained algebraic transformation. Here
is the minimal set needed for our proof:

@mdexp.code *)

type rule =
  | Eval_const
  | Peel_sum
  | Subst of
      { from : expr
      ; to_ : expr
      }
  | Fold_add_right
  | Add_to_frac
  | Factor_right
  | Comm_mul

(* @mdexp

Each rule has a short label and a description: *)

let rule_label = function
  | Eval_const -> "evaluate"
  | Peel_sum -> "peel last term"
  | Subst _ -> "substitution"
  | Fold_add_right -> "fold added constants"
  | Add_to_frac -> "common denominator"
  | Factor_right -> "factor"
  | Comm_mul -> "commute"
;;

let rule_description = function
  | Eval_const -> "evaluate a constant expression"
  | Peel_sum -> {|sum(a, b+1, f) -> sum(a, b, f) + f(b+1)|}
  | Subst _ -> "replace a sub-expression"
  | Fold_add_right -> {|(e + a) + b -> e + (a + b)|}
  | Add_to_frac -> {|a/c + b -> (a + b*c) / c|}
  | Factor_right -> {|a*c + b*c -> (a + b) * c|}
  | Comm_mul -> {|a * b -> b * a|}
;;

let%expect_test "rule descriptions" =
  let open Print_table.O in
  let rules =
    [ Eval_const
    ; Peel_sum
    ; Subst { from = Int 0; to_ = Int 0 }
    ; Fold_add_right
    ; Add_to_frac
    ; Factor_right
    ; Comm_mul
    ]
  in
  let columns =
    [ Column.make ~header:"Rule" (fun r -> Cell.text (rule_label r))
    ; Column.make ~header:"Transformation" (fun r -> Cell.text (rule_description r))
    ]
  in
  let print_table = Print_table.make ~columns ~rows:rules in
  print_endline (Print_table.to_string_markdown print_table);
  (* @mdexp.snapshot *)
  [%expect
    {|| Rule                 | Transformation                          |
|:---------------------|:----------------------------------------|
| evaluate             | evaluate a constant expression          |
| peel last term       | sum(a, b+1, f) -> sum(a, b, f) + f(b+1) |
| substitution         | replace a sub-expression                |
| fold added constants | (e + a) + b -> e + (a + b)              |
| common denominator   | a/c + b -> (a + b*c) / c                |
| factor               | a*c + b*c -> (a + b) * c                |
| commute              | a * b -> b * a                          ||}]
;;

(* @mdexp

### Locations

A rule is applied at a specific position in the expression tree.
Locations navigate into subexpressions:

@mdexp.code *)

type loc =
  | Here
  | In_left of loc
  | In_right of loc
  | In_num of loc

(* @mdexp

### Applying rules

The `apply_rule` function applies a rule at the top level of an
expression. It raises if the rule does not match:

@mdexp.code *)

let apply_rule rule expr =
  match rule, expr with
  | Eval_const, _ -> Int (eval [] expr)
  | Peel_sum, Sum { var; from; to_; body } ->
    (match to_ with
     | Add (rest, Int 1) ->
       Add (Sum { var; from; to_ = rest; body }, subst_var ~var ~by:to_ body)
     | _ -> Code_error.raise "Cannot peel: upper bound not of form e+1" [])
  | Subst { from; to_ }, _ ->
    if equal_expr expr from
    then to_
    else Code_error.raise "Subst: expression does not match" []
  | Fold_add_right, Add (Add (e, Int a), Int b) -> Add (e, Int (a + b))
  | Add_to_frac, Add (Frac { num; den }, b) -> Frac { num = Add (num, Mul (den, b)); den }
  | Factor_right, Add (Mul (a, c1), Mul (b, c2)) ->
    if equal_expr c1 c2
    then Mul (Add (a, b), c1)
    else Code_error.raise "Factor_right: right factors differ" []
  | Comm_mul, Mul (a, b) -> Mul (b, a)
  | _ -> Code_error.raise "Rule does not apply" []
;;

(* @mdexp

The `apply_at` function navigates to a location and applies the
rule there:

@mdexp.code *)

let rec apply_at loc rule expr =
  match loc, expr with
  | Here, _ -> apply_rule rule expr
  | In_left loc, Add (a, b) -> Add (apply_at loc rule a, b)
  | In_left loc, Mul (a, b) -> Mul (apply_at loc rule a, b)
  | In_right loc, Add (a, b) -> Add (a, apply_at loc rule b)
  | In_right loc, Mul (a, b) -> Mul (a, apply_at loc rule b)
  | In_num loc, Frac { num; den } -> Frac { num = apply_at loc rule num; den }
  | _ -> Code_error.raise "Location does not match expression shape" []
;;

(* @mdexp

### Proof structure

A proof is a starting expression, a sequence of tactic steps, and
an expected goal. Each step names a rule, a location, and an
optional annotation for rendering:

@mdexp.code *)

type proof_step =
  { rule : rule
  ; loc : loc
  ; label : string option
  }

type proof =
  { start : expr
  ; steps : proof_step list
  ; goal : expr
  }

(* @mdexp

`run_proof` executes the proof: it applies each tactic in sequence,
computing the intermediate expressions, and checks that the final
expression matches the goal structurally:

@mdexp.code *)

type computed_step =
  { result : expr
  ; justification : string
  }

type derivation =
  { start : expr
  ; steps : computed_step list
  }

let run_proof (p : proof) : derivation =
  let final, rev_steps =
    List.fold_left p.steps ~init:(p.start, []) ~f:(fun (current, acc) step ->
      let result = apply_at step.loc step.rule current in
      let justification =
        match step.label with
        | Some s -> s ^ " [" ^ rule_label step.rule ^ "]"
        | None -> rule_label step.rule
      in
      result, { result; justification } :: acc)
  in
  require (equal_expr final p.goal);
  { start = p.start; steps = List.rev rev_steps }
;;

(* @mdexp

### Rendering

The renderer turns a derivation into a LaTeX `aligned` environment:

@mdexp.code *)

let render_derivation d =
  let buf = Buffer.create 256 in
  Buffer.add_string buf "\\\\[\n\\begin{aligned}\n";
  Buffer.add_string buf (to_latex d.start);
  let len = List.length d.steps in
  List.iteri d.steps ~f:(fun i step ->
    Buffer.add_string buf "\n  &= ";
    Buffer.add_string buf (to_latex step.result);
    Buffer.add_string buf " && \\text{(";
    Buffer.add_string buf step.justification;
    Buffer.add_string buf ")}";
    if i < len - 1 then Buffer.add_string buf " \\\\\\\\");
  Buffer.add_string buf "\n\\end{aligned}\n\\\\]";
  Buffer.contents buf
;;

(* @mdexp

### Proof by induction

We prove the identity by induction on *n*. Each proof is a sequence
of named rules --- no hand-written result expressions. The system
computes every intermediate step and verifies the goal structurally.

**Base case** (`n = 1`): we substitute *n* with 1 in both sides of
the identity and evaluate:

@mdexp.code *)

let at_n n = subst_var ~var:"n" ~by:(Int n)

let base_case =
  run_proof
    { start = at_n 1 sum_expr
    ; steps = [ { rule = Eval_const; loc = Here; label = None } ]
    ; goal = Int 1
    }
;;

let base_case_rhs =
  run_proof
    { start = at_n 1 closed_form
    ; steps = [ { rule = Eval_const; loc = Here; label = None } ]
    ; goal = Int 1
    }
;;

(* @mdexp

**Inductive step**: assuming the identity holds for *n*, we show it
holds for *n + 1*. Five rules drive the derivation:

@mdexp.code *)

let n_plus_1 = Add (Var "n", Int 1)
let n_plus_2 = Add (Var "n", Int 2)

let inductive_step =
  run_proof
    { start = Sum { var = "i"; from = Int 1; to_ = n_plus_1; body = Var "i" }
    ; steps =
        [ { rule = Peel_sum; loc = Here; label = None }
        ; { rule =
              Subst
                { from = Sum { var = "i"; from = Int 1; to_ = Var "n"; body = Var "i" }
                ; to_ = Frac { num = Mul (Var "n", n_plus_1); den = Int 2 }
                }
          ; loc = In_left Here
          ; label = Some "induction hypothesis"
          }
        ; { rule = Add_to_frac; loc = Here; label = None }
        ; { rule = Factor_right; loc = In_num Here; label = None }
        ; { rule = Comm_mul; loc = In_num Here; label = None }
        ]
    ; goal = Frac { num = Mul (n_plus_1, n_plus_2); den = Int 2 }
    }
;;

(* @mdexp

The rendered derivations read exactly like a pencil-and-paper proof,
but every step has been machine-checked.

**Base case** (`n = 1`): the left-hand side is *)

let%expect_test "base case lhs" =
  print_string (render_derivation base_case);
  (* @mdexp.snapshot *)
  [%expect
    {|\\[
\begin{aligned}
\sum_{i=1}^{1} i
  &= 1 && \text{(evaluate)}
\end{aligned}
\\]|}]
;;

(* @mdexp and the right-hand side is *)

let%expect_test "base case rhs" =
  print_string (render_derivation base_case_rhs);
  (* @mdexp.snapshot *)
  [%expect
    {|\\[
\begin{aligned}
\frac{1 \cdot (1 + 1)}{2}
  &= 1 && \text{(evaluate)}
\end{aligned}
\\]|}]
;;

(* @mdexp *)

let goal_of derivation = (List.last_exn derivation.steps).result

let%expect_test "base case goals match" =
  let lhs = goal_of base_case in
  let rhs = goal_of base_case_rhs in
  require (equal_expr lhs rhs);
  Printf.printf "Both sides equal \\\\( %s \\\\). &#x2713;" (to_latex lhs);
  (* @mdexp.snapshot *)
  [%expect {|Both sides equal \\( 1 \\). &#x2713;|}]
;;

(* @mdexp

**Inductive step**: assuming the identity holds for *n*, we derive
it for *n + 1*: *)

let%expect_test "inductive step" =
  print_string (render_derivation inductive_step);
  (* @mdexp.snapshot *)
  [%expect
    {|\\[
\begin{aligned}
\sum_{i=1}^{n + 1} i
  &= \sum_{i=1}^{n} i + n + 1 && \text{(peel last term)} \\\\
  &= \frac{n \cdot (n + 1)}{2} + n + 1 && \text{(induction hypothesis [substitution])} \\\\
  &= \frac{n \cdot (n + 1) + 2 \cdot (n + 1)}{2} && \text{(common denominator)} \\\\
  &= \frac{(n + 2) \cdot (n + 1)}{2} && \text{(factor)} \\\\
  &= \frac{(n + 1) \cdot (n + 2)}{2} && \text{(commute)}
\end{aligned}
\\]|}]
;;

(* @mdexp and the closed form for *n + 1* simplifies to the same expression: *)

let inductive_step_rhs =
  run_proof
    { start = subst_var ~var:"n" ~by:n_plus_1 closed_form
    ; steps = [ { rule = Fold_add_right; loc = In_num (In_right Here); label = None } ]
    ; goal = Frac { num = Mul (n_plus_1, n_plus_2); den = Int 2 }
    }
;;

let%expect_test "inductive step rhs" =
  print_string (render_derivation inductive_step_rhs);
  (* @mdexp.snapshot *)
  [%expect
    {|\\[
\begin{aligned}
\frac{(n + 1) \cdot (n + 1 + 1)}{2}
  &= \frac{(n + 1) \cdot (n + 2)}{2} && \text{(fold added constants)}
\end{aligned}
\\]|}]
;;

(* @mdexp *)

let%expect_test "inductive step goals match" =
  let lhs = goal_of inductive_step in
  let rhs = goal_of inductive_step_rhs in
  require (equal_expr lhs rhs);
  Printf.printf "Both sides equal \\\\( %s \\\\). &#x2713;" (to_latex lhs);
  (* @mdexp.snapshot *)
  [%expect {|Both sides equal \\( \frac{(n + 1) \cdot (n + 2)}{2} \\). &#x2713;|}]
;;

(* @mdexp

### Takeaways

The examples in this chapter illustrate the same core principle at
increasing levels of ambition:

1. **Tables** --- typed data generates markdown, and background tests
   enforce invariants the reader never sees.
2. **Math rendering** --- a single `expr` value drives both the
   LaTeX output and numerical verification.
3. **Proof assistant** --- algebraic rules compute every intermediate
   step, and structural equality replaces numerical spot-checking.

In each case the pattern is the same: the host language defines a
small domain model, mdexp renders it into the document, and the
test harness verifies it. Because the rendered content and the
verification share the same source, the documentation cannot drift
from reality. *)
