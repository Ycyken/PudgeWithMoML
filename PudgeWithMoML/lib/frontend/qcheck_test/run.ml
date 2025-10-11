[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open Ast
open Parser
open Format

let arbitrary_program printer =
  QCheck.make
    gen_program
    ~print:
      (asprintf "%a" (fun fmt c ->
         fprintf fmt "Generated:\n%a\n\n" printer c;
         match parse (asprintf "%a\n" AstPP.pp_program c) with
         | Ok parsed -> fprintf fmt "Parsed:\n%a" printer parsed
         | Error e -> fprintf fmt "Parsing error:\n%s\n" e))
    ~shrink:Shrink.shrink_program
;;

let run runs printer dparse =
  let arb = arbitrary_program printer in
  let _ =
    QCheck_base_runner.run_tests
      [ QCheck.(
          Test.make arb ~count:runs (fun c ->
            if dparse
            then (
              AstPP.pp_program Format.std_formatter c;
              true)
            else Ok c = parse (asprintf "%a\n" AstPP.pp_program c)))
      ]
  in
  ()
;;
