(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

open PudgeWithMoML.Frontend.Parser
open PudgeWithMoML.Frontend.Ast

let%expect_test "fac" =
  let input =
    {| let rec fac n =
  if n <= 1
  then 1
  else let n1 = n-1 in
       let m = fac n1 in
       n*m

let main = fac 4 |}
  in
  let result = parse input in
  let () =
    match result with
    | Error e -> print_endline e
    | Ok s -> pp_program Format.std_formatter s
  in
  [%expect
    {|
      [(Rec,
        [((PVar "fac"),
          (Lambda ((PVar "n"),
             (If_then_else (
                (Apply ((Apply ((Variable "<="), (Variable "n"))),
                   (Const (Int_lt 1)))),
                (Const (Int_lt 1)),
                (Some (LetIn (Nonrec,
                         [((PVar "n1"),
                           (Apply ((Apply ((Variable "-"), (Variable "n"))),
                              (Const (Int_lt 1)))))
                           ],
                         (LetIn (Nonrec,
                            [((PVar "m"),
                              (Apply ((Variable "fac"), (Variable "n1"))))],
                            (Apply ((Apply ((Variable "*"), (Variable "n"))),
                               (Variable "m")))
                            ))
                         )))
                ))
             )))
          ]);
        (Nonrec, [((PVar "main"), (Apply ((Variable "fac"), (Const (Int_lt 4)))))])
        ] |}]
;;
