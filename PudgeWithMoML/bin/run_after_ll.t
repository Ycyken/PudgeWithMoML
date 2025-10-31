( IT MUST BE AT THE START OF THE CRAM TEST )
  $ rm -f results.txt
  $ touch results.txt

  $ make compile opts=-anf input=test/manytests/typed/010faccps_ll.ml --no-print-directory -C ..
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe | tee -a results.txt && echo "-----" >> results.txt
  24
  $ cat ../main.anf
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
  $ cat ../main.s
  .text
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
    addi sp, sp, -32
    ld t0, -32(fp)
    sd t0, 0(sp)
    li t0, 1
    sd t0, 8(sp)
    ld t0, -24(fp)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure
  # Free args on stack
    addi sp, sp, 32
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
    addi sp, sp, -32
    ld t0, -32(fp)
    sd t0, 0(sp)
    li t0, 1
    sd t0, 8(sp)
    li t0, 1
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure
  # Free args on stack
    addi sp, sp, 32
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
    la t5, fresh_1__2
    li t6, 3
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 2
    sd t0, 8(sp)
    ld t0, 0(fp)
    sd t0, 16(sp)
    ld t0, 8(fp)
    sd t0, 24(sp)
  # End loading args on stack
    call apply_closure
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
  # End Apply fac_cps__6 with 2 args
  L3:
    ld ra, 40(sp)
    ld fp, 32(sp)
    addi sp, sp, 48
    ret
  .globl _start
  _start:
    mv fp, sp
    addi sp, sp, -16
  # Apply fac_cps__6 with 2 args
  # Load args on stack
    addi sp, sp, -16
    li t0, 4
    sd t0, 0(sp)
    addi sp, sp, -16
    la t5, id__0
    li t6, 1
    sd t5, 0(sp)
    sd t6, 8(sp)
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
    sd t0, -8(fp)
  # Apply print_int
    ld a0, -8(fp)
    call print_int
    mv t0, a0
  # End Apply print_int
    sd t0, -16(fp)
    li t0, 0
    la t1, main__9
    sd t0, 0(t1)
    call flush
    li a0, 0
    li a7, 94
    ecall
  .data
  main__9: .dword 0

  $ make compile opts=-anf input=test/manytests/typed/010fibcps_ll.ml --no-print-directory -C ..
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe  | tee -a results.txt && echo "-----" >> results.txt
  8
  $ cat ../main.anf
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
  $ cat ../main.s
  .text
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
    addi sp, sp, -32
    ld t0, -32(fp)
    sd t0, 0(sp)
    li t0, 1
    sd t0, 8(sp)
    ld t0, -24(fp)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Apply k__4 with 1 args
    ld ra, 24(sp)
    ld fp, 16(sp)
    addi sp, sp, 32
    ret
  .globl fresh_1__6
  fresh_1__6:
    addi sp, sp, -48
    sd ra, 40(sp)
    sd fp, 32(sp)
    addi fp, sp, 48
    ld t0, 0(fp)
    li t1, 2
    sub t0, t0, t1
    sd t0, -24(fp)
  # Partial application fresh_2__2 with 2 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, fresh_2__2
    li t6, 3
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 2
    sd t0, 8(sp)
    ld t0, 24(fp)
    sd t0, 16(sp)
    ld t0, 8(fp)
    sd t0, 24(sp)
  # End loading args on stack
    call apply_closure
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
    li t0, 1
    sd t0, 8(sp)
    ld t0, -24(fp)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
    mv t0, a0
    sd t0, -48(fp)
  # Load args on stack
    addi sp, sp, -32
    ld t0, -48(fp)
    sd t0, 0(sp)
    li t0, 1
    sd t0, 8(sp)
    ld t0, -32(fp)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Apply fib__9 with 2 args
    ld ra, 40(sp)
    ld fp, 32(sp)
    addi sp, sp, 48
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
    beq t0, zero, L4
  # Apply k__13 with 1 args
    ld t0, 8(fp)
    sd t0, -32(fp)
  # Load args on stack
    addi sp, sp, -32
    ld t0, -32(fp)
    sd t0, 0(sp)
    li t0, 1
    sd t0, 8(sp)
    ld t0, 0(fp)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Apply k__13 with 1 args
    j L5
  L4:
    ld t0, 0(fp)
    li t1, 1
    sub t0, t0, t1
    sd t0, -40(fp)
  # Partial application fresh_1__6 with 3 args
  # Load args on stack
    addi sp, sp, -48
    addi sp, sp, -16
    la t5, fresh_1__6
    li t6, 4
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    ld t0, 0(fp)
    sd t0, 16(sp)
    ld t0, 8(fp)
    sd t0, 24(sp)
    addi sp, sp, -16
    la t5, fib__11
    li t6, 2
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 32(sp)
  # End loading args on stack
    call apply_closure
    mv t0, a0
  # Free args on stack
    addi sp, sp, 48
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
  # End Apply fib__11 with 2 args
  L5:
    ld ra, 40(sp)
    ld fp, 32(sp)
    addi sp, sp, 48
    ret
  .globl _start
  _start:
    mv fp, sp
    addi sp, sp, -24
  # Apply fib__11 with 2 args
  # Load args on stack
    addi sp, sp, -16
    li t0, 6
    sd t0, 0(sp)
    addi sp, sp, -16
    la t5, id__0
    li t6, 1
    sd t5, 0(sp)
    sd t6, 8(sp)
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
    sd t0, -8(fp)
  # Apply print_int
    ld a0, -8(fp)
    call print_int
    mv t0, a0
  # End Apply print_int
    sd t0, -16(fp)
    ld t0, -16(fp)
    sd t0, -24(fp)
    li t0, 0
    la t1, main__14
    sd t0, 0(t1)
    call flush
    li a0, 0
    li a7, 94
    ecall
  .data
  main__14: .dword 0


( IT MUST BE AT THE END OF THE CRAM TEST )
  $ cat results.txt
  24
  -----
  8
  -----
