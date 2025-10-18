(fac)
  $ ../bin/compiler.exe -dparsetree <<'EOF'
  > let rec fac n =
  > if n <= 1
  > then 1
  > else let n1 = n-1 in
  >      let m = fac n1 in
  >      n*m
  > 
  > let main = fac 4
  > EOF
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
                    (LetIn (Nonrec,
                       ((PVar "m"), (Apply ((Variable "fac"), (Variable "n1")))),
                       (Apply ((Apply ((Variable "*"), (Variable "n"))),
                          (Variable "m")))
                       ))
                    )))
           ))
        ))),
    []);
    (Nonrec, ((PVar "main"), (Apply ((Variable "fac"), (Const (Int_lt 4))))),
     [])
    ]

(custom infix operator)
  $ ../bin/compiler.exe -dparsetree <<'EOF'
  > let _ = 1 %$*&+^~ y
  > EOF
  [(Nonrec,
    (Wild,
     (Apply ((Apply ((Variable "%$*&+^~"), (Const (Int_lt 1)))), (Variable "y")
        ))),
    [])]

(operator as variable expr)
  $ ../bin/compiler.exe -dparsetree <<'EOF'
  > let _ = (+) 4
  > EOF
  [(Nonrec, (Wild, (Apply ((Variable "+"), (Const (Int_lt 4))))), [])]

(operators precedence and associativity)
  $ ../bin/compiler.exe -dparsetree <<'EOF'
  > let _ = a || b :: c :: d * e
  > EOF
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
    [])]

(operator as pattern)
  $ ../bin/compiler.exe -dparsetree <<'EOF'
  > let _ = match 4 with
  > | (+) -> 5
  > EOF
  [(Nonrec,
    (Wild, (Match ((Const (Int_lt 4)), ((PVar "+"), (Const (Int_lt 5))), []))),
    [])]

(nested tuples)
  $ ../bin/compiler.exe -dparsetree <<'EOF'
  > let _ = (1,2,3), t, (), (4), true, f
  > EOF
  [(Nonrec,
    (Wild,
     (Tuple (
        (Tuple ((Const (Int_lt 1)), (Const (Int_lt 2)), [(Const (Int_lt 3))])),
        (Variable "t"),
        [(Const Unit_lt); (Const (Int_lt 4)); (Const (Bool_lt true));
          (Variable "f")]
        ))),
    [])]

(types)
  $ ../bin/compiler.exe -dparsetree <<'EOF'
  > let a (b: int) (c:'7) (d: '2 -> unit) (e: '3 list ) (f: '4 -> (f) * '1) (g: '2 -> sss option) = 0
  > EOF
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
    [])]

(nested types)
  $ ../bin/compiler.exe -dparsetree <<'EOF'
  > let a (b: '3 list list option) (c: int option option list) = 0
  > EOF
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
    [])]

(binary subtract)
  $ ../bin/compiler.exe -dparsetree <<'EOF'
  > let _ = a - 3
  > EOF
  [(Nonrec,
    (Wild,
     (Apply ((Apply ((Variable "-"), (Variable "a"))), (Const (Int_lt 3))))),
    [])]

(function apply of letIn)
  $ ../bin/compiler.exe -dparsetree <<'EOF'
  > let _ = f (let x = false in true) || x
  > EOF
  [(Nonrec,
    (Wild,
     (Apply (
        (Apply ((Variable "||"),
           (Apply ((Variable "f"),
              (LetIn (Nonrec, ((PVar "x"), (Const (Bool_lt false))),
                 (Const (Bool_lt true))))
              ))
           )),
        (Variable "x")))),
    [])]

(arithmetic with unary operations and variables)
  $ ../bin/compiler.exe -dparsetree <<'EOF'
  > let _ = - a - - b + 4
  > EOF
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
    [])]

(sum of function applying)
  $ ../bin/compiler.exe -dparsetree <<'EOF'
  > let _ = f 4 + g 3
  > EOF
  [(Nonrec,
    (Wild,
     (Apply (
        (Apply ((Variable "+"), (Apply ((Variable "f"), (Const (Int_lt 4)))))),
        (Apply ((Variable "g"), (Const (Int_lt 3))))))),
    [])]

(order of logical expressions and function applying)
  $ ../bin/compiler.exe -dparsetree <<'EOF'
  > let _ = let x = true in not x || true && f 12
  > EOF
  [(Nonrec,
    (Wild,
     (LetIn (Nonrec, ((PVar "x"), (Const (Bool_lt true))),
        (Apply (
           (Apply ((Variable "||"), (Apply ((Variable "not"), (Variable "x")))
              )),
           (Apply ((Apply ((Variable "&&"), (Const (Bool_lt true)))),
              (Apply ((Variable "f"), (Const (Int_lt 12))))))
           ))
        ))),
    [])]

(logical expression)
  $ ../bin/compiler.exe -dparsetree <<'EOF'
  > let _ = (3 + 5) >= 8 || true && (5 <> 4)
  > EOF
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
    [])]

(unary chain)
  $ ../bin/compiler.exe -dparsetree <<'EOF'
  > let _ = not not ( not true && false || 3 > 5)
  > EOF
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
    [])]

(if with comparison)
  $ ../bin/compiler.exe -dparsetree <<'EOF'
  > let _ = if 3 > 2 && false then 5 + 7 else 12
  > EOF
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
    [])]

(sum with if)
  $ ../bin/compiler.exe -dparsetree <<'EOF'
  > let _ = a + if 3 > 2 then 2 else 1
  > EOF
  [(Nonrec,
    (Wild,
     (Apply ((Apply ((Variable "+"), (Variable "a"))),
        (If_then_else (
           (Apply ((Apply ((Variable ">"), (Const (Int_lt 3)))),
              (Const (Int_lt 2)))),
           (Const (Int_lt 2)), (Some (Const (Int_lt 1)))))
        ))),
    [])]

(inner expressions with LetIn and If)
  $ ../bin/compiler.exe -dparsetree <<'EOF'
  > let _ = if let x = true in let y = false in x || y then 3 else if 5 > 3 then 2 else 1
  > EOF
  [(Nonrec,
    (Wild,
     (If_then_else (
        (LetIn (Nonrec, ((PVar "x"), (Const (Bool_lt true))),
           (LetIn (Nonrec, ((PVar "y"), (Const (Bool_lt false))),
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
    [])]

(fail in ITE with incorrect else expression)
  $ ../bin/compiler.exe -dparsetree <<'EOF'
  > let _ = if true then 1 else 2c
  > EOF
  Parsing error: : end_of_input

(fail in apply with complex expression without parentheses)
  $ ../bin/compiler.exe -dparsetree <<'EOF'
  > let _ = f let x = 1 in x
  > EOF
  Parsing error: : end_of_input

(apply if with parentheses)
  $ ../bin/compiler.exe -dparsetree <<'EOF'
  > let _ = (if(false)then(a) else(b))c
  > EOF
  [(Nonrec,
    (Wild,
     (Apply (
        (If_then_else ((Const (Bool_lt false)), (Variable "a"),
           (Some (Variable "b")))),
        (Variable "c")))),
    [])]

(precedence of -, apply, tuple etc)
  $ ../bin/compiler.exe -dparsetree <<'EOF'
  > let _ = -(let x = 1 in x) (fun x -> x) 1,2,3
  > EOF
  [(Nonrec,
    (Wild,
     (Tuple (
        (Apply ((Variable "~-"),
           (Apply (
              (Apply (
                 (LetIn (Nonrec, ((PVar "x"), (Const (Int_lt 1))),
                    (Variable "x"))),
                 (Lambda ((PVar "x"), (Variable "x"))))),
              (Const (Int_lt 1))))
           )),
        (Const (Int_lt 2)), [(Const (Int_lt 3))]))),
    [])]

(precedence of infix operator with if and apply)
  $ ../bin/compiler.exe -dparsetree <<'EOF'
  > let _ =  (if true then 1 + 2 f (function | x -> x) ) k
  > EOF
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
    [])]

(fail when args in not-variable binding)
  $ ../bin/compiler.exe -dparsetree <<'EOF'
  > let _ x = 1
  > EOF
  Parsing error: : Args in let bind are only allowed when binding a variable name 

(fail when args in not-variable binding)
  $ ../bin/compiler.exe -dparsetree <<'EOF'
  > let _ = let 1 y = 1 in x + 2
  > EOF
  Parsing error: : char '('
