[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open Frontend.Ast
open Frontend.Keywords
open Base

type imm =
  | ImmConst of literal
  | ImmVar of ident

type cexpr =
  | CImm of imm
  | CTuple of imm * imm * imm list
  | CBinop of ident * imm * imm
  | CNot of imm
  | CLambda of imm * aexpr
  | CApp of imm * imm
  | CIte of imm * aexpr * aexpr

and aexpr =
  | ALet of is_recursive * ident * cexpr * aexpr
  | ACExpr of cexpr

type binding = ident * aexpr
type astr_item = is_recursive * binding * binding list
type aprogram = astr_item list
type state = { counter : int }

open Common.Monad.Counter

let make_labmda_arg =
  let+ fresh = make_fresh in
  "anf__larg" ^ Int.to_string fresh
;;

let is_op name = List.mem (String.to_list op_chars) name.[0] ~equal:Char.equal

let rec anf (e : expr) (expr_with_hole : imm -> aexpr t) : aexpr t =
  match e with
  | Const c -> expr_with_hole (ImmConst c)
  | Variable n -> expr_with_hole (ImmVar n)
  | LetIn (rec_flag, (PVar name, value), body) ->
    let* body = anf body expr_with_hole in
    anf value (fun immv -> ALet (rec_flag, name, CImm immv, body) |> return)
  | Apply (Apply (Variable f, arg1), arg2) when is_op f ->
    anf arg1 (fun i1 -> anf arg2 (fun i2 -> ACExpr (CBinop (f, i1, i2)) |> return))
  (* | Lambda (arg, body) ->
    let k_end i = ACExpr (CImm i) |> return in
    let* body' = anf body k_end in
    emit (CLambda (ImmVar arg, body')) k
  | Apply (f, a) -> anf f (fun ifun -> anf a (fun iarg -> ) k)) *)
  | _ -> failwith "Not implemented"
;;

let anf_str_item : structure_item -> astr_item t = function
  | Nonrec, (PVar name, v), [] ->
    let+ v' = anf v (fun i -> ACExpr (CImm i) |> return) in
    Nonrec, (name, v'), []
  | _ -> failwith "Not implemented"
;;

let anf_program program : aprogram =
  let program' =
    List.fold_right
      ~f:(fun item acc ->
        let* acc = acc in
        let+ item' = anf_str_item item in
        item' :: acc)
      ~init:(return [])
      program
  in
  run program' 0 |> snd
;;
