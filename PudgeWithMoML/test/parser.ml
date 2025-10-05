[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open PudgeWithMoML.Frontend.Parser
open PudgeWithMoML.Frontend.Ast

let print_result = function
  | Ok pr -> pp_program Format.std_formatter pr
  | Error e -> Format.fprintf Format.std_formatter "Parse error: %s" e
;;

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
  let () = print_result result in
  [%expect
    {|
      [(Rec,
        ((PVar "fac"),
         (Lambda ((PVar "n"),
            (If_then_else (
               (Apply ((Apply ((Variable "<="), (Variable "n"))),
                  (Const (Int_lt 1)))),
               (Const (Int_lt 1)),
               (Some (LetIn (Nonrec,
                        ((PVar "n1"),
                         (Apply ((Apply ((Variable "-"), (Variable "n"))),
                            (Const (Int_lt 1))))),
                        [],
                        (LetIn (Nonrec,
                           ((PVar "m"), (Apply ((Variable "fac"), (Variable "n1")))),
                           [],
                           (Apply ((Apply ((Variable "*"), (Variable "n"))),
                              (Variable "m")))
                           ))
                        )))
               ))
            ))),
        []);
        (Nonrec, ((PVar "main"), (Apply ((Variable "fac"), (Const (Int_lt 4))))),
         [])
        ] |}]
;;

let%expect_test "custom infix operator" =
  let input = "let _ = 1 %$*&+^~ y" in
  let result = parse input in
  let () = print_result result in
  [%expect {|
    [(Nonrec,
      (Wild,
       (Apply ((Apply ((Variable "%$*&+^~"), (Const (Int_lt 1)))), (Variable "y")
          ))),
      [])] |}]
;;

let%expect_test "operator as variable expr" =
  let input = "let _ = (+) 4" in
  let result = parse input in
  let () = print_result result in
  [%expect {| [(Nonrec, (Wild, (Apply ((Variable "+"), (Const (Int_lt 4))))), [])] |}]
;;

let%expect_test "operator as pattern" =
  let input =
    {|let _ = match 4 with
| (+) -> 5
|}
  in
  let result = parse input in
  let () = print_result result in
  [%expect {|
    [(Nonrec,
      (Wild, (Match ((Const (Int_lt 4)), ((PVar "+"), (Const (Int_lt 5))), []))),
      [])] |}]
;;
