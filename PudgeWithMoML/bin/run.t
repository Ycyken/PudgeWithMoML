  $ clang-18 -c runtime.c -o runtime.o
  $ ./main.exe
  $ ls
  main.exe
  out.ll
  runtime.c
  runtime.o
  $ cat out.ll | grep -E 'source_filename|target datalayout|ModuleID' --invert-match
  target triple = "x86_64-pc-linux-gnu"
  
  declare void @print_int(i64)
  
  define i64 @main() {
  entry:
    call void @print_int(i64 70)
    ret i64 0
  }
  $ clang-18 out.ll runtime.o -o demo1.exe
  $ echo "Press $(./demo1.exe) to pay respect"
  Press F to pay respect
