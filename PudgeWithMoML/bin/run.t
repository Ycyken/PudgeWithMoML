  $ ./compiler.exe -fromfile fact
  $ riscv64-linux-gnu-as -march=rv64gc a.s -o temp.o
  $ riscv64-linux-gnu-ld temp.o -o a.exe
  $ cat a.s
  .text
  .globl _start
  fac:
    addi sp, sp, -56
    sd ra, 48(sp)
    sd fp, 40(sp)
    addi fp, sp, 56
    sd a0, -24(fp)
    ld t0, -24(fp)
    li t1, 1
    slt t0, t1, t0
    xori t0, t0, 1
    beq t0, zero, L0
    li a0, 1
    j L1
  L0:
    ld t0, -24(fp)
    li t1, 1
    sub t0, t0, t1
    sd t0, -32(fp)
    ld a0, -32(fp)
    call fac
    mv t0, a0
    sd t0, -40(fp)
    ld t0, -24(fp)
    ld t1, -40(fp)
    mul a0, t0, t1
  L1:
    ld ra, 48(sp)
    ld fp, 40(sp)
    addi sp, sp, 56
    ret
  _start:
    li a0, 4
    call fac
    li a7, 94
    ecall
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ./a.exe
  [24]
