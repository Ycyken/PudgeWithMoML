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
[@@deriving show { with_path = false }]

type cexpr =
  | CImm of imm
  | CTuple of imm * imm * imm list
  | CBinop of ident * imm * imm
  | CNot of imm
  | CLambda of ident * aexpr
  | CApp of imm * imm * imm list
  | CIte of imm * aexpr * aexpr
[@@deriving show { with_path = false }]

and aexpr =
  | ALet of is_recursive * ident * cexpr * aexpr
  | ACExpr of cexpr
[@@deriving show { with_path = false }]

type binding = ident * aexpr [@@deriving show { with_path = false }]

type astr_item = is_recursive * binding * binding list
[@@deriving show { with_path = false }]

type aprogram = astr_item list [@@deriving show { with_path = false }]

let mk_alet rf name1 v body =
  match rf, body with
  (* let x = v in x*)
  | Nonrec, ACExpr (CImm (ImmVar name2)) when String.equal name1 name2 -> ACExpr v
  | _ -> ALet (rf, name1, v, body)
;;

open Common.Monad.Counter

let make_temp =
  let+ fresh = make_fresh in
  "anf_t" ^ Int.to_string fresh
;;

let is_op name = List.mem (String.to_list op_chars) name.[0] ~equal:Char.equal

let rec anf (e : expr) (expr_with_hole : imm -> aexpr t) : aexpr t =
  match e with
  | Const c -> expr_with_hole (ImmConst c)
  | Variable n -> expr_with_hole (ImmVar n)
  | LetIn (rec_flag, (PVar name, value), body) ->
    let* body = anf body expr_with_hole in
    anf value (fun immv -> mk_alet rec_flag name (CImm immv) body |> return)
  | LetIn (_, (Wild, value), body) ->
    let* body = anf body expr_with_hole in
    anf value (fun _ -> body |> return)
  | Apply (Apply (Variable f, arg1), arg2) when is_op f ->
    anf arg1 (fun i1 ->
      anf arg2 (fun i2 ->
        let* temp = make_temp in
        let* ehole = expr_with_hole (ImmVar temp) in
        mk_alet Nonrec temp (CBinop (f, i1, i2)) ehole |> return))
  | Lambda (PVar arg, body) ->
    let+ body' = anf body expr_with_hole in
    let lambda = CLambda (arg, body') in
    ACExpr lambda
  | Apply ((Apply (_, _) as app), arg1) ->
    let f, args =
      let rec helper e =
        match e with
        | Apply (f, arg) ->
          let f', args = helper f in
          f', args @ [ arg ]
        | _ -> e, []
      in
      helper (Apply (app, arg1))
    in
    let rec anf_list (l : expr list) (k : imm list -> aexpr t) =
      match l with
      | hd :: tl -> anf hd (fun i -> anf_list tl (fun res -> k (i :: res)))
      | [] -> k []
    in
    anf f (fun i1 ->
      anf_list args (fun l ->
        let* temp = make_temp in
        let* ehole = expr_with_hole (ImmVar temp) in
        match l with
        | arg :: args -> mk_alet Nonrec temp (CApp (i1, arg, args)) ehole |> return
        | [] -> failwith "Apply must contain at least one argument"))
  | Apply (f, arg) ->
    anf f (fun i1 ->
      anf arg (fun i2 ->
        let* temp = make_temp in
        let* ehole = expr_with_hole (ImmVar temp) in
        mk_alet Nonrec temp (CApp (i1, i2, [])) ehole |> return))
  | If_then_else (i, t, e) ->
    anf i (fun i' ->
      let* t' = anf t expr_with_hole in
      let* e' =
        match e with
        | Some e -> anf e expr_with_hole
        | None -> ACExpr (CImm (ImmConst Unit_lt)) |> return
      in
      ACExpr (CIte (i', t', e')) |> return)
  | other -> failwith (Stdlib.Format.asprintf "Not implemented %a" pp_expr other)
;;

let anf_str_item : structure_item -> astr_item t = function
  | rec_flag, (PVar name, v), [] ->
    let+ v' = anf v (fun i -> ACExpr (CImm i) |> return) in
    rec_flag, (name, v'), []
  | rec_flag, (Wild, v), [] ->
    (* TODO: alpha conversion must keep wildcard variable but exec code *)
    let+ v' = anf v (fun i -> ACExpr (CImm i) |> return) in
    rec_flag, ("_", v'), []
  | other ->
    failwith (Stdlib.Format.asprintf "Not implemented %a" pp_structure_item other)
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
