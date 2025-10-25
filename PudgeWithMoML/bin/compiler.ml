[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open PudgeWithMoML.Frontend.Parser
open PudgeWithMoML.Frontend.Inferencer
open PudgeWithMoML.Middle_end.AlphaConversion
open PudgeWithMoML.Middle_end.Anf
open PudgeWithMoML.Middle_end.AnfPP
open PudgeWithMoML.Riscv.Codegen
open Stdio
open Format

type opts =
  { mutable input_file : string
  ; mutable output_file : string
  ; mutable dump_parsetree : bool
  ; mutable dump_types : bool
  ; mutable dump_anf : bool
  }

let compiler opts =
  let input =
    if opts.input_file <> ""
    then In_channel.read_all opts.input_file
    else In_channel.input_all stdin
  in
  let program = parse input in
  match program with
  | Error e -> eprintf "Parsing error: %s\n" e
  | Ok program ->
    if opts.dump_parsetree
    then (
      PudgeWithMoML.Frontend.Ast.pp_program std_formatter program;
      printf "\n")
    else (
      match infer program with
      | Error e -> fprintf std_formatter "Type error: %a\n" pp_error e
      | Ok env ->
        if opts.dump_types
        then TypeEnv.pp std_formatter env
        else (
          let oc = Out_channel.create opts.output_file in
          let fmt = Format.formatter_of_out_channel oc in
          let a_converted = convert_program program in
          let anf = anf_program a_converted in
          let () =
            if opts.dump_anf
            then (
              let oc = Out_channel.create "main.anf" in
              let fmt = Format.formatter_of_out_channel oc in
              pp_aprogram fmt anf;
              Out_channel.close oc)
          in
          gen_aprogram fmt anf))
;;

let () =
  let opts =
    { input_file = ""
    ; output_file = "main.s"
    ; dump_parsetree = false
    ; dump_types = false
    ; dump_anf = false
    }
  in
  let open Stdlib.Arg in
  let speclist =
    [ "-fromfile", String (fun filename -> opts.input_file <- filename), "Input file name"
    ; "-o", String (fun filename -> opts.output_file <- filename), "Output file name"
    ; ( "-dparsetree"
      , Unit (fun _ -> opts.dump_parsetree <- true)
      , "Dump parse tree, don't typecheck and codegen anything" )
    ; ( "-dtypes"
      , Unit (fun _ -> opts.dump_types <- true)
      , "Dump types, don't codegen anything" )
    ; ( "-anf"
      , Unit (fun _ -> opts.dump_anf <- true)
      , "Generate main.anf file with ANF representation" )
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
