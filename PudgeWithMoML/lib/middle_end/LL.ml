[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open Anf
open Common.Monad.Counter

let make_fresh : string t =
  let+ fresh = make_fresh in
  "f_" ^ Int.to_string fresh
;;

(* Now need only to avoid let [arg__0 = f__0 in arg__0 ...] situation *)
let rec simplify =
  let simplify_cexpr = function
    | (CImm _ | CBinop _ | CNot _ | CApp _) as e -> e
    | CLambda (name, e) -> CLambda (name, simplify e)
    | CIte (imm, th, el) -> CIte (imm, simplify th, simplify el)
  in
  function
  | ALet (_, name, CImm (ImmVar f), ACExpr (CApp (ImmVar a_name, imm, imms)))
    when name = a_name -> ACExpr (CApp (ImmVar f, imm, imms))
  | ALet (is_rec, name, cexpr, aexpr) ->
    ALet (is_rec, name, simplify_cexpr cexpr, simplify aexpr)
  | ACExpr e -> ACExpr (simplify_cexpr e)
;;

(* Return args of cexpr. Otherwise return empty array *)
let get_args cexpr =
  match cexpr with
  | CLambda (arg, body) ->
    let rec helper acc = function
      | ACExpr (CLambda (arg, body)) -> helper (arg :: acc) body
      | e -> List.rev acc, e
    in
    helper [ arg ] body
  | _ -> [], ACExpr cexpr
;;

let create_lambda args body =
  let last = Base.List.last_exn args in
  let args = Base.List.drop_last_exn args in
  Base.List.fold_right
    ~f:(fun (arg : string) (cexpr : cexpr) -> CLambda (arg, ACExpr cexpr))
    ~init:(CLambda (last, body))
    args
;;

(* Save lambdas that we will up in code *)
let rec convert_ll_cexpr = function
  | (CImm _ | CBinop _ | CApp _ | CNot _) as e -> (e, []) |> return
  | CLambda _ as lam ->
    let args, body = get_args lam in
    let* body', lams = convert_ll_aexpr body in
    let new_lambda = create_lambda args body' in
    let+ fresh = make_fresh in
    CImm (ImmVar fresh), lams @ [ fresh, new_lambda ]
  | CIte (imm, th, el) ->
    let* th', lams1 = convert_ll_aexpr th in
    let+ el', lams2 = convert_ll_aexpr el in
    CIte (imm, th', el'), lams1 @ lams2

and convert_ll_aexpr = function
  | ACExpr e ->
    let+ e', lams = convert_ll_cexpr e in
    ACExpr e', lams
  | ALet (is_rec, name, cexpr, aexpr) ->
    let* cexpr', lams1 = convert_ll_cexpr cexpr in
    let+ aexpr', lams2 = convert_ll_aexpr aexpr in
    ALet (is_rec, name, cexpr', aexpr'), lams1 @ lams2
;;

(* Apply lambda lifting to aprogram. *)
(* After lifting all inner function will be top-level (all functions must be closed). *)
let convert_ll_pr (pr : aprogram) : aprogram =
  let open Frontend.Ast in
  let rec helper (acc : aprogram) : aprogram -> aprogram t = function
    | (is_rec, (name, ACExpr (CLambda _ as lam)), binds) :: tl ->
      let args, body = get_args lam in
      let* body', lams = convert_ll_aexpr body in
      let lams =
        Base.List.map lams ~f:(fun (lam_name, lam_cexpr) ->
          Nonrec, (lam_name, ACExpr lam_cexpr), [])
      in
      let new_lambda = create_lambda args body' in
      helper
        ((is_rec, (name, simplify (ACExpr new_lambda)), binds) :: (List.rev lams @ acc))
        tl
    | (is_rec, (name, aexpr), binds) :: tl ->
      let* aexpr', lams = convert_ll_aexpr aexpr in
      let lams =
        Base.List.map lams ~f:(fun (lam_name, lam_cexpr) ->
          Nonrec, (lam_name, ACExpr lam_cexpr), [])
      in
      helper ((is_rec, (name, simplify aexpr'), binds) :: (List.rev lams @ acc)) tl
    | [] -> return (List.rev acc)
  in
  run (helper [] pr) 0 |> snd
;;
