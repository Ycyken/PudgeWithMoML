[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open PudgeWithMoML.Frontend.Parser
open PudgeWithMoML.Riscv.Codegen
open PudgeWithMoML.Frontend.Inferencer
open Stdio

type opts =
  { mutable input_file : string
  ; mutable output_file : string
  ; mutable dump_parsetree : bool
  ; mutable dump_types : bool
  }

let compiler opts =
  let input = In_channel.read_all opts.input_file |> String.trim in
  let program = parse input in
  match program with
  | Error e -> eprintf "Parsing error: %s\n" e
  | Ok program ->
    if opts.dump_parsetree
    then (
      PudgeWithMoML.Frontend.Ast.pp_program Format.std_formatter program;
      printf "\n")
    else
      let open Format in
      (match infer program with
       | Error e -> fprintf std_formatter "Type error: %a\n" pp_error e
       | Ok env ->
         if opts.dump_types
         then TypeEnv.pp std_formatter env
         else (
           let oc = Out_channel.create opts.output_file in
           let fmt = Format.formatter_of_out_channel oc in
           gen_program program fmt))
;;

let () =
  let opts =
    { input_file = ""; output_file = "a.s"; dump_parsetree = false; dump_types = false }
  in
  let open Stdlib.Arg in
  let speclist =
    [ "-fromfile", String (fun filename -> opts.input_file <- filename), "Input file name"
    ; "-o", String (fun filename -> opts.output_file <- filename), "Output file name"
    ; ( "-dparsetree"
      , Unit (fun _ -> opts.dump_parsetree <- true)
      , "Dump parse tree, don't typecheck and evaluate anything" )
    ; ( "-dtypes"
      , Unit (fun _ -> opts.dump_types <- true)
      , "Dump types, don't evaluate anything" )
    ]
  in
  let anon_func _ =
    Stdlib.Format.eprintf "Positioned arguments are not supported\n";
    Stdlib.exit 1
  in
  let usage_msg = "Mini-ml to riscv compiler" in
  let () = parse speclist anon_func usage_msg in
  compiler opts
;;
