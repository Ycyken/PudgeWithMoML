[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open Ast
open TypedTree
open Format

module TypeEnv : sig
  type t

  val pp : formatter -> t -> unit
end

type error =
  [ `Occurs_check
  | `Undef_var of string
  | `Unification_failed of typ * typ
  | `Not_allowed_right_hand_side_let_rec
  | `Not_allowed_left_hand_side_let_rec
  | `Bound_several_times
  ]

val pp_error : formatter -> error -> unit
val infer : program -> (TypeEnv.t, error) result
