( IT MUST BE AT THE START OF THE CRAM TEST )
  $ rm -f results.txt
  $ touch results.txt

  $ make compile opts=-anf input=bin/tests/fact --no-print-directory -C ..
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
    addi sp, sp, -56
    sd ra, 48(sp)
    sd fp, 40(sp)
    addi fp, sp, 56
    ld t0, 0(fp)
    li t1, 1
    slt t0, t1, t0
    xori t0, t0, 1
    sd t0, -24(fp)
    ld t0, -24(fp)
    beq t0, zero, L0
    li a0, 1
    j L1
  L0:
    ld t0, 0(fp)
    li t1, 1
    sub t0, t0, t1
    sd t0, -32(fp)
    ld t0, -32(fp)
    sd t0, -40(fp)
  # Apply fac__0 with 1 args
  # Load args on stack
    addi sp, sp, -16
    ld t0, -40(fp)
    sd t0, 0(sp)
  # End loading args on stack
    call fac__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    mv t0, a0
  # End Apply fac__0 with 1 args
    sd t0, -48(fp)
    ld t0, -48(fp)
    sd t0, -56(fp)
    ld t0, 0(fp)
    ld t1, -56(fp)
    mul a0, t0, t1
  L1:
    ld ra, 48(sp)
    ld fp, 40(sp)
    addi sp, sp, 56
    ret
  .globl _start
  _start:
    mv fp, sp
    addi sp, sp, -8
  # Apply fac__0 with 1 args
  # Load args on stack
    addi sp, sp, -16
    li t0, 4
    sd t0, 0(sp)
  # End loading args on stack
    call fac__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    mv t0, a0
  # End Apply fac__0 with 1 args
    sd t0, -8(fp)
  # Apply print_int
    ld a0, -8(fp)
    call print_int
    mv t0, a0
  # End Apply print_int
    call flush
    li a0, 0
    li a7, 94
    ecall

  $ make compile opts=-anf input=bin/tests/fib --no-print-directory -C ..
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
    addi sp, sp, -56
    sd ra, 48(sp)
    sd fp, 40(sp)
    addi fp, sp, 56
    ld t0, 0(fp)
    li t1, 2
    slt t0, t0, t1
    sd t0, -24(fp)
    ld t0, -24(fp)
    beq t0, zero, L0
    ld a0, 0(fp)
    j L1
  L0:
    ld t0, 0(fp)
    li t1, 1
    sub t0, t0, t1
    sd t0, -32(fp)
  # Apply fib__0 with 1 args
  # Load args on stack
    addi sp, sp, -16
    ld t0, -32(fp)
    sd t0, 0(sp)
  # End loading args on stack
    call fib__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    mv t0, a0
  # End Apply fib__0 with 1 args
    sd t0, -40(fp)
    ld t0, 0(fp)
    li t1, 2
    sub t0, t0, t1
    sd t0, -48(fp)
  # Apply fib__0 with 1 args
  # Load args on stack
    addi sp, sp, -16
    ld t0, -48(fp)
    sd t0, 0(sp)
  # End loading args on stack
    call fib__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    mv t0, a0
  # End Apply fib__0 with 1 args
    sd t0, -56(fp)
    ld t0, -40(fp)
    ld t1, -56(fp)
    add a0, t0, t1
  L1:
    ld ra, 48(sp)
    ld fp, 40(sp)
    addi sp, sp, 56
    ret
  .globl _start
  _start:
    mv fp, sp
    addi sp, sp, -8
  # Apply fib__0 with 1 args
  # Load args on stack
    addi sp, sp, -16
    li t0, 10
    sd t0, 0(sp)
  # End loading args on stack
    call fib__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    mv t0, a0
  # End Apply fib__0 with 1 args
    sd t0, -8(fp)
  # Apply print_int
    ld a0, -8(fp)
    call print_int
    mv t0, a0
  # End Apply print_int
    call flush
    li a0, 0
    li a7, 94
    ecall

  $ make compile opts=-anf input=bin/tests/large_if --no-print-directory -C ..
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
    addi sp, sp, -24
    sd ra, 16(sp)
    sd fp, 8(sp)
    addi fp, sp, 24
    li t0, 0
    ld t1, 0(fp)
    sub t0, t0, t1
    snez t0, t0
    sd t0, -24(fp)
    ld t0, -24(fp)
    beq t0, zero, L0
  # Apply print_int
    li a0, 0
    call print_int
  # End Apply print_int
    j L1
  L0:
  # Apply print_int
    li a0, 1
    call print_int
  # End Apply print_int
  L1:
    ld ra, 16(sp)
    ld fp, 8(sp)
    addi sp, sp, 24
    ret
  .globl _start
  _start:
    mv fp, sp
    addi sp, sp, -136
    li t0, 0
    li t1, 1
    sub t0, t0, t1
    seqz t0, t0
    sd t0, -8(fp)
    ld t0, -8(fp)
    beq t0, zero, L14
    li t0, 0
    li t1, 1
    sub t0, t0, t1
    seqz t0, t0
    sd t0, -16(fp)
    ld t0, -16(fp)
    beq t0, zero, L6
    li t0, 0
    li t1, 1
    sub t0, t0, t1
    seqz t0, t0
    sd t0, -24(fp)
    ld t0, -24(fp)
    beq t0, zero, L2
    li t0, 0
    sd t0, -32(fp)
  # Apply large__0 with 1 args
  # Load args on stack
    addi sp, sp, -16
    ld t0, -32(fp)
    sd t0, 0(sp)
  # End loading args on stack
    call large__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    mv t0, a0
  # End Apply large__0 with 1 args
    j L3
  L2:
    li t0, 1
    sd t0, -40(fp)
  # Apply large__0 with 1 args
  # Load args on stack
    addi sp, sp, -16
    ld t0, -40(fp)
    sd t0, 0(sp)
  # End loading args on stack
    call large__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    mv t0, a0
  # End Apply large__0 with 1 args
  L3:
    j L7
  L6:
    li t0, 1
    li t1, 1
    sub t0, t0, t1
    seqz t0, t0
    sd t0, -48(fp)
    ld t0, -48(fp)
    beq t0, zero, L4
    li t0, 0
    sd t0, -56(fp)
  # Apply large__0 with 1 args
  # Load args on stack
    addi sp, sp, -16
    ld t0, -56(fp)
    sd t0, 0(sp)
  # End loading args on stack
    call large__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    mv t0, a0
  # End Apply large__0 with 1 args
    j L5
  L4:
    li t0, 1
    sd t0, -64(fp)
  # Apply large__0 with 1 args
  # Load args on stack
    addi sp, sp, -16
    ld t0, -64(fp)
    sd t0, 0(sp)
  # End loading args on stack
    call large__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    mv t0, a0
  # End Apply large__0 with 1 args
  L5:
  L7:
    j L15
  L14:
  # Apply print_int
    li a0, 42
    call print_int
    mv t0, a0
  # End Apply print_int
    sd t0, -72(fp)
    ld t0, -72(fp)
    sd t0, -80(fp)
    li t0, 1
    li t1, 1
    sub t0, t0, t1
    seqz t0, t0
    sd t0, -88(fp)
    ld t0, -88(fp)
    beq t0, zero, L12
    li t0, 0
    li t1, 1
    sub t0, t0, t1
    seqz t0, t0
    sd t0, -96(fp)
    ld t0, -96(fp)
    beq t0, zero, L8
    li t0, 0
    sd t0, -104(fp)
  # Apply large__0 with 1 args
  # Load args on stack
    addi sp, sp, -16
    ld t0, -104(fp)
    sd t0, 0(sp)
  # End loading args on stack
    call large__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    mv t0, a0
  # End Apply large__0 with 1 args
    j L9
  L8:
    li t0, 1
    sd t0, -112(fp)
  # Apply large__0 with 1 args
  # Load args on stack
    addi sp, sp, -16
    ld t0, -112(fp)
    sd t0, 0(sp)
  # End loading args on stack
    call large__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    mv t0, a0
  # End Apply large__0 with 1 args
  L9:
    j L13
  L12:
    li t0, 1
    li t1, 1
    sub t0, t0, t1
    seqz t0, t0
    sd t0, -120(fp)
    ld t0, -120(fp)
    beq t0, zero, L10
    li t0, 0
    sd t0, -128(fp)
  # Apply large__0 with 1 args
  # Load args on stack
    addi sp, sp, -16
    ld t0, -128(fp)
    sd t0, 0(sp)
  # End loading args on stack
    call large__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    mv t0, a0
  # End Apply large__0 with 1 args
    j L11
  L10:
    li t0, 1
    sd t0, -136(fp)
  # Apply large__0 with 1 args
  # Load args on stack
    addi sp, sp, -16
    ld t0, -136(fp)
    sd t0, 0(sp)
  # End loading args on stack
    call large__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    mv t0, a0
  # End Apply large__0 with 1 args
  L11:
  L13:
  L15:
    call flush
    li a0, 0
    li a7, 94
    ecall

( IT MUST BE AT THE END OF THE CRAM TEST )
  $ cat results.txt
  24
  -----
  55
  -----
  42
  0
  -----
