[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open TypedTree
open Generate

type ident = string [@@deriving show { with_path = false }]

type literal =
  | Int_lt of (int[@gen QCheck.Gen.small_int])
  | Bool_lt of bool
  | Unit_lt
[@@deriving show { with_path = false }, qcheck]

type pattern =
  | Wild
  | PList of
      (pattern list[@gen QCheck.Gen.(list_size (0 -- 3) (gen_pattern_sized (n / 20)))])
  | PCons of pattern * pattern
  | PTuple of
      pattern
      * pattern
      * (pattern list[@gen QCheck.Gen.(list_size (0 -- 2) (gen_pattern_sized (n / 20)))])
  | PConst of literal
  | PVar of ident
  | POption of pattern option
  | PConstraint of pattern * typ
[@@deriving show { with_path = false }, qcheck]

type is_recursive =
  | Nonrec
  | Rec
[@@deriving show { with_path = false }, qcheck]

type expr =
  | Const of literal
  | Tuple of
      (expr[@gen gen_expr_sized (n / 4)])
      * (expr[@gen gen_expr_sized (n / 4)])
      * (expr list[@gen QCheck.Gen.(list_size (0 -- 2) (gen_expr_sized (n / 20)))])
  | List of (expr list[@gen QCheck.Gen.(list_size (0 -- 3) (gen_expr_sized (n / 20)))])
  | Variable of ident
  | If_then_else of
      (expr[@gen gen_expr_sized (n / 4)])
      * (expr[@gen gen_expr_sized (n / 4)])
      * (expr option[@gen QCheck.Gen.option (gen_expr_sized (n / 4))])
  | Lambda of (pattern[@gen gen_pattern_sized (n / 2)]) * expr
  | Apply of (expr[@gen gen_expr_sized (n / 4)]) * (expr[@gen gen_expr_sized (n / 4)])
  | Function of
      case * (case list[@gen QCheck.Gen.(list_size (0 -- 2) (gen_case_sized (n / 20)))])
  | Match of
      (expr[@gen gen_expr_sized (n / 4)])
      * (case[@gen gen_case_sized (n / 4)])
      * (case list[@gen QCheck.Gen.(list_size (0 -- 2) (gen_case_sized (n / 20)))])
  | Option of (expr option[@gen QCheck.Gen.option (gen_expr_sized (n / 4))])
  | EConstraint of (expr[@gen gen_expr_sized (n / 4)]) * typ
  | LetIn of is_recursive * (binding[@gen gen_binding_sized (n / 4)]) * expr
[@@deriving show { with_path = false }, qcheck]

and binding =
  (pattern[@gen gen_pattern_sized (n / 4)]) * (expr[@gen gen_expr_sized (n / 4)])
[@@deriving show { with_path = false }, qcheck]

and case = (pattern[@gen gen_pattern_sized (n / 4)]) * (expr[@gen gen_expr_sized (n / 4)])
[@@deriving show { with_path = false }, qcheck]

type structure_item =
  is_recursive
  * binding
  * (binding list[@gen QCheck.Gen.(list_size (0 -- 1) gen_binding)])
[@@deriving show { with_path = false }, qcheck]

type program =
  (structure_item list[@gen QCheck.Gen.(list_size (1 -- 2) gen_structure_item)])
[@@deriving show { with_path = false }, qcheck]

let eapp func args =
  Base.List.fold_left args ~init:func ~f:(fun acc arg -> Apply (acc, arg))
;;

let eapp2 func a b = eapp func [ a; b ]

let elambda func args =
  Base.List.fold_right args ~init:func ~f:(fun arg acc -> Lambda (arg, acc))
;;

let eeq a b = eapp (Variable "=") [ a; b ]
let eneq a b = eapp (Variable "<>") [ a; b ]
let elt a b = eapp (Variable "<") [ a; b ]
let elte a b = eapp (Variable "<=") [ a; b ]
let egt a b = eapp (Variable ">") [ a; b ]
let egte a b = eapp (Variable ">=") [ a; b ]
let eadd a b = eapp (Variable "+") [ a; b ]
let esub a b = eapp (Variable "-") [ a; b ]
let emul a b = eapp (Variable "*") [ a; b ]
let ediv a b = eapp (Variable "/") [ a; b ]
let eland a b = eapp (Variable "&&") [ a; b ]
let elor a b = eapp (Variable "||") [ a; b ]
let econs a b = eapp (Variable "::") [ a; b ]
let euminus a = eapp (Variable "~-") [ a ]
let std_binops = [ "="; "<>"; "<"; "<="; ">"; ">="; "+"; "-"; "*"; "/"; "&&"; "||"; "::" ]
let std_ops = "not" :: "~-" :: std_binops

let std_lib =
  [ "print_int"
  ; "print_gc_status"
  ; "print_gc_stats"
  ; "gc_collect"
  ; "get_heap_start"
  ; "get_heap_finish"
  ]
;;
