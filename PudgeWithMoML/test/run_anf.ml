[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open PudgeWithMoML.Frontend.Parser
open PudgeWithMoML.Frontend.Inferencer
open PudgeWithMoML.Middle_end
open PudgeWithMoML.Middle_end.Anf
open PudgeWithMoML.Middle_end.AlphaConversion
open Format

let compiler () =
  let input = In_channel.input_all stdin in
  let program = parse input in
  match program with
  | Error e -> eprintf "Parsing error: %s\n" e
  | Ok program ->
    (match infer program with
     | Error e -> fprintf std_formatter "Type error: %a\n" pp_error e
     | Ok _ ->
       let a_converted = convert_program program in
       let anf = anf_program a_converted in
       AnfPP.pp_aprogram std_formatter anf)
;;

let () = compiler ()
