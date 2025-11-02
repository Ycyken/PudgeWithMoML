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

type context = (string, string, String.comparator_witness) Map.t

let default = Map.of_alist_exn (module String) (List.map std_ops ~f:(fun op -> op, op))

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

and convert_list_pat ctx pats =
  List.fold_right
    ~f:(fun pat acc ->
      let* pats, ctx = acc in
      let+ pat', ctx = convert_pat ctx pat in
      pat' :: pats, ctx)
    ~init:(return ([], ctx))
    pats
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
  | LetIn (Nonrec, (name, value), body) ->
    let* value' = convert_expr ctx value in
    let* pat', ctx = convert_pat ctx name in
    let+ body' = convert_expr ctx body in
    LetIn (Nonrec, (pat', value'), body')
  | LetIn (Rec, (name, value), body) ->
    let* pat', ctx = convert_pat ctx name in
    let* value' = convert_expr ctx value in
    let+ body' = convert_expr ctx body in
    LetIn (Rec, (pat', value'), body')

and convert_list_expr ctx = function
  | [] -> return []
  | x :: xs ->
    let* x' = convert_expr ctx x in
    let+ xs' = convert_list_expr ctx xs in
    x' :: xs'
;;

let convert_str_item ctx (rec_flag, (pat, value), binds) : (structure_item * context) t =
  let pats = List.map binds ~f:fst in
  let exprs = List.map binds ~f:snd in
  let* pat', new_ctx = convert_pat ctx pat in
  let* pats', new_ctx = convert_list_pat new_ctx pats in
  let ctx =
    match rec_flag with
    | Rec -> new_ctx
    | Nonrec -> ctx
  in
  let* expr' = convert_expr ctx value in
  let+ exprs' = convert_list_expr ctx exprs in
  (rec_flag, (pat', expr'), List.zip_exn pats' exprs'), new_ctx
;;

let convert_program (program : program) =
  let prg_w_ctx =
    List.fold
      ~f:(fun acc str_item ->
        let* items, ctx = acc in
        let+ item, ctx = convert_str_item ctx str_item in
        item :: items, ctx)
      ~init:(return ([], default))
      program
  in
  run prg_w_ctx 0 |> snd |> fst |> List.rev
;;

let%expect_test "test_pattern" =
  let open Stdlib.Format in
  let open Frontend.AstPP in
  let all_patterns : pattern list =
    [ Wild
    ; PList [ PConst (Int_lt 1); PVar "x" ]
    ; PCons (PConst (Int_lt 1), PVar "xs")
    ; PTuple (PVar "a", PVar "b", [ PConst (Int_lt 2) ])
    ; PConst (Int_lt 42)
    ; PVar "x"
    ; POption None
    ; POption (Some (PVar "y"))
    ; PConstraint (PVar "z", Primitive "t")
    ]
  in
  List.iter
    ~f:(fun pattern ->
      let result = convert_pat default pattern in
      let result = run result 0 |> snd |> fst in
      printf "%a\n" pp_pattern result)
    all_patterns;
  [%expect
    {|
    _
    [1; x__0 ]
    (1) :: (xs__0 )
    (a__0 , b__1 , 2)
    42
    x__0
    None
    Some (y__0 )
    (z__0  : t) |}]
;;

let%expect_test "test_expr" =
  let open Stdlib.Format in
  let open Frontend.AstPP in
  let all_exprs : expr list =
    [ Const (Int_lt 1)
    ; Tuple (Const (Int_lt 1), Const (Int_lt 2), [ Const (Int_lt 3) ])
    ; List [ Const (Int_lt 1); Const (Int_lt 2) ]
    ; Variable "x"
    ; If_then_else (Const (Bool_lt true), Const (Int_lt 1), Some (Const (Int_lt 0)))
    ; If_then_else (Const (Bool_lt false), Const (Int_lt 2), None)
    ; Lambda (PVar "x", Variable "x")
    ; Apply (Apply (Variable "+", Const (Int_lt 3)), Const (Int_lt 4))
    ; Apply (Variable "f", Const (Int_lt 5))
    ; Function
        ((PConst (Int_lt 1), Const (Int_lt 1)), [ PConst (Int_lt 2), Const (Int_lt 2) ])
    ; Match
        ( Variable "v"
        , (PConst (Int_lt 0), Const (Int_lt 0))
        , [ PConst (Int_lt 1), Const (Int_lt 1) ] )
    ; Option None
    ; Option (Some (Const (Int_lt 9)))
    ; EConstraint (Variable "x", Primitive "t")
    ; LetIn (Nonrec, (PVar "z", Const (Int_lt 9)), Variable "z")
    ; LetIn
        ( Rec
        , (PVar "f", Lambda (PVar "x", Variable "x"))
        , Apply (Variable "f", Const (Int_lt 1)) )
    ]
  in
  List.iter
    ~f:(fun expr ->
      let result = convert_expr default expr in
      let result = run result 0 |> snd in
      printf "%a\n" pp_expr result)
    all_exprs;
  [%expect {|
    1
    ((1), (2), (3))
    [1; 2]
    x
    if (true) then (1) else 0
    if (false) then (2)
    fun (x__0 ) -> x__0
    (3) + (4)
    (f ) (5)
    fun (function_arg__0__1 ) -> match (function_arg__0__1 ) with
    | 1 -> (1)
    | 2 -> (2)

    match (v ) with
    | 0 -> (0)
    | 1 -> (1)

    None
    Some (9)
    (x  : t)
    let z__0  = 9 in
    z__0
    let rec f__0  = fun (x__1 ) -> x__1  in
    (f__0 ) (1) |}]
;;
