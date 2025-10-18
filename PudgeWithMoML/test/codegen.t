(just a number)
  $ ./run_codegen.exe <<'EOF'
  > let main = 122
  warning: here-document at line 1 delimited by end-of-file (wanted `EOF')
  .text
  .globl _start
  _start:
    addi sp, sp, 0
    addi fp, sp, 0
    li a0, 122
    li a7, 94
    ecall

(binary op)
  $ ./run_codegen.exe <<'EOF'
  > let main = 5 + 2
  warning: here-document at line 1 delimited by end-of-file (wanted `EOF')
  .text
  .globl _start
  _start:
    addi sp, sp, 0
    addi fp, sp, 0
    li t0, 5
    li t1, 2
    add a0, t0, t1
    li a7, 94
    ecall

  $ ./run_codegen.exe <<'EOF'
  > let x = 2
  > let main = 5 + x
  warning: here-document at line 1 delimited by end-of-file (wanted `EOF')
  .text
  .globl _start
  _start:
    addi sp, sp, -8
    addi fp, sp, 8
    li t0, 2
    sd t0, -8(fp)
    li t0, 5
    ld t1, -8(fp)
    add a0, t0, t1
    li a7, 94
    ecall

  $ ./run_codegen.exe <<'EOF'
  > let x = 2
  > let homka = 122
  > let z = 17
  > let main = x + homka + z + 5
  warning: here-document at line 1 delimited by end-of-file (wanted `EOF')
  .text
  .globl _start
  Fatal error: exception Failure("gen_expr: not implemented")
  Raised at Stdlib.failwith in file "stdlib.ml", line 29, characters 17-33
  Called from PudgeWithMoML__Riscv__Codegen.gather_anf.helper in file "lib/riscv/codegen.ml", line 274, characters 20-40
  Called from PudgeWithMoML__Riscv__Codegen.gather_anf in file "lib/riscv/codegen.ml", line 278, characters 4-13
  Called from PudgeWithMoML__Riscv__Codegen.gen_program_anf in file "lib/riscv/codegen.ml", line 295, characters 16-47
  Called from Dune__exe__Run_codegen.compiler in file "test/run_codegen.ml", line 29, characters 7-40
  [2]

(if then else)
  $ ./run_codegen.exe <<'EOF'
  > let main = if true then 2 else 4
  warning: here-document at line 1 delimited by end-of-file (wanted `EOF')
  .text
  .globl _start
  _start:
    addi sp, sp, 0
    addi fp, sp, 0
    li t0, 1
    beq t0, zero, L0
    li a0, 2
    j L1
  L0:
    li a0, 4
  L1:
    li a7, 94
    ecall

  $ ./run_codegen.exe <<'EOF'
  > let x = true
  > let main = if x then 122 else 17
  warning: here-document at line 1 delimited by end-of-file (wanted `EOF')
  .text
  .globl _start
  _start:
    addi sp, sp, -8
    addi fp, sp, 8
    li t0, 1
    sd t0, -8(fp)
    ld t0, -8(fp)
    beq t0, zero, L0
    li a0, 122
    j L1
  L0:
    li a0, 17
  L1:
    li a7, 94
    ecall

(lambda)
  $ ./run_codegen.exe <<'EOF'
  > let homka = fun x -> x + 2
  > let main = homka 2
  warning: here-document at line 1 delimited by end-of-file (wanted `EOF')
  .text
  .globl _start
  _start:
    addi sp, sp, -8
    addi fp, sp, 8
    li a0, 2
    call homka__0
    li a7, 94
    ecall
