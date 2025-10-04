  $ ./compiler.exe -fromfile fact
  $ riscv64-linux-gnu-as -march=rv64gc a.s -o temp.o
  $ riscv64-linux-gnu-ld temp.o -o a.exe
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ./a.exe
  $ echo $?
