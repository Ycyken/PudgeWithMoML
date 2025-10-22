  $ make compile input=bin/fact_cc_ln --no-print-directory -C ..
  Fatal error: exception Failure("gen_cexpr case not implemented yet: fun k__4 ->\nfun p__5 ->\nlet anf_t10 = p__5 * n__3 in\nk__4 anf_t10")
  Raised at Stdlib.failwith in file "stdlib.ml", line 29, characters 17-33
  Called from PudgeWithMoML__Riscv__Codegen.gen_astr_item in file "lib/riscv/codegen.ml", line 146, characters 21-41
  Called from PudgeWithMoML__Common__Monad.State.(>>=) in file "lib/common/monad.ml", line 39, characters 16-20
  Called from PudgeWithMoML__Common__Monad.State.(>>=) in file "lib/common/monad.ml", line 39, characters 16-20
  Called from PudgeWithMoML__Riscv__Codegen.gen_aprogram in file "lib/riscv/codegen.ml", line 186, characters 16-43
  Called from Dune__exe__Compiler.compiler in file "bin/compiler.ml", line 49, characters 10-30
  make: *** [Makefile:27: compile] Error 2
  [2]

  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe
  [1]
  $ cat ../main.s


  $ make compile input=bin/fact --no-print-directory -C ..
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe
  24
  $ cat ../main.s
  .text
  .globl _start
  fac__0:
    addi sp, sp, -80
    sd ra, 72(sp)
    sd fp, 64(sp)
    addi fp, sp, 80
    sd a0, -24(fp)
    ld t0, -24(fp)
    li t1, 1
    slt t0, t1, t0
    xori t0, t0, 1
    sd t0, -32(fp)
    ld t0, -32(fp)
    beq t0, zero, L0
    li a0, 1
    j L1
  L0:
    ld t0, -24(fp)
    li t1, 1
    sub t0, t0, t1
    sd t0, -40(fp)
    ld t0, -40(fp)
    sd t0, -48(fp)
    ld a0, -48(fp)
    call fac__0
    mv t0, a0
    sd t0, -56(fp)
    ld t0, -56(fp)
    sd t0, -64(fp)
    ld t0, -24(fp)
    ld t1, -64(fp)
    mul a0, t0, t1
  L1:
    ld ra, 72(sp)
    ld fp, 64(sp)
    addi sp, sp, 80
    ret
  _start:
    mv fp, sp
    addi sp, sp, -8
    li a0, 4
    call fac__0
    mv t0, a0
    sd t0, -8(fp)
    ld a0, -8(fp)
    call print_int
    call flush
    li a0, 0
    li a7, 94
    ecall

  $ make compile input=bin/fib --no-print-directory -C ..
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe
  55
  $ cat ../main.s
  .text
  .globl _start
  fib__0:
    addi sp, sp, -80
    sd ra, 72(sp)
    sd fp, 64(sp)
    addi fp, sp, 80
    sd a0, -24(fp)
    ld t0, -24(fp)
    li t1, 2
    slt t0, t0, t1
    sd t0, -32(fp)
    ld t0, -32(fp)
    beq t0, zero, L0
    ld a0, -24(fp)
    j L1
  L0:
    ld t0, -24(fp)
    li t1, 1
    sub t0, t0, t1
    sd t0, -40(fp)
    ld a0, -40(fp)
    call fib__0
    mv t0, a0
    sd t0, -48(fp)
    ld t0, -24(fp)
    li t1, 2
    sub t0, t0, t1
    sd t0, -56(fp)
    ld a0, -56(fp)
    call fib__0
    mv t0, a0
    sd t0, -64(fp)
    ld t0, -48(fp)
    ld t1, -64(fp)
    add a0, t0, t1
  L1:
    ld ra, 72(sp)
    ld fp, 64(sp)
    addi sp, sp, 80
    ret
  _start:
    mv fp, sp
    addi sp, sp, -8
    li a0, 10
    call fib__0
    mv t0, a0
    sd t0, -8(fp)
    ld a0, -8(fp)
    call print_int
    call flush
    li a0, 0
    li a7, 94
    ecall

  $ make compile input=bin/large_if --no-print-directory -C ..
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe
  42
  0
  $ cat ../main.s
  .text
  .globl _start
  large__0:
    addi sp, sp, -48
    sd ra, 40(sp)
    sd fp, 32(sp)
    addi fp, sp, 48
    sd a0, -24(fp)
    li t0, 0
    ld t1, -24(fp)
    sub t0, t0, t1
    snez t0, t0
    sd t0, -32(fp)
    ld t0, -32(fp)
    beq t0, zero, L0
    li a0, 0
    call print_int
    j L1
  L0:
    li a0, 1
    call print_int
  L1:
    ld ra, 40(sp)
    ld fp, 32(sp)
    addi sp, sp, 48
    ret
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
    ld a0, -32(fp)
    call large__0
    j L3
  L2:
    li t0, 1
    sd t0, -40(fp)
    ld a0, -40(fp)
    call large__0
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
    ld a0, -56(fp)
    call large__0
    j L5
  L4:
    li t0, 1
    sd t0, -64(fp)
    ld a0, -64(fp)
    call large__0
  L5:
  L7:
    j L15
  L14:
    li a0, 42
    call print_int
    mv t0, a0
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
    ld a0, -104(fp)
    call large__0
    j L9
  L8:
    li t0, 1
    sd t0, -112(fp)
    ld a0, -112(fp)
    call large__0
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
    ld a0, -128(fp)
    call large__0
    j L11
  L10:
    li t0, 1
    sd t0, -136(fp)
    ld a0, -136(fp)
    call large__0
  L11:
  L13:
  L15:
    call flush
    li a0, 0
    li a7, 94
    ecall
