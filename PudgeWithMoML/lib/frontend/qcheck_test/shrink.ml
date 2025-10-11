[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open Ast
open QCheck.Iter

let shrink_lt : literal QCheck.Shrink.t = function
  | Int_lt x -> QCheck.Shrink.int x >|= fun a' -> Int_lt a'
  | Bool_lt _ -> empty
  | Unit_lt -> empty
;;

let rec shrink_bind : binding QCheck.Shrink.t = function
  | pat, expr ->
    shrink_pattern pat
    >|= (fun pat' -> pat', expr)
    <+> (shrink_expr expr >|= fun expr' -> pat, expr')

and shrink_expr = function
  | Const lt -> shrink_lt lt >|= fun a' -> Const a'
  | Tuple (e1, e2, rest) ->
    of_list [ e1; e2 ]
    <+> (shrink_expr e1 >|= fun a' -> Tuple (a', e2, rest))
    <+> (shrink_expr e2 >|= fun a' -> Tuple (e1, a', rest))
    <+> (QCheck.Shrink.list ~shrink:shrink_expr rest >|= fun a' -> Tuple (e1, e2, a'))
  | List l -> QCheck.Shrink.list ~shrink:shrink_expr l >|= fun l' -> List l'
  | Variable _ -> empty
  | If_then_else (i, t, Some e) ->
    of_list [ i; t; e; If_then_else (i, e, None) ]
    <+> (shrink_expr i >|= fun a' -> If_then_else (a', t, Some e))
    <+> (shrink_expr t >|= fun a' -> If_then_else (i, a', Some e))
  | If_then_else (i, t, None) ->
    of_list [ i; t ]
    <+> (shrink_expr i >|= fun a' -> If_then_else (a', t, None))
    <+> (shrink_expr t >|= fun a' -> If_then_else (i, a', None))
  | Lambda (pat, body) ->
    shrink_expr body
    >|= (fun body' -> Lambda (pat, body'))
    <+> (shrink_pattern pat >|= fun pat' -> Lambda (pat', body))
  | Apply (f, arg) ->
    of_list [ f; arg ]
    <+> (shrink_expr f >|= fun a' -> Apply (a', arg))
    <+> (shrink_expr arg >|= fun a' -> Apply (f, a'))
  | Function ((pat1, expr1), cases) ->
    of_list (expr1 :: List.map snd cases)
    <+> (shrink_pattern pat1 >|= fun a' -> Function ((a', expr1), cases))
    <+> (shrink_expr expr1 >|= fun a' -> Function ((pat1, a'), cases))
    <+> (QCheck.Shrink.list
           ~shrink:(fun (p, e) ->
             (let* p_shr = shrink_pattern p in
              return (p_shr, e))
             <+>
             let* e_shr = shrink_expr e in
             return (p, e_shr))
           cases
         >|= fun a' -> Function ((pat1, expr1), a'))
  | Match (value, (pat1, expr1), cases) ->
    of_list (value :: expr1 :: List.map snd cases)
    <+> (shrink_expr value >|= fun a' -> Match (a', (pat1, expr1), cases))
    <+> (shrink_pattern pat1 >|= fun a' -> Match (value, (a', expr1), cases))
    <+> (shrink_expr expr1 >|= fun a' -> Match (value, (pat1, a'), cases))
    <+> (QCheck.Shrink.list
           ~shrink:(fun (p, e) ->
             (let* p_shr = shrink_pattern p in
              return (p_shr, e))
             <+>
             let* e_shr = shrink_expr e in
             return (p, e_shr))
           cases
         >|= fun a' -> Match (value, (pat1, expr1), a'))
  | Option (Some e) ->
    of_list [ e; Option None ] <+> (shrink_expr e >|= fun a' -> Option (Some a'))
  | Option None -> empty
  | EConstraint (e, t) -> return e <+> shrink_expr e >|= fun a' -> EConstraint (a', t)
  | LetIn (rec_flag, bind, inner_e) ->
    shrink_bind bind
    >|= (fun a' -> LetIn (rec_flag, a', inner_e))
    <+> (shrink_expr inner_e >|= fun a' -> LetIn (rec_flag, bind, a'))

and shrink_pattern = function
  | PList l -> QCheck.Shrink.list ~shrink:shrink_pattern l >|= fun l' -> PList l'
  | PCons (l, r) ->
    shrink_pattern l
    >|= (fun l' -> PCons (l', r))
    <+> (shrink_pattern r >|= fun r' -> PCons (l, r'))
  | PTuple (p1, p2, rest) ->
    of_list [ p1; p2 ]
    <+> (shrink_pattern p1 >|= fun p1' -> PTuple (p1', p2, rest))
    <+> (shrink_pattern p2 >|= fun p2' -> PTuple (p1, p2', rest))
    <+> (QCheck.Shrink.list ~shrink:shrink_pattern rest
         >|= fun rest' -> PTuple (p1, p2, rest'))
  | PConst lt -> shrink_lt lt >|= fun lt' -> PConst lt'
  | POption (Some p) -> return p
  | POption None -> empty
  | Wild -> empty
  | PVar _ -> empty
  | PConstraint (p, _) -> return p
;;

let shrink_str_item : structure_item QCheck.Shrink.t = function
  | rec_flag, bind, binds ->
    shrink_bind bind
    >|= (fun a' -> rec_flag, a', binds)
    <+> (QCheck.Shrink.list ~shrink:shrink_bind binds >|= fun a' -> rec_flag, bind, a')
    <+>
      (match binds with
      | [] -> empty
      | hd :: _ -> return (rec_flag, hd, []))
;;

let shrink_program : program QCheck.Shrink.t = function
  | hd :: tl ->
    shrink_str_item hd
    >|= (fun hd' -> hd' :: tl)
    <+> (QCheck.Shrink.list ~shrink:shrink_str_item tl >|= fun tl' -> hd :: tl')
  | _ -> empty
;;
