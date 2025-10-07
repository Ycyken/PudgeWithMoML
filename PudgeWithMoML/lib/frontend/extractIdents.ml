[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open Ast
open Base

module type R = sig
  type 'a t
  type error

  val return : 'a -> 'a t
  val fail : error -> 'a t
  val bound_error : error

  module Syntax : sig
    val ( let* ) : 'a t -> ('a -> 'b t) -> 'b t
  end
end

module ExtractIdents (R : R) : sig
  type t

  val extract_names_from_pattern : pattern -> t R.t
  val elements : t -> string list
end = struct
  include Stdlib.Set.Make (String)
  open R
  open R.Syntax

  let union_disjoint s1 s2 =
    let* s1 = s1 in
    let* s2 = s2 in
    if is_empty (inter s1 s2) then return (union s1 s2) else fail bound_error
  ;;

  let union_disjoint_many sets = List.fold ~init:(return empty) ~f:union_disjoint sets

  let rec extract_names_from_pattern =
    let extr = extract_names_from_pattern in
    function
    | PVar name -> return (singleton name)
    | PList l -> union_disjoint_many (List.map l ~f:extr)
    | PCons (hd, tl) -> union_disjoint (extr hd) (extr tl)
    | PTuple (fst, snd, rest) ->
      union_disjoint_many (List.map ~f:extr (fst :: snd :: rest))
    | POption (Some p) -> extr p
    | PConstraint (p, _) -> extr p
    | POption None -> return empty
    | Wild -> return empty
    | PConst _ -> return empty
  ;;
end

module Make = ExtractIdents
