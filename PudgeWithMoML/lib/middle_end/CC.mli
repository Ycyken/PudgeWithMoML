[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open Base
open Anf

(* Apply closure conversion to aprogram. *)
(* After conversion all function are closed (withour free variables). *)
val convert_cc_pr : Anf.aprogram -> (aprogram, string) Base.Result.t
