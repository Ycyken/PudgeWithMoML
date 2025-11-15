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
  ; mutable dump_cc : bool
  ; mutable gen_middleend : bool
  }

let file name f =
  Out_channel.with_file name ~f:(fun oc -> f (Format.formatter_of_out_channel oc))
;;

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
    then fprintf std_formatter "%a\n" PudgeWithMoML.Frontend.Ast.pp_program program
    else (
      match infer program with
      | Error e -> eprintf "Type error: %a\n" pp_error e
      | Ok env when opts.dump_types -> TypeEnv.pp std_formatter env
      | Ok _ ->
        (match program |> convert_program |> anf_program with
         | Error e -> eprintf "ANF conversion error: %s\n" e
         | Ok anf when opts.dump_anf -> fprintf std_formatter "%a\n" pp_aprogram anf
         | Ok anf ->
           (match convert_cc_pr anf with
            | Error e -> eprintf "ANF closure conversion error: %s\n" e
            | Ok cc when opts.dump_cc -> fprintf std_formatter "%a\n" pp_aprogram cc
            | Ok cc ->
              let ll = convert_ll_pr cc in
              if opts.gen_middleend then file "main.anf" (fun fmt -> pp_aprogram fmt ll);
              file opts.output_file (fun fmt ->
                match gen_aprogram fmt ll with
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
    ; dump_cc = false
    ; gen_middleend = false
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
    ; "-anf", Unit (fun _ -> opts.dump_anf <- true), "Dump ANF, don't codegen anything"
    ; ( "-cc"
      , Unit (fun _ -> opts.dump_cc <- true)
      , "Dump ANF after closure conversion, don't codegen anything" )
    ; ( "-gen_mid"
      , Unit (fun _ -> opts.gen_middleend <- true)
      , "Generate main.anf file with program representation after all middleend \
         transformations" )
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
