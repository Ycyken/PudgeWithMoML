  $ ../bin/compiler.exe -fromfile manytests/do_not_type/001.ml -dtypes
  Type error: Undefined variable 'fac'

  $ ../bin/compiler.exe -fromfile manytests/do_not_type/002if.ml -dtypes
  Type error: unification failed on int and bool
  
  $ ../bin/compiler.exe -fromfile manytests/do_not_type/003occurs.ml -dtypes
  Type error: Occurs check failed

  $ ../bin/compiler.exe -fromfile manytests/do_not_type/004let_poly.ml -dtypes
  Type error: unification failed on bool and int
  
  $ ../bin/compiler.exe -fromfile manytests/do_not_type/015tuples.ml -dtypes
  Type error: Only variables are allowed as left-hand side of `let rec'

  $ ../bin/compiler.exe -fromfile manytests/do_not_type/099.ml -dtypes
  Type error: Only variables are allowed as left-hand side of `let rec'
