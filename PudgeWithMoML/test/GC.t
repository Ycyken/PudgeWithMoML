( simple example )
  $ make compile FIXADDR=1 opts=-gen_mid --no-print-directory -C .. << 'EOF'
  > let add a b = a + b
  > let _ = print_gc_status ()
  > let f useless = 
  >   let homka1 = add 1 in
  >   let homka2 = homka1 2 in
  >   let homka3 = homka1 3 in
  >   ()
  > let _ = f ()
  > let _ = print_gc_status ()
  > let _ = gc_collect ()
  > let _ = print_gc_status ()
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe 
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100000000
    Space capacity: 8192 words
    Currently used: 0 words
    Live objects: 0
  
  Statistics:
    Total allocations: 0
    Total allocated words: 0
    Collections performed: 0
  
  New space layout:
  ============ GC STATUS ============
  
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100000000
    Space capacity: 8192 words
    Currently used: 17 words
    Live objects: 3
  
  Statistics:
    Total allocations: 3
    Total allocated words: 17
    Collections performed: 0
  
  New space layout:
  	(0x0) 0x0: [size: 4]
  	(0x8) 0x1: [data: 0x40002a]
  	(0x10) 0x2: [data: 0x1]
  	(0x18) 0x3: [data: 0x0]
  	(0x20) 0x4: [data: 0x0]
  	(0x28) 0x5: [size: 5]
  	(0x30) 0x6: [data: 0x400000]
  	(0x38) 0x7: [data: 0x2]
  	(0x40) 0x8: [data: 0x0]
  	(0x48) 0x9: [data: 0x0]
  	(0x50) 0xa: [data: 0x0]
  	(0x58) 0xb: [size: 5]
  	(0x60) 0xc: [data: 0x400000]
  	(0x68) 0xd: [data: 0x2]
  	(0x70) 0xe: [data: 0x1]
  	(0x78) 0xf: [data: 0x3]
  	(0x80) 0x10: [data: 0x0]
  ============ GC STATUS ============
  
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100010000
    Space capacity: 8192 words
    Currently used: 0 words
    Live objects: 0
  
  Statistics:
    Total allocations: 3
    Total allocated words: 17
    Collections performed: 1
  
  New space layout:
  ============ GC STATUS ============
  
  $ cat ../main.anf
  let add__0 = fun a__1 ->
    fun b__2 ->
    a__1 + b__2 
  
  
  let _ = print_gc_status () 
  
  
  let f__3 = fun useless__4 ->
    let anf_t6 = add__0 1 in
    let homka1__5 = anf_t6 in
    let anf_t5 = homka1__5 2 in
    let homka2__6 = anf_t5 in
    let anf_t4 = homka1__5 3 in
    let homka3__7 = anf_t4 in
    () 
  
  
  let _ = f__3 () 
  
  
  let _ = print_gc_status () 
  
  
  let _ = gc_collect () 
  
  
  let _ = print_gc_status () 
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
    srai t0, t0, 1
    srai t1, t1, 1
    add a0, t0, t1
    slli a0, a0, 1
    ori a0, a0, 1
    ld ra, 8(sp)
    ld fp, 0(sp)
    addi sp, sp, 16
    ret
  .globl f__3
  f__3:
    addi sp, sp, -64
    sd ra, 56(sp)
    sd fp, 48(sp)
    addi fp, sp, 64
  # Application to add__0 with 1 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, add__0
    li t6, 5
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    li t0, 3
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to add__0 with 1 args
    sd t0, -24(fp)
    ld t0, -24(fp)
    sd t0, -32(fp)
  # Application to homka1__5 with 1 args
  # Load args on stack
    addi sp, sp, -32
    ld t0, -32(fp)
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    li t0, 5
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to homka1__5 with 1 args
    sd t0, -40(fp)
    ld t0, -40(fp)
    sd t0, -48(fp)
  # Application to homka1__5 with 1 args
  # Load args on stack
    addi sp, sp, -32
    ld t0, -32(fp)
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    li t0, 7
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to homka1__5 with 1 args
    sd t0, -56(fp)
    ld t0, -56(fp)
    sd t0, -64(fp)
    li a0, 1
    ld ra, 56(sp)
    ld fp, 48(sp)
    addi sp, sp, 64
    ret
  .globl _start
  _start:
    mv fp, sp
    mv a0, sp
    call init_GC
    addi sp, sp, 0
    call print_gc_status
    la a1, _
    sd a0, 0(a1)
  # Application to f__3 with 1 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, f__3
    li t6, 3
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    li t0, 1
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to f__3 with 1 args
    la a1, _
    sd a0, 0(a1)
    call print_gc_status
    la a1, _
    sd a0, 0(a1)
    call gc_collect
    la a1, _
    sd a0, 0(a1)
    call print_gc_status
    la a1, _
    sd a0, 0(a1)
    call flush
    li a0, 0
    li a7, 94
    ecall
  .section global_vars, "aw", @progbits
  .balign 8
  .globl _
  _: .dword 0

( alloc inner closure )
  $ make compile FIXADDR=1 opts=-gen_mid --no-print-directory -C .. << 'EOF'
  > let wrap f x = f x
  > let id x = x
  > let homka useless wrap id =
  >   let my_id = wrap id in
  >   my_id 5
  > let homs = homka 2 wrap id
  > let _ = print_gc_status ()
  > let _ = gc_collect ()
  > let _ = print_gc_status ()
  > let main = print_int homs
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe 
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100000000
    Space capacity: 8192 words
    Currently used: 24 words
    Live objects: 4
  
  Statistics:
    Total allocations: 4
    Total allocated words: 24
    Collections performed: 0
  
  New space layout:
  	(0x0) 0x0: [size: 6]
  	(0x8) 0x1: [data: 0x40003a]
  	(0x10) 0x2: [data: 0x3]
  	(0x18) 0x3: [data: 0x0]
  	(0x20) 0x4: [data: 0x0]
  	(0x28) 0x5: [data: 0x0]
  	(0x30) 0x6: [data: 0x0]
  	(0x38) 0x7: [size: 5]
  	(0x40) 0x8: [data: 0x400000]
  	(0x48) 0x9: [data: 0x2]
  	(0x50) 0xa: [data: 0x0]
  	(0x58) 0xb: [data: 0x0]
  	(0x60) 0xc: [data: 0x0]
  	(0x68) 0xd: [size: 4]
  	(0x70) 0xe: [data: 0x400028]
  	(0x78) 0xf: [data: 0x1]
  	(0x80) 0x10: [data: 0x0]
  	(0x88) 0x11: [data: 0x0]
  	(0x90) 0x12: [size: 5]
  	(0x98) 0x13: [data: 0x400000]
  	(0xa0) 0x14: [data: 0x2]
  	(0xa8) 0x15: [data: 0x1]
  	(0xb0) 0x16: [data: 0x404310]
  	(0xb8) 0x17: [data: 0x0]
  ============ GC STATUS ============
  
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100010000
    Space capacity: 8192 words
    Currently used: 0 words
    Live objects: 0
  
  Statistics:
    Total allocations: 4
    Total allocated words: 24
    Collections performed: 1
  
  New space layout:
  ============ GC STATUS ============
  
  5
  $ cat ../main.anf
  let wrap__0 = fun f__1 ->
    fun x__2 ->
    f__1 x__2 
  
  
  let id__3 = fun x__4 ->
    x__4 
  
  
  let homka__5 = fun useless__6 ->
    fun wrap__7 ->
    fun id__8 ->
    let anf_t6 = wrap__7 id__8 in
    anf_t6 5 
  
  
  let homs__10 = homka__5 2 wrap__0 id__3 
  
  
  let _ = print_gc_status () 
  
  
  let _ = gc_collect () 
  
  
  let _ = print_gc_status () 
  
  
  let main__11 = print_int homs__10 
  $ cat ../main.s
  .text
  .globl wrap__0
  wrap__0:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd fp, 0(sp)
    addi fp, sp, 16
  # Application to f__1 with 1 args
  # Load args on stack
    addi sp, sp, -32
    ld t0, 0(fp)
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    ld t0, 8(fp)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to f__1 with 1 args
    ld ra, 8(sp)
    ld fp, 0(sp)
    addi sp, sp, 16
    ret
  .globl id__3
  id__3:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd fp, 0(sp)
    addi fp, sp, 16
    ld a0, 0(fp)
    ld ra, 8(sp)
    ld fp, 0(sp)
    addi sp, sp, 16
    ret
  .globl homka__5
  homka__5:
    addi sp, sp, -32
    sd ra, 24(sp)
    sd fp, 16(sp)
    addi fp, sp, 32
  # Application to wrap__7 with 1 args
  # Load args on stack
    addi sp, sp, -32
    ld t0, 8(fp)
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    ld t0, 16(fp)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to wrap__7 with 1 args
    sd t0, -24(fp)
  # Application to anf_t6 with 1 args
  # Load args on stack
    addi sp, sp, -32
    ld t0, -24(fp)
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    li t0, 11
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to anf_t6 with 1 args
    ld ra, 24(sp)
    ld fp, 16(sp)
    addi sp, sp, 32
    ret
  .globl _start
  _start:
    mv fp, sp
    mv a0, sp
    call init_GC
    addi sp, sp, 0
  # Application to homka__5 with 3 args
  # Load args on stack
    addi sp, sp, -48
    addi sp, sp, -16
    la t5, homka__5
    li t6, 7
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 7
    sd t0, 8(sp)
    li t0, 5
    sd t0, 16(sp)
    addi sp, sp, -16
    la t5, wrap__0
    li t6, 5
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 24(sp)
    addi sp, sp, -16
    la t5, id__3
    li t6, 3
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 32(sp)
  # End loading args on stack
    call apply_closure_chain
  # Free args on stack
    addi sp, sp, 48
  # End free args on stack
  # End Application to homka__5 with 3 args
    la a1, homs__10
    sd a0, 0(a1)
    call print_gc_status
    la a1, _
    sd a0, 0(a1)
    call gc_collect
    la a1, _
    sd a0, 0(a1)
    call print_gc_status
    la a1, _
    sd a0, 0(a1)
  # Apply print_int
    la t5, homs__10
    ld a0, 0(t5)
    call print_int
  # End Apply print_int
    la a1, main__11
    sd a0, 0(a1)
    call flush
    li a0, 0
    li a7, 94
    ecall
  .section global_vars, "aw", @progbits
  .balign 8
  .globl _
  _: .dword 0
  .globl homs__10
  homs__10: .dword 0
  .globl main__11
  main__11: .dword 0

(many closures, realloc heap)
  $ make compile FIXADDR=1 opts=-gen_mid --no-print-directory -C .. << 'EOF'
  > let sum x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12 x13 x14 x15 x16 x17 x18 x19 x20 = x20
  > let rec f x = if (x <= 1)
  > then let _ = print_gc_stats () in 1 
  > else let t = sum 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 in f (x - 1) + t 20
  > 
  > let main = let _ = print_int (f 1501) in ()
  > let _ = print_gc_stats ()
  > let _ = gc_collect ()
  > let _ = print_gc_stats ()
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe 
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100000000
    Space capacity: 65536 words
    Currently used: 52414 words
    Live objects: 3373
  
  Statistics:
    Total allocations: 4502
    Total allocated words: 79510
    Collections performed: 29
  ============ GC STATUS ============
  
  30001
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100000000
    Space capacity: 65536 words
    Currently used: 52419 words
    Live objects: 3374
  
  Statistics:
    Total allocations: 4503
    Total allocated words: 79515
    Collections performed: 29
  ============ GC STATUS ============
  
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100080000
    Space capacity: 65536 words
    Currently used: 5 words
    Live objects: 1
  
  Statistics:
    Total allocations: 4504
    Total allocated words: 79520
    Collections performed: 30
  ============ GC STATUS ============
  
  $ cat ../main.anf
  let sum__0 = fun x1__1 ->
    fun x2__2 ->
    fun x3__3 ->
    fun x4__4 ->
    fun x5__5 ->
    fun x6__6 ->
    fun x7__7 ->
    fun x8__8 ->
    fun x9__9 ->
    fun x10__10 ->
    fun x11__11 ->
    fun x12__12 ->
    fun x13__13 ->
    fun x14__14 ->
    fun x15__15 ->
    fun x16__16 ->
    fun x17__17 ->
    fun x18__18 ->
    fun x19__19 ->
    fun x20__20 ->
    x20__20 
  
  
  let rec f__21 = fun x__22 ->
    let anf_t5 = x__22 <= 1 in
    if anf_t5 then (let anf_t6 = print_gc_stats () in
    1)
    else let anf_t11 = sum__0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 in
    let t__23 = anf_t11 in
    let anf_t7 = x__22 - 1 in
    let anf_t8 = f__21 anf_t7 in
    let anf_t9 = t__23 20 in
    anf_t8 + anf_t9 
  
  
  let main__24 = let anf_t3 = f__21 1501 in
    let anf_t4 = print_int anf_t3 in
    () 
  
  
  let _ = print_gc_stats () 
  
  
  let _ = gc_collect () 
  
  
  let _ = print_gc_stats () 
  $ cat ../main.s
  .text
  .globl sum__0
  sum__0:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd fp, 0(sp)
    addi fp, sp, 16
    ld a0, 152(fp)
    ld ra, 8(sp)
    ld fp, 0(sp)
    addi sp, sp, 16
    ret
  .globl f__21
  f__21:
    addi sp, sp, -80
    sd ra, 72(sp)
    sd fp, 64(sp)
    addi fp, sp, 80
    ld t0, 0(fp)
    li t1, 3
    slt t0, t1, t0
    xori t0, t0, 1
    sd t0, -24(fp)
    ld t0, -24(fp)
    beq t0, zero, L0
  # Application to print_gc_stats with 1 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, print_gc_stats
    li t6, 3
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    li t0, 1
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to print_gc_stats with 1 args
    sd t0, -32(fp)
    li a0, 3
    j L1
  L0:
  # Application to sum__0 with 19 args
  # Load args on stack
    addi sp, sp, -176
    addi sp, sp, -16
    la t5, sum__0
    li t6, 41
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 39
    sd t0, 8(sp)
    li t0, 3
    sd t0, 16(sp)
    li t0, 5
    sd t0, 24(sp)
    li t0, 7
    sd t0, 32(sp)
    li t0, 9
    sd t0, 40(sp)
    li t0, 11
    sd t0, 48(sp)
    li t0, 13
    sd t0, 56(sp)
    li t0, 15
    sd t0, 64(sp)
    li t0, 17
    sd t0, 72(sp)
    li t0, 19
    sd t0, 80(sp)
    li t0, 21
    sd t0, 88(sp)
    li t0, 23
    sd t0, 96(sp)
    li t0, 25
    sd t0, 104(sp)
    li t0, 27
    sd t0, 112(sp)
    li t0, 29
    sd t0, 120(sp)
    li t0, 31
    sd t0, 128(sp)
    li t0, 33
    sd t0, 136(sp)
    li t0, 35
    sd t0, 144(sp)
    li t0, 37
    sd t0, 152(sp)
    li t0, 39
    sd t0, 160(sp)
  # End loading args on stack
    call apply_closure_chain
    mv t0, a0
  # Free args on stack
    addi sp, sp, 176
  # End free args on stack
  # End Application to sum__0 with 19 args
    sd t0, -40(fp)
    ld t0, -40(fp)
    sd t0, -48(fp)
    ld t0, 0(fp)
    li t1, 3
    srai t0, t0, 1
    srai t1, t1, 1
    sub t0, t0, t1
    slli t0, t0, 1
    ori t0, t0, 1
    sd t0, -56(fp)
  # Application to f__21 with 1 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, f__21
    li t6, 3
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    ld t0, -56(fp)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to f__21 with 1 args
    sd t0, -64(fp)
  # Application to t__23 with 1 args
  # Load args on stack
    addi sp, sp, -32
    ld t0, -48(fp)
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    li t0, 41
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to t__23 with 1 args
    sd t0, -72(fp)
    ld t0, -64(fp)
    ld t1, -72(fp)
    srai t0, t0, 1
    srai t1, t1, 1
    add a0, t0, t1
    slli a0, a0, 1
    ori a0, a0, 1
  L1:
    ld ra, 72(sp)
    ld fp, 64(sp)
    addi sp, sp, 80
    ret
  .globl _start
  _start:
    mv fp, sp
    mv a0, sp
    call init_GC
    addi sp, sp, -16
  # Application to f__21 with 1 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, f__21
    li t6, 3
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    li t0, 3003
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to f__21 with 1 args
    sd t0, -8(fp)
  # Apply print_int
    ld a0, -8(fp)
    call print_int
    mv t0, a0
  # End Apply print_int
    sd t0, -16(fp)
    li a0, 1
    la a1, main__24
    sd a0, 0(a1)
  # Application to print_gc_stats with 1 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, print_gc_stats
    li t6, 3
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    li t0, 1
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to print_gc_stats with 1 args
    la a1, _
    sd a0, 0(a1)
    call gc_collect
    la a1, _
    sd a0, 0(a1)
  # Application to print_gc_stats with 1 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, print_gc_stats
    li t6, 3
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    li t0, 1
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to print_gc_stats with 1 args
    la a1, _
    sd a0, 0(a1)
    call flush
    li a0, 0
    li a7, 94
    ecall
  .section global_vars, "aw", @progbits
  .balign 8
  .globl _
  _: .dword 0
  .globl main__24
  main__24: .dword 0

( a lot of collector )
  $ make compile FIXADDR=1 opts=-gen_mid --no-print-directory -C .. << 'EOF'
  > let gleb a b = a + b
  > let _ = print_gc_stats ()
  > let rec homs x = if x = 0 then 0 else let t = gleb 2 in homs (x - 1)
  > let _ = print_int (homs 15)
  > let _ = print_gc_stats ()
  > let _ = gc_collect ()
  > let _ = print_gc_stats ()
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe 
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100000000
    Space capacity: 8192 words
    Currently used: 5 words
    Live objects: 1
  
  Statistics:
    Total allocations: 1
    Total allocated words: 5
    Collections performed: 0
  ============ GC STATUS ============
  
  0
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100000000
    Space capacity: 8192 words
    Currently used: 270 words
    Live objects: 48
  
  Statistics:
    Total allocations: 48
    Total allocated words: 270
    Collections performed: 0
  ============ GC STATUS ============
  
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100010000
    Space capacity: 8192 words
    Currently used: 5 words
    Live objects: 1
  
  Statistics:
    Total allocations: 49
    Total allocated words: 275
    Collections performed: 1
  ============ GC STATUS ============
  

( move multiple objects to old_space )
  $ make compile FIXADDR=1 opts=-gen_mid --no-print-directory -C .. << 'EOF'
  > let add a b = a + b
  > let main = 
  >   let homka1 = add 5 in
  >   let homka2 = add 3 in
  >   let homka2 = print_gc_status () in
  >   let homka3 = gc_collect () in
  >   let homka4 = print_gc_status () in
  >   let lol = (homka1 2) in
  >   let homka5 = print_gc_status () in
  >   print_int lol
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe 
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100000000
    Space capacity: 8192 words
    Currently used: 24 words
    Live objects: 4
  
  Statistics:
    Total allocations: 4
    Total allocated words: 24
    Collections performed: 0
  
  New space layout:
  	(0x0) 0x0: [size: 5]
  	(0x8) 0x1: [data: 0x400000]
  	(0x10) 0x2: [data: 0x2]
  	(0x18) 0x3: [data: 0x0]
  	(0x20) 0x4: [data: 0x0]
  	(0x28) 0x5: [data: 0x0]
  	(0x30) 0x6: [size: 5]
  	(0x38) 0x7: [data: 0x400000]
  	(0x40) 0x8: [data: 0x2]
  	(0x48) 0x9: [data: 0x1]
  	(0x50) 0xa: [data: 0xb]
  	(0x58) 0xb: [data: 0x0]
  	(0x60) 0xc: [size: 5]
  	(0x68) 0xd: [data: 0x400000]
  	(0x70) 0xe: [data: 0x2]
  	(0x78) 0xf: [data: 0x0]
  	(0x80) 0x10: [data: 0x0]
  	(0x88) 0x11: [data: 0x0]
  	(0x90) 0x12: [size: 5]
  	(0x98) 0x13: [data: 0x400000]
  	(0xa0) 0x14: [data: 0x2]
  	(0xa8) 0x15: [data: 0x1]
  	(0xb0) 0x16: [data: 0x7]
  	(0xb8) 0x17: [data: 0x0]
  ============ GC STATUS ============
  
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100010000
    Space capacity: 8192 words
    Currently used: 12 words
    Live objects: 2
  
  Statistics:
    Total allocations: 4
    Total allocated words: 24
    Collections performed: 1
  
  New space layout:
  	(0x10000) 0x0: [size: 5]
  	(0x10008) 0x1: [data: 0x400000]
  	(0x10010) 0x2: [data: 0x2]
  	(0x10018) 0x3: [data: 0x1]
  	(0x10020) 0x4: [data: 0xb]
  	(0x10028) 0x5: [data: 0x0]
  	(0x10030) 0x6: [size: 5]
  	(0x10038) 0x7: [data: 0x400000]
  	(0x10040) 0x8: [data: 0x2]
  	(0x10048) 0x9: [data: 0x1]
  	(0x10050) 0xa: [data: 0x7]
  	(0x10058) 0xb: [data: 0x0]
  ============ GC STATUS ============
  
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100010000
    Space capacity: 8192 words
    Currently used: 12 words
    Live objects: 2
  
  Statistics:
    Total allocations: 4
    Total allocated words: 24
    Collections performed: 1
  
  New space layout:
  	(0x10000) 0x0: [size: 5]
  	(0x10008) 0x1: [data: 0x400000]
  	(0x10010) 0x2: [data: 0x2]
  	(0x10018) 0x3: [data: 0x1]
  	(0x10020) 0x4: [data: 0xb]
  	(0x10028) 0x5: [data: 0x0]
  	(0x10030) 0x6: [size: 5]
  	(0x10038) 0x7: [data: 0x400000]
  	(0x10040) 0x8: [data: 0x2]
  	(0x10048) 0x9: [data: 0x1]
  	(0x10050) 0xa: [data: 0x7]
  	(0x10058) 0xb: [data: 0x0]
  ============ GC STATUS ============
  
  7
  $ cat ../main.anf
  let add__0 = fun a__1 ->
    fun b__2 ->
    a__1 + b__2 
  
  
  let main__3 = let anf_t7 = add__0 5 in
    let homka1__4 = anf_t7 in
    let anf_t6 = add__0 3 in
    let homka2__5 = anf_t6 in
    let anf_t5 = print_gc_status () in
    let homka2__6 = anf_t5 in
    let anf_t4 = gc_collect () in
    let homka3__7 = anf_t4 in
    let anf_t3 = print_gc_status () in
    let homka4__8 = anf_t3 in
    let anf_t2 = homka1__4 2 in
    let lol__9 = anf_t2 in
    let anf_t1 = print_gc_status () in
    let homka5__10 = anf_t1 in
    print_int lol__9 
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
    srai t0, t0, 1
    srai t1, t1, 1
    add a0, t0, t1
    slli a0, a0, 1
    ori a0, a0, 1
    ld ra, 8(sp)
    ld fp, 0(sp)
    addi sp, sp, 16
    ret
  .globl _start
  _start:
    mv fp, sp
    mv a0, sp
    call init_GC
    addi sp, sp, -112
  # Application to add__0 with 1 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, add__0
    li t6, 5
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    li t0, 11
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to add__0 with 1 args
    sd t0, -8(fp)
    ld t0, -8(fp)
    sd t0, -16(fp)
  # Application to add__0 with 1 args
  # Load args on stack
    addi sp, sp, -32
    addi sp, sp, -16
    la t5, add__0
    li t6, 5
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    li t0, 7
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to add__0 with 1 args
    sd t0, -24(fp)
    ld t0, -24(fp)
    sd t0, -32(fp)
    call print_gc_status
    sd t0, -40(fp)
    ld t0, -40(fp)
    sd t0, -48(fp)
    call gc_collect
    sd t0, -56(fp)
    ld t0, -56(fp)
    sd t0, -64(fp)
    call print_gc_status
    sd t0, -72(fp)
    ld t0, -72(fp)
    sd t0, -80(fp)
  # Application to homka1__4 with 1 args
  # Load args on stack
    addi sp, sp, -32
    ld t0, -16(fp)
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    li t0, 5
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to homka1__4 with 1 args
    sd t0, -88(fp)
    ld t0, -88(fp)
    sd t0, -96(fp)
    call print_gc_status
    sd t0, -104(fp)
    ld t0, -104(fp)
    sd t0, -112(fp)
  # Apply print_int
    ld a0, -96(fp)
    call print_int
  # End Apply print_int
    la a1, main__3
    sd a0, 0(a1)
    call flush
    li a0, 0
    li a7, 94
    ecall
  .section global_vars, "aw", @progbits
  .balign 8
  .globl main__3
  main__3: .dword 0


( many closures, heap is dynamicly resized )
  $ make compile FIXADDR=1 --no-print-directory -C .. << 'EOF'
  > let rec fib n k = if n < 2 then k n else fib (n - 1) (fun a -> fib (n - 2) (fun b -> k (a + b)))
  > let main = print_int (fib 15 (fun x -> x))
  > let _ = print_gc_stats ()
  > let _ = gc_collect ()
  > let _ = print_gc_stats ()
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe 
  610
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100000000
    Space capacity: 65536 words
    Currently used: 39456 words
    Live objects: 5919
  
  Statistics:
    Total allocations: 5919
    Total allocated words: 39456
    Collections performed: 3
  ============ GC STATUS ============
  
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100080000
    Space capacity: 65536 words
    Currently used: 10 words
    Live objects: 2
  
  Statistics:
    Total allocations: 5920
    Total allocated words: 39461
    Collections performed: 4
  ============ GC STATUS ============
  

( get current capacity of heap )
  $ make compile FIXADDR=1 opts=-gen_mid --no-print-directory -C .. << 'EOF'
  > let start = get_heap_start ()
  > let end = get_heap_fin ()
  > let main = print_int ((end - start) / 8)
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe 
  8192

( numbers can't be equal existings addresses on heap )
  $ make compile FIXADDR=1 --no-print-directory -C .. << 'EOF'
  > let add x y = x + y
  > let homka = add 122
  > let _ = print_gc_status ()
  > let start1 = get_heap_start ()
  > let _ = gc_collect ()
  > let start2 = get_heap_start ()
  > let _ = print_int (start2 - start1)
  > let _ = print_gc_status ()
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe 
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100000000
    Space capacity: 8192 words
    Currently used: 12 words
    Live objects: 2
  
  Statistics:
    Total allocations: 2
    Total allocated words: 12
    Collections performed: 0
  
  New space layout:
  	(0x0) 0x0: [size: 5]
  	(0x8) 0x1: [data: 0x400000]
  	(0x10) 0x2: [data: 0x2]
  	(0x18) 0x3: [data: 0x0]
  	(0x20) 0x4: [data: 0x0]
  	(0x28) 0x5: [data: 0x0]
  	(0x30) 0x6: [size: 5]
  	(0x38) 0x7: [data: 0x400000]
  	(0x40) 0x8: [data: 0x2]
  	(0x48) 0x9: [data: 0x1]
  	(0x50) 0xa: [data: 0xf5]
  	(0x58) 0xb: [data: 0x0]
  ============ GC STATUS ============
  
  65536
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100010000
    Space capacity: 8192 words
    Currently used: 6 words
    Live objects: 1
  
  Statistics:
    Total allocations: 2
    Total allocated words: 12
    Collections performed: 1
  
  New space layout:
  	(0x10000) 0x0: [size: 5]
  	(0x10008) 0x1: [data: 0x400000]
  	(0x10010) 0x2: [data: 0x2]
  	(0x10018) 0x3: [data: 0x1]
  	(0x10020) 0x4: [data: 0xf5]
  	(0x10028) 0x5: [data: 0x0]
  ============ GC STATUS ============
  

(swap spaces twice)
  $ make compile FIXADDR=1 --no-print-directory -C .. << 'EOF'
  > let f x y = x + y
  > let g a b c = a + (b c)
  > let main = g 10 (f 20)
  > let _ = gc_collect ()
  > let _ = print_gc_status ()
  > let main = print_int (main 30)
  > let _ = gc_collect ()
  > let _ = print_gc_status ()
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe 
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100010000
    Space capacity: 8192 words
    Currently used: 13 words
    Live objects: 2
  
  Statistics:
    Total allocations: 4
    Total allocated words: 26
    Collections performed: 1
  
  New space layout:
  	(0x10000) 0x0: [size: 5]
  	(0x10008) 0x1: [data: 0x400000]
  	(0x10010) 0x2: [data: 0x2]
  	(0x10018) 0x3: [data: 0x1]
  	(0x10020) 0x4: [data: 0x29]
  	(0x10028) 0x5: [data: 0x0]
  	(0x10030) 0x6: [size: 6]
  	(0x10038) 0x7: [data: 0x40002a]
  	(0x10040) 0x8: [data: 0x3]
  	(0x10048) 0x9: [data: 0x2]
  	(0x10050) 0xa: [data: 0x15]
  	(0x10058) 0xb: [data: 0x4142a8]
  	(0x10060) 0xc: [data: 0x0]
  ============ GC STATUS ============
  
  60
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100000000
    Space capacity: 8192 words
    Currently used: 13 words
    Live objects: 2
  
  Statistics:
    Total allocations: 4
    Total allocated words: 26
    Collections performed: 2
  
  New space layout:
  	(0x0) 0x0: [size: 5]
  	(0x8) 0x1: [data: 0x400000]
  	(0x10) 0x2: [data: 0x2]
  	(0x18) 0x3: [data: 0x1]
  	(0x20) 0x4: [data: 0x29]
  	(0x28) 0x5: [data: 0x0]
  	(0x30) 0x6: [size: 6]
  	(0x38) 0x7: [data: 0x40002a]
  	(0x40) 0x8: [data: 0x3]
  	(0x48) 0x9: [data: 0x2]
  	(0x50) 0xa: [data: 0x15]
  	(0x58) 0xb: [data: 0x4042a8]
  	(0x60) 0xc: [data: 0x0]
  ============ GC STATUS ============
  

