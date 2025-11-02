[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

val pp_expr : Format.formatter -> Ast.expr -> unit
val pp_structure_item : Format.formatter -> Ast.structure_item -> unit
val pp_pattern : Format.formatter -> Ast.pattern -> unit
val pp_program : Format.formatter -> Ast.program -> unit
val pp_literal : Format.formatter -> Ast.literal -> unit
val pp_rec_flag : Format.formatter -> Ast.is_recursive -> unit
val pp_varname : Format.formatter -> string -> unit
