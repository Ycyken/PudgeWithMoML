[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open Anf

val pp_cexpr : Format.formatter -> cexpr -> unit
val pp_aexpr : Format.formatter -> aexpr -> unit
val pp_astr_item : Format.formatter -> astr_item -> unit
val pp_aprogram : Format.formatter -> aprogram -> unit
