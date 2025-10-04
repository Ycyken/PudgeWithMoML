(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

open TypedTree

type ident = string [@@deriving show { with_path = false }]

type literal =
  | Int_lt of int
  | Bool_lt of bool
  | Unit_lt
[@@deriving show { with_path = false }]

type pattern =
  | Wild (** [_] *)
  | PList of pattern list (**[ [], [1;2;3] ] *)
  | PCons of pattern * pattern (**[ hd :: tl ] *)
  | PTuple of pattern * pattern * pattern list (** | [(a, b)] -> *)
  | PConst of literal (** | [4] -> *)
  | PVar of ident (** | [x] -> *)
  | POption of pattern option
  | PConstraint of pattern * typ
[@@deriving show { with_path = false }]

type is_recursive =
  | Nonrec
  | Rec
[@@deriving show { with_path = false }]

type expr =
  | Const of literal
  | Tuple of expr * expr * expr list
  | List of expr list
  | Variable of ident
  | If_then_else of expr * expr * expr option
  | Lambda of pattern * expr
  | Apply of expr * expr
  | Function of case * case list (** [function | p1 -> e1 | p2 -> e2 | ... |]*)
  | Match of expr * case * case list (** [match x with | p1 -> e1 | p2 -> e2 | ...] *)
  | Option of expr option
  | EConstraint of expr * typ
  | LetIn of is_recursive * binding list * expr
[@@deriving show { with_path = false }]

and binding = pattern * expr [@@deriving show { with_path = false }]
and case = pattern * expr [@@deriving show { with_path = false }]

type structure_item = is_recursive * binding list [@@deriving show { with_path = false }]
type program = structure_item list [@@deriving show { with_path = false }]

let eapp func args =
  Base.List.fold_left args ~init:func ~f:(fun acc arg -> Apply (acc, arg))
;;

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
let euminus a = eapp (Variable "-") [ a ]
