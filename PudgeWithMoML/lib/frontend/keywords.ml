(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

let is_keyword = function
  | "if"
  | "then"
  | "else"
  | "let"
  | "in"
  | "not"
  | "true"
  | "false"
  | "fun"
  | "match"
  | "with"
  | "and"
  | "Some"
  | "None"
  | "function"
  | "->"
  | "|"
  | ":"
  | "::"
  | "_" -> true
  | _ -> false
;;

let op_chars = "+-*/<>|!$%&.:=?@^~"
