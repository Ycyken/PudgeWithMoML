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
    Space capacity: 65536 words
    Currently used: 0 words
    Live objects: 0
  
  Statistics:
    Total allocations: 0
    Total allocated: 0 words
    Collections performed: 0
  
  New space layout:
  ============ GC STATUS ============
  
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100000000
    Space capacity: 65536 words
    Currently used: 17 words
    Live objects: 3
  
  Statistics:
    Total allocations: 3
    Total allocated: 17 words
    Collections performed: 0
  
  New space layout:
  	(0x100000000) 0x0: [size: 4]
  	(0x100000008) 0x1: [data: 0x40002a]
  	(0x100000010) 0x2: [data: 0x1]
  	(0x100000018) 0x3: [data: (nil)]
  	(0x100000020) 0x4: [data: (nil)]
  	(0x100000028) 0x5: [size: 5]
  	(0x100000030) 0x6: [data: 0x400000]
  	(0x100000038) 0x7: [data: 0x2]
  	(0x100000040) 0x8: [data: (nil)]
  	(0x100000048) 0x9: [data: (nil)]
  	(0x100000050) 0xa: [data: (nil)]
  	(0x100000058) 0xb: [size: 5]
  	(0x100000060) 0xc: [data: 0x400000]
  	(0x100000068) 0xd: [data: 0x2]
  	(0x100000070) 0xe: [data: 0x1]
  	(0x100000078) 0xf: [data: 0x3]
  	(0x100000080) 0x10: [data: (nil)]
  ============ GC STATUS ============
  
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100080000
    Space capacity: 65536 words
    Currently used: 0 words
    Live objects: 0
  
  Statistics:
    Total allocations: 3
    Total allocated: 17 words
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
    Space capacity: 65536 words
    Currently used: 24 words
    Live objects: 4
  
  Statistics:
    Total allocations: 4
    Total allocated: 24 words
    Collections performed: 0
  
  New space layout:
  	(0x100000000) 0x0: [size: 6]
  	(0x100000008) 0x1: [data: 0x40003a]
  	(0x100000010) 0x2: [data: 0x3]
  	(0x100000018) 0x3: [data: (nil)]
  	(0x100000020) 0x4: [data: (nil)]
  	(0x100000028) 0x5: [data: (nil)]
  	(0x100000030) 0x6: [data: (nil)]
  	(0x100000038) 0x7: [size: 5]
  	(0x100000040) 0x8: [data: 0x400000]
  	(0x100000048) 0x9: [data: 0x2]
  	(0x100000050) 0xa: [data: (nil)]
  	(0x100000058) 0xb: [data: (nil)]
  	(0x100000060) 0xc: [data: (nil)]
  	(0x100000068) 0xd: [size: 4]
  	(0x100000070) 0xe: [data: 0x400028]
  	(0x100000078) 0xf: [data: 0x1]
  	(0x100000080) 0x10: [data: (nil)]
  	(0x100000088) 0x11: [data: (nil)]
  	(0x100000090) 0x12: [size: 5]
  	(0x100000098) 0x13: [data: 0x400000]
  	(0x1000000a0) 0x14: [data: 0x2]
  	(0x1000000a8) 0x15: [data: 0x1]
  	(0x1000000b0) 0x16: [data: 0x4000974080]
  	(0x1000000b8) 0x17: [data: (nil)]
  ============ GC STATUS ============
  
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100080000
    Space capacity: 65536 words
    Currently used: 0 words
    Live objects: 0
  
  Statistics:
    Total allocations: 4
    Total allocated: 24 words
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

( a lot of garbage and collections )
  $ make compile FIXADDR=1 opts=-gen_mid --no-print-directory -C .. << 'EOF'
  > let gleb a b = a + b
  > let _ = print_gc_stats ()
  > let rec homs x useless = if x = 0 then 0 else let t = gleb 2 in homs (x - 1) useless
  > let _ = print_int (homs 2000 0)
  > let _ = print_gc_stats ()
  > let _ = gc_collect () 
  > let _ = print_gc_stats ()
  > 
  > let _ = print_int (homs 1500 0)
  > let _ = print_gc_stats ()
  > let _ = gc_collect ()
  > let _ = print_gc_stats ()
  > 
  > let clos = homs 1500
  > let _ = print_gc_stats ()
  > let _ = gc_collect ()
  > let _ = print_gc_stats ()
  > let _ = print_int (clos 0)
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe 
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100000000
    Space capacity: 65536 words
    Currently used: 5 words
    Live objects: 1
  
  Statistics:
    Total allocations: 1
    Total allocated: 5 words
    Collections performed: 0
  ============ GC STATUS ============
  
  0
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100000000
    Space capacity: 65536 words
    Currently used: 36016 words
    Live objects: 6003
  
  Statistics:
    Total allocations: 6003
    Total allocated: 36016 words
    Collections performed: 0
  ============ GC STATUS ============
  
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100080000
    Space capacity: 65536 words
    Currently used: 5 words
    Live objects: 1
  
  Statistics:
    Total allocations: 6004
    Total allocated: 36021 words
    Collections performed: 1
  ============ GC STATUS ============
  
  0
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100080000
    Space capacity: 65536 words
    Currently used: 27016 words
    Live objects: 4503
  
  Statistics:
    Total allocations: 10506
    Total allocated: 63032 words
    Collections performed: 1
  ============ GC STATUS ============
  
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100000000
    Space capacity: 65536 words
    Currently used: 5 words
    Live objects: 1
  
  Statistics:
    Total allocations: 10507
    Total allocated: 63037 words
    Collections performed: 2
  ============ GC STATUS ============
  
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100000000
    Space capacity: 65536 words
    Currently used: 22 words
    Live objects: 4
  
  Statistics:
    Total allocations: 10510
    Total allocated: 63054 words
    Collections performed: 2
  ============ GC STATUS ============
  
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100080000
    Space capacity: 65536 words
    Currently used: 11 words
    Live objects: 2
  
  Statistics:
    Total allocations: 10511
    Total allocated: 63059 words
    Collections performed: 3
  ============ GC STATUS ============
  
  0
( closures as arguments )
  $ make compile FIXADDR=1 opts=-gen_mid --no-print-directory -C .. << 'EOF'
  > let weird a k1 k2 b k3 useless = k2 (k1 a) 1 + k3 b 
  > let sum3 x y z = x + y + z
  > let g = sum3 1 4
  > let clos = let t1 = weird 5 g (sum3 2) in
  >   let _ = print_gc_stats () in
  >   let t2 = (fun m -> m * 2) in
  >   let res = t1 10 t2 in
  >   let _ = print_gc_stats () in
  >   let _ = gc_collect () in
  >   res
  > let _ = gc_collect ()
  > let _ = print_gc_stats ()
  > let _ = print_int (clos 0)
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe 
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100000000
    Space capacity: 65536 words
    Currently used: 53 words
    Live objects: 7
  
  Statistics:
    Total allocations: 7
    Total allocated: 53 words
    Collections performed: 0
  ============ GC STATUS ============
  
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100000000
    Space capacity: 65536 words
    Currently used: 73 words
    Live objects: 10
  
  Statistics:
    Total allocations: 10
    Total allocated: 73 words
    Collections performed: 0
  ============ GC STATUS ============
  
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100000000
    Space capacity: 65536 words
    Currently used: 44 words
    Live objects: 6
  
  Statistics:
    Total allocations: 11
    Total allocated: 78 words
    Collections performed: 2
  ============ GC STATUS ============
  
  33

( get current capacity of heap )
  $ make compile FIXADDR=1 opts=-gen_mid --no-print-directory -C .. << 'EOF'
  > let start = get_heap_start ()
  > let end = get_heap_fin ()
  > let main = print_int ((end - start) / 8)
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe 
  65536

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
    Space capacity: 65536 words
    Currently used: 12 words
    Live objects: 2
  
  Statistics:
    Total allocations: 2
    Total allocated: 12 words
    Collections performed: 0
  
  New space layout:
  	(0x100000000) 0x0: [size: 5]
  	(0x100000008) 0x1: [data: 0x400000]
  	(0x100000010) 0x2: [data: 0x2]
  	(0x100000018) 0x3: [data: (nil)]
  	(0x100000020) 0x4: [data: (nil)]
  	(0x100000028) 0x5: [data: (nil)]
  	(0x100000030) 0x6: [size: 5]
  	(0x100000038) 0x7: [data: 0x400000]
  	(0x100000040) 0x8: [data: 0x2]
  	(0x100000048) 0x9: [data: 0x1]
  	(0x100000050) 0xa: [data: 0xf5]
  	(0x100000058) 0xb: [data: (nil)]
  ============ GC STATUS ============
  
  524288
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100080000
    Space capacity: 65536 words
    Currently used: 6 words
    Live objects: 1
  
  Statistics:
    Total allocations: 2
    Total allocated: 12 words
    Collections performed: 1
  
  New space layout:
  	(0x100080000) 0x0: [size: 5]
  	(0x100080008) 0x1: [data: 0x400000]
  	(0x100080010) 0x2: [data: 0x2]
  	(0x100080018) 0x3: [data: 0x1]
  	(0x100080020) 0x4: [data: 0xf5]
  	(0x100080028) 0x5: [data: (nil)]
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
    New space address: 0x100080000
    Space capacity: 65536 words
    Currently used: 13 words
    Live objects: 2
  
  Statistics:
    Total allocations: 4
    Total allocated: 26 words
    Collections performed: 1
  
  New space layout:
  	(0x100080000) 0x0: [size: 5]
  	(0x100080008) 0x1: [data: 0x400000]
  	(0x100080010) 0x2: [data: 0x2]
  	(0x100080018) 0x3: [data: 0x1]
  	(0x100080020) 0x4: [data: 0x29]
  	(0x100080028) 0x5: [data: (nil)]
  	(0x100080030) 0x6: [size: 6]
  	(0x100080038) 0x7: [data: 0x40002a]
  	(0x100080040) 0x8: [data: 0x3]
  	(0x100080048) 0x9: [data: 0x2]
  	(0x100080050) 0xa: [data: 0x15]
  	(0x100080058) 0xb: [data: 0x40009f4018]
  	(0x100080060) 0xc: [data: (nil)]
  ============ GC STATUS ============
  
  60
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100000000
    Space capacity: 65536 words
    Currently used: 13 words
    Live objects: 2
  
  Statistics:
    Total allocations: 4
    Total allocated: 26 words
    Collections performed: 2
  
  New space layout:
  	(0x100000000) 0x0: [size: 5]
  	(0x100000008) 0x1: [data: 0x400000]
  	(0x100000010) 0x2: [data: 0x2]
  	(0x100000018) 0x3: [data: 0x1]
  	(0x100000020) 0x4: [data: 0x29]
  	(0x100000028) 0x5: [data: (nil)]
  	(0x100000030) 0x6: [size: 6]
  	(0x100000038) 0x7: [data: 0x40002a]
  	(0x100000040) 0x8: [data: 0x3]
  	(0x100000048) 0x9: [data: 0x2]
  	(0x100000050) 0xa: [data: 0x15]
  	(0x100000058) 0xb: [data: 0x4000974018]
  	(0x100000060) 0xc: [data: (nil)]
  ============ GC STATUS ============
  

