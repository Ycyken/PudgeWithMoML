[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open PudgeWithMoML.Frontend.Parser
open PudgeWithMoML.Frontend.Inferencer
open PudgeWithMoML.Middle_end.AlphaConversion
open PudgeWithMoML.Middle_end.Anf
open PudgeWithMoML.Middle_end.AnfPP
open PudgeWithMoML.Middle_end.CC
open PudgeWithMoML.Middle_end.LL
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
  match parse input with
  | Error e -> eprintf "Parsing error: %s\n" e
  | Ok program ->
    if opts.dump_parsetree
    then (
      PudgeWithMoML.Frontend.Ast.pp_program std_formatter program;
      printf "\n")
    else (
      match infer program with
      | Error e -> eprintf "Type error: %a\n" pp_error e
      | Ok env when opts.dump_types -> TypeEnv.pp std_formatter env
      | Ok _ ->
        (match program |> convert_program |> anf_program with
         | Error e -> eprintf "ANF conversion error: %s\n" e
         | Ok anf ->
           (match convert_cc_pr anf with
            | Error e -> eprintf "ANF closure conversion error: %s\n" e
            | Ok anf ->
              let anf = convert_ll_pr anf in
              if opts.dump_anf
              then
                Out_channel.with_file "main.anf" ~f:(fun oc ->
                  pp_aprogram (Format.formatter_of_out_channel oc) anf);
              Out_channel.with_file opts.output_file ~f:(fun oc ->
                match gen_aprogram (Format.formatter_of_out_channel oc) anf with
                | Error e -> eprintf "Codegen error: %s\n" e
                | Ok () -> ()))))
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
