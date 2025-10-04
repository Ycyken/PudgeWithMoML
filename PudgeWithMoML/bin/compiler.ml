(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

open PudgeWithMoML.Frontend.Parser
open PudgeWithMoML.Riscv.Codegen
open Stdio

type opts =
  { mutable input_file : string
  ; mutable output_file : string
  }

let compiler input_file output_file =
  let input = In_channel.read_all input_file |> String.trim in
  let program = parse input in
  match program with
  | Error e -> eprintf "Parsing error: %s\n" e
  | Ok program ->
    let oc = Out_channel.create output_file in
    let fmt = Format.formatter_of_out_channel oc in
    gen_program program fmt
;;

let () =
  let opts = { input_file = ""; output_file = "a.s" } in
  let open Stdlib.Arg in
  let speclist =
    [ "-fromfile", String (fun filename -> opts.input_file <- filename), "Input file name"
    ; "-o", String (fun filename -> opts.output_file <- filename), "Output file name"
    ]
  in
  let anon_func _ =
    Stdlib.Format.eprintf "Positioned arguments are not supported\n";
    Stdlib.exit 1
  in
  let usage_msg = "Mini-ml to riscv compiler" in
  let () = parse speclist anon_func usage_msg in
  compiler opts.input_file opts.output_file
;;
