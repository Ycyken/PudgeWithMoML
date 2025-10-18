[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open Frontend.Ast

(** Performs alpha-conversion to distinguish shadowed variables 
    and prevent user-defined names from clashing with compiler-generated ones (e.g., from ANF).  *)
val convert_program : program -> program
