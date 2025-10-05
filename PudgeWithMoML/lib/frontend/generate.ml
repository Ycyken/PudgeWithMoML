[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open QCheck.Gen
open Keywords

let gen_varname =
  let gen_lowercase_str =
    let gen_char = char_range 'a' 'z' in
    let len = int_range 1 5 in
    string_size ~gen:gen_char len
  in
  gen_lowercase_str
  >>= fun name -> if is_keyword name then gen_lowercase_str else return name
;;

let gen_operator =
  let gen_op =
    let gen_char = oneofl (String.to_seq op_chars |> List.of_seq) in
    let len = int_range 1 3 in
    string_size ~gen:gen_char len
  in
  gen_op >>= fun op -> if is_keyword op then gen_op else return op
;;

let gen_ident = oneof [ gen_varname; gen_operator ]
