( IT MUST BE AT THE START OF THE CRAM TEST )
  $ rm -f results.txt
  $ touch results.txt

(print_int)
  $ make compile --no-print-directory -C .. << 'EOF'
  > let main = print_int 5
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe  | tee -a results.txt && echo "-----" >> results.txt
  5
  $ cat ../main.s
  .text
  .globl _start
  _start:
    mv fp, sp
    addi sp, sp, 0
  # Apply print_int
    li a0, 5
    call print_int
    mv t0, a0
  # End Apply print_int
    la t1, main__0
    sd t0, 0(t1)
    call flush
    li a0, 0
    li a7, 94
    ecall
  .data
  main__0: .dword 0

( just add )
  $ make compile opts=-anf --no-print-directory -C .. << 'EOF'
  > let add x y = x + y
  > let main = print_int (add 5 2)
  > EOF

  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe  | tee -a results.txt && echo "-----" >> results.txt
  7
  $ cat ../main.anf
  let add__0 = fun x__1 ->
    fun y__2 ->
    x__1 + y__2 
  
  
  let main__3 = let anf_t0 = add__0 5 2 in
    print_int anf_t0 
  $ cat ../main.s
  .text
  .globl add__0
  add__0:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd fp, 0(sp)
    addi fp, sp, 16
    ld t0, 0(fp)
    ld t1, 8(fp)
    add a0, t0, t1
    ld ra, 8(sp)
    ld fp, 0(sp)
    addi sp, sp, 16
    ret
  .globl _start
  _start:
    mv fp, sp
    addi sp, sp, -8
  # Apply add__0 with 2 args
  # Load args on stack
    addi sp, sp, -16
    li t0, 5
    sd t0, 0(sp)
    li t0, 2
    sd t0, 8(sp)
  # End loading args on stack
    call add__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    mv t0, a0
  # End Apply add__0 with 2 args
    sd t0, -8(fp)
  # Apply print_int
    ld a0, -8(fp)
    call print_int
    mv t0, a0
  # End Apply print_int
    la t1, main__3
    sd t0, 0(t1)
    call flush
    li a0, 0
    li a7, 94
    ecall
  .data
  main__3: .dword 0

( a lot of variables )
  $ make compile opts=-anf --no-print-directory -C .. << 'EOF'
  > let homka x0 x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 = x0
  > let main = print_int (homka 122 1 2 3 4 5 6 7 8 9 10 11)
  > EOF

  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe  | tee -a results.txt && echo "-----" >> results.txt
  122
  $ cat ../main.anf
  let homka__0 = fun x0__1 ->
    fun x1__2 ->
    fun x2__3 ->
    fun x3__4 ->
    fun x4__5 ->
    fun x5__6 ->
    fun x6__7 ->
    fun x7__8 ->
    fun x8__9 ->
    fun x9__10 ->
    fun x10__11 ->
    fun x11__12 ->
    x0__1 
  
  
  let main__13 = let anf_t0 = homka__0 122 1 2 3 4 5 6 7 8 9 10 11 in
    print_int anf_t0 

  $ cat ../main.s
  .text
  .globl homka__0
  homka__0:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd fp, 0(sp)
    addi fp, sp, 16
    ld a0, 0(fp)
    ld ra, 8(sp)
    ld fp, 0(sp)
    addi sp, sp, 16
    ret
  .globl _start
  _start:
    mv fp, sp
    addi sp, sp, -8
  # Apply homka__0 with 12 args
  # Load args on stack
    addi sp, sp, -96
    li t0, 122
    sd t0, 0(sp)
    li t0, 1
    sd t0, 8(sp)
    li t0, 2
    sd t0, 16(sp)
    li t0, 3
    sd t0, 24(sp)
    li t0, 4
    sd t0, 32(sp)
    li t0, 5
    sd t0, 40(sp)
    li t0, 6
    sd t0, 48(sp)
    li t0, 7
    sd t0, 56(sp)
    li t0, 8
    sd t0, 64(sp)
    li t0, 9
    sd t0, 72(sp)
    li t0, 10
    sd t0, 80(sp)
    li t0, 11
    sd t0, 88(sp)
  # End loading args on stack
    call homka__0
  # Free args on stack
    addi sp, sp, 96
  # End free args on stack
    mv t0, a0
  # End Apply homka__0 with 12 args
    sd t0, -8(fp)
  # Apply print_int
    ld a0, -8(fp)
    call print_int
    mv t0, a0
  # End Apply print_int
    la t1, main__13
    sd t0, 0(t1)
    call flush
    li a0, 0
    li a7, 94
    ecall
  .data
  main__13: .dword 0

(just id)
  $ make compile opts=-anf --no-print-directory -C .. << 'EOF'
  > let id x1 x2 = x2
  > let main = print_int (id 5 5)
  > EOF

  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe  | tee -a results.txt && echo "-----" >> results.txt
  5
  $ cat ../main.anf
  let id__0 = fun x1__1 ->
    fun x2__2 ->
    x2__2 
  
  
  let main__3 = let anf_t0 = id__0 5 5 in
    print_int anf_t0 
  $ cat ../main.s
  .text
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
  .globl _start
  _start:
    mv fp, sp
    addi sp, sp, -8
  # Apply id__0 with 2 args
  # Load args on stack
    addi sp, sp, -16
    li t0, 5
    sd t0, 0(sp)
    li t0, 5
    sd t0, 8(sp)
  # End loading args on stack
    call id__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    mv t0, a0
  # End Apply id__0 with 2 args
    sd t0, -8(fp)
  # Apply print_int
    ld a0, -8(fp)
    call print_int
    mv t0, a0
  # End Apply print_int
    la t1, main__3
    sd t0, 0(t1)
    call flush
    li a0, 0
    li a7, 94
    ecall
  .data
  main__3: .dword 0

(function as argument)
  $ make compile opts=-anf --no-print-directory -C .. << 'EOF'
  > let app f x = f x
  > let inc x = x + 1
  > let main = print_int (app inc 5)
  > EOF

  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe  | tee -a results.txt && echo "-----" >> results.txt
  6
  $ cat ../main.anf
  let app__0 = fun f__1 ->
    fun x__2 ->
    f__1 x__2 
  
  
  let inc__3 = fun x__4 ->
    x__4 + 1 
  
  
  let main__5 = let anf_t0 = app__0 inc__3 5 in
    print_int anf_t0 

  $ cat ../main.s
  .text
  .globl app__0
  app__0:
    addi sp, sp, -24
    sd ra, 16(sp)
    sd fp, 8(sp)
    addi fp, sp, 24
  # Apply f__1 with 1 args
    ld t0, 0(fp)
    sd t0, -24(fp)
  # Load args on stack
    addi sp, sp, -32
    ld t0, -24(fp)
    sd t0, 0(sp)
    li t0, 1
    sd t0, 8(sp)
    ld t0, 8(fp)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Apply f__1 with 1 args
    ld ra, 16(sp)
    ld fp, 8(sp)
    addi sp, sp, 24
    ret
  .globl inc__3
  inc__3:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd fp, 0(sp)
    addi fp, sp, 16
    ld t0, 0(fp)
    li t1, 1
    add a0, t0, t1
    ld ra, 8(sp)
    ld fp, 0(sp)
    addi sp, sp, 16
    ret
  .globl _start
  _start:
    mv fp, sp
    addi sp, sp, -8
  # Apply app__0 with 2 args
  # Load args on stack
    addi sp, sp, -16
    addi sp, sp, -16
    la t5, inc__3
    li t6, 1
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 5
    sd t0, 8(sp)
  # End loading args on stack
    call app__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    mv t0, a0
  # End Apply app__0 with 2 args
    sd t0, -8(fp)
  # Apply print_int
    ld a0, -8(fp)
    call print_int
    mv t0, a0
  # End Apply print_int
    la t1, main__5
    sd t0, 0(t1)
    call flush
    li a0, 0
    li a7, 94
    ecall
  .data
  main__5: .dword 0

(shadowing is correct)
  $ make compile --no-print-directory -C .. << 'EOF'
  > let res = let x = 10 in let t = (let x = 20 in print_int x) in print_int x
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe  | tee -a results.txt && echo "-----" >> results.txt
  20
  10
  $ cat ../main.s
  .text
  .globl _start
  _start:
    mv fp, sp
    addi sp, sp, -32
    li t0, 10
    sd t0, -8(fp)
    li t0, 20
    sd t0, -16(fp)
  # Apply print_int
    ld a0, -16(fp)
    call print_int
    mv t0, a0
  # End Apply print_int
    sd t0, -24(fp)
    ld t0, -24(fp)
    sd t0, -32(fp)
  # Apply print_int
    ld a0, -8(fp)
    call print_int
    mv t0, a0
  # End Apply print_int
    la t1, res__0
    sd t0, 0(t1)
    call flush
    li a0, 0
    li a7, 94
    ecall
  .data
  res__0: .dword 0

(simple partial application)
  $ make compile opts=-anf --no-print-directory -C .. << 'EOF'
  > let add x y = x + y
  > let main = let inc = add 1 in print_int (inc 121)
  > EOF

  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe  | tee -a results.txt && echo "-----" >> results.txt
  122
  $ cat ../main.anf
  let add__0 = fun x__1 ->
    fun y__2 ->
    x__1 + y__2 
  
  
  let main__3 = let anf_t2 = add__0 1 in
    let inc__4 = anf_t2 in
    let anf_t0 = inc__4 121 in
    print_int anf_t0 
  $ cat ../main.s
  .text
  .globl add__0
  add__0:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd fp, 0(sp)
    addi fp, sp, 16
    ld t0, 0(fp)
    ld t1, 8(fp)
    add a0, t0, t1
    ld ra, 8(sp)
    ld fp, 0(sp)
    addi sp, sp, 16
    ret
  .globl _start
  _start:
    mv fp, sp
    addi sp, sp, -32
  # Partial application add__0 with 1 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, add__0
    li t6, 2
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 1
    sd t0, 8(sp)
    li t0, 1
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Partial application add__0 with 1 args
    sd t0, -8(fp)
    ld t0, -8(fp)
    sd t0, -16(fp)
  # Apply inc__4 with 1 args
    ld t0, -16(fp)
    sd t0, -24(fp)
  # Load args on stack
    addi sp, sp, -32
    ld t0, -24(fp)
    sd t0, 0(sp)
    li t0, 1
    sd t0, 8(sp)
    li t0, 121
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
    mv t0, a0
  # End Apply inc__4 with 1 args
    sd t0, -32(fp)
  # Apply print_int
    ld a0, -32(fp)
    call print_int
    mv t0, a0
  # End Apply print_int
    la t1, main__3
    sd t0, 0(t1)
    call flush
    li a0, 0
    li a7, 94
    ecall
  .data
  main__3: .dword 0

(double partial application)
  $ make compile opts=-anf --no-print-directory -C .. << 'EOF'
  > let add x y = x + y
  > let main = let inc = add 1 in let _ = print_int (inc 121) in print_int (inc 122)
  > EOF

  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe  | tee -a results.txt && echo "-----" >> results.txt
  122
  123
  $ cat ../main.anf
  let add__0 = fun x__1 ->
    fun y__2 ->
    x__1 + y__2 
  
  
  let main__3 = let anf_t4 = add__0 1 in
    let inc__4 = anf_t4 in
    let anf_t2 = inc__4 121 in
    let anf_t3 = print_int anf_t2 in
    let anf_t0 = inc__4 122 in
    print_int anf_t0 

  $ cat ../main.s
  .text
  .globl add__0
  add__0:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd fp, 0(sp)
    addi fp, sp, 16
    ld t0, 0(fp)
    ld t1, 8(fp)
    add a0, t0, t1
    ld ra, 8(sp)
    ld fp, 0(sp)
    addi sp, sp, 16
    ret
  .globl _start
  _start:
    mv fp, sp
    addi sp, sp, -56
  # Partial application add__0 with 1 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, add__0
    li t6, 2
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 1
    sd t0, 8(sp)
    li t0, 1
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Partial application add__0 with 1 args
    sd t0, -8(fp)
    ld t0, -8(fp)
    sd t0, -16(fp)
  # Apply inc__4 with 1 args
    ld t0, -16(fp)
    sd t0, -24(fp)
  # Load args on stack
    addi sp, sp, -32
    ld t0, -24(fp)
    sd t0, 0(sp)
    li t0, 1
    sd t0, 8(sp)
    li t0, 121
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
    mv t0, a0
  # End Apply inc__4 with 1 args
    sd t0, -32(fp)
  # Apply print_int
    ld a0, -32(fp)
    call print_int
    mv t0, a0
  # End Apply print_int
    sd t0, -40(fp)
  # Apply inc__4 with 1 args
    ld t0, -16(fp)
    sd t0, -48(fp)
  # Load args on stack
    addi sp, sp, -32
    ld t0, -48(fp)
    sd t0, 0(sp)
    li t0, 1
    sd t0, 8(sp)
    li t0, 122
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
    mv t0, a0
  # End Apply inc__4 with 1 args
    sd t0, -56(fp)
  # Apply print_int
    ld a0, -56(fp)
    call print_int
    mv t0, a0
  # End Apply print_int
    la t1, main__3
    sd t0, 0(t1)
    call flush
    li a0, 0
    li a7, 94
    ecall
  .data
  main__3: .dword 0

(Global variables and .data section)
  $ make compile opts=-anf --no-print-directory -C .. << 'EOF'
  > let x = 4
  > let x = 5
  > let main = print_int 5
  > EOF

  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe  | tee -a results.txt && echo "-----" >> results.txt
  5
  $ cat ../main.anf
  let x__0 = 4 
  
  
  let x__1 = 5 
  
  
  let main__2 = print_int 5 

  $ cat ../main.s
  .text
  .globl _start
  _start:
    mv fp, sp
    addi sp, sp, 0
    li t0, 4
    la t1, x__0
    sd t0, 0(t1)
    li t0, 5
    la t1, x__1
    sd t0, 0(t1)
  # Apply print_int
    li a0, 5
    call print_int
    mv t0, a0
  # End Apply print_int
    la t1, main__2
    sd t0, 0(t1)
    call flush
    li a0, 0
    li a7, 94
    ecall
  .data
  x__0: .dword 0
  x__1: .dword 0
  main__2: .dword 0

(Global variables with partial application)
  $ make compile opts=-anf --no-print-directory -C .. << 'EOF'
  > let add x y = x + y
  > let add5 = add 5
  > let main = print_int (add5 117)
  > EOF

  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe  | tee -a results.txt && echo "-----" >> results.txt
  122
  $ cat ../main.anf
  let add__0 = fun x__1 ->
    fun y__2 ->
    x__1 + y__2 
  
  
  let add5__3 = add__0 5 
  
  
  let main__4 = let anf_t0 = add5__3 117 in
    print_int anf_t0 

  $ cat ../main.s
  .text
  .globl add__0
  add__0:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd fp, 0(sp)
    addi fp, sp, 16
    ld t0, 0(fp)
    ld t1, 8(fp)
    add a0, t0, t1
    ld ra, 8(sp)
    ld fp, 0(sp)
    addi sp, sp, 16
    ret
  .globl _start
  _start:
    mv fp, sp
    addi sp, sp, -16
  # Partial application add__0 with 1 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, add__0
    li t6, 2
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 1
    sd t0, 8(sp)
    li t0, 5
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Partial application add__0 with 1 args
    la t1, add5__3
    sd t0, 0(t1)
  # Apply add5__3 with 1 args
    la t5, add5__3
    ld t0, 0(t5)
    sd t0, -8(fp)
  # Load args on stack
    addi sp, sp, -32
    ld t0, -8(fp)
    sd t0, 0(sp)
    li t0, 1
    sd t0, 8(sp)
    li t0, 117
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
    mv t0, a0
  # End Apply add5__3 with 1 args
    sd t0, -16(fp)
  # Apply print_int
    ld a0, -16(fp)
    call print_int
    mv t0, a0
  # End Apply print_int
    la t1, main__4
    sd t0, 0(t1)
    call flush
    li a0, 0
    li a7, 94
    ecall
  .data
  add5__3: .dword 0
  main__4: .dword 0

(A lot of global variables with partial application)
  $ make compile opts=-anf --no-print-directory -C .. << 'EOF'
  > let add x y = x + y
  > let add5 = add 5
  > let inc = add 1
  > let homka = 17
  > let homka122 = add 120 2
  > let main = let _ = print_int (add5 110) in let _ = print_int homka122 in print_int homka
  > EOF

  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe  | tee -a results.txt && echo "-----" >> results.txt
  115
  122
  17
  $ cat ../main.anf
  let add__0 = fun x__1 ->
    fun y__2 ->
    x__1 + y__2 
  
  
  let add5__3 = add__0 5 
  
  
  let inc__4 = add__0 1 
  
  
  let homka__5 = 17 
  
  
  let homka122__6 = add__0 120 2 
  
  
  let main__7 = let anf_t2 = add5__3 110 in
    let anf_t3 = print_int anf_t2 in
    let anf_t1 = print_int homka122__6 in
    print_int homka__5 

  $ cat ../main.s
  .text
  .globl add__0
  add__0:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd fp, 0(sp)
    addi fp, sp, 16
    ld t0, 0(fp)
    ld t1, 8(fp)
    add a0, t0, t1
    ld ra, 8(sp)
    ld fp, 0(sp)
    addi sp, sp, 16
    ret
  .globl _start
  _start:
    mv fp, sp
    addi sp, sp, -32
  # Partial application add__0 with 1 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, add__0
    li t6, 2
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 1
    sd t0, 8(sp)
    li t0, 5
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Partial application add__0 with 1 args
    la t1, add5__3
    sd t0, 0(t1)
  # Partial application add__0 with 1 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, add__0
    li t6, 2
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 1
    sd t0, 8(sp)
    li t0, 1
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Partial application add__0 with 1 args
    la t1, inc__4
    sd t0, 0(t1)
    li t0, 17
    la t1, homka__5
    sd t0, 0(t1)
  # Apply add__0 with 2 args
  # Load args on stack
    addi sp, sp, -16
    li t0, 120
    sd t0, 0(sp)
    li t0, 2
    sd t0, 8(sp)
  # End loading args on stack
    call add__0
  # Free args on stack
    addi sp, sp, 16
  # End free args on stack
    mv t0, a0
  # End Apply add__0 with 2 args
    la t1, homka122__6
    sd t0, 0(t1)
  # Apply add5__3 with 1 args
    la t5, add5__3
    ld t0, 0(t5)
    sd t0, -8(fp)
  # Load args on stack
    addi sp, sp, -32
    ld t0, -8(fp)
    sd t0, 0(sp)
    li t0, 1
    sd t0, 8(sp)
    li t0, 110
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
    mv t0, a0
  # End Apply add5__3 with 1 args
    sd t0, -16(fp)
  # Apply print_int
    ld a0, -16(fp)
    call print_int
    mv t0, a0
  # End Apply print_int
    sd t0, -24(fp)
  # Apply print_int
    la t5, homka122__6
    ld a0, 0(t5)
    call print_int
    mv t0, a0
  # End Apply print_int
    sd t0, -32(fp)
  # Apply print_int
    la t5, homka__5
    ld a0, 0(t5)
    call print_int
    mv t0, a0
  # End Apply print_int
    la t1, main__7
    sd t0, 0(t1)
    call flush
    li a0, 0
    li a7, 94
    ecall
  .data
  add5__3: .dword 0
  inc__4: .dword 0
  homka__5: .dword 0
  homka122__6: .dword 0
  main__7: .dword 0

( global and local x )
  $ make compile opts=-anf --no-print-directory -C .. << 'EOF'
  > let x = 5
  > let f = let x = 2 in print_int x
  > let g = print_int x
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe  | tee -a results.txt && echo "-----" >> results.txt
  2
  5
  $ cat ../main.anf
  let x__0 = 5 
  
  
  let f__1 = let x__2 = 2 in
    print_int x__2 
  
  
  let g__3 = print_int x__0 

  $ cat ../main.s
  .text
  .globl _start
  _start:
    mv fp, sp
    addi sp, sp, -8
    li t0, 5
    la t1, x__0
    sd t0, 0(t1)
    li t0, 2
    sd t0, -8(fp)
  # Apply print_int
    ld a0, -8(fp)
    call print_int
    mv t0, a0
  # End Apply print_int
    la t1, f__1
    sd t0, 0(t1)
  # Apply print_int
    la t5, x__0
    ld a0, 0(t5)
    call print_int
    mv t0, a0
  # End Apply print_int
    la t1, g__3
    sd t0, 0(t1)
    call flush
    li a0, 0
    li a7, 94
    ecall
  .data
  x__0: .dword 0
  f__1: .dword 0
  g__3: .dword 0

  $ make compile opts=-anf --no-print-directory -C .. << 'EOF'
  > let t = if true then 1 else 2         
  > let _ = print_int t
  > let f x = print_int x
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe  | tee -a results.txt && echo "-----" >> results.txt
  1
  $ cat ../main.anf
  let t__0 = if true then (1)
    else 2 
  
  
  let _ = print_int t__0 
  
  
  let f__1 = fun x__2 ->
    print_int x__2 
  $ cat ../main.s
  .text
  .globl f__1
  f__1:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd fp, 0(sp)
    addi fp, sp, 16
  # Apply print_int
    ld a0, 0(fp)
    call print_int
  # End Apply print_int
    ld ra, 8(sp)
    ld fp, 0(sp)
    addi sp, sp, 16
    ret
  .globl _start
  _start:
    mv fp, sp
    addi sp, sp, 0
    li t0, 1
    beq t0, zero, L0
    li t0, 1
    j L1
  L0:
    li t0, 2
  L1:
    la t1, t__0
    sd t0, 0(t1)
  # Apply print_int
    la t5, t__0
    ld a0, 0(t5)
    call print_int
    mv t0, a0
  # End Apply print_int
    la t1, _
    sd t0, 0(t1)
    call flush
    li a0, 0
    li a7, 94
    ecall
  .data
  t__0: .dword 0
  _: .dword 0

( IT MUST BE AT THE END OF THE CRAM TEST )
  $ cat results.txt
  5
  -----
  7
  -----
  122
  -----
  5
  -----
  6
  -----
  20
  10
  -----
  122
  -----
  122
  123
  -----
  5
  -----
  122
  -----
  115
  122
  17
  -----
  2
  5
  -----
  1
  -----
