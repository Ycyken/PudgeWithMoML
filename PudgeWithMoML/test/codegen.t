(print_int)
  $ make compile --no-print-directory -C .. << 'EOF'
  > let main = print_int 5
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe
  5
  $ cat ../main.s
  .text
  .globl _start
  _start:
    mv fp, sp
    addi sp, sp, 0
    li a0, 5
    call print_int
    call flush
    li a0, 0
    li a7, 94
    ecall

