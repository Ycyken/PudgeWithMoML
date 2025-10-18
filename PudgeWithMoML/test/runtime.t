  $ make compile --no-print-directory -C .. << 'EOF'
  > let main = print_int 5
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe
  5
  $ cat ../main.s
  .text
  .globl _start
  _start:
    mv fp, sp
    li a0, 5
    call print_int
    call flush
    li a0, 0
    li a7, 94
    ecall


  $ make compile --no-print-directory -C .. << 'EOF'
  > let large x = if 0<>x then print_int 0 else print_int 1
  > let main =
  >   let x = if (if (if 0=1
  >                   then 0=1 else (let t42 = print_int 42 in 1=1))
  >               then 0=1 else 1=1)
  >           then 0 else 1 in
  >   large x
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
