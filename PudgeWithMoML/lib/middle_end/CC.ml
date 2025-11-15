[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open Frontend.Ast
open Anf

(* open AnfPP *)
module FVSet = Stdlib.Set.Make (String)

let get_fv_imm is_top_level = function
  | ImmConst _ -> FVSet.empty
  | ImmVar v when is_top_level v -> FVSet.empty
  | ImmVar v -> FVSet.singleton v
;;

let rec get_fv_cexpr is_top_level = function
  | CImm imm -> get_fv_imm is_top_level imm
  | CBinop (_, imm1, imm2) ->
    FVSet.union (get_fv_imm is_top_level imm1) (get_fv_imm is_top_level imm2)
  | CNot imm -> get_fv_imm is_top_level imm
  | CLambda (name, body) -> FVSet.remove name (get_fv_aexpr is_top_level body)
  | CApp (imm1, imm2, imms) ->
    List.fold_left
      (fun set arg -> FVSet.union set (get_fv_imm is_top_level arg))
      FVSet.empty
      (imm1 :: imm2 :: imms)
  | CIte (imm, th, el) ->
    FVSet.union
      (get_fv_imm is_top_level imm)
      (FVSet.union (get_fv_aexpr is_top_level th) (get_fv_aexpr is_top_level el))

and get_fv_aexpr is_top_level = function
  | ACExpr cexpr -> get_fv_cexpr is_top_level cexpr
  | ALet (is_rec, name, cexpr, aexpr) ->
    let cexpr_fv =
      match is_rec with
      | Rec -> FVSet.remove name (get_fv_cexpr is_top_level cexpr)
      | Nonrec -> get_fv_cexpr is_top_level cexpr
    in
    let aexpr_fv = FVSet.remove name (get_fv_aexpr is_top_level aexpr) in
    FVSet.union cexpr_fv aexpr_fv
;;

open Common.Monad.CounterR

let make_fresh : string t =
  let+ fresh = make_fresh in
  "arg_" ^ Int.to_string fresh
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

(* Take all free variables in aexpr and change it with map *)
let change_fv (map : (string * string) list) =
  let contain x = List.find_opt (fun (fv, _) -> fv = x) map in
  let change_fv_imm = function
    | ImmConst _ as e -> e
    | ImmVar v ->
      (match contain v with
       | Some (_, new_v) -> ImmVar new_v
       | None -> ImmVar v)
  in
  let rec change_fv_cexpr = function
    | CImm imm -> CImm (change_fv_imm imm)
    | CBinop (name, imm1, imm2) -> CBinop (name, change_fv_imm imm1, change_fv_imm imm2)
    | CNot imm -> CNot (change_fv_imm imm)
    | CApp (imm1, imm2, imms) ->
      CApp (change_fv_imm imm1, change_fv_imm imm2, Base.List.map imms ~f:change_fv_imm)
    | CIte (imm, th, el) ->
      CIte (change_fv_imm imm, change_fv_aexpr th, change_fv_aexpr el)
    | CLambda (name, aexpr) -> CLambda (name, change_fv_aexpr aexpr)
  and change_fv_aexpr = function
    | ACExpr e -> ACExpr (change_fv_cexpr e)
    | ALet (is_rec, name, cexpr, aexpr) ->
      ALet (is_rec, name, change_fv_cexpr cexpr, change_fv_aexpr aexpr)
  in
  change_fv_aexpr
;;

let rec convert_cc_cexpr is_top_level = function
  | CImm _ as exp -> ACExpr exp |> return
  | CBinop _ as exp -> ACExpr exp |> return
  | CLambda _ as lam ->
    let args, body = get_args lam in
    let* body' = convert_cc_aexpr is_top_level body in
    let fvs =
      FVSet.elements (FVSet.diff (get_fv_aexpr is_top_level body') (FVSet.of_list args))
    in
    let new_fvs = Base.List.map fvs ~f:(fun fv -> fv ^ "__new") in
    let body' = change_fv (Base.List.zip_exn fvs new_fvs) body' in
    let lambda =
      let last = Base.List.last_exn args in
      let args = Base.List.drop_last_exn args in
      Base.List.fold_right
        ~f:(fun arg cexpr -> CLambda (arg, ACExpr cexpr))
        ~init:(CLambda (last, body'))
        args
    in
    (match fvs with
     | [] -> ACExpr lambda |> return
     | _ ->
       let homka =
         Base.List.fold_right
           ~f:(fun fv lambda -> CLambda (fv, ACExpr lambda))
           ~init:lambda
           new_fvs
       in
       let+ fresh = make_fresh in
       let arg, args = Base.List.nth_exn fvs 0, Base.List.drop fvs 1 in
       let imms = Base.List.map args ~f:(fun i -> ImmVar i) in
       ALet (Nonrec, fresh, homka, ACExpr (CApp (ImmVar fresh, ImmVar arg, imms))))
  | CNot _ as exp -> ACExpr exp |> return
  | CApp _ as exp -> ACExpr exp |> return
  | CIte (name, th, el) ->
    let* first = convert_cc_aexpr is_top_level th in
    let* second = convert_cc_aexpr is_top_level el in
    ACExpr (CIte (name, first, second)) |> return

and convert_cc_aexpr is_top_level = function
  | ACExpr cexp -> convert_cc_cexpr is_top_level cexp
  | ALet (is_rec, name, cexpr, aexpr) ->
    (* Initially we have let homka = e1 in e2 *)
    (* e1 is cexpr and it can be lambda or some other expression *)
    (* If e1 is lambda with free variables then after conversion
    it will be aexpr: let temp = new_lambda in new_lambda fv1 fv2 fv3 *)
    let* first = convert_cc_cexpr is_top_level cexpr in
    let* second = convert_cc_aexpr is_top_level aexpr in
    (match first with
     | ACExpr e -> ALet (is_rec, name, e, second) |> return
     | ALet (is_rec_outer, name_outer, cexpr_outer, aexpr_outer) ->
       (match aexpr_outer with
        | ALet _ -> fail "Wrong work of convert_cc_cexpr"
        | ACExpr e ->
          ALet (is_rec_outer, name_outer, cexpr_outer, ALet (Nonrec, name, e, aexpr))
          |> return))
;;

(* Apply closure conversion to aprogram. *)
(* After conversion all function are closed (withour free variables). *)
let convert_cc_pr (pr : aprogram) =
  (* If function top-level*)
  let is_top_level name =
    match name with
    | n when Base.List.mem std_lib n ~equal:String.equal -> true
    | _ ->
      let rec helper (astr : astr_item list) =
        match astr with
        | (_, (f, ACExpr (CLambda _)), []) :: tl -> f = name || helper tl
        | _ :: tl -> helper tl
        | [] -> false
      in
      helper pr
  in
  let rec helper (acc : aprogram) : aprogram -> aprogram t = function
    | (is_rec, (name, aexpr), binds) :: tl ->
      let* aexpr' = convert_cc_aexpr is_top_level aexpr in
      helper ((is_rec, (name, aexpr'), binds) :: acc) tl
    | [] -> return (List.rev acc)
  in
  run (helper [] pr) 0 |> snd
;;
