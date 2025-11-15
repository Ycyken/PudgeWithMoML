( IT MUST BE AT THE START OF THE CRAM TEST )
  $ rm -f results.txt
  $ touch results.txt

  $ make compile opts=-gen_mid input=bin/tests/fact --no-print-directory -C ..
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe  | tee -a results.txt && echo "-----" >> results.txt
  24
  $ cat ../main.anf
  let rec fac__0 = fun n__1 ->
    let anf_t2 = n__1 <= 1 in
    if anf_t2 then (1)
    else let anf_t5 = n__1 - 1 in
    let n1__2 = anf_t5 in
    let anf_t4 = fac__0 n1__2 in
    let m__3 = anf_t4 in
    n__1 * m__3 
  
  
  let main__4 = let anf_t0 = fac__0 4 in
    print_int anf_t0 
  $ cat ../main.s
  .text
  .globl fac__0
  fac__0:
    addi sp, sp, -64
    sd ra, 56(sp)
    sd fp, 48(sp)
    addi fp, sp, 64
    ld t0, 0(fp)
    li t1, 3
    slt t0, t1, t0
    xori t0, t0, 1
    sd t0, -24(fp)
    ld t0, -24(fp)
    beq t0, zero, L0
    li a0, 3
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
    ld t0, -32(fp)
    sd t0, -40(fp)
  # Application to fac__0 with 1 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, fac__0
    li t6, 3
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    ld t0, -40(fp)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to fac__0 with 1 args
    sd t0, -48(fp)
    ld t0, -48(fp)
    sd t0, -56(fp)
    ld t0, 0(fp)
    ld t1, -56(fp)
    srai t0, t0, 1
    srai t1, t1, 1
    mul a0, t0, t1
    slli a0, a0, 1
    ori a0, a0, 1
  L1:
    ld ra, 56(sp)
    ld fp, 48(sp)
    addi sp, sp, 64
    ret
  .globl _start
  _start:
    mv fp, sp
    mv a0, sp
    call init_GC
    addi sp, sp, -8
  # Application to fac__0 with 1 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, fac__0
    li t6, 3
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    li t0, 9
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to fac__0 with 1 args
    sd t0, -8(fp)
  # Apply print_int
    ld a0, -8(fp)
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

  $ make compile opts=-gen_mid input=bin/tests/fib --no-print-directory -C ..
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe  | tee -a results.txt && echo "-----" >> results.txt
  55
  $ cat ../main.anf
  let rec fib__0 = fun n__1 ->
    let anf_t2 = n__1 < 2 in
    if anf_t2 then (n__1)
    else let anf_t3 = n__1 - 1 in
    let anf_t4 = fib__0 anf_t3 in
    let anf_t5 = n__1 - 2 in
    let anf_t6 = fib__0 anf_t5 in
    anf_t4 + anf_t6 
  
  
  let main__2 = let anf_t0 = fib__0 10 in
    print_int anf_t0 
  $ cat ../main.s
  .text
  .globl fib__0
  fib__0:
    addi sp, sp, -64
    sd ra, 56(sp)
    sd fp, 48(sp)
    addi fp, sp, 64
    ld t0, 0(fp)
    li t1, 5
    slt t0, t0, t1
    sd t0, -24(fp)
    ld t0, -24(fp)
    beq t0, zero, L0
    ld a0, 0(fp)
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
  # Application to fib__0 with 1 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, fib__0
    li t6, 3
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    ld t0, -32(fp)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to fib__0 with 1 args
    sd t0, -40(fp)
    ld t0, 0(fp)
    li t1, 5
    srai t0, t0, 1
    srai t1, t1, 1
    sub t0, t0, t1
    slli t0, t0, 1
    ori t0, t0, 1
    sd t0, -48(fp)
  # Application to fib__0 with 1 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, fib__0
    li t6, 3
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    ld t0, -48(fp)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to fib__0 with 1 args
    sd t0, -56(fp)
    ld t0, -40(fp)
    ld t1, -56(fp)
    srai t0, t0, 1
    srai t1, t1, 1
    add a0, t0, t1
    slli a0, a0, 1
    ori a0, a0, 1
  L1:
    ld ra, 56(sp)
    ld fp, 48(sp)
    addi sp, sp, 64
    ret
  .globl _start
  _start:
    mv fp, sp
    mv a0, sp
    call init_GC
    addi sp, sp, -8
  # Application to fib__0 with 1 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, fib__0
    li t6, 3
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    li t0, 21
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to fib__0 with 1 args
    sd t0, -8(fp)
  # Apply print_int
    ld a0, -8(fp)
    call print_int
  # End Apply print_int
    la a1, main__2
    sd a0, 0(a1)
    call flush
    li a0, 0
    li a7, 94
    ecall
  .section global_vars, "aw", @progbits
  .balign 8
  .globl main__2
  main__2: .dword 0

  $ make compile opts=-gen_mid input=bin/tests/large_if --no-print-directory -C ..
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe  | tee -a results.txt && echo "-----" >> results.txt
  42
  0
  $ cat ../main.anf
  let large__0 = fun x__1 ->
    let anf_t9 = 0 <> x__1 in
    if anf_t9 then (print_int 0)
    else print_int 1 
  
  
  let main__2 = let anf_t1 = 0 = 1 in
    if anf_t1 then (let anf_t2 = 0 = 1 in
    if anf_t2 then (let anf_t3 = 0 = 1 in
    if anf_t3 then (let x__4 = 0 in
    large__0 x__4)
    else let x__4 = 1 in
    large__0 x__4)
    else let anf_t4 = 1 = 1 in
    if anf_t4 then (let x__4 = 0 in
    large__0 x__4)
    else let x__4 = 1 in
    large__0 x__4)
    else let anf_t8 = print_int 42 in
    let t42__3 = anf_t8 in
    let anf_t5 = 1 = 1 in
    if anf_t5 then (let anf_t6 = 0 = 1 in
    if anf_t6 then (let x__4 = 0 in
    large__0 x__4)
    else let x__4 = 1 in
    large__0 x__4)
    else let anf_t7 = 1 = 1 in
    if anf_t7 then (let x__4 = 0 in
    large__0 x__4)
    else let x__4 = 1 in
    large__0 x__4 
  $ cat ../main.s
  .text
  .globl large__0
  large__0:
    addi sp, sp, -32
    sd ra, 24(sp)
    sd fp, 16(sp)
    addi fp, sp, 32
    li t0, 1
    ld t1, 0(fp)
    sub t0, t0, t1
    snez t0, t0
    sd t0, -24(fp)
    ld t0, -24(fp)
    beq t0, zero, L0
  # Apply print_int
    li a0, 1
    call print_int
  # End Apply print_int
    j L1
  L0:
  # Apply print_int
    li a0, 3
    call print_int
  # End Apply print_int
  L1:
    ld ra, 24(sp)
    ld fp, 16(sp)
    addi sp, sp, 32
    ret
  .globl _start
  _start:
    mv fp, sp
    mv a0, sp
    call init_GC
    addi sp, sp, -136
    li t0, 1
    li t1, 3
    sub t0, t0, t1
    seqz t0, t0
    sd t0, -8(fp)
    ld t0, -8(fp)
    beq t0, zero, L14
    li t0, 1
    li t1, 3
    sub t0, t0, t1
    seqz t0, t0
    sd t0, -16(fp)
    ld t0, -16(fp)
    beq t0, zero, L6
    li t0, 1
    li t1, 3
    sub t0, t0, t1
    seqz t0, t0
    sd t0, -24(fp)
    ld t0, -24(fp)
    beq t0, zero, L2
    li t0, 1
    sd t0, -32(fp)
  # Application to large__0 with 1 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, large__0
    li t6, 3
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    ld t0, -32(fp)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to large__0 with 1 args
    j L3
  L2:
    li t0, 3
    sd t0, -40(fp)
  # Application to large__0 with 1 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, large__0
    li t6, 3
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    ld t0, -40(fp)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to large__0 with 1 args
  L3:
    j L7
  L6:
    li t0, 3
    li t1, 3
    sub t0, t0, t1
    seqz t0, t0
    sd t0, -48(fp)
    ld t0, -48(fp)
    beq t0, zero, L4
    li t0, 1
    sd t0, -56(fp)
  # Application to large__0 with 1 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, large__0
    li t6, 3
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    ld t0, -56(fp)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to large__0 with 1 args
    j L5
  L4:
    li t0, 3
    sd t0, -64(fp)
  # Application to large__0 with 1 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, large__0
    li t6, 3
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    ld t0, -64(fp)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to large__0 with 1 args
  L5:
  L7:
    j L15
  L14:
  # Apply print_int
    li a0, 85
    call print_int
    mv t0, a0
  # End Apply print_int
    sd t0, -72(fp)
    ld t0, -72(fp)
    sd t0, -80(fp)
    li t0, 3
    li t1, 3
    sub t0, t0, t1
    seqz t0, t0
    sd t0, -88(fp)
    ld t0, -88(fp)
    beq t0, zero, L12
    li t0, 1
    li t1, 3
    sub t0, t0, t1
    seqz t0, t0
    sd t0, -96(fp)
    ld t0, -96(fp)
    beq t0, zero, L8
    li t0, 1
    sd t0, -104(fp)
  # Application to large__0 with 1 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, large__0
    li t6, 3
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    ld t0, -104(fp)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to large__0 with 1 args
    j L9
  L8:
    li t0, 3
    sd t0, -112(fp)
  # Application to large__0 with 1 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, large__0
    li t6, 3
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    ld t0, -112(fp)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to large__0 with 1 args
  L9:
    j L13
  L12:
    li t0, 3
    li t1, 3
    sub t0, t0, t1
    seqz t0, t0
    sd t0, -120(fp)
    ld t0, -120(fp)
    beq t0, zero, L10
    li t0, 1
    sd t0, -128(fp)
  # Application to large__0 with 1 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, large__0
    li t6, 3
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    ld t0, -128(fp)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to large__0 with 1 args
    j L11
  L10:
    li t0, 3
    sd t0, -136(fp)
  # Application to large__0 with 1 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, large__0
    li t6, 3
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    ld t0, -136(fp)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to large__0 with 1 args
  L11:
  L13:
  L15:
    la a1, main__2
    sd a0, 0(a1)
    call flush
    li a0, 0
    li a7, 94
    ecall
  .section global_vars, "aw", @progbits
  .balign 8
  .globl main__2
  main__2: .dword 0

( IT MUST BE AT THE END OF THE CRAM TEST )
  $ cat results.txt
  24
  -----
  55
  -----
  42
  0
  -----
