[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open Anf

(* Apply lambda lifting to aprogram. *)
(* After lifting all inner function will be top-level (all functions must be closed). *)
val convert_ll_pr : aprogram -> aprogram
