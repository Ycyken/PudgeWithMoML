[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open TypedTree
open Format

let rec pp_typ fmt = function
  | Primitive s -> fprintf fmt "%s" s
  | Type_var var -> fprintf fmt "'%d" var
  | Arrow (fst, snd) ->
    (match fst with
     | Arrow _ -> fprintf fmt "(%a) -> %a" pp_typ fst pp_typ snd
     | _ -> fprintf fmt "%a -> %a" pp_typ fst pp_typ snd)
  | Type_list t ->
    (match t with
     | Arrow _ | Type_tuple _ -> fprintf fmt "(%a) list" pp_typ t
     | _ -> fprintf fmt "%a list" pp_typ t)
  | Type_tuple (first, second, rest) ->
    Format.pp_print_list
      ~pp_sep:(fun fmt () -> fprintf fmt " * ")
      (fun fmt typ ->
         match typ with
         | Type_tuple _ | Arrow _ -> fprintf fmt "(%a)" pp_typ typ
         | _ -> pp_typ fmt typ)
      fmt
      (first :: second :: rest)
  | TOption t ->
    (match t with
     | Type_tuple _ | Arrow _ -> fprintf fmt "(%a) option" pp_typ t
     | t -> fprintf fmt "%a option" pp_typ t)
;;
