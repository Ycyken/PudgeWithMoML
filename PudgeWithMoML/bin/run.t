  $ make compile input=bin/fact --no-print-directory -C .. << 'EOF'
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
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe
  24
