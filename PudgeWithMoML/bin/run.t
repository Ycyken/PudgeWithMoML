  $ make compile input=bin/fact_cc_ln --no-print-directory -C ..
  Fatal error: exception Failure("unbound variable: id__0")
  Raised at Stdlib.failwith in file "stdlib.ml", line 29, characters 17-33
  Called from PudgeWithMoML__Common__Monad.State.(>>|).(fun) in file "lib/common/monad.ml", line 43, characters 42-47
  Called from PudgeWithMoML__Common__Monad.State.(>>=) in file "lib/common/monad.ml", line 39, characters 16-20
  Called from PudgeWithMoML__Common__Monad.State.(>>=) in file "lib/common/monad.ml", line 39, characters 16-20
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

  $ make compile input=bin/fact --no-print-directory -C ..
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe
  24
  $ cat ../main.s
  .text
  .globl _start
  .globl fac__0
  fac__0:
    addi sp, sp, -72
    sd ra, 64(sp)
    sd fp, 56(sp)
    addi fp, sp, 72
    ld t0, 8(fp)
    li t1, 1
    slt t0, t1, t0
    xori t0, t0, 1
    sd t0, -24(fp)
    ld t0, -24(fp)
    beq t0, zero, L0
    li a0, 1
    j L1
  L0:
    ld t0, 8(fp)
    li t1, 1
    sub t0, t0, t1
    sd t0, -32(fp)
    ld t0, -32(fp)
    sd t0, -40(fp)
    addi sp, sp, -16
    ld t0, -40(fp)
    sd t0, 8(sp)
    call fac__0
    addi sp, sp, 16
    mv t0, a0
    sd t0, -64(fp)
    ld t0, -64(fp)
    sd t0, -72(fp)
    ld t0, 8(fp)
    ld t1, -72(fp)
    mul a0, t0, t1
  L1:
    ld ra, 64(sp)
    ld fp, 56(sp)
    addi sp, sp, 72
    ret
  _start:
    mv fp, sp
    addi sp, sp, -24
    addi sp, sp, -16
    li t0, 4
    sd t0, 8(sp)
    call fac__0
    addi sp, sp, 16
    mv t0, a0
    sd t0, -24(fp)
    ld a0, -24(fp)
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
  .globl fib__0
  fib__0:
    addi sp, sp, -88
    sd ra, 80(sp)
    sd fp, 72(sp)
    addi fp, sp, 88
    ld t0, 8(fp)
    li t1, 2
    slt t0, t0, t1
    sd t0, -24(fp)
    ld t0, -24(fp)
    beq t0, zero, L0
    ld a0, 8(fp)
    j L1
  L0:
    ld t0, 8(fp)
    li t1, 1
    sub t0, t0, t1
    sd t0, -32(fp)
    addi sp, sp, -16
    ld t0, -32(fp)
    sd t0, 8(sp)
    call fib__0
    addi sp, sp, 16
    mv t0, a0
    sd t0, -56(fp)
    ld t0, 8(fp)
    li t1, 2
    sub t0, t0, t1
    sd t0, -64(fp)
    addi sp, sp, -16
    ld t0, -64(fp)
    sd t0, 8(sp)
    call fib__0
    addi sp, sp, 16
    mv t0, a0
    sd t0, -88(fp)
    ld t0, -56(fp)
    ld t1, -88(fp)
    add a0, t0, t1
  L1:
    ld ra, 80(sp)
    ld fp, 72(sp)
    addi sp, sp, 88
    ret
  _start:
    mv fp, sp
    addi sp, sp, -24
    addi sp, sp, -16
    li t0, 10
    sd t0, 8(sp)
    call fib__0
    addi sp, sp, 16
    mv t0, a0
    sd t0, -24(fp)
    ld a0, -24(fp)
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
  .globl large__0
  large__0:
    addi sp, sp, -24
    sd ra, 16(sp)
    sd fp, 8(sp)
    addi fp, sp, 24
    li t0, 0
    ld t1, 8(fp)
    sub t0, t0, t1
    snez t0, t0
    sd t0, -24(fp)
    ld t0, -24(fp)
    beq t0, zero, L0
    li a0, 0
    call print_int
    j L1
  L0:
    li a0, 1
    call print_int
  L1:
    ld ra, 16(sp)
    ld fp, 8(sp)
    addi sp, sp, 24
    ret
  _start:
    mv fp, sp
    addi sp, sp, -264
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
    addi sp, sp, -16
    ld t0, -32(fp)
    sd t0, 8(sp)
    call large__0
    addi sp, sp, 16
    j L3
  L2:
    li t0, 1
    sd t0, -56(fp)
    addi sp, sp, -16
    ld t0, -56(fp)
    sd t0, 8(sp)
    call large__0
    addi sp, sp, 16
  L3:
    j L7
  L6:
    li t0, 1
    li t1, 1
    sub t0, t0, t1
    seqz t0, t0
    sd t0, -80(fp)
    ld t0, -80(fp)
    beq t0, zero, L4
    li t0, 0
    sd t0, -88(fp)
    addi sp, sp, -16
    ld t0, -88(fp)
    sd t0, 8(sp)
    call large__0
    addi sp, sp, 16
    j L5
  L4:
    li t0, 1
    sd t0, -112(fp)
    addi sp, sp, -16
    ld t0, -112(fp)
    sd t0, 8(sp)
    call large__0
    addi sp, sp, 16
  L5:
  L7:
    j L15
  L14:
    li a0, 42
    call print_int
    mv t0, a0
    sd t0, -136(fp)
    ld t0, -136(fp)
    sd t0, -144(fp)
    li t0, 1
    li t1, 1
    sub t0, t0, t1
    seqz t0, t0
    sd t0, -152(fp)
    ld t0, -152(fp)
    beq t0, zero, L12
    li t0, 0
    li t1, 1
    sub t0, t0, t1
    seqz t0, t0
    sd t0, -160(fp)
    ld t0, -160(fp)
    beq t0, zero, L8
    li t0, 0
    sd t0, -168(fp)
    addi sp, sp, -16
    ld t0, -168(fp)
    sd t0, 8(sp)
    call large__0
    addi sp, sp, 16
    j L9
  L8:
    li t0, 1
    sd t0, -192(fp)
    addi sp, sp, -16
    ld t0, -192(fp)
    sd t0, 8(sp)
    call large__0
    addi sp, sp, 16
  L9:
    j L13
  L12:
    li t0, 1
    li t1, 1
    sub t0, t0, t1
    seqz t0, t0
    sd t0, -216(fp)
    ld t0, -216(fp)
    beq t0, zero, L10
    li t0, 0
    sd t0, -224(fp)
    addi sp, sp, -16
    ld t0, -224(fp)
    sd t0, 8(sp)
    call large__0
    addi sp, sp, 16
    j L11
  L10:
    li t0, 1
    sd t0, -248(fp)
    addi sp, sp, -16
    ld t0, -248(fp)
    sd t0, 8(sp)
    call large__0
    addi sp, sp, 16
  L11:
  L13:
  L15:
    call flush
    li a0, 0
    li a7, 94
    ecall
