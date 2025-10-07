[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open Ast

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

module Make (R : R) : sig
  type t

  val extract_names_from_pattern : pattern -> t R.t
  val elements : t -> string list
end
