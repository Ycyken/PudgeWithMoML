[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open Ast
open Format
open TypesPp
open Keywords

let pp_rec_flag fmt = function
  | Rec -> fprintf fmt "rec "
  | Nonrec -> ()
;;

let pp_varname fmt name =
  if String.for_all (String.contains op_chars) name
  then fprintf fmt "(%s)" name
  else fprintf fmt "%s" name
;;

let pp_literal fmt = function
  | Int_lt i -> fprintf fmt "%d" i
  | Bool_lt b -> fprintf fmt "%b" b
  | Unit_lt -> fprintf fmt "()"
;;

let rec pp_pattern fmt = function
  | Wild -> fprintf fmt "_ "
  | PList l ->
    fprintf fmt "[";
    pp_print_list ~pp_sep:(fun fmt () -> fprintf fmt "; ") pp_pattern fmt l;
    fprintf fmt "]"
  | PCons (l, r) -> fprintf fmt "(%a) :: (%a) " pp_pattern l pp_pattern r
  | PTuple (p1, p2, rest) ->
    fprintf fmt "(";
    pp_print_list
      ~pp_sep:(fun fmt () -> fprintf fmt ", ")
      pp_pattern
      fmt
      (p1 :: p2 :: rest);
    fprintf fmt ")"
  | PConst literal -> pp_literal fmt literal
  | PVar name -> fprintf fmt "%a " pp_varname name
  | POption p ->
    (match p with
     | None -> fprintf fmt "None "
     | Some p -> fprintf fmt "Some (%a) " pp_pattern p)
  | PConstraint (p, t) -> fprintf fmt "(%a : %a) " pp_pattern p pp_typ t

and pp_expr fmt = function
  | Const lt -> pp_literal fmt lt
  | Tuple (e1, e2, rest) ->
    fprintf fmt "(";
    pp_print_list
      ~pp_sep:(fun fmt () -> fprintf fmt ", ")
      pp_parens_expr
      fmt
      (e1 :: e2 :: rest);
    fprintf fmt ")"
  | List l ->
    fprintf fmt "[";
    pp_print_list ~pp_sep:(fun fmt () -> fprintf fmt "; ") pp_expr fmt l;
    fprintf fmt "]"
  | Variable name -> fprintf fmt "%a " pp_varname name
  | If_then_else (cond, then_body, else_body) ->
    fprintf fmt "if (%a) then (%a) " pp_expr cond pp_expr then_body;
    (match else_body with
     | Some body -> fprintf fmt "else %a " pp_expr body
     | None -> ())
  | Lambda (arg, body) -> fprintf fmt "fun (%a) -> %a" pp_pattern arg pp_expr body
  | Apply (Apply (Variable op, left), right)
    when String.for_all (String.contains op_chars) op ->
    fprintf fmt "(%a) %s (%a)" pp_expr left op pp_expr right
  | Apply (func, arg) -> fprintf fmt "(%a) (%a)" pp_expr func pp_expr arg
  | Function ((pat1, expr1), cases) ->
    fprintf fmt "function ";
    List.iter
      (fun (pat, expr) -> fprintf fmt "| %a -> (%a) \n" pp_pattern pat pp_expr expr)
      ((pat1, expr1) :: cases)
  | Match (value, (pat1, expr1), cases) ->
    fprintf fmt "match (%a) with \n" pp_expr value;
    List.iter
      (fun (pat, expr) -> fprintf fmt "| %a -> (%a) \n" pp_pattern pat pp_expr expr)
      ((pat1, expr1) :: cases)
  | Option e ->
    (match e with
     | None -> fprintf fmt "None "
     | Some e -> fprintf fmt "Some (%a)" pp_expr e)
  | EConstraint (e, t) -> fprintf fmt "(%a : %a) " pp_expr e pp_typ t
  | LetIn (rec_flag, bind, in_expr) ->
    fprintf fmt "let %a" pp_rec_flag rec_flag;
    pp_bind fmt bind;
    fprintf fmt "in\n";
    fprintf fmt "%a " pp_expr in_expr

and pp_bind fmt : binding -> unit = function
  | pat, body -> fprintf fmt "%a = %a " pp_pattern pat pp_expr body

and pp_parens_expr fmt expr = fprintf fmt "(%a)" pp_expr expr

let pp_structure_item fmt : structure_item -> unit = function
  | rec_flag, bind, binds ->
    fprintf fmt "let %a" pp_rec_flag rec_flag;
    pp_print_list
      ~pp_sep:(fun fmt () -> fprintf fmt "\n\nand ")
      pp_bind
      fmt
      (bind :: binds)
;;

let pp_program fmt (program : program) =
  pp_print_list ~pp_sep:(fun fmt () -> fprintf fmt "\n\n") pp_structure_item fmt program
;;

let%expect_test "pp god ast" =
  let sample_program : program =
    [ Nonrec, (PVar "x", Const (Int_lt 42)), [ PVar "extra", Const (Int_lt 100) ]
    ; ( Nonrec
      , (PList [ PVar "a"; PVar "b" ], List [ Const (Int_lt 1); Const (Int_lt 2) ])
      , [] )
    ; Nonrec, (PCons (PConst (Int_lt 1), PVar "tail"), Variable "tail"), []
    ; ( Nonrec
      , ( PTuple (PVar "p1", PVar "p2", [ PVar "p3"; PVar "+++" ])
        , Tuple (Variable "p1", Variable "p2", [ Variable "p3"; Variable "+++" ]) )
      , [] )
    ; Nonrec, (PConst (Bool_lt true), Const (Bool_lt false)), []
    ; ( Nonrec
      , ( Wild
        , If_then_else (Const (Bool_lt true), Const (Int_lt 1), Some (Const (Int_lt 0)))
        )
      , [] )
    ; Nonrec, (Wild, If_then_else (Const (Bool_lt true), Const (Int_lt 1), None)), []
    ; ( Nonrec
      , ( PVar "if_no_else"
        , If_then_else (Const (Bool_lt false), Const (Int_lt 2), Some (Const Unit_lt)) )
      , [] )
    ; Nonrec, (PVar "lam", Lambda (PVar "x", Variable "x")), []
    ; ( Nonrec
      , (PVar "apply_op", Apply (Apply (Variable "+", Const (Int_lt 3)), Const (Int_lt 4)))
      , [] )
    ; Nonrec, (PVar "apply_norm", Apply (Variable "f", Const (Int_lt 5))), []
    ; ( Nonrec
      , ( PVar "fn"
        , Function
            ( (PConst (Int_lt 1), Const (Int_lt 1))
            , [ PConst (Int_lt 2), Const (Int_lt 2) ] ) )
      , [] )
    ; ( Nonrec
      , ( PVar "mt"
        , Match
            ( Variable "v"
            , (PConst (Int_lt 0), Const (Int_lt 0))
            , [ PConst (Int_lt 1), Const (Int_lt 1) ] ) )
      , [] )
    ; Nonrec, (PVar "opt_some", Option (Some (Const (Int_lt 7)))), []
    ; Nonrec, (PVar "opt_none", Option None), []
    ; ( Nonrec
      , (PVar "letin", LetIn (Nonrec, (PVar "z", Const (Int_lt 9)), Variable "z"))
      , [] )
    ; ( Nonrec
      , ( PVar "big_tuple"
        , Tuple
            ( Tuple (Const (Int_lt 1), Const (Int_lt 2), [])
            , Const (Int_lt 3)
            , [ Const (Int_lt 4) ] ) )
      , [] )
    ; Nonrec, (POption None, Const (Int_lt 0)), []
    ; Nonrec, (POption (Some (PConst (Int_lt 8))), Const (Int_lt 8)), []
    ; Nonrec, (PVar "normal_name", Variable "normal_name"), []
    ; Nonrec, (PVar "constr_pattern", Const (Int_lt 0)), []
    ; ( Nonrec
      , ( PConstraint (PVar "constr_pattern", Primitive "Homka")
        , EConstraint (Const (Int_lt 0), Primitive "Homka") )
      , [] )
    ]
  in
  pp_program std_formatter sample_program;
  [%expect
    {|
    let x  = 42

    and extra  = 100

    let [a ; b ] = [1; 2]

    let (1) :: (tail )  = tail

    let (p1 , p2 , p3 , (+++) ) = ((p1 ), (p2 ), (p3 ), ((+++) ))

    let true = false

    let _  = if (true) then (1) else 0

    let _  = if (true) then (1)

    let if_no_else  = if (false) then (2) else ()

    let lam  = fun (x ) -> x

    let apply_op  = (3) + (4)

    let apply_norm  = (f ) (5)

    let fn  = function | 1 -> (1)
    | 2 -> (2)


    let mt  = match (v ) with
    | 0 -> (0)
    | 1 -> (1)


    let opt_some  = Some (7)

    let opt_none  = None

    let letin  = let z  = 9 in
    z

    let big_tuple  = ((((1), (2))), (3), (4))

    let None  = 0

    let Some (8)  = 8

    let normal_name  = normal_name

    let constr_pattern  = 0

    let (constr_pattern  : Homka)  = (0 : Homka) |}]
;;
