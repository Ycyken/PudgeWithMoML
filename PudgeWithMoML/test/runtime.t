  $ make compile --no-print-directory -C .. << 'EOF'
  > let main = print_int 5
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
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe
  5

  $ make compile --no-print-directory -C .. << 'EOF'
  > let large x = if 0<>x then print_int 0 else print_int 1
  > let main =
  >   let x = if (if (if 0=1
  >                   then 0=1 else (let t42 = print_int 42 in 1=1))
  >               then 0=1 else 1=1)
  >           then 0 else 1 in
  >   large x
  > EOF
  $ cat ../main.s
