  $ make compile input=bin/fact_cc_ln --no-print-directory -C ..

  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe
  63182 Segmentation fault      (core dumped) qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe
  [139]
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
  .globl fresh_1__2
  fresh_1__2:
    addi sp, sp, -24
    sd ra, 16(sp)
    sd fp, 8(sp)
    addi fp, sp, 24
    ld t0, 8(fp)
    ld t1, 24(fp)
    mul t0, t0, t1
    sd t0, -24(fp)
  # Load args on stack
    addi sp, sp, -16
    ld t0, -24(fp)
    sd t0, 8(sp)
  # End loading args on stack
    ld t0, 16(fp)
    jalr ra, t0, 0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    ld ra, 16(sp)
    ld fp, 8(sp)
    addi sp, sp, 24
    ret
  .globl fac_cps__6
  fac_cps__6:
    addi sp, sp, -40
    sd ra, 32(sp)
    sd fp, 24(sp)
    addi fp, sp, 40
    ld t0, 8(fp)
    li t1, 1
    sub t0, t0, t1
    seqz t0, t0
    sd t0, -24(fp)
    ld t0, -24(fp)
    beq t0, zero, L0
  # Load args on stack
    addi sp, sp, -16
    li t0, 1
    sd t0, 8(sp)
  # End loading args on stack
    ld t0, 0(fp)
    jalr ra, t0, 0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    j L1
  L0:
    ld t0, 8(fp)
    li t1, 1
    sub t0, t0, t1
    sd t0, -32(fp)
  # Load args on stack
    addi sp, sp, -16
    ld t0, 8(fp)
    sd t0, 8(sp)
    ld t0, 0(fp)
    sd t0, 0(sp)
  # End loading args on stack
    call fresh_1__2
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    mv t0, a0
    sd t0, -40(fp)
  # Load args on stack
    addi sp, sp, -16
    ld t0, -32(fp)
    sd t0, 8(sp)
    ld t0, -40(fp)
    sd t0, 0(sp)
  # End loading args on stack
    call fac_cps__6
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
  L1:
    ld ra, 32(sp)
    ld fp, 24(sp)
    addi sp, sp, 40
    ret
  _start:
    mv fp, sp
    addi sp, sp, -16
  # Load args on stack
    addi sp, sp, -16
    li t0, 4
    sd t0, 8(sp)
    la t0, id__0
    sd t0, 0(sp)
  # End loading args on stack
    call fac_cps__6
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    mv t0, a0
    sd t0, -8(fp)
    ld a0, -8(fp)
    call print_int
    mv t0, a0
    sd t0, -16(fp)
    li a0, 0
    call flush
    li a0, 0
    li a7, 94
    ecall

  $ make compile input=bin/fact --no-print-directory -C ..
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe
  24
  $ cat ../main.s
  .text
  .globl _start
  .globl fac__0
  fac__0:
    addi sp, sp, -56
    sd ra, 48(sp)
    sd fp, 40(sp)
    addi fp, sp, 56
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
  # Load args on stack
    addi sp, sp, -16
    ld t0, -40(fp)
    sd t0, 8(sp)
  # End loading args on stack
    call fac__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    mv t0, a0
    sd t0, -48(fp)
    ld t0, -48(fp)
    sd t0, -56(fp)
    ld t0, 8(fp)
    ld t1, -56(fp)
    mul a0, t0, t1
  L1:
    ld ra, 48(sp)
    ld fp, 40(sp)
    addi sp, sp, 56
    ret
  _start:
    mv fp, sp
    addi sp, sp, -8
  # Load args on stack
    addi sp, sp, -16
    li t0, 4
    sd t0, 8(sp)
  # End loading args on stack
    call fac__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
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
  .globl fib__0
  fib__0:
    addi sp, sp, -56
    sd ra, 48(sp)
    sd fp, 40(sp)
    addi fp, sp, 56
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
  # Load args on stack
    addi sp, sp, -16
    ld t0, -32(fp)
    sd t0, 8(sp)
  # End loading args on stack
    call fib__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    mv t0, a0
    sd t0, -40(fp)
    ld t0, 8(fp)
    li t1, 2
    sub t0, t0, t1
    sd t0, -48(fp)
  # Load args on stack
    addi sp, sp, -16
    ld t0, -48(fp)
    sd t0, 8(sp)
  # End loading args on stack
    call fib__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    mv t0, a0
    sd t0, -56(fp)
    ld t0, -40(fp)
    ld t1, -56(fp)
    add a0, t0, t1
  L1:
    ld ra, 48(sp)
    ld fp, 40(sp)
    addi sp, sp, 56
    ret
  _start:
    mv fp, sp
    addi sp, sp, -8
  # Load args on stack
    addi sp, sp, -16
    li t0, 10
    sd t0, 8(sp)
  # End loading args on stack
    call fib__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
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
  # Load args on stack
    addi sp, sp, -16
    ld t0, -32(fp)
    sd t0, 8(sp)
  # End loading args on stack
    call large__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    j L3
  L2:
    li t0, 1
    sd t0, -40(fp)
  # Load args on stack
    addi sp, sp, -16
    ld t0, -40(fp)
    sd t0, 8(sp)
  # End loading args on stack
    call large__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
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
  # Load args on stack
    addi sp, sp, -16
    ld t0, -56(fp)
    sd t0, 8(sp)
  # End loading args on stack
    call large__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    j L5
  L4:
    li t0, 1
    sd t0, -64(fp)
  # Load args on stack
    addi sp, sp, -16
    ld t0, -64(fp)
    sd t0, 8(sp)
  # End loading args on stack
    call large__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
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
  # Load args on stack
    addi sp, sp, -16
    ld t0, -104(fp)
    sd t0, 8(sp)
  # End loading args on stack
    call large__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    j L9
  L8:
    li t0, 1
    sd t0, -112(fp)
  # Load args on stack
    addi sp, sp, -16
    ld t0, -112(fp)
    sd t0, 8(sp)
  # End loading args on stack
    call large__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
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
  # Load args on stack
    addi sp, sp, -16
    ld t0, -128(fp)
    sd t0, 8(sp)
  # End loading args on stack
    call large__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    j L11
  L10:
    li t0, 1
    sd t0, -136(fp)
  # Load args on stack
    addi sp, sp, -16
    ld t0, -136(fp)
    sd t0, 8(sp)
  # End loading args on stack
    call large__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
  L11:
  L13:
  L15:
    call flush
    li a0, 0
    li a7, 94
    ecall
