[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open PudgeWithMoML.Frontend.Qcheck_test.Run

type opts =
  { mutable runs : int
  ; mutable pp : bool
  ; mutable dparse : bool
  }

let () =
  let opts = { runs = 1; pp = false; dparse = false } in
  let speclist =
    [ "-seed", Arg.Int QCheck_base_runner.set_seed, " Set seed"
    ; "-gen", Arg.Int (fun n -> opts.runs <- n), " Number of runs"
    ; "-pp", Arg.Unit (fun _ -> opts.pp <- true), " Pretty print ast in a failure case"
    ; ( "-onlygen"
      , Arg.Unit (fun _ -> opts.dparse <- true)
      , " Don't parse, only generate Ast and print" )
    ]
  in
  let () = Arg.parse speclist (fun _ -> assert false) "help" in
  let printer =
    if opts.pp
    then PudgeWithMoML.Frontend.AstPP.pp_program
    else PudgeWithMoML.Frontend.Ast.pp_program
  in
  run opts.runs printer opts.dparse
;;
