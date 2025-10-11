[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open Frontend.Ast

type imm =
  | ImmConst of literal
  | ImmVar of ident

type cexpr =
  | CImm of imm
  | CTuple of imm * imm * imm list
  | CApp of imm * imm
  | CIte of imm * aexpr * aexpr

and aexpr =
  | ALet of is_recursive * ident * cexpr * aexpr
  | ACExpr of cexpr

type binding = ident * aexpr
type astr_item = is_recursive * binding * binding list
type program = astr_item * astr_item list
type state = { counter : int }

open Common.Monad.Counter

let rec anf (e : expr) (expr_with_hole : imm -> aexpr t) : aexpr t =
  match e with
  | Const c -> expr_with_hole (ImmConst c)
  | Variable n -> expr_with_hole (ImmVar n)
  | LetIn (rec_flag, (PVar name, value), body) ->
    let* body = anf body expr_with_hole in
    anf value (fun immv -> ALet (rec_flag, name, CImm immv, body) |> return)
  | _ -> failwith "Not implemented"
;;
