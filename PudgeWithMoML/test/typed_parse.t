  $ ../bin/compiler.exe -fromfile manytests/typed/001fac.ml -dparsetree
  [(Rec,
    ((PVar "fac"),
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
    []);
    (Nonrec,
     ((PVar "main"),
      (LetIn (Nonrec,
         ((PConst Unit_lt),
          (Apply ((Variable "print_int"),
             (Apply ((Variable "fac"), (Const (Int_lt 4))))))),
         (Const (Int_lt 0))))),
     [])
    ]
  $ ../bin/compiler.exe -fromfile manytests/typed/002fac.ml -dparsetree
  [(Rec,
    ((PVar "fac_cps"),
     (Lambda ((PVar "n"),
        (Lambda ((PVar "k"),
           (If_then_else (
              (Apply ((Apply ((Variable "="), (Variable "n"))),
                 (Const (Int_lt 1)))),
              (Apply ((Variable "k"), (Const (Int_lt 1)))),
              (Some (Apply (
                       (Apply ((Variable "fac_cps"),
                          (Apply ((Apply ((Variable "-"), (Variable "n"))),
                             (Const (Int_lt 1))))
                          )),
                       (Lambda ((PVar "p"),
                          (Apply ((Variable "k"),
                             (Apply ((Apply ((Variable "*"), (Variable "p"))),
                                (Variable "n")))
                             ))
                          ))
                       )))
              ))
           ))
        ))),
    []);
    (Nonrec,
     ((PVar "main"),
      (LetIn (Nonrec,
         ((PConst Unit_lt),
          (Apply ((Variable "print_int"),
             (Apply ((Apply ((Variable "fac_cps"), (Const (Int_lt 4)))),
                (Lambda ((PVar "print_int"), (Variable "print_int")))))
             ))),
         (Const (Int_lt 0))))),
     [])
    ]

  $ ../bin/compiler.exe -fromfile manytests/typed/003fib.ml -dparsetree
  [(Rec,
    ((PVar "fib_acc"),
     (Lambda ((PVar "a"),
        (Lambda ((PVar "b"),
           (Lambda ((PVar "n"),
              (If_then_else (
                 (Apply ((Apply ((Variable "="), (Variable "n"))),
                    (Const (Int_lt 1)))),
                 (Variable "b"),
                 (Some (LetIn (Nonrec,
                          ((PVar "n1"),
                           (Apply ((Apply ((Variable "-"), (Variable "n"))),
                              (Const (Int_lt 1))))),
                          (LetIn (Nonrec,
                             ((PVar "ab"),
                              (Apply ((Apply ((Variable "+"), (Variable "a"))),
                                 (Variable "b")))),
                             (Apply (
                                (Apply (
                                   (Apply ((Variable "fib_acc"), (Variable "b")
                                      )),
                                   (Variable "ab"))),
                                (Variable "n1")))
                             ))
                          )))
                 ))
              ))
           ))
        ))),
    []);
    (Rec,
     ((PVar "fib"),
      (Lambda ((PVar "n"),
         (If_then_else (
            (Apply ((Apply ((Variable "<"), (Variable "n"))),
               (Const (Int_lt 2)))),
            (Variable "n"),
            (Some (Apply (
                     (Apply ((Variable "+"),
                        (Apply ((Variable "fib"),
                           (Apply ((Apply ((Variable "-"), (Variable "n"))),
                              (Const (Int_lt 1))))
                           ))
                        )),
                     (Apply ((Variable "fib"),
                        (Apply ((Apply ((Variable "-"), (Variable "n"))),
                           (Const (Int_lt 2))))
                        ))
                     )))
            ))
         ))),
     []);
    (Nonrec,
     ((PVar "main"),
      (LetIn (Nonrec,
         ((PConst Unit_lt),
          (Apply ((Variable "print_int"),
             (Apply (
                (Apply ((Apply ((Variable "fib_acc"), (Const (Int_lt 0)))),
                   (Const (Int_lt 1)))),
                (Const (Int_lt 4))))
             ))),
         (LetIn (Nonrec,
            ((PConst Unit_lt),
             (Apply ((Variable "print_int"),
                (Apply ((Variable "fib"), (Const (Int_lt 4))))))),
            (Const (Int_lt 0))))
         ))),
     [])
    ]

  $ ../bin/compiler.exe -fromfile manytests/typed/004manyargs.ml -dparsetree
  [(Nonrec,
    ((PVar "wrap"),
     (Lambda ((PVar "f"),
        (If_then_else (
           (Apply ((Apply ((Variable "="), (Const (Int_lt 1)))),
              (Const (Int_lt 1)))),
           (Variable "f"), (Some (Variable "f"))))
        ))),
    []);
    (Nonrec,
     ((PVar "test3"),
      (Lambda ((PVar "a"),
         (Lambda ((PVar "b"),
            (Lambda ((PVar "c"),
               (LetIn (Nonrec,
                  ((PVar "a"), (Apply ((Variable "print_int"), (Variable "a")))),
                  (LetIn (Nonrec,
                     ((PVar "b"),
                      (Apply ((Variable "print_int"), (Variable "b")))),
                     (LetIn (Nonrec,
                        ((PVar "c"),
                         (Apply ((Variable "print_int"), (Variable "c")))),
                        (Const (Int_lt 0))))
                     ))
                  ))
               ))
            ))
         ))),
     []);
    (Nonrec,
     ((PVar "test10"),
      (Lambda ((PVar "a"),
         (Lambda ((PVar "b"),
            (Lambda ((PVar "c"),
               (Lambda ((PVar "d"),
                  (Lambda ((PVar "e"),
                     (Lambda ((PVar "f"),
                        (Lambda ((PVar "g"),
                           (Lambda ((PVar "h"),
                              (Lambda ((PVar "i"),
                                 (Lambda ((PVar "j"),
                                    (Apply (
                                       (Apply ((Variable "+"),
                                          (Apply (
                                             (Apply ((Variable "+"),
                                                (Apply (
                                                   (Apply ((Variable "+"),
                                                      (Apply (
                                                         (Apply (
                                                            (Variable "+"),
                                                            (Apply (
                                                               (Apply (
                                                                  (Variable "+"),
                                                                  (Apply (
                                                                     (Apply (
                                                                      (Variable
                                                                      "+"),
                                                                      (Apply (
                                                                      (Apply (
                                                                      (Variable
                                                                      "+"),
                                                                      (Apply (
                                                                      (Apply (
                                                                      (Variable
                                                                      "+"),
                                                                      (Apply (
                                                                      (Apply (
                                                                      (Variable
                                                                      "+"),
                                                                      (Variable
                                                                      "a"))),
                                                                      (Variable
                                                                      "b"))))),
                                                                      (Variable
                                                                      "c"))))),
                                                                      (Variable
                                                                      "d"))))),
                                                                     (Variable
                                                                      "e")
                                                                     ))
                                                                  )),
                                                               (Variable "f")))
                                                            )),
                                                         (Variable "g")))
                                                      )),
                                                   (Variable "h")))
                                                )),
                                             (Variable "i")))
                                          )),
                                       (Variable "j")))
                                    ))
                                 ))
                              ))
                           ))
                        ))
                     ))
                  ))
               ))
            ))
         ))),
     []);
    (Nonrec,
     ((PVar "main"),
      (LetIn (Nonrec,
         ((PVar "rez"),
          (Apply (
             (Apply (
                (Apply (
                   (Apply (
                      (Apply (
                         (Apply (
                            (Apply (
                               (Apply (
                                  (Apply (
                                     (Apply (
                                        (Apply ((Variable "wrap"),
                                           (Variable "test10"))),
                                        (Const (Int_lt 1)))),
                                     (Const (Int_lt 10)))),
                                  (Const (Int_lt 100)))),
                               (Const (Int_lt 1000)))),
                            (Const (Int_lt 10000)))),
                         (Const (Int_lt 100000)))),
                      (Const (Int_lt 1000000)))),
                   (Const (Int_lt 10000000)))),
                (Const (Int_lt 100000000)))),
             (Const (Int_lt 1000000000))))),
         (LetIn (Nonrec,
            ((PConst Unit_lt),
             (Apply ((Variable "print_int"), (Variable "rez")))),
            (LetIn (Nonrec,
               ((PVar "temp2"),
                (Apply (
                   (Apply (
                      (Apply ((Apply ((Variable "wrap"), (Variable "test3"))),
                         (Const (Int_lt 1)))),
                      (Const (Int_lt 10)))),
                   (Const (Int_lt 100))))),
               (Const (Int_lt 0))))
            ))
         ))),
     [])
    ]

  $ ../bin/compiler.exe -fromfile manytests/typed/005fix.ml -dparsetree
  [(Rec,
    ((PVar "fix"),
     (Lambda ((PVar "f"),
        (Lambda ((PVar "x"),
           (Apply (
              (Apply ((Variable "f"),
                 (Apply ((Variable "fix"), (Variable "f"))))),
              (Variable "x")))
           ))
        ))),
    []);
    (Nonrec,
     ((PVar "fac"),
      (Lambda ((PVar "self"),
         (Lambda ((PVar "n"),
            (If_then_else (
               (Apply ((Apply ((Variable "<="), (Variable "n"))),
                  (Const (Int_lt 1)))),
               (Const (Int_lt 1)),
               (Some (Apply ((Apply ((Variable "*"), (Variable "n"))),
                        (Apply ((Variable "self"),
                           (Apply ((Apply ((Variable "-"), (Variable "n"))),
                              (Const (Int_lt 1))))
                           ))
                        )))
               ))
            ))
         ))),
     []);
    (Nonrec,
     ((PVar "main"),
      (LetIn (Nonrec,
         ((PConst Unit_lt),
          (Apply ((Variable "print_int"),
             (Apply ((Apply ((Variable "fix"), (Variable "fac"))),
                (Const (Int_lt 6))))
             ))),
         (Const (Int_lt 0))))),
     [])
    ]

  $ ../bin/compiler.exe -fromfile manytests/typed/006partial.ml -dparsetree
  [(Nonrec,
    ((PVar "foo"),
     (Lambda ((PVar "b"),
        (If_then_else ((Variable "b"),
           (Lambda ((PVar "foo"),
              (Apply ((Apply ((Variable "+"), (Variable "foo"))),
                 (Const (Int_lt 2))))
              )),
           (Some (Lambda ((PVar "foo"),
                    (Apply ((Apply ((Variable "*"), (Variable "foo"))),
                       (Const (Int_lt 10))))
                    )))
           ))
        ))),
    []);
    (Nonrec,
     ((PVar "foo"),
      (Lambda ((PVar "x"),
         (Apply ((Apply ((Variable "foo"), (Const (Bool_lt true)))),
            (Apply ((Apply ((Variable "foo"), (Const (Bool_lt false)))),
               (Apply ((Apply ((Variable "foo"), (Const (Bool_lt true)))),
                  (Apply ((Apply ((Variable "foo"), (Const (Bool_lt false)))),
                     (Variable "x")))
                  ))
               ))
            ))
         ))),
     []);
    (Nonrec,
     ((PVar "main"),
      (LetIn (Nonrec,
         ((PConst Unit_lt),
          (Apply ((Variable "print_int"),
             (Apply ((Variable "foo"), (Const (Int_lt 11))))))),
         (Const (Int_lt 0))))),
     [])
    ]

  $ ../bin/compiler.exe -fromfile manytests/typed/006partial2.ml -dparsetree
  [(Nonrec,
    ((PVar "foo"),
     (Lambda ((PVar "a"),
        (Lambda ((PVar "b"),
           (Lambda ((PVar "c"),
              (LetIn (Nonrec,
                 ((PConst Unit_lt),
                  (Apply ((Variable "print_int"), (Variable "a")))),
                 (LetIn (Nonrec,
                    ((PConst Unit_lt),
                     (Apply ((Variable "print_int"), (Variable "b")))),
                    (LetIn (Nonrec,
                       ((PConst Unit_lt),
                        (Apply ((Variable "print_int"), (Variable "c")))),
                       (Apply ((Apply ((Variable "+"), (Variable "a"))),
                          (Apply ((Apply ((Variable "*"), (Variable "b"))),
                             (Variable "c")))
                          ))
                       ))
                    ))
                 ))
              ))
           ))
        ))),
    []);
    (Nonrec,
     ((PVar "main"),
      (LetIn (Nonrec,
         ((PVar "foo"), (Apply ((Variable "foo"), (Const (Int_lt 1))))),
         (LetIn (Nonrec,
            ((PVar "foo"), (Apply ((Variable "foo"), (Const (Int_lt 2))))),
            (LetIn (Nonrec,
               ((PVar "foo"), (Apply ((Variable "foo"), (Const (Int_lt 3))))),
               (LetIn (Nonrec,
                  ((PConst Unit_lt),
                   (Apply ((Variable "print_int"), (Variable "foo")))),
                  (Const (Int_lt 0))))
               ))
            ))
         ))),
     [])
    ]

  $ ../bin/compiler.exe -fromfile manytests/typed/006partial3.ml -dparsetree
  [(Nonrec,
    ((PVar "foo"),
     (Lambda ((PVar "a"),
        (LetIn (Nonrec,
           ((PConst Unit_lt), (Apply ((Variable "print_int"), (Variable "a")))),
           (Lambda ((PVar "b"),
              (LetIn (Nonrec,
                 ((PConst Unit_lt),
                  (Apply ((Variable "print_int"), (Variable "b")))),
                 (Lambda ((PVar "c"),
                    (Apply ((Variable "print_int"), (Variable "c")))))
                 ))
              ))
           ))
        ))),
    []);
    (Nonrec,
     ((PVar "main"),
      (LetIn (Nonrec,
         ((PConst Unit_lt),
          (Apply (
             (Apply ((Apply ((Variable "foo"), (Const (Int_lt 4)))),
                (Const (Int_lt 8)))),
             (Const (Int_lt 9))))),
         (Const (Int_lt 0))))),
     [])
    ]

  $ ../bin/compiler.exe -fromfile manytests/typed/007order.ml -dparsetree
  [(Nonrec,
    ((PVar "_start"),
     (Lambda ((PConst Unit_lt),
        (Lambda ((PConst Unit_lt),
           (Lambda ((PVar "a"),
              (Lambda ((PConst Unit_lt),
                 (Lambda ((PVar "b"),
                    (Lambda ((PVar "_c"),
                       (Lambda ((PConst Unit_lt),
                          (Lambda ((PVar "d"),
                             (Lambda ((PVar "__"),
                                (LetIn (Nonrec,
                                   ((PConst Unit_lt),
                                    (Apply ((Variable "print_int"),
                                       (Apply (
                                          (Apply ((Variable "+"),
                                             (Variable "a"))),
                                          (Variable "b")))
                                       ))),
                                   (LetIn (Nonrec,
                                      ((PConst Unit_lt),
                                       (Apply ((Variable "print_int"),
                                          (Variable "__")))),
                                      (Apply (
                                         (Apply ((Variable "+"),
                                            (Apply (
                                               (Apply ((Variable "/"),
                                                  (Apply (
                                                     (Apply ((Variable "*"),
                                                        (Variable "a"))),
                                                     (Variable "b")))
                                                  )),
                                               (Variable "_c")))
                                            )),
                                         (Variable "d")))
                                      ))
                                   ))
                                ))
                             ))
                          ))
                       ))
                    ))
                 ))
              ))
           ))
        ))),
    []);
    (Nonrec,
     ((PVar "main"),
      (Apply ((Variable "print_int"),
         (Apply (
            (Apply (
               (Apply (
                  (Apply (
                     (Apply (
                        (Apply (
                           (Apply (
                              (Apply (
                                 (Apply ((Variable "_start"),
                                    (Apply ((Variable "print_int"),
                                       (Const (Int_lt 1))))
                                    )),
                                 (Apply ((Variable "print_int"),
                                    (Const (Int_lt 2))))
                                 )),
                              (Const (Int_lt 3)))),
                           (Apply ((Variable "print_int"), (Const (Int_lt 4))))
                           )),
                        (Const (Int_lt 100)))),
                     (Const (Int_lt 1000)))),
                  (Apply ((Variable "print_int"), (Const (Int_lt -1)))))),
               (Const (Int_lt 10000)))),
            (Const (Int_lt -555555))))
         ))),
     [])
    ]

  $ ../bin/compiler.exe -fromfile manytests/typed/008ascription.ml -dparsetree
  [(Nonrec,
    ((PVar "addi"),
     (Lambda ((PVar "f"),
        (Lambda ((PVar "g"),
           (Lambda ((PVar "x"),
              (EConstraint (
                 (Apply ((Apply ((Variable "f"), (Variable "x"))),
                    (EConstraint ((Apply ((Variable "g"), (Variable "x"))),
                       (Primitive "bool")))
                    )),
                 (Primitive "int")))
              ))
           ))
        ))),
    []);
    (Nonrec,
     ((PVar "main"),
      (LetIn (Nonrec,
         ((PConst Unit_lt),
          (Apply ((Variable "print_int"),
             (Apply (
                (Apply (
                   (Apply ((Variable "addi"),
                      (Lambda ((PVar "x"),
                         (Lambda ((PVar "b"),
                            (If_then_else ((Variable "b"),
                               (Apply (
                                  (Apply ((Variable "+"), (Variable "x"))),
                                  (Const (Int_lt 1)))),
                               (Some (Apply (
                                        (Apply ((Variable "*"), (Variable "x")
                                           )),
                                        (Const (Int_lt 2)))))
                               ))
                            ))
                         ))
                      )),
                   (Lambda ((PVar "_start"),
                      (Apply (
                         (Apply ((Variable "="),
                            (Apply (
                               (Apply ((Variable "/"), (Variable "_start"))),
                               (Const (Int_lt 2))))
                            )),
                         (Const (Int_lt 0))))
                      ))
                   )),
                (Const (Int_lt 4))))
             ))),
         (Const (Int_lt 0))))),
     [])
    ]

  $ ../bin/compiler.exe -fromfile manytests/typed/009let_poly.ml -dparsetree
  [(Nonrec,
    ((PVar "temp"),
     (LetIn (Nonrec, ((PVar "f"), (Lambda ((PVar "x"), (Variable "x")))),
        (Tuple ((Apply ((Variable "f"), (Const (Int_lt 1)))),
           (Apply ((Variable "f"), (Const (Bool_lt true)))), []))
        ))),
    [])]

  $ ../bin/compiler.exe -fromfile manytests/typed/010fac_anf.ml -dparsetree
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
  $ ../bin/compiler.exe -fromfile manytests/typed/011mapcps.ml -dparsetree
  [(Rec,
    ((PVar "map"),
     (Lambda ((PVar "f"),
        (Lambda ((PVar "xs"),
           (Lambda ((PVar "k"),
              (Match ((Variable "xs"),
                 ((PList []), (Apply ((Variable "k"), (List [])))),
                 [((PCons ((PVar "h"), (PVar "tl"))),
                   (Apply (
                      (Apply ((Apply ((Variable "map"), (Variable "f"))),
                         (Variable "tl"))),
                      (Lambda ((PVar "tl"),
                         (Apply ((Variable "k"),
                            (Apply (
                               (Apply ((Variable "::"),
                                  (Apply ((Variable "f"), (Variable "h"))))),
                               (Variable "tl")))
                            ))
                         ))
                      )))
                   ]
                 ))
              ))
           ))
        ))),
    []);
    (Rec,
     ((PVar "iter"),
      (Lambda ((PVar "f"),
         (Lambda ((PVar "xs"),
            (Match ((Variable "xs"), ((PList []), (Const Unit_lt)),
               [((PCons ((PVar "h"), (PVar "tl"))),
                 (LetIn (Nonrec,
                    ((PVar "w"), (Apply ((Variable "f"), (Variable "h")))),
                    (Apply ((Apply ((Variable "iter"), (Variable "f"))),
                       (Variable "tl")))
                    )))
                 ]
               ))
            ))
         ))),
     []);
    (Nonrec,
     ((PVar "main"),
      (Apply ((Apply ((Variable "iter"), (Variable "print_int"))),
         (Apply (
            (Apply (
               (Apply ((Variable "map"),
                  (Lambda ((PVar "x"),
                     (Apply ((Apply ((Variable "+"), (Variable "x"))),
                        (Const (Int_lt 1))))
                     ))
                  )),
               (List
                  [(Const (Int_lt 1)); (Const (Int_lt 2)); (Const (Int_lt 3))])
               )),
            (Lambda ((PVar "x"), (Variable "x")))))
         ))),
     [])
    ]

  $ ../bin/compiler.exe -fromfile manytests/typed/012fibcps.ml -dparsetree
  [(Rec,
    ((PVar "fib"),
     (Lambda ((PVar "n"),
        (Lambda ((PVar "k"),
           (If_then_else (
              (Apply ((Apply ((Variable "<"), (Variable "n"))),
                 (Const (Int_lt 2)))),
              (Apply ((Variable "k"), (Variable "n"))),
              (Some (Apply (
                       (Apply ((Variable "fib"),
                          (Apply ((Apply ((Variable "-"), (Variable "n"))),
                             (Const (Int_lt 1))))
                          )),
                       (Lambda ((PVar "a"),
                          (Apply (
                             (Apply ((Variable "fib"),
                                (Apply (
                                   (Apply ((Variable "-"), (Variable "n"))),
                                   (Const (Int_lt 2))))
                                )),
                             (Lambda ((PVar "b"),
                                (Apply ((Variable "k"),
                                   (Apply (
                                      (Apply ((Variable "+"), (Variable "a"))),
                                      (Variable "b")))
                                   ))
                                ))
                             ))
                          ))
                       )))
              ))
           ))
        ))),
    []);
    (Nonrec,
     ((PVar "main"),
      (Apply ((Variable "print_int"),
         (Apply ((Apply ((Variable "fib"), (Const (Int_lt 6)))),
            (Lambda ((PVar "x"), (Variable "x")))))
         ))),
     [])
    ]

  $ ../bin/compiler.exe -fromfile manytests/typed/013foldfoldr.ml -dparsetree
  [(Nonrec, ((PVar "id"), (Lambda ((PVar "x"), (Variable "x")))), []);
    (Rec,
     ((PVar "fold_right"),
      (Lambda ((PVar "f"),
         (Lambda ((PVar "acc"),
            (Lambda ((PVar "xs"),
               (Match ((Variable "xs"), ((PList []), (Variable "acc")),
                  [((PCons ((PVar "h"), (PVar "tl"))),
                    (Apply ((Apply ((Variable "f"), (Variable "h"))),
                       (Apply (
                          (Apply (
                             (Apply ((Variable "fold_right"), (Variable "f"))),
                             (Variable "acc"))),
                          (Variable "tl")))
                       )))
                    ]
                  ))
               ))
            ))
         ))),
     []);
    (Nonrec,
     ((PVar "foldl"),
      (Lambda ((PVar "f"),
         (Lambda ((PVar "a"),
            (Lambda ((PVar "bs"),
               (Apply (
                  (Apply (
                     (Apply (
                        (Apply ((Variable "fold_right"),
                           (Lambda ((PVar "b"),
                              (Lambda ((PVar "g"),
                                 (Lambda ((PVar "x"),
                                    (Apply ((Variable "g"),
                                       (Apply (
                                          (Apply ((Variable "f"),
                                             (Variable "x"))),
                                          (Variable "b")))
                                       ))
                                    ))
                                 ))
                              ))
                           )),
                        (Variable "id"))),
                     (Variable "bs"))),
                  (Variable "a")))
               ))
            ))
         ))),
     []);
    (Nonrec,
     ((PVar "main"),
      (Apply ((Variable "print_int"),
         (Apply (
            (Apply (
               (Apply ((Variable "foldl"),
                  (Lambda ((PVar "x"),
                     (Lambda ((PVar "y"),
                        (Apply ((Apply ((Variable "*"), (Variable "x"))),
                           (Variable "y")))
                        ))
                     ))
                  )),
               (Const (Int_lt 1)))),
            (List [(Const (Int_lt 1)); (Const (Int_lt 2)); (Const (Int_lt 3))])
            ))
         ))),
     [])
    ]

  $ ../bin/compiler.exe -fromfile manytests/typed/015tuples.ml -dparsetree
  [(Rec,
    ((PVar "fix"),
     (Lambda ((PVar "f"),
        (Lambda ((PVar "x"),
           (Apply (
              (Apply ((Variable "f"),
                 (Apply ((Variable "fix"), (Variable "f"))))),
              (Variable "x")))
           ))
        ))),
    []);
    (Nonrec,
     ((PVar "map"),
      (Lambda ((PVar "f"),
         (Lambda ((PVar "p"),
            (LetIn (Nonrec,
               ((PTuple ((PVar "a"), (PVar "b"), [])), (Variable "p")),
               (Tuple ((Apply ((Variable "f"), (Variable "a"))),
                  (Apply ((Variable "f"), (Variable "b"))), []))
               ))
            ))
         ))),
     []);
    (Nonrec,
     ((PVar "fixpoly"),
      (Lambda ((PVar "l"),
         (Apply (
            (Apply ((Variable "fix"),
               (Lambda ((PVar "self"),
                  (Lambda ((PVar "l"),
                     (Apply (
                        (Apply ((Variable "map"),
                           (Lambda ((PVar "li"),
                              (Lambda ((PVar "x"),
                                 (Apply (
                                    (Apply ((Variable "li"),
                                       (Apply ((Variable "self"),
                                          (Variable "l")))
                                       )),
                                    (Variable "x")))
                                 ))
                              ))
                           )),
                        (Variable "l")))
                     ))
                  ))
               )),
            (Variable "l")))
         ))),
     []);
    (Nonrec,
     ((PVar "feven"),
      (Lambda ((PVar "p"),
         (Lambda ((PVar "n"),
            (LetIn (Nonrec,
               ((PTuple ((PVar "e"), (PVar "o"), [])), (Variable "p")),
               (If_then_else (
                  (Apply ((Apply ((Variable "="), (Variable "n"))),
                     (Const (Int_lt 0)))),
                  (Const (Int_lt 1)),
                  (Some (Apply ((Variable "o"),
                           (Apply ((Apply ((Variable "-"), (Variable "n"))),
                              (Const (Int_lt 1))))
                           )))
                  ))
               ))
            ))
         ))),
     []);
    (Nonrec,
     ((PVar "fodd"),
      (Lambda ((PVar "p"),
         (Lambda ((PVar "n"),
            (LetIn (Nonrec,
               ((PTuple ((PVar "e"), (PVar "o"), [])), (Variable "p")),
               (If_then_else (
                  (Apply ((Apply ((Variable "="), (Variable "n"))),
                     (Const (Int_lt 0)))),
                  (Const (Int_lt 0)),
                  (Some (Apply ((Variable "e"),
                           (Apply ((Apply ((Variable "-"), (Variable "n"))),
                              (Const (Int_lt 1))))
                           )))
                  ))
               ))
            ))
         ))),
     []);
    (Nonrec,
     ((PVar "tie"),
      (Apply ((Variable "fixpoly"),
         (Tuple ((Variable "feven"), (Variable "fodd"), []))))),
     []);
    (Rec,
     ((PVar "meven"),
      (Lambda ((PVar "n"),
         (If_then_else (
            (Apply ((Apply ((Variable "="), (Variable "n"))),
               (Const (Int_lt 0)))),
            (Const (Int_lt 1)),
            (Some (Apply ((Variable "modd"),
                     (Apply ((Apply ((Variable "-"), (Variable "n"))),
                        (Const (Int_lt 1))))
                     )))
            ))
         ))),
     [((PVar "modd"),
       (Lambda ((PVar "n"),
          (If_then_else (
             (Apply ((Apply ((Variable "="), (Variable "n"))),
                (Const (Int_lt 0)))),
             (Const (Int_lt 1)),
             (Some (Apply ((Variable "meven"),
                      (Apply ((Apply ((Variable "-"), (Variable "n"))),
                         (Const (Int_lt 1))))
                      )))
             ))
          )))
       ]);
    (Nonrec,
     ((PVar "main"),
      (LetIn (Nonrec,
         ((PConst Unit_lt),
          (Apply ((Variable "print_int"),
             (Apply ((Variable "modd"), (Const (Int_lt 1))))))),
         (LetIn (Nonrec,
            ((PConst Unit_lt),
             (Apply ((Variable "print_int"),
                (Apply ((Variable "meven"), (Const (Int_lt 2))))))),
            (LetIn (Nonrec,
               ((PTuple ((PVar "even"), (PVar "odd"), [])), (Variable "tie")),
               (LetIn (Nonrec,
                  ((PConst Unit_lt),
                   (Apply ((Variable "print_int"),
                      (Apply ((Variable "odd"), (Const (Int_lt 3))))))),
                  (LetIn (Nonrec,
                     ((PConst Unit_lt),
                      (Apply ((Variable "print_int"),
                         (Apply ((Variable "even"), (Const (Int_lt 4))))))),
                     (Const (Int_lt 0))))
                  ))
               ))
            ))
         ))),
     [])
    ]

  $ ../bin/compiler.exe -fromfile manytests/typed/016lists.ml -dparsetree
  [(Rec,
    ((PVar "length"),
     (Lambda ((PVar "xs"),
        (Match ((Variable "xs"), ((PList []), (Const (Int_lt 0))),
           [((PCons ((PVar "h"), (PVar "tl"))),
             (Apply ((Apply ((Variable "+"), (Const (Int_lt 1)))),
                (Apply ((Variable "length"), (Variable "tl"))))))
             ]
           ))
        ))),
    []);
    (Nonrec,
     ((PVar "length_tail"),
      (LetIn (Rec,
         ((PVar "helper"),
          (Lambda ((PVar "acc"),
             (Lambda ((PVar "xs"),
                (Match ((Variable "xs"), ((PList []), (Variable "acc")),
                   [((PCons ((PVar "h"), (PVar "tl"))),
                     (Apply (
                        (Apply ((Variable "helper"),
                           (Apply ((Apply ((Variable "+"), (Variable "acc"))),
                              (Const (Int_lt 1))))
                           )),
                        (Variable "tl"))))
                     ]
                   ))
                ))
             ))),
         (Apply ((Variable "helper"), (Const (Int_lt 0))))))),
     []);
    (Rec,
     ((PVar "map"),
      (Lambda ((PVar "f"),
         (Lambda ((PVar "xs"),
            (Match ((Variable "xs"), ((PList []), (List [])),
               [((PCons ((PVar "a"), (PList []))),
                 (List [(Apply ((Variable "f"), (Variable "a")))]));
                 ((PCons ((PVar "a"), (PCons ((PVar "b"), (PList []))))),
                  (List
                     [(Apply ((Variable "f"), (Variable "a")));
                       (Apply ((Variable "f"), (Variable "b")))]));
                 ((PCons ((PVar "a"),
                     (PCons ((PVar "b"), (PCons ((PVar "c"), (PList []))))))),
                  (List
                     [(Apply ((Variable "f"), (Variable "a")));
                       (Apply ((Variable "f"), (Variable "b")));
                       (Apply ((Variable "f"), (Variable "c")))]));
                 ((PCons ((PVar "a"),
                     (PCons ((PVar "b"),
                        (PCons ((PVar "c"), (PCons ((PVar "d"), (PVar "tl")))))
                        ))
                     )),
                  (Apply (
                     (Apply ((Variable "::"),
                        (Apply ((Variable "f"), (Variable "a"))))),
                     (Apply (
                        (Apply ((Variable "::"),
                           (Apply ((Variable "f"), (Variable "b"))))),
                        (Apply (
                           (Apply ((Variable "::"),
                              (Apply ((Variable "f"), (Variable "c"))))),
                           (Apply (
                              (Apply ((Variable "::"),
                                 (Apply ((Variable "f"), (Variable "d"))))),
                              (Apply (
                                 (Apply ((Variable "map"), (Variable "f"))),
                                 (Variable "tl")))
                              ))
                           ))
                        ))
                     )))
                 ]
               ))
            ))
         ))),
     []);
    (Rec,
     ((PVar "append"),
      (Lambda ((PVar "xs"),
         (Lambda ((PVar "ys"),
            (Match ((Variable "xs"), ((PList []), (Variable "ys")),
               [((PCons ((PVar "x"), (PVar "xs"))),
                 (Apply ((Apply ((Variable "::"), (Variable "x"))),
                    (Apply ((Apply ((Variable "append"), (Variable "xs"))),
                       (Variable "ys")))
                    )))
                 ]
               ))
            ))
         ))),
     []);
    (Nonrec,
     ((PVar "concat"),
      (LetIn (Rec,
         ((PVar "helper"),
          (Lambda ((PVar "xs"),
             (Match ((Variable "xs"), ((PList []), (List [])),
                [((PCons ((PVar "h"), (PVar "tl"))),
                  (Apply ((Apply ((Variable "append"), (Variable "h"))),
                     (Apply ((Variable "helper"), (Variable "tl"))))))
                  ]
                ))
             ))),
         (Variable "helper")))),
     []);
    (Rec,
     ((PVar "iter"),
      (Lambda ((PVar "f"),
         (Lambda ((PVar "xs"),
            (Match ((Variable "xs"), ((PList []), (Const Unit_lt)),
               [((PCons ((PVar "h"), (PVar "tl"))),
                 (LetIn (Nonrec,
                    ((PConst Unit_lt), (Apply ((Variable "f"), (Variable "h")))),
                    (Apply ((Apply ((Variable "iter"), (Variable "f"))),
                       (Variable "tl")))
                    )))
                 ]
               ))
            ))
         ))),
     []);
    (Rec,
     ((PVar "cartesian"),
      (Lambda ((PVar "xs"),
         (Lambda ((PVar "ys"),
            (Match ((Variable "xs"), ((PList []), (List [])),
               [((PCons ((PVar "h"), (PVar "tl"))),
                 (Apply (
                    (Apply ((Variable "append"),
                       (Apply (
                          (Apply ((Variable "map"),
                             (Lambda ((PVar "a"),
                                (Tuple ((Variable "h"), (Variable "a"), []))))
                             )),
                          (Variable "ys")))
                       )),
                    (Apply ((Apply ((Variable "cartesian"), (Variable "tl"))),
                       (Variable "ys")))
                    )))
                 ]
               ))
            ))
         ))),
     []);
    (Nonrec,
     ((PVar "main"),
      (LetIn (Nonrec,
         ((PConst Unit_lt),
          (Apply ((Apply ((Variable "iter"), (Variable "print_int"))),
             (List [(Const (Int_lt 1)); (Const (Int_lt 2)); (Const (Int_lt 3))])
             ))),
         (LetIn (Nonrec,
            ((PConst Unit_lt),
             (Apply ((Variable "print_int"),
                (Apply ((Variable "length"),
                   (Apply (
                      (Apply ((Variable "cartesian"),
                         (List [(Const (Int_lt 1)); (Const (Int_lt 2))]))),
                      (List
                         [(Const (Int_lt 1)); (Const (Int_lt 2));
                           (Const (Int_lt 3)); (Const (Int_lt 4))])
                      ))
                   ))
                ))),
            (Const (Int_lt 0))))
         ))),
     [])
    ]
