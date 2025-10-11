[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open Frontend.Ast
open Common.Monad.Counter
open Base

let make_fresh name =
  let+ fresh = make_fresh in
  let new_name = name ^ "__" ^ Int.to_string fresh in
  new_name
;;

let rec convert_pat ctx = function
  | Wild -> return (Wild, ctx)
  | PList l ->
    let+ l', ctx = convert_list_pat ctx l in
    PList l', ctx
  | PCons (hd, tl) ->
    let* hd', ctx = convert_pat ctx hd in
    let+ tl', ctx = convert_pat ctx tl in
    PCons (hd', tl'), ctx
  | PTuple (p1, p2, rest) ->
    let* p1', ctx = convert_pat ctx p1 in
    let* p2', ctx = convert_pat ctx p2 in
    let+ rest', ctx = convert_list_pat ctx rest in
    PTuple (p1', p2', rest'), ctx
  | PConst _ as p -> return (p, ctx)
  | PVar name ->
    let+ new_name = make_fresh name in
    let ctx = Map.set ctx ~key:name ~data:new_name in
    PVar new_name, ctx
  | POption None as p -> return (p, ctx)
  | POption (Some p) ->
    let* p', ctx = convert_pat ctx p in
    return (POption (Some p'), ctx)
  | PConstraint (p, t) ->
    let* p', ctx = convert_pat ctx p in
    return (PConstraint (p', t), ctx)

and convert_list_pat ctx = function
  | [] -> return ([], ctx)
  | x :: xs ->
    let* x', ctx = convert_pat ctx x in
    let+ xs', ctx = convert_list_pat ctx xs in
    x' :: xs', ctx
;;

let rec convert_expr ctx = function
  | Const _ as e -> return e
  | Tuple (e1, e2, rest) ->
    let* e1' = convert_expr ctx e1 in
    let* e2' = convert_expr ctx e2 in
    let+ rest' =
      List.fold_right
        ~f:(fun e acc ->
          let* acc = acc in
          let+ e' = convert_expr ctx e in
          e' :: acc)
        rest
        ~init:(return [])
    in
    Tuple (e1', e2', rest')
  | List l ->
    let+ l' = convert_list_expr ctx l in
    List l'
  | Variable name ->
    Option.value (Map.find ctx name) ~default:name |> fun n -> Variable n |> return
  | If_then_else (i, t, e) ->
    let* i' = convert_expr ctx i in
    let* t' = convert_expr ctx t in
    let+ e' =
      match e with
      | Some e -> convert_expr ctx e >>| fun e' -> Some e'
      | None -> return None
    in
    If_then_else (i', t', e')
  | Lambda (arg, body) ->
    let* arg', ctx = convert_pat ctx arg in
    let+ body' = convert_expr ctx body in
    Lambda (arg', body')
  | Apply (f, arg) ->
    let* f' = convert_expr ctx f in
    let+ arg' = convert_expr ctx arg in
    Apply (f', arg')
  | Function (case, cases) ->
    (* eliminate function to match *)
    let* new_name = make_fresh "function_arg" in
    convert_expr ctx (Lambda (PVar new_name, Match (Variable new_name, case, cases)))
  | Match (value, (pat, expr), cases) ->
    let* value' = convert_expr ctx value in
    let* pat', ctx = convert_pat ctx pat in
    let* expr' = convert_expr ctx expr in
    let+ cases' =
      List.fold_right
        ~f:(fun (p, e) acc ->
          let* acc = acc in
          let* p', ctx = convert_pat ctx p in
          let+ e' = convert_expr ctx e in
          (p', e') :: acc)
        ~init:(return [])
        cases
    in
    Match (value', (pat', expr'), cases')
  | Option None as e -> return e
  | Option (Some e) ->
    let+ e' = convert_expr ctx e in
    Option (Some e')
  | EConstraint (e, t) ->
    let+ e' = convert_expr ctx e in
    EConstraint (e', t)
  | LetIn (Rec, (name, value), body) ->
    let* pat', ctx = convert_pat ctx name in
    let* value' = convert_expr ctx value in
    let+ body' = convert_expr ctx body in
    LetIn (Rec, (pat', value'), body')
  | LetIn (Nonrec, (name, value), body) ->
    let* value' = convert_expr ctx value in
    let* pat', ctx = convert_pat ctx name in
    let+ body' = convert_expr ctx body in
    LetIn (Nonrec, (pat', value'), body')

and convert_list_expr ctx = function
  | [] -> return []
  | x :: xs ->
    let* x' = convert_expr ctx x in
    let+ xs' = convert_list_expr ctx xs in
    x' :: xs'
;;
