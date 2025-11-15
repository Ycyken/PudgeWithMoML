( IT MUST BE AT THE START OF THE CRAM TEST )
  $ rm -f results.txt
  $ touch results.txt

  $ make compile opts=-gen_mid input=test/manytests/typed/012faccps.ml --no-print-directory -C ..
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe  | tee -a results.txt && echo "-----" >> results.txt
  720
  $ cat ../main.anf
  let f_0 = fun k__2__new ->
    fun n__1__new ->
    fun a__3 ->
    let anf_t6 = a__3 * n__1__new in
    k__2__new anf_t6 
  
  
  let rec fac__0 = fun n__1 ->
    fun k__2 ->
    let anf_t3 = n__1 < 2 in
    if anf_t3 then (k__2 1)
    else let anf_t5 = n__1 - 1 in
    let arg_0 = f_0 in
    let anf_t8 = arg_0 k__2 n__1 in
    fac__0 anf_t5 anf_t8 
  
  
  let f_1 = fun x__5 ->
    x__5 
  
  
  let main__4 = let anf_t0 = f_1 in
    let anf_t1 = fac__0 6 anf_t0 in
    print_int anf_t1 

  $ cat ../main.s
  .text
  .globl f_0
  f_0:
    addi sp, sp, -32
    sd ra, 24(sp)
    sd fp, 16(sp)
    addi fp, sp, 32
    ld t0, 16(fp)
    ld t1, 8(fp)
    srai t0, t0, 1
    srai t1, t1, 1
    mul t0, t0, t1
    slli t0, t0, 1
    ori t0, t0, 1
    sd t0, -24(fp)
  # Application to k__2__new with 1 args
  # Load args on stack
    addi sp, sp, -32
    ld t0, 0(fp)
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    ld t0, -24(fp)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to k__2__new with 1 args
    ld ra, 24(sp)
    ld fp, 16(sp)
    addi sp, sp, 32
    ret
  .globl fac__0
  fac__0:
    addi sp, sp, -48
    sd ra, 40(sp)
    sd fp, 32(sp)
    addi fp, sp, 48
    ld t0, 0(fp)
    li t1, 5
    slt t0, t0, t1
    sd t0, -24(fp)
    ld t0, -24(fp)
    beq t0, zero, L0
  # Application to k__2 with 1 args
  # Load args on stack
    addi sp, sp, -32
    ld t0, 8(fp)
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    li t0, 3
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to k__2 with 1 args
    j L1
  L0:
    ld t0, 0(fp)
    li t1, 3
    srai t0, t0, 1
    srai t1, t1, 1
    sub t0, t0, t1
    slli t0, t0, 1
    ori t0, t0, 1
    sd t0, -32(fp)
    addi sp, sp, -16
    la t5, f_0
    li t6, 7
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, -40(fp)
  # Application to arg_0 with 2 args
  # Load args on stack
    addi sp, sp, -32
    ld t0, -40(fp)
    sd t0, 0(sp)
    li t0, 5
    sd t0, 8(sp)
    ld t0, 8(fp)
    sd t0, 16(sp)
    ld t0, 0(fp)
    sd t0, 24(sp)
  # End loading args on stack
    call apply_closure_chain
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to arg_0 with 2 args
    sd t0, -48(fp)
  # Application to fac__0 with 2 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, fac__0
    li t6, 5
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 5
    sd t0, 8(sp)
    ld t0, -32(fp)
    sd t0, 16(sp)
    ld t0, -48(fp)
    sd t0, 24(sp)
  # End loading args on stack
    call apply_closure_chain
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to fac__0 with 2 args
  L1:
    ld ra, 40(sp)
    ld fp, 32(sp)
    addi sp, sp, 48
    ret
  .globl f_1
  f_1:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd fp, 0(sp)
    addi fp, sp, 16
    ld a0, 0(fp)
    ld ra, 8(sp)
    ld fp, 0(sp)
    addi sp, sp, 16
    ret
  .globl _start
  _start:
    mv fp, sp
    mv a0, sp
    call init_GC
    addi sp, sp, -16
    addi sp, sp, -16
    la t5, f_1
    li t6, 3
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, -8(fp)
  # Application to fac__0 with 2 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, fac__0
    li t6, 5
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 5
    sd t0, 8(sp)
    li t0, 13
    sd t0, 16(sp)
    ld t0, -8(fp)
    sd t0, 24(sp)
  # End loading args on stack
    call apply_closure_chain
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to fac__0 with 2 args
    sd t0, -16(fp)
  # Apply print_int
    ld a0, -16(fp)
    call print_int
  # End Apply print_int
    la a1, main__4
    sd a0, 0(a1)
    call flush
    li a0, 0
    li a7, 94
    ecall
  .section global_vars, "aw", @progbits
  .balign 8
  .globl main__4
  main__4: .dword 0


  $ make compile opts=-gen_mid input=test/manytests/typed/012fibcps.ml --no-print-directory -C ..
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe  | tee -a results.txt && echo "-----" >> results.txt
  8
  $ cat ../main.anf
  let f_0 = fun a__3__new ->
    fun k__2__new ->
    fun b__4 ->
    let anf_t7 = a__3__new + b__4 in
    k__2__new anf_t7 
  
  
  let f_1 = fun k__2__new ->
    fun n__1__new ->
    fun a__3 ->
    let anf_t6 = n__1__new - 2 in
    let arg_0 = f_0 in
    let anf_t9 = arg_0 a__3 k__2__new in
    fib__0 anf_t6 anf_t9 
  
  
  let rec fib__0 = fun n__1 ->
    fun k__2 ->
    let anf_t3 = n__1 < 2 in
    if anf_t3 then (k__2 n__1)
    else let anf_t5 = n__1 - 1 in
    let arg_1 = f_1 in
    let anf_t11 = arg_1 k__2 n__1 in
    fib__0 anf_t5 anf_t11 
  
  
  let f_2 = fun x__6 ->
    x__6 
  
  
  let main__5 = let anf_t0 = f_2 in
    let anf_t1 = fib__0 6 anf_t0 in
    print_int anf_t1 

  $ cat ../main.s
  .text
  .globl f_0
  f_0:
    addi sp, sp, -32
    sd ra, 24(sp)
    sd fp, 16(sp)
    addi fp, sp, 32
    ld t0, 0(fp)
    ld t1, 16(fp)
    srai t0, t0, 1
    srai t1, t1, 1
    add t0, t0, t1
    slli t0, t0, 1
    ori t0, t0, 1
    sd t0, -24(fp)
  # Application to k__2__new with 1 args
  # Load args on stack
    addi sp, sp, -32
    ld t0, 8(fp)
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    ld t0, -24(fp)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to k__2__new with 1 args
    ld ra, 24(sp)
    ld fp, 16(sp)
    addi sp, sp, 32
    ret
  .globl f_1
  f_1:
    addi sp, sp, -48
    sd ra, 40(sp)
    sd fp, 32(sp)
    addi fp, sp, 48
    ld t0, 8(fp)
    li t1, 5
    srai t0, t0, 1
    srai t1, t1, 1
    sub t0, t0, t1
    slli t0, t0, 1
    ori t0, t0, 1
    sd t0, -24(fp)
    addi sp, sp, -16
    la t5, f_0
    li t6, 7
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, -32(fp)
  # Application to arg_0 with 2 args
  # Load args on stack
    addi sp, sp, -32
    ld t0, -32(fp)
    sd t0, 0(sp)
    li t0, 5
    sd t0, 8(sp)
    ld t0, 16(fp)
    sd t0, 16(sp)
    ld t0, 0(fp)
    sd t0, 24(sp)
  # End loading args on stack
    call apply_closure_chain
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to arg_0 with 2 args
    sd t0, -40(fp)
  # Application to fib__0 with 2 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, fib__0
    li t6, 5
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 5
    sd t0, 8(sp)
    ld t0, -24(fp)
    sd t0, 16(sp)
    ld t0, -40(fp)
    sd t0, 24(sp)
  # End loading args on stack
    call apply_closure_chain
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to fib__0 with 2 args
    ld ra, 40(sp)
    ld fp, 32(sp)
    addi sp, sp, 48
    ret
  .globl fib__0
  fib__0:
    addi sp, sp, -48
    sd ra, 40(sp)
    sd fp, 32(sp)
    addi fp, sp, 48
    ld t0, 0(fp)
    li t1, 5
    slt t0, t0, t1
    sd t0, -24(fp)
    ld t0, -24(fp)
    beq t0, zero, L0
  # Application to k__2 with 1 args
  # Load args on stack
    addi sp, sp, -32
    ld t0, 8(fp)
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    ld t0, 0(fp)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to k__2 with 1 args
    j L1
  L0:
    ld t0, 0(fp)
    li t1, 3
    srai t0, t0, 1
    srai t1, t1, 1
    sub t0, t0, t1
    slli t0, t0, 1
    ori t0, t0, 1
    sd t0, -32(fp)
    addi sp, sp, -16
    la t5, f_1
    li t6, 7
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, -40(fp)
  # Application to arg_1 with 2 args
  # Load args on stack
    addi sp, sp, -32
    ld t0, -40(fp)
    sd t0, 0(sp)
    li t0, 5
    sd t0, 8(sp)
    ld t0, 8(fp)
    sd t0, 16(sp)
    ld t0, 0(fp)
    sd t0, 24(sp)
  # End loading args on stack
    call apply_closure_chain
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to arg_1 with 2 args
    sd t0, -48(fp)
  # Application to fib__0 with 2 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, fib__0
    li t6, 5
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 5
    sd t0, 8(sp)
    ld t0, -32(fp)
    sd t0, 16(sp)
    ld t0, -48(fp)
    sd t0, 24(sp)
  # End loading args on stack
    call apply_closure_chain
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to fib__0 with 2 args
  L1:
    ld ra, 40(sp)
    ld fp, 32(sp)
    addi sp, sp, 48
    ret
  .globl f_2
  f_2:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd fp, 0(sp)
    addi fp, sp, 16
    ld a0, 0(fp)
    ld ra, 8(sp)
    ld fp, 0(sp)
    addi sp, sp, 16
    ret
  .globl _start
  _start:
    mv fp, sp
    mv a0, sp
    call init_GC
    addi sp, sp, -16
    addi sp, sp, -16
    la t5, f_2
    li t6, 3
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, -8(fp)
  # Application to fib__0 with 2 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, fib__0
    li t6, 5
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 5
    sd t0, 8(sp)
    li t0, 13
    sd t0, 16(sp)
    ld t0, -8(fp)
    sd t0, 24(sp)
  # End loading args on stack
    call apply_closure_chain
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to fib__0 with 2 args
    sd t0, -16(fp)
  # Apply print_int
    ld a0, -16(fp)
    call print_int
  # End Apply print_int
    la a1, main__5
    sd a0, 0(a1)
    call flush
    li a0, 0
    li a7, 94
    ecall
  .section global_vars, "aw", @progbits
  .balign 8
  .globl main__5
  main__5: .dword 0

  $ make compile opts=-gen_mid input=test/manytests/typed/004manyargs.ml --no-print-directory -C ..
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe  | tee -a results.txt && echo "-----" >> results.txt
  1111111111
  1
  10
  100
  $ cat ../main.anf
  let wrap__0 = fun f__1 ->
    let anf_t15 = 1 = 1 in
    if anf_t15 then (f__1)
    else f__1 
  
  
  let test3__2 = fun a__3 ->
    fun b__4 ->
    fun c__5 ->
    let anf_t14 = print_int a__3 in
    let a__6 = anf_t14 in
    let anf_t13 = print_int b__4 in
    let b__7 = anf_t13 in
    let anf_t12 = print_int c__5 in
    let c__8 = anf_t12 in
    0 
  
  
  let test10__9 = fun a__10 ->
    fun b__11 ->
    fun c__12 ->
    fun d__13 ->
    fun e__14 ->
    fun f__15 ->
    fun g__16 ->
    fun h__17 ->
    fun i__18 ->
    fun j__19 ->
    let anf_t3 = a__10 + b__11 in
    let anf_t4 = anf_t3 + c__12 in
    let anf_t5 = anf_t4 + d__13 in
    let anf_t6 = anf_t5 + e__14 in
    let anf_t7 = anf_t6 + f__15 in
    let anf_t8 = anf_t7 + g__16 in
    let anf_t9 = anf_t8 + h__17 in
    let anf_t10 = anf_t9 + i__18 in
    anf_t10 + j__19 
  
  
  let main__20 = let anf_t2 = wrap__0 test10__9 1 10 100 1000 10000 100000 1000000 10000000 100000000 1000000000 in
    let rez__21 = anf_t2 in
    let anf_t1 = print_int rez__21 in
    let anf_t0 = wrap__0 test3__2 1 10 100 in
    let temp2__22 = anf_t0 in
    0 

  $ cat ../main.s
  .text
  .globl wrap__0
  wrap__0:
    addi sp, sp, -32
    sd ra, 24(sp)
    sd fp, 16(sp)
    addi fp, sp, 32
    li t0, 3
    li t1, 3
    sub t0, t0, t1
    seqz t0, t0
    sd t0, -24(fp)
    ld t0, -24(fp)
    beq t0, zero, L0
    ld a0, 0(fp)
    j L1
  L0:
    ld a0, 0(fp)
  L1:
    ld ra, 24(sp)
    ld fp, 16(sp)
    addi sp, sp, 32
    ret
  .globl test3__2
  test3__2:
    addi sp, sp, -64
    sd ra, 56(sp)
    sd fp, 48(sp)
    addi fp, sp, 64
  # Apply print_int
    ld a0, 0(fp)
    call print_int
    mv t0, a0
  # End Apply print_int
    sd t0, -24(fp)
    ld t0, -24(fp)
    sd t0, -32(fp)
  # Apply print_int
    ld a0, 8(fp)
    call print_int
    mv t0, a0
  # End Apply print_int
    sd t0, -40(fp)
    ld t0, -40(fp)
    sd t0, -48(fp)
  # Apply print_int
    ld a0, 16(fp)
    call print_int
    mv t0, a0
  # End Apply print_int
    sd t0, -56(fp)
    ld t0, -56(fp)
    sd t0, -64(fp)
    li a0, 1
    ld ra, 56(sp)
    ld fp, 48(sp)
    addi sp, sp, 64
    ret
  .globl test10__9
  test10__9:
    addi sp, sp, -80
    sd ra, 72(sp)
    sd fp, 64(sp)
    addi fp, sp, 80
    ld t0, 0(fp)
    ld t1, 8(fp)
    srai t0, t0, 1
    srai t1, t1, 1
    add t0, t0, t1
    slli t0, t0, 1
    ori t0, t0, 1
    sd t0, -24(fp)
    ld t0, -24(fp)
    ld t1, 16(fp)
    srai t0, t0, 1
    srai t1, t1, 1
    add t0, t0, t1
    slli t0, t0, 1
    ori t0, t0, 1
    sd t0, -32(fp)
    ld t0, -32(fp)
    ld t1, 24(fp)
    srai t0, t0, 1
    srai t1, t1, 1
    add t0, t0, t1
    slli t0, t0, 1
    ori t0, t0, 1
    sd t0, -40(fp)
    ld t0, -40(fp)
    ld t1, 32(fp)
    srai t0, t0, 1
    srai t1, t1, 1
    add t0, t0, t1
    slli t0, t0, 1
    ori t0, t0, 1
    sd t0, -48(fp)
    ld t0, -48(fp)
    ld t1, 40(fp)
    srai t0, t0, 1
    srai t1, t1, 1
    add t0, t0, t1
    slli t0, t0, 1
    ori t0, t0, 1
    sd t0, -56(fp)
    ld t0, -56(fp)
    ld t1, 48(fp)
    srai t0, t0, 1
    srai t1, t1, 1
    add t0, t0, t1
    slli t0, t0, 1
    ori t0, t0, 1
    sd t0, -64(fp)
    ld t0, -64(fp)
    ld t1, 56(fp)
    srai t0, t0, 1
    srai t1, t1, 1
    add t0, t0, t1
    slli t0, t0, 1
    ori t0, t0, 1
    sd t0, -72(fp)
    ld t0, -72(fp)
    ld t1, 64(fp)
    srai t0, t0, 1
    srai t1, t1, 1
    add t0, t0, t1
    slli t0, t0, 1
    ori t0, t0, 1
    sd t0, -80(fp)
    ld t0, -80(fp)
    ld t1, 72(fp)
    srai t0, t0, 1
    srai t1, t1, 1
    add a0, t0, t1
    slli a0, a0, 1
    ori a0, a0, 1
    ld ra, 72(sp)
    ld fp, 64(sp)
    addi sp, sp, 80
    ret
  .globl _start
  _start:
    mv fp, sp
    mv a0, sp
    call init_GC
    addi sp, sp, -40
  # Application to wrap__0 with 11 args
  # Load args on stack
    addi sp, sp, -112
    addi sp, sp, -16
    la t5, wrap__0
    li t6, 3
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 23
    sd t0, 8(sp)
    addi sp, sp, -16
    la t5, test10__9
    li t6, 21
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 16(sp)
    li t0, 3
    sd t0, 24(sp)
    li t0, 21
    sd t0, 32(sp)
    li t0, 201
    sd t0, 40(sp)
    li t0, 2001
    sd t0, 48(sp)
    li t0, 20001
    sd t0, 56(sp)
    li t0, 200001
    sd t0, 64(sp)
    li t0, 2000001
    sd t0, 72(sp)
    li t0, 20000001
    sd t0, 80(sp)
    li t0, 200000001
    sd t0, 88(sp)
    li t0, 2000000001
    sd t0, 96(sp)
  # End loading args on stack
    call apply_closure_chain
    mv t0, a0
  # Free args on stack
    addi sp, sp, 112
  # End free args on stack
  # End Application to wrap__0 with 11 args
    sd t0, -8(fp)
    ld t0, -8(fp)
    sd t0, -16(fp)
  # Apply print_int
    ld a0, -16(fp)
    call print_int
    mv t0, a0
  # End Apply print_int
    sd t0, -24(fp)
  # Application to wrap__0 with 4 args
  # Load args on stack
    addi sp, sp, -48
    addi sp, sp, -16
    la t5, wrap__0
    li t6, 3
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 9
    sd t0, 8(sp)
    addi sp, sp, -16
    la t5, test3__2
    li t6, 7
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 16(sp)
    li t0, 3
    sd t0, 24(sp)
    li t0, 21
    sd t0, 32(sp)
    li t0, 201
    sd t0, 40(sp)
  # End loading args on stack
    call apply_closure_chain
    mv t0, a0
  # Free args on stack
    addi sp, sp, 48
  # End free args on stack
  # End Application to wrap__0 with 4 args
    sd t0, -32(fp)
    ld t0, -32(fp)
    sd t0, -40(fp)
    li a0, 1
    la a1, main__20
    sd a0, 0(a1)
    call flush
    li a0, 0
    li a7, 94
    ecall
  .section global_vars, "aw", @progbits
  .balign 8
  .globl main__20
  main__20: .dword 0

( IT MUST BE AT THE END OF THE CRAM TEST )
  $ cat results.txt
  720
  -----
  8
  -----
  1111111111
  1
  10
  100
  -----
