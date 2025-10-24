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
    addi sp, sp, -8
    sd a0, -8(fp)
  # Apply print_int
    li a0, 5
    call print_int
    call flush
    li a0, 0
    li a7, 94
    ecall

( just add )
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
    ld t0, 0(fp)
    ld t1, 8(fp)
    add a0, t0, t1
    ld ra, 8(sp)
    ld fp, 0(sp)
    addi sp, sp, 16
    ret
  _start:
    mv fp, sp
    addi sp, sp, -16
    sd a0, -8(fp)
  # Apply add__0 with 2 args
  # Load args on stack
    addi sp, sp, -16
    li t0, 5
    sd t0, 0(sp)
    li t0, 2
    sd t0, 8(sp)
  # End loading args on stack
    call add__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    mv t0, a0
  # End Apply add__0 with 2 args
    sd t0, -16(fp)
  # Apply print_int
    ld a0, -16(fp)
    call print_int
    call flush
    li a0, 0
    li a7, 94
    ecall

( a lot of variables )
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
    ld a0, 0(fp)
    ld ra, 8(sp)
    ld fp, 0(sp)
    addi sp, sp, 16
    ret
  _start:
    mv fp, sp
    addi sp, sp, -16
    sd a0, -8(fp)
  # Apply homka__0 with 12 args
  # Load args on stack
    addi sp, sp, -96
    li t0, 122
    sd t0, 0(sp)
    li t0, 1
    sd t0, 8(sp)
    li t0, 2
    sd t0, 16(sp)
    li t0, 3
    sd t0, 24(sp)
    li t0, 4
    sd t0, 32(sp)
    li t0, 5
    sd t0, 40(sp)
    li t0, 6
    sd t0, 48(sp)
    li t0, 7
    sd t0, 56(sp)
    li t0, 8
    sd t0, 64(sp)
    li t0, 9
    sd t0, 72(sp)
    li t0, 10
    sd t0, 80(sp)
    li t0, 11
    sd t0, 88(sp)
  # End loading args on stack
    call homka__0
  # Free args on stack
    addi sp, sp, 96
  # End free args on stack
    mv t0, a0
  # End Apply homka__0 with 12 args
    sd t0, -16(fp)
  # Apply print_int
    ld a0, -16(fp)
    call print_int
    call flush
    li a0, 0
    li a7, 94
    ecall

(just id)
  $ ./run_anf.exe << 'EOF'
  > let id x1 x2 = x2
  > let main = print_int (id 5 5)
  > EOF
  let id__0 = fun x1__1 ->
    fun x2__2 ->
    x2__2 
  
  
  let main__3 = let anf_t0 = id__0 5 5 in
    print_int anf_t0 
  $ rm ../main.exe ../main.s
  $ make compile --no-print-directory -C .. << 'EOF'
  > let id x1 x2 = x2
  > let main = print_int (id 5 5)
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
    addi sp, sp, -16
    sd a0, -8(fp)
  # Apply id__0 with 2 args
  # Load args on stack
    addi sp, sp, -16
    li t0, 5
    sd t0, 0(sp)
    li t0, 5
    sd t0, 8(sp)
  # End loading args on stack
    call id__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    mv t0, a0
  # End Apply id__0 with 2 args
    sd t0, -16(fp)
  # Apply print_int
    ld a0, -16(fp)
    call print_int
    call flush
    li a0, 0
    li a7, 94
    ecall

(function as argument)
  $ ./run_anf.exe << 'EOF'
  > let app f x = f x
  > let inc x = x + 1
  > let main = print_int (app inc 5)
  > EOF
  let app__0 = fun f__1 ->
    fun x__2 ->
    f__1 x__2 
  
  
  let inc__3 = fun x__4 ->
    x__4 + 1 
  
  
  let main__5 = let anf_t0 = app__0 inc__3 5 in
    print_int anf_t0 
  $ rm ../main.exe ../main.s
  $ make compile --no-print-directory -C .. << 'EOF'
  > let app f x = f x
  > let inc x = x + 1
  > let main = print_int (app inc 5)
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe
  6
  $ cat ../main.s
  .text
  .globl _start
  .globl app__0
  app__0:
    addi sp, sp, -24
    sd ra, 16(sp)
    sd fp, 8(sp)
    addi fp, sp, 24
  # Apply f__1 with 1 args
    ld t0, 0(fp)
    sd t0, -24(fp)
  # Load args on stack
    addi sp, sp, -16
    ld t0, -24(fp)
    sd t0, 0(sp)
    ld t0, 8(fp)
    sd t0, 8(sp)
  # End loading args on stack
    call apply_1
    mv a0, a0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
  # End Apply f__1 with 1 args
    ld ra, 16(sp)
    ld fp, 8(sp)
    addi sp, sp, 24
    ret
  .globl inc__3
  inc__3:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd fp, 0(sp)
    addi fp, sp, 16
    ld t0, 0(fp)
    li t1, 1
    add a0, t0, t1
    ld ra, 8(sp)
    ld fp, 0(sp)
    addi sp, sp, 16
    ret
  _start:
    mv fp, sp
    addi sp, sp, -16
    sd a0, -8(fp)
  # Apply app__0 with 2 args
  # Load args on stack
    addi sp, sp, -16
    addi sp, sp, -16
    la t0, inc__3
    li t1, 1
    sd t0, 0(sp)
    sd t1, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 5
    sd t0, 8(sp)
  # End loading args on stack
    call app__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    mv t0, a0
  # End Apply app__0 with 2 args
    sd t0, -16(fp)
  # Apply print_int
    ld a0, -16(fp)
    call print_int
    call flush
    li a0, 0
    li a7, 94
    ecall

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
    addi sp, sp, -40
    sd a0, -8(fp)
    li t0, 10
    sd t0, -16(fp)
    li t0, 20
    sd t0, -24(fp)
  # Apply print_int
    ld a0, -24(fp)
    call print_int
    mv t0, a0
  # End Apply print_int
    sd t0, -32(fp)
    ld t0, -32(fp)
    sd t0, -40(fp)
  # Apply print_int
    ld a0, -16(fp)
    call print_int
    call flush
    li a0, 0
    li a7, 94
    ecall

(simple partial application)
  $ ./run_anf.exe << 'EOF'
  > let add x y = x + y
  > let main = let inc = add 1 in print_int (inc 121)
  > EOF
  let add__0 = fun x__1 ->
    fun y__2 ->
    x__1 + y__2 
  
  
  let main__3 = let anf_t2 = add__0 1 in
    let inc__4 = anf_t2 in
    let anf_t0 = inc__4 121 in
    print_int anf_t0 
  $ rm ../main.exe ../main.s
  $ make compile --no-print-directory -C .. << 'EOF'
  > let add x y = x + y
  > let main = let inc = add 1 in print_int (inc 121)
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe
  122
  $ cat ../main.s
  .text
  .globl _start
  .globl add__0
  add__0:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd fp, 0(sp)
    addi fp, sp, 16
    ld t0, 0(fp)
    ld t1, 8(fp)
    add a0, t0, t1
    ld ra, 8(sp)
    ld fp, 0(sp)
    addi sp, sp, 16
    ret
  _start:
    mv fp, sp
    addi sp, sp, -40
    sd a0, -8(fp)
  # Partial application add__0 with 1 args
  # Load args on stack
    addi sp, sp, -16
    addi sp, sp, -16
    la t0, add__0
    li t1, 2
    sd t0, 0(sp)
    sd t1, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 1
    sd t0, 8(sp)
  # End loading args on stack
    call apply_1
    mv t0, a0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
  # End Partial application add__0 with 1 args
    sd t0, -16(fp)
    ld t0, -16(fp)
    sd t0, -24(fp)
  # Apply inc__4 with 1 args
    ld t0, -24(fp)
    sd t0, -32(fp)
  # Load args on stack
    addi sp, sp, -16
    ld t0, -32(fp)
    sd t0, 0(sp)
    li t0, 121
    sd t0, 8(sp)
  # End loading args on stack
    call apply_1
    mv t0, a0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
  # End Apply inc__4 with 1 args
    sd t0, -40(fp)
  # Apply print_int
    ld a0, -40(fp)
    call print_int
    call flush
    li a0, 0
    li a7, 94
    ecall

(fact ll cc)
  $ ./run_anf.exe << 'EOF'
  > let id x = x
  > let fresh_1 n k p = k (p * n)
  > 
  > let rec fac_cps n k =
  >   if n = 1
  >   then k 1
  >   else fac_cps (n-1) (fresh_1 n k)
  > 
  > let main =
  >   let _ = print_int (fac_cps 4 id) in
  >   0
  > EOF
  let id__0 = fun x__1 ->
    x__1 
  
  
  let fresh_1__2 = fun n__3 ->
    fun k__4 ->
    fun p__5 ->
    let anf_t7 = p__5 * n__3 in
    k__4 anf_t7 
  
  
  let rec fac_cps__6 = fun n__7 ->
    fun k__8 ->
    let anf_t2 = n__7 = 1 in
    if anf_t2 then (k__8 1)
    else let anf_t4 = n__7 - 1 in
    let anf_t5 = fresh_1__2 n__7 k__8 in
    fac_cps__6 anf_t4 anf_t5 
  
  
  let main__9 = let anf_t0 = fac_cps__6 4 id__0 in
    let anf_t1 = print_int anf_t0 in
    0 
  $ rm ../main.exe ../main.s
  $ make compile --no-print-directory -C .. << 'EOF'
  > let id x = x
  > let fresh_1 n k p = k (p * n)
  > 
  > let rec fac_cps n k =
  >   if n = 1
  >   then k 1
  >   else fac_cps (n-1) (fresh_1 n k)
  > 
  > let main =
  >   let _ = print_int (fac_cps 4 id) in
  >   0
  > EOF
  $ cp ../main.exe /home/homka/code/asm/homka.exe
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe
  24
  $ cat ../main.s
  .text
  .globl _start
  .globl id__0
  id__0:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd fp, 0(sp)
    addi fp, sp, 16
    ld a0, 0(fp)
    ld ra, 8(sp)
    ld fp, 0(sp)
    addi sp, sp, 16
    ret
  .globl fresh_1__2
  fresh_1__2:
    addi sp, sp, -32
    sd ra, 24(sp)
    sd fp, 16(sp)
    addi fp, sp, 32
    ld t0, 16(fp)
    ld t1, 0(fp)
    mul t0, t0, t1
    sd t0, -24(fp)
  # Apply k__4 with 1 args
    ld t0, 8(fp)
    sd t0, -32(fp)
  # Load args on stack
    addi sp, sp, -16
    ld t0, -32(fp)
    sd t0, 0(sp)
    ld t0, -24(fp)
    sd t0, 8(sp)
  # End loading args on stack
    call apply_1
    mv a0, a0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
  # End Apply k__4 with 1 args
    ld ra, 24(sp)
    ld fp, 16(sp)
    addi sp, sp, 32
    ret
  .globl fac_cps__6
  fac_cps__6:
    addi sp, sp, -48
    sd ra, 40(sp)
    sd fp, 32(sp)
    addi fp, sp, 48
    ld t0, 0(fp)
    li t1, 1
    sub t0, t0, t1
    seqz t0, t0
    sd t0, -24(fp)
    ld t0, -24(fp)
    beq t0, zero, L2
  # Apply k__8 with 1 args
    ld t0, 8(fp)
    sd t0, -32(fp)
  # Load args on stack
    addi sp, sp, -16
    ld t0, -32(fp)
    sd t0, 0(sp)
    li t0, 1
    sd t0, 8(sp)
  # End loading args on stack
    call apply_1
    mv a0, a0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
  # End Apply k__8 with 1 args
    j L3
  L2:
    ld t0, 0(fp)
    li t1, 1
    sub t0, t0, t1
    sd t0, -40(fp)
  # Partial application fresh_1__2 with 2 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t0, fresh_1__2
    li t1, 3
    sd t0, 0(sp)
    sd t1, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    ld t0, 0(fp)
    sd t0, 8(sp)
    ld t0, 8(fp)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_2
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Partial application fresh_1__2 with 2 args
    sd t0, -48(fp)
  # Apply fac_cps__6 with 2 args
  # Load args on stack
    addi sp, sp, -16
    ld t0, -40(fp)
    sd t0, 0(sp)
    ld t0, -48(fp)
    sd t0, 8(sp)
  # End loading args on stack
    call fac_cps__6
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
  L3:
    ld ra, 40(sp)
    ld fp, 32(sp)
    addi sp, sp, 48
    ret
  _start:
    mv fp, sp
    addi sp, sp, -24
    sd a0, -8(fp)
  # Apply fac_cps__6 with 2 args
  # Load args on stack
    addi sp, sp, -16
    li t0, 4
    sd t0, 0(sp)
    addi sp, sp, -16
    la t0, id__0
    li t1, 1
    sd t0, 0(sp)
    sd t1, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 8(sp)
  # End loading args on stack
    call fac_cps__6
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    mv t0, a0
  # End Apply fac_cps__6 with 2 args
    sd t0, -16(fp)
  # Apply print_int
    ld a0, -16(fp)
    call print_int
    mv t0, a0
  # End Apply print_int
    sd t0, -24(fp)
    li a0, 0
    call flush
    li a0, 0
    li a7, 94
    ecall

(fibonacci ll cc)
  $ ./run_anf.exe << 'EOF'
  > let id x = x
  > let fresh_2 p1 k p2 =
  >   k (p1 + p2)
  > 
  > let fresh_1 n k fib p1 =
  >   fib (n-2) (fresh_2 p1 k)
  > 
  > let rec fib n k =
  >   if n < 2
  >   then k n
  >   else fib (n - 1) (fresh_1 n k fib)
  > 
  > let main =
  >   let z = print_int (fib 6 id)  in
  >   0
  > EOF
  let id__0 = fun x__1 ->
    x__1 
  
  
  let fresh_2__2 = fun p1__3 ->
    fun k__4 ->
    fun p2__5 ->
    let anf_t10 = p1__3 + p2__5 in
    k__4 anf_t10 
  
  
  let fresh_1__6 = fun n__7 ->
    fun k__8 ->
    fun fib__9 ->
    fun p1__10 ->
    let anf_t7 = n__7 - 2 in
    let anf_t8 = fresh_2__2 p1__10 k__8 in
    fib__9 anf_t7 anf_t8 
  
  
  let rec fib__11 = fun n__12 ->
    fun k__13 ->
    let anf_t2 = n__12 < 2 in
    if anf_t2 then (k__13 n__12)
    else let anf_t4 = n__12 - 1 in
    let anf_t5 = fresh_1__6 n__12 k__13 fib__11 in
    fib__11 anf_t4 anf_t5 
  
  
  let main__14 = let anf_t0 = fib__11 6 id__0 in
    let anf_t1 = print_int anf_t0 in
    let z__15 = anf_t1 in
    0 
  $ make compile --no-print-directory -C .. << 'EOF'
  > let id x = x
  > let fresh_2 p1 k p2 =
  >   k (p1 + p2)
  > 
  > let fresh_1 n k fib p1 =
  >   fib (n-2) (fresh_2 p1 k)
  > 
  > let rec fib n k =
  >   if n < 2
  >   then k n
  >   else fib (n - 1) (fresh_1 n k fib)
  > 
  > let main =
  >   let z = print_int (fib 6 id)  in
  >   0
  > EOF
  $ cp ../main.exe /home/homka/code/asm/homka.exe
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe
  8
  $ cat ../main.s
  .text
  .globl _start
  .globl id__0
  id__0:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd fp, 0(sp)
    addi fp, sp, 16
    ld a0, 0(fp)
    ld ra, 8(sp)
    ld fp, 0(sp)
    addi sp, sp, 16
    ret
  .globl fresh_2__2
  fresh_2__2:
    addi sp, sp, -32
    sd ra, 24(sp)
    sd fp, 16(sp)
    addi fp, sp, 32
    ld t0, 0(fp)
    ld t1, 16(fp)
    add t0, t0, t1
    sd t0, -24(fp)
  # Apply k__4 with 1 args
    ld t0, 8(fp)
    sd t0, -32(fp)
  # Load args on stack
    addi sp, sp, -16
    ld t0, -32(fp)
    sd t0, 0(sp)
    ld t0, -24(fp)
    sd t0, 8(sp)
  # End loading args on stack
    call apply_1
    mv a0, a0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
  # End Apply k__4 with 1 args
    ld ra, 24(sp)
    ld fp, 16(sp)
    addi sp, sp, 32
    ret
  .globl fresh_1__6
  fresh_1__6:
    addi sp, sp, -40
    sd ra, 32(sp)
    sd fp, 24(sp)
    addi fp, sp, 40
    ld t0, 0(fp)
    li t1, 2
    sub t0, t0, t1
    sd t0, -24(fp)
  # Partial application fresh_2__2 with 2 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t0, fresh_2__2
    li t1, 3
    sd t0, 0(sp)
    sd t1, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    ld t0, 24(fp)
    sd t0, 8(sp)
    ld t0, 8(fp)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_2
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Partial application fresh_2__2 with 2 args
    sd t0, -32(fp)
  # Apply fib__9 with 2 args
    ld t0, 16(fp)
    sd t0, -40(fp)
  # Load args on stack
    addi sp, sp, -32
    ld t0, -40(fp)
    sd t0, 0(sp)
    ld t0, -24(fp)
    sd t0, 8(sp)
    ld t0, -32(fp)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_2
    mv a0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Apply fib__9 with 2 args
    ld ra, 32(sp)
    ld fp, 24(sp)
    addi sp, sp, 40
    ret
  .globl fib__11
  fib__11:
    addi sp, sp, -48
    sd ra, 40(sp)
    sd fp, 32(sp)
    addi fp, sp, 48
    ld t0, 0(fp)
    li t1, 2
    slt t0, t0, t1
    sd t0, -24(fp)
    ld t0, -24(fp)
    beq t0, zero, L3
  # Apply k__13 with 1 args
    ld t0, 8(fp)
    sd t0, -32(fp)
  # Load args on stack
    addi sp, sp, -16
    ld t0, -32(fp)
    sd t0, 0(sp)
    ld t0, 0(fp)
    sd t0, 8(sp)
  # End loading args on stack
    call apply_1
    mv a0, a0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
  # End Apply k__13 with 1 args
    j L4
  L3:
    ld t0, 0(fp)
    li t1, 1
    sub t0, t0, t1
    sd t0, -40(fp)
  # Partial application fresh_1__6 with 3 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t0, fresh_1__6
    li t1, 4
    sd t0, 0(sp)
    sd t1, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    ld t0, 0(fp)
    sd t0, 8(sp)
    ld t0, 8(fp)
    sd t0, 16(sp)
    addi sp, sp, -16
    la t0, fib__11
    li t1, 2
    sd t0, 0(sp)
    sd t1, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 24(sp)
  # End loading args on stack
    call apply_3
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Partial application fresh_1__6 with 3 args
    sd t0, -48(fp)
  # Apply fib__11 with 2 args
  # Load args on stack
    addi sp, sp, -16
    ld t0, -40(fp)
    sd t0, 0(sp)
    ld t0, -48(fp)
    sd t0, 8(sp)
  # End loading args on stack
    call fib__11
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
  L4:
    ld ra, 40(sp)
    ld fp, 32(sp)
    addi sp, sp, 48
    ret
  _start:
    mv fp, sp
    addi sp, sp, -32
    sd a0, -8(fp)
  # Apply fib__11 with 2 args
  # Load args on stack
    addi sp, sp, -16
    li t0, 6
    sd t0, 0(sp)
    addi sp, sp, -16
    la t0, id__0
    li t1, 1
    sd t0, 0(sp)
    sd t1, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 8(sp)
  # End loading args on stack
    call fib__11
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    mv t0, a0
  # End Apply fib__11 with 2 args
    sd t0, -16(fp)
  # Apply print_int
    ld a0, -16(fp)
    call print_int
    mv t0, a0
  # End Apply print_int
    sd t0, -24(fp)
    ld t0, -24(fp)
    sd t0, -32(fp)
    li a0, 0
    call flush
    li a0, 0
    li a7, 94
    ecall
