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
  [%expect
    {|
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

let%expect_test "operators precedence and associativity" =
  let input = "let _ = a || b :: c :: d * e" in
  let result = parse input in
  let () = print_result result in
  [%expect
    {|
    [(Nonrec,
      (Wild,
       (Apply ((Apply ((Variable "||"), (Variable "a"))),
          (Apply ((Apply ((Variable "::"), (Variable "b"))),
             (Apply ((Apply ((Variable "::"), (Variable "c"))),
                (Apply ((Apply ((Variable "*"), (Variable "d"))), (Variable "e")
                   ))
                ))
             ))
          ))),
      [])] |}]
;;

let%expect_test "operator as pattern" =
  let input =
    {|let _ = match 4 with
| (+) -> 5
|}
  in
  let result = parse input in
  let () = print_result result in
  [%expect
    {|
    [(Nonrec,
      (Wild, (Match ((Const (Int_lt 4)), ((PVar "+"), (Const (Int_lt 5))), []))),
      [])] |}]
;;

let%expect_test "nested tuples" =
  let input =
    {|let _ = (1,2,3), t, (), (4), true, f
|}
  in
  let result = parse input in
  let () = print_result result in
  [%expect
    {|
    [(Nonrec,
      (Wild,
       (Tuple (
          (Tuple ((Const (Int_lt 1)), (Const (Int_lt 2)), [(Const (Int_lt 3))])),
          (Variable "t"),
          [(Const Unit_lt); (Const (Int_lt 4)); (Const (Bool_lt true));
            (Variable "f")]
          ))),
      [])] |}]
;;

let%expect_test "types" =
  let input =
    {|let a (b: int) (c:'7) (d: '2 -> unit) (e: '3 list ) (f: '4 -> (f) * '1) (g: '2 -> sss option) = 0|}
  in
  let result = parse input in
  let () = print_result result in
  [%expect
    {|
    [(Nonrec,
      ((PVar "a"),
       (Lambda ((PConstraint ((PVar "b"), (Primitive "int"))),
          (Lambda ((PConstraint ((PVar "c"), (Type_var 7))),
             (Lambda (
                (PConstraint ((PVar "d"),
                   (Arrow ((Type_var 2), (Primitive "unit"))))),
                (Lambda ((PConstraint ((PVar "e"), (Type_list (Type_var 3)))),
                   (Lambda (
                      (PConstraint ((PVar "f"),
                         (Arrow ((Type_var 4),
                            (Type_tuple ((Primitive "f"), (Type_var 1), []))))
                         )),
                      (Lambda (
                         (PConstraint ((PVar "g"),
                            (Arrow ((Type_var 2), (TOption (Primitive "sss")))))),
                         (Const (Int_lt 0))))
                      ))
                   ))
                ))
             ))
          ))),
      [])] |}]
;;

let%expect_test "nested types" =
  let input = {|let a (b: '3 list list option) (c: int option option list) = 0|} in
  let result = parse input in
  let () = print_result result in
  [%expect
    {|
    [(Nonrec,
      ((PVar "a"),
       (Lambda (
          (PConstraint ((PVar "b"),
             (TOption (Type_list (Type_list (Type_var 3)))))),
          (Lambda (
             (PConstraint ((PVar "c"),
                (Type_list (TOption (TOption (Primitive "int")))))),
             (Const (Int_lt 0))))
          ))),
      [])] |}]
;;
