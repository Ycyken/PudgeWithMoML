(print_int)
  $ make compile --no-print-directory -C .. << 'EOF'
  > let main = print_int 5
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe
  5
  $ cat ../main.s
  .text
  .globl _start
  _start:
    mv fp, sp
    addi sp, sp, 0
    li a0, 5
    call print_int
    call flush
    li a0, 0
    li a7, 94
    ecall

  $ ./run_anf.exe << 'EOF'
  > let add x y = x + y
  > let main = print_int (add 5 2)
  > EOF
  let add__0 = fun x__1 ->
    fun y__2 ->
    x__1 + y__2 
  
  
  let main__3 = let anf_t0 = add__0 5 2 in
    print_int anf_t0 
  $ rm ../main.exe ../main.s
  $ make compile --no-print-directory -C .. << 'EOF'
  > let add x y = x + y
  > let main = print_int (add 5 2)
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe
  7
  $ cat ../main.s
  .text
  .globl _start
  .globl add__0
  add__0:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd fp, 0(sp)
    addi fp, sp, 16
    ld t0, 8(fp)
    ld t1, 0(fp)
    add a0, t0, t1
    ld ra, 8(sp)
    ld fp, 0(sp)
    addi sp, sp, 16
    ret
  _start:
    mv fp, sp
    addi sp, sp, -24
    addi sp, sp, -16
    li t0, 5
    sd t0, 8(sp)
    li t0, 2
    sd t0, 0(sp)
    call add__0
    addi sp, sp, 16
    mv t0, a0
    sd t0, -24(fp)
    ld a0, -24(fp)
    call print_int
    call flush
    li a0, 0
    li a7, 94
    ecall

  $ ./run_anf.exe << 'EOF'
  > let homka x0 x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 = x0
  > let main = print_int (homka 122 1 2 3 4 5 6 7 8 9 10 11)
  > EOF
  let homka__0 = fun x0__1 ->
    fun x1__2 ->
    fun x2__3 ->
    fun x3__4 ->
    fun x4__5 ->
    fun x5__6 ->
    fun x6__7 ->
    fun x7__8 ->
    fun x8__9 ->
    fun x9__10 ->
    fun x10__11 ->
    fun x11__12 ->
    x0__1 
  
  
  let main__13 = let anf_t0 = homka__0 122 1 2 3 4 5 6 7 8 9 10 11 in
    print_int anf_t0 
  $ rm ../main.exe ../main.s
  $ make compile --no-print-directory -C .. << 'EOF'
  > let homka x0 x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 = x0
  > let main = print_int (homka 122 1 2 3 4 5 6 7 8 9 10 11)
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe
  122
  $ cat ../main.s
  .text
  .globl _start
  .globl homka__0
  homka__0:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd fp, 0(sp)
    addi fp, sp, 16
    ld a0, 88(fp)
    ld ra, 8(sp)
    ld fp, 0(sp)
    addi sp, sp, 16
    ret
  _start:
    mv fp, sp
    addi sp, sp, -104
    addi sp, sp, -96
    li t0, 122
    sd t0, 88(sp)
    li t0, 1
    sd t0, 80(sp)
    li t0, 2
    sd t0, 72(sp)
    li t0, 3
    sd t0, 64(sp)
    li t0, 4
    sd t0, 56(sp)
    li t0, 5
    sd t0, 48(sp)
    li t0, 6
    sd t0, 40(sp)
    li t0, 7
    sd t0, 32(sp)
    li t0, 8
    sd t0, 24(sp)
    li t0, 9
    sd t0, 16(sp)
    li t0, 10
    sd t0, 8(sp)
    li t0, 11
    sd t0, 0(sp)
    call homka__0
    addi sp, sp, 96
    mv t0, a0
    sd t0, -104(fp)
    ld a0, -104(fp)
    call print_int
    call flush
    li a0, 0
    li a7, 94
    ecall

  $ ./run_anf.exe << 'EOF'
  > let id x = x
  > let main = print_int (id 5)
  > EOF
  let id__0 = fun x__1 ->
    x__1 
  
  
  let main__2 = let anf_t0 = id__0 5 in
    print_int anf_t0 
  $ rm ../main.exe ../main.s
  $ make compile --no-print-directory -C .. << 'EOF'
  > let id x = x
  > let main = print_int (id 5)
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe
  5
  $ cat ../main.s
  .text
  .globl _start
  .globl id__0
  id__0:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd fp, 0(sp)
    addi fp, sp, 16
    ld a0, 8(fp)
    ld ra, 8(sp)
    ld fp, 0(sp)
    addi sp, sp, 16
    ret
  _start:
    mv fp, sp
    addi sp, sp, -24
    addi sp, sp, -16
    li t0, 5
    sd t0, 8(sp)
    call id__0
    addi sp, sp, 16
    mv t0, a0
    sd t0, -24(fp)
    ld a0, -24(fp)
    call print_int
    call flush
    li a0, 0
    li a7, 94
    ecall

(function as argument)
  $ ./run_anf.exe << 'EOF'
  > let app f x = f x
  > let inc x = x + 1
  > let main = app inc 5
  > EOF
  let app__0 = fun f__1 ->
    fun x__2 ->
    f__1 x__2 
  
  
  let inc__3 = fun x__4 ->
    x__4 + 1 
  
  
  let main__5 = app__0 inc__3 5 
  $ rm ../main.exe ../main.s
  $ make compile --no-print-directory -C .. << 'EOF'
  > let app f x = f x
  > let inc x = x + 1
  > let main = app inc 5
  > EOF
  Fatal error: exception Failure("unbound variable: inc__3")
  Raised at Stdlib.failwith in file "stdlib.ml", line 29, characters 17-33
  Called from PudgeWithMoML__Common__Monad.State.(>>|).(fun) in file "lib/common/monad.ml", line 43, characters 42-47
  Called from PudgeWithMoML__Common__Monad.State.(>>=) in file "lib/common/monad.ml", line 39, characters 16-20
  Called from PudgeWithMoML__Common__Monad.State.(>>=) in file "lib/common/monad.ml", line 39, characters 16-20
  Called from PudgeWithMoML__Common__Monad.State.(>>=) in file "lib/common/monad.ml", line 39, characters 16-20
  Called from PudgeWithMoML__Common__Monad.State.(>>=) in file "lib/common/monad.ml", line 39, characters 16-20
  Called from PudgeWithMoML__Common__Monad.State.(>>=) in file "lib/common/monad.ml", line 39, characters 16-20
  Called from PudgeWithMoML__Common__Monad.State.(>>=) in file "lib/common/monad.ml", line 39, characters 16-20
  Called from PudgeWithMoML__Riscv__Codegen.gen_aprogram in file "lib/riscv/codegen.ml", line 255, characters 16-43
  Called from Dune__exe__Compiler.compiler in file "bin/compiler.ml", line 49, characters 10-30
  make: *** [Makefile:27: compile] Error 2
  [2]
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe
  [1]
  $ cat ../main.s

(shadowing is correct)
  $ make compile --no-print-directory -C .. << 'EOF'
  > let res = let x = 10 in let t = (let x = 20 in print_int x) in print_int x
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe
  20
  10
  $ cat ../main.s
  .text
  .globl _start
  _start:
    mv fp, sp
    addi sp, sp, -32
    li t0, 10
    sd t0, -8(fp)
    li t0, 20
    sd t0, -16(fp)
    ld a0, -16(fp)
    call print_int
    mv t0, a0
    sd t0, -24(fp)
    ld t0, -24(fp)
    sd t0, -32(fp)
    ld a0, -8(fp)
    call print_int
    call flush
    li a0, 0
    li a7, 94
    ecall

