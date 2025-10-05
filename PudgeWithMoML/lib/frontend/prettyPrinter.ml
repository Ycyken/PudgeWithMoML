[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open Ast
open Format
open TypesPp
open Keywords

let pp_rec_flag fmt = function
  | Rec -> fprintf fmt "rec"
  | Nonrec -> ()
;;

let pp_varname fmt name =
  if String.for_all (String.contains op_chars) name
  then fprintf fmt "(%s)" name
  else fprintf fmt "%s " name
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
  | PConst literal -> fprintf fmt "%a " pp_expr (Const literal)
  | PVar name -> fprintf fmt "%a " pp_varname name
  | POption p ->
    (match p with
     | None -> fprintf fmt "None "
     | Some p -> fprintf fmt "Some (%a) " pp_pattern p)
  | PConstraint (p, t) -> fprintf fmt "(%a : %a) " pp_pattern p pp_typ t

and pp_expr fmt = function
  | Const (Int_lt i) -> fprintf fmt "%d " i
  | Const (Bool_lt b) -> fprintf fmt "%b " b
  | Const Unit_lt -> fprintf fmt "() "
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
  | Apply (func, arg) -> fprintf fmt "(%a) %a" pp_expr func pp_expr arg
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
  | LetIn (rec_flag, bind, binds, in_expr) ->
    fprintf fmt "let %a " pp_rec_flag rec_flag;
    pp_print_list
      ~pp_sep:(fun fmt () -> fprintf fmt "\n\nand ")
      pp_bind
      fmt
      (bind :: binds);
    fprintf fmt "in\n";
    fprintf fmt "%a " pp_expr in_expr

and pp_bind fmt : binding -> unit = function
  | pat, body -> fprintf fmt "%a = %a " pp_pattern pat pp_expr body

and pp_parens_expr fmt expr = fprintf fmt "(%a)" pp_expr expr

let pp_structure_item fmt : structure_item -> unit = function
  | rec_flag, bind, binds ->
    fprintf fmt "let %a " pp_rec_flag rec_flag;
    pp_print_list
      ~pp_sep:(fun fmt () -> fprintf fmt "\n\nand ")
      pp_bind
      fmt
      (bind :: binds)
;;

let pp_program fmt (program : program) =
  pp_print_list ~pp_sep:(fun fmt () -> fprintf fmt "\n\n") pp_structure_item fmt program
;;
