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

let%expect_test "binary subtract" =
  let input = {| let _ = a - 3|} in
  let result = parse input in
  let () = print_result result in
  [%expect
    {|
    [(Nonrec,
      (Wild,
       (Apply ((Apply ((Variable "-"), (Variable "a"))), (Const (Int_lt 3))))),
      [])] |}]
;;

let%expect_test "function apply of letIn" =
  let input = {| let _ = f (let x = false in true) || x |} in
  let result = parse input in
  let () = print_result result in
  [%expect
    {|
    [(Nonrec,
      (Wild,
       (Apply (
          (Apply ((Variable "||"),
             (Apply ((Variable "f"),
                (LetIn (Nonrec, ((PVar "x"), (Const (Bool_lt false))), [],
                   (Const (Bool_lt true))))
                ))
             )),
          (Variable "x")))),
      [])] |}]
;;

let%expect_test "arithmetic with unary operations and variables" =
  let input = {| let _ = - a - - b + 4|} in
  let result = parse input in
  let () = print_result result in
  [%expect
    {|
    [(Nonrec,
      (Wild,
       (Apply (
          (Apply ((Variable "+"),
             (Apply (
                (Apply ((Variable "-"), (Apply ((Variable "~-"), (Variable "a")))
                   )),
                (Apply ((Variable "~-"), (Variable "b")))))
             )),
          (Const (Int_lt 4))))),
      [])] |}]
;;

let%expect_test "sum of function applying" =
  let input = {| let _ = f 4 + g 3|} in
  let result = parse input in
  let () = print_result result in
  [%expect
    {|
    [(Nonrec,
      (Wild,
       (Apply (
          (Apply ((Variable "+"), (Apply ((Variable "f"), (Const (Int_lt 4)))))),
          (Apply ((Variable "g"), (Const (Int_lt 3))))))),
      [])] |}]
;;

let%expect_test "order of logical expressions and function applying" =
  let input = {| let _ = let x = true in not x || true && f 12|} in
  let result = parse input in
  let () = print_result result in
  [%expect
    {|
[(Nonrec,
  (Wild,
   (LetIn (Nonrec, ((PVar "x"), (Const (Bool_lt true))), [],
      (Apply (
         (Apply ((Variable "||"), (Apply ((Variable "not"), (Variable "x")))
            )),
         (Apply ((Apply ((Variable "&&"), (Const (Bool_lt true)))),
            (Apply ((Variable "f"), (Const (Int_lt 12))))))
         ))
      ))),
  [])] |}]
;;

let%expect_test "logical expression" =
  let input = {| let _ = (3 + 5) >= 8 || true && (5 <> 4) |} in
  let result = parse input in
  let () = print_result result in
  [%expect
    {|
    [(Nonrec,
      (Wild,
       (Apply (
          (Apply ((Variable "||"),
             (Apply (
                (Apply ((Variable ">="),
                   (Apply ((Apply ((Variable "+"), (Const (Int_lt 3)))),
                      (Const (Int_lt 5))))
                   )),
                (Const (Int_lt 8))))
             )),
          (Apply ((Apply ((Variable "&&"), (Const (Bool_lt true)))),
             (Apply ((Apply ((Variable "<>"), (Const (Int_lt 5)))),
                (Const (Int_lt 4))))
             ))
          ))),
      [])] |}]
;;

let%expect_test "unary chain" =
  let input = "let _ = not not ( not true && false || 3 > 5)" in
  let result = parse input in
  let () = print_result result in
  [%expect
    {|
[(Nonrec,
  (Wild,
   (Apply ((Apply ((Variable "not"), (Variable "not"))),
      (Apply (
         (Apply ((Variable "||"),
            (Apply (
               (Apply ((Variable "&&"),
                  (Apply ((Variable "not"), (Const (Bool_lt true)))))),
               (Const (Bool_lt false))))
            )),
         (Apply ((Apply ((Variable ">"), (Const (Int_lt 3)))),
            (Const (Int_lt 5))))
         ))
      ))),
  [])] |}]
;;

let%expect_test "if with comparison" =
  let input = "let _ = if 3 > 2 && false then 5 + 7 else 12" in
  let result = parse input in
  let () = print_result result in
  [%expect
    {|
    [(Nonrec,
      (Wild,
       (If_then_else (
          (Apply (
             (Apply ((Variable "&&"),
                (Apply ((Apply ((Variable ">"), (Const (Int_lt 3)))),
                   (Const (Int_lt 2))))
                )),
             (Const (Bool_lt false)))),
          (Apply ((Apply ((Variable "+"), (Const (Int_lt 5)))),
             (Const (Int_lt 7)))),
          (Some (Const (Int_lt 12)))))),
      [])] |}]
;;

let%expect_test "sum with if" =
  let input = "let _ = a + if 3 > 2 then 2 else 1" in
  let result = parse input in
  let () = print_result result in
  [%expect
    {|
    [(Nonrec,
      (Wild,
       (Apply ((Apply ((Variable "+"), (Variable "a"))),
          (If_then_else (
             (Apply ((Apply ((Variable ">"), (Const (Int_lt 3)))),
                (Const (Int_lt 2)))),
             (Const (Int_lt 2)), (Some (Const (Int_lt 1)))))
          ))),
      [])] |}]
;;

let%expect_test "inner expressions with LetIn and If" =
  let input =
    "let _ = if let x = true in let y = false in x || y then 3 else if 5 > 3 then 2 else \
     1"
  in
  let result = parse input in
  let () = print_result result in
  [%expect
    {|
    [(Nonrec,
      (Wild,
       (If_then_else (
          (LetIn (Nonrec, ((PVar "x"), (Const (Bool_lt true))), [],
             (LetIn (Nonrec, ((PVar "y"), (Const (Bool_lt false))), [],
                (Apply ((Apply ((Variable "||"), (Variable "x"))), (Variable "y")
                   ))
                ))
             )),
          (Const (Int_lt 3)),
          (Some (If_then_else (
                   (Apply ((Apply ((Variable ">"), (Const (Int_lt 5)))),
                      (Const (Int_lt 3)))),
                   (Const (Int_lt 2)), (Some (Const (Int_lt 1))))))
          ))),
      [])] |}]
;;

let%expect_test "fail in ITE with incorrect else expression" =
  let input = "let _ = if true then 1 else 2c" in
  let result = parse input in
  let () = print_result result in
  [%expect {| Parse error: : end_of_input |}]
;;

let%expect_test "fail in apply with complex expression without parenteses" =
  let input = "let _ = f let x = 1 in x" in
  let result = parse input in
  let () = print_result result in
  [%expect {| Parse error: : end_of_input |}]
;;

let%expect_test "apply if with parentheses" =
  let input = "let _ = (if(false)then(a) else(b))c" in
  let result = parse input in
  let () = print_result result in
  [%expect
    {|
    [(Nonrec,
      (Wild,
       (Apply (
          (If_then_else ((Const (Bool_lt false)), (Variable "a"),
             (Some (Variable "b")))),
          (Variable "c")))),
      [])] |}]
;;

let%expect_test "precedence of -, apply, tuple etc" =
  let input = "let _ = -(let x = 1 in x) (fun x -> x) 1,2,3" in
  let result = parse input in
  let () = print_result result in
  [%expect
    {|
    [(Nonrec,
      (Wild,
       (Tuple (
          (Apply ((Variable "~-"),
             (Apply (
                (Apply (
                   (LetIn (Nonrec, ((PVar "x"), (Const (Int_lt 1))), [],
                      (Variable "x"))),
                   (Lambda ((PVar "x"), (Variable "x"))))),
                (Const (Int_lt 1))))
             )),
          (Const (Int_lt 2)), [(Const (Int_lt 3))]))),
      [])] |}]
;;

let%expect_test "precedence of infix operator with if and apply" =
  let input = "let _ =  (if true then 1 + 2 f (function | x -> x) ) k" in
  let result = parse input in
  let () = print_result result in
  [%expect
    {|
    [(Nonrec,
      (Wild,
       (Apply (
          (If_then_else ((Const (Bool_lt true)),
             (Apply ((Apply ((Variable "+"), (Const (Int_lt 1)))),
                (Apply ((Apply ((Const (Int_lt 2)), (Variable "f"))),
                   (Function (((PVar "x"), (Variable "x")), []))))
                )),
             None)),
          (Variable "k")))),
      [])] |}]
;;
