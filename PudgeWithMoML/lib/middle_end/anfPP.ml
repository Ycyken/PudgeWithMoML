[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open Format
open Frontend.AstPP
open Anf

let pp_imm fmt = function
  | ImmConst l -> pp_literal fmt l
  | ImmVar v -> pp_varname fmt v
;;

let rec pp_cexpr fmt = function
  | CImm imm -> pp_imm fmt imm
  | CTuple (i1, i2, rest) ->
    fprintf fmt "(";
    pp_print_list ~pp_sep:(fun fmt () -> fprintf fmt ", ") pp_imm fmt (i1 :: i2 :: rest);
    fprintf fmt ")"
  | CLambda (arg, body) -> fprintf fmt "fun %a ->\n%a" pp_imm arg pp_aexpr body
  | CBinop (op, left, right) -> fprintf fmt "%a %s %a" pp_imm left op pp_imm right
  | CNot i -> fprintf fmt "not %a" pp_imm i
  | CApp (f, arg) -> fprintf fmt "%a %a" pp_imm f pp_imm arg
  | CIte (i, t, e) ->
    fprintf fmt "if %a then (%a)\nelse %a " pp_imm i pp_aexpr t pp_aexpr e

and pp_aexpr fmt = function
  | ALet (rec_flag, name, cexpr, body) ->
    Format.fprintf
      fmt
      "%a %s = %a in\n%a"
      pp_rec_flag
      rec_flag
      name
      pp_cexpr
      cexpr
      pp_aexpr
      body
  | ACExpr cexpr -> pp_cexpr fmt cexpr
;;

let pp_bind fmt : binding -> unit = function
  | name, body -> fprintf fmt "%a = %a " pp_varname name pp_aexpr body
;;

let pp_astr_item fmt (rec_flag, bind, binds) =
  fprintf fmt "let %a " pp_rec_flag rec_flag;
  pp_print_list ~pp_sep:(fun fmt () -> fprintf fmt "\n\nand ") pp_bind fmt (bind :: binds)
;;

let pp_aprogram fmt (program : aprogram) =
  pp_print_list ~pp_sep:(fun fmt () -> fprintf fmt "\n\n") pp_astr_item fmt program
;;
