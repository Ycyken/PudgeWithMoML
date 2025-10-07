[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open Generate

type binder = int [@@deriving show { with_path = false }, qcheck]

type typ =
  | Primitive of (string[@gen gen_varname])
  | Type_var of (binder[@gen QCheck.Gen.small_int])
  | Arrow of typ * typ
  | Type_list of typ
  | Type_tuple of
      typ
      * typ
      * (typ list[@gen QCheck.Gen.(list_size (0 -- 2) (gen_typ_sized (n / 20)))])
  | TOption of typ
[@@deriving show { with_path = false }, qcheck]

let arrow_t first_types last_type =
  let open Base in
  List.fold_right first_types ~init:last_type ~f:(fun left right -> Arrow (left, right))
;;

module VarSet = struct
  include Stdlib.Set.Make (Int)

  let pp fmt s =
    Format.fprintf fmt "[ ";
    iter (Format.fprintf fmt "%d; ") s;
    Format.fprintf fmt "]"
  ;;
end

type binder_set = VarSet.t [@@deriving show { with_path = false }]
type scheme = Scheme of binder_set * typ

let int_typ = Primitive "int"
let bool_typ = Primitive "bool"
let string_typ = Primitive "string"
let unit_typ = Primitive "unit"
let typevar n = Type_var n
