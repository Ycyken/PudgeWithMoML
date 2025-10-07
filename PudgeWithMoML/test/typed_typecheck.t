  $ ../bin/compiler.exe -fromfile manytests/typed/001fac.ml -dtypes
  val fac : int -> int
  val main : int

  $ ../bin/compiler.exe -fromfile manytests/typed/002fac.ml -dtypes
  val fac_cps : int -> (int -> '16) -> '16
  val main : int

  $ ../bin/compiler.exe -fromfile manytests/typed/003fib.ml -dtypes
  val fib : int -> int
  val fib_acc : int -> int -> int -> int
  val main : int

  $ ../bin/compiler.exe -fromfile manytests/typed/004manyargs.ml -dtypes
  val main : int
  val test10 : int -> int -> int -> int -> int -> int -> int -> int -> int -> int -> int
  val test3 : int -> int -> int -> int
  val wrap : '3 -> '3

  $ ../bin/compiler.exe -fromfile manytests/typed/005fix.ml -dtypes
  val fac : (int -> int) -> int -> int
  val fix : (('5 -> '8) -> '5 -> '8) -> '5 -> '8
  val main : int

  $ ../bin/compiler.exe -fromfile manytests/typed/006partial.ml -dtypes
  val foo : int -> int
  val main : int

  $ ../bin/compiler.exe -fromfile manytests/typed/006partial2.ml -dtypes
  val foo : int -> int -> int -> int
  val main : int

  $ ../bin/compiler.exe -fromfile manytests/typed/006partial3.ml -dtypes
  val foo : int -> int -> int -> unit
  val main : int

  $ ../bin/compiler.exe -fromfile manytests/typed/007order.ml -dtypes
  val _start : unit -> unit -> int -> unit -> int -> int -> unit -> int -> int -> int
  val main : unit

  $ ../bin/compiler.exe -fromfile manytests/typed/008ascription.ml -dtypes
  val addi : ('5 -> bool -> int) -> ('5 -> bool) -> '5 -> int
  val main : int

  $ ../bin/compiler.exe -fromfile manytests/typed/009let_poly.ml -dtypes
  val temp : int * bool

  $ ../bin/compiler.exe -fromfile manytests/typed/010fac_anf.ml -dtypes
  val fac : int -> int
  val main : int

  $ ../bin/compiler.exe -fromfile manytests/typed/011mapcps.ml -dtypes
  val iter : ('27 -> '30) -> '27 list -> unit
  val main : unit
  val map : ('8 -> '17) -> '8 list -> ('17 list -> '20) -> '20

  $ ../bin/compiler.exe -fromfile manytests/typed/012fibcps.ml -dtypes
  val fib : int -> (int -> '21) -> '21
  val main : unit

  $ ../bin/compiler.exe -fromfile manytests/typed/013foldfoldr.ml -dtypes
  val fold_right : ('10 -> '17 -> '17) -> '17 -> '10 list -> '17
  val foldl : ('20 -> '24 -> '20) -> '20 -> '24 list -> '20
  val id : '3 -> '3
  val main : unit

  $ ../bin/compiler.exe -fromfile manytests/typed/015tuples.ml -dtypes
  val feven : '36 * (int -> int) -> int -> int
  val fix : (('5 -> '8) -> '5 -> '8) -> '5 -> '8
  val fixpoly : (('25 -> '28) * ('25 -> '28) -> '25 -> '28) * (('25 -> '28) * ('25 -> '28) -> '25 -> '28) -> ('25 -> '28) * ('25 -> '28)
  val fodd : (int -> int) * '48 -> int -> int
  val main : int
  val map : ('12 -> '14) -> '12 * '12 -> '14 * '14
  val meven : int -> int
  val modd : int -> int
  val tie : (int -> int) * (int -> int)

  $ ../bin/compiler.exe -fromfile manytests/typed/016lists.ml -dtypes
  val append : '77 list -> '77 list -> '77 list
  val cartesian : '115 list -> '122 list -> ('115 * '122) list
  val concat : '98 list list -> '98 list
  val iter : ('104 -> unit) -> '104 list -> unit
  val length : '6 list -> int
  val length_tail : '25 list -> int
  val main : int
  val map : ('32 -> '64) -> '32 list -> '64 list
