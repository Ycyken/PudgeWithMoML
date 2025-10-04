  $ ./compiler.exe -fromfile fact
  $ riscv64-linux-gnu-as -march=rv64gc a.s -o temp.o
  $ riscv64-linux-gnu-ld temp.o -o a.exe
  $ cat a.s
  .text
  .globl _start
  fac:
    addi sp, sp, -32
    sd ra, 0(sp)
    sd a0, 8(sp)
    ld t0, 8(sp)
    li t1, 1
    slt t0, t1, t0
    xori t0, t0, 1
    beq t0, zero, L0
    li a0, 1
    j L1
  L0:
    ld t0, 8(sp)
    li t1, 1
    sub t0, t0, t1
    sd t0, 16(sp)
    ld a0, 16(sp)
    call fac
    mv t0, a0
    sd t0, 24(sp)
    ld t0, 8(sp)
    ld t1, 24(sp)
    mul a0, t0, t1
  L1:
    ld ra, 0(sp)
    addi sp, sp, 32
    ret
  _start:
    li a0, 4
    call fac
    li a7, 94
    ecall
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ./a.exe
  [24]
