  $ ../bin/compiler.exe -fromfile manytests/do_not_type/001.ml -dparsetree
  [(Nonrec,
    ((PVar "recfac"),
     (Lambda ((PVar "n"),
        (If_then_else (
           (Apply ((Apply ((Variable "<="), (Variable "n"))),
              (Const (Int_lt 1)))),
           (Const (Int_lt 1)),
           (Some (Apply ((Apply ((Variable "*"), (Variable "n"))),
                    (Apply ((Variable "fac"),
                       (Apply ((Apply ((Variable "-"), (Variable "n"))),
                          (Const (Int_lt 1))))
                       ))
                    )))
           ))
        ))),
    [])]

  $ ../bin/compiler.exe -fromfile manytests/do_not_type/002if.ml -dparsetree
  [(Nonrec,
    ((PVar "main"),
     (If_then_else ((Const (Bool_lt true)), (Const (Int_lt 1)),
        (Some (Const (Bool_lt false)))))),
    [])]

  $ ../bin/compiler.exe -fromfile manytests/do_not_type/003occurs.ml -dparsetree
  [(Nonrec,
    ((PVar "fix"),
     (Lambda ((PVar "f"),
        (Apply (
           (Lambda ((PVar "x"),
              (Apply ((Variable "f"),
                 (Lambda ((PVar "f"),
                    (Apply ((Apply ((Variable "x"), (Variable "x"))),
                       (Variable "f")))
                    ))
                 ))
              )),
           (Lambda ((PVar "x"),
              (Apply ((Variable "f"),
                 (Lambda ((PVar "f"),
                    (Apply ((Apply ((Variable "x"), (Variable "x"))),
                       (Variable "f")))
                    ))
                 ))
              ))
           ))
        ))),
    [])]

  $ ../bin/compiler.exe -fromfile manytests/do_not_type/004let_poly.ml -dparsetree
  [(Nonrec,
    ((PVar "temp"),
     (Apply (
        (Lambda ((PVar "f"),
           (Tuple ((Apply ((Variable "f"), (Const (Int_lt 1)))),
              (Apply ((Variable "f"), (Const (Bool_lt true)))), []))
           )),
        (Lambda ((PVar "x"), (Variable "x")))))),
    [])]

  $ ../bin/compiler.exe -fromfile manytests/do_not_type/015tuples.ml -dparsetree
  [(Rec,
    ((PTuple ((PVar "a"), (PVar "b"), [])),
     (Tuple ((Variable "a"), (Variable "b"), []))),
    [])]

  $ ../bin/compiler.exe -fromfile manytests/do_not_type/099.ml -dparsetree
  [(Rec, ((POption (Some (PVar "x"))), (Option (Some (Const (Int_lt 1))))), []);
    (Nonrec, ((POption (Some (PVar "a"))), (Variable "<")), []);
    (Nonrec, ((PConst Unit_lt), (Lambda ((PVar "x"), (Variable "x")))), [])]
