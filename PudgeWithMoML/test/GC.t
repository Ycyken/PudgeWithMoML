( simple example )
  $ make compile FIXADDR=1 opts=-gen_mid --no-print-directory -C .. << 'EOF'
  > let add a b = a + b
  > let _ = print_gc_stats ()
  > let f u = let g1 = add 1 in let g2 = add 2 in let g3 = add 3 in 12
  > let res = f 5
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
    Currently used: 41 words
    Live objects: 8
  
  Statistics:
    Total allocations: 8
    Total allocated words: 41
    Collections performed: 0
  ============ GC STATUS ============
  
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100000000
    Space capacity: 8192 words
    Currently used: 59 words
    Live objects: 11
  
  Statistics:
    Total allocations: 11
    Total allocated words: 59
    Collections performed: 0
  ============ GC STATUS ============
  
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100010000
    Space capacity: 8192 words
    Currently used: 41 words
    Live objects: 8
  
  Statistics:
    Total allocations: 11
    Total allocated words: 59
    Collections performed: 1
  ============ GC STATUS ============
  
  $ cat ../main.anf
  let add__0 = fun a__1 ->
    fun b__2 ->
    a__1 + b__2 
  
  
  let _ = print_gc_stats () 
  
  
  let f__3 = fun u__4 ->
    let anf_t6 = add__0 1 in
    let g1__5 = anf_t6 in
    let anf_t5 = add__0 2 in
    let g2__6 = anf_t5 in
    let anf_t4 = add__0 3 in
    let g3__7 = anf_t4 in
    12 
  
  
  let res__8 = f__3 5 
  
  
  let _ = print_gc_stats () 
  
  
  let _ = gc_collect () 
  
  
  let _ = print_gc_stats () 
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
    la t0, closure_add__0
    ld t0, 0(t0)
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
  # Application to add__0 with 1 args
  # Load args on stack
    addi sp, sp, -32
    la t0, closure_add__0
    ld t0, 0(t0)
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
  # End Application to add__0 with 1 args
    sd t0, -40(fp)
    ld t0, -40(fp)
    sd t0, -48(fp)
  # Application to add__0 with 1 args
  # Load args on stack
    addi sp, sp, -32
    la t0, closure_add__0
    ld t0, 0(t0)
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
    sd t0, -56(fp)
    ld t0, -56(fp)
    sd t0, -64(fp)
    li a0, 25
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
    call init_closures
  # Application to print_gc_stats with 1 args
  # Load args on stack
    addi sp, sp, -32
    la t0, closure_print_gc_stats
    ld t0, 0(t0)
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
  # Application to f__3 with 1 args
  # Load args on stack
    addi sp, sp, -32
    la t0, closure_f__3
    ld t0, 0(t0)
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
  # End Application to f__3 with 1 args
    la a1, res__8
    sd a0, 0(a1)
  # Application to print_gc_stats with 1 args
  # Load args on stack
    addi sp, sp, -32
    la t0, closure_print_gc_stats
    ld t0, 0(t0)
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
    la t0, closure_print_gc_stats
    ld t0, 0(t0)
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
  .globl res__8
  res__8: .dword 0

( don't collect needed objects )
  $ make compile FIXADDR=1 opts=-gen_mid --no-print-directory -C .. << 'EOF'
  > let f x y = x * y 
  > let id x = x
  > let h a b k = k a b
  > let m = 
  >   let c1 = h 12 in 
  >   let c2 = c1 13 in 
  >   let _ = gc_collect () in 
  >   let c3 = h f in
  >   print_gc_stats ()
  > let _ = gc_collect ()
  > let _ = print_gc_stats ()
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe 
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100010000
    Space capacity: 8192 words
    Currently used: 69 words
    Live objects: 12
  
  Statistics:
    Total allocations: 12
    Total allocated words: 69
    Collections performed: 1
  ============ GC STATUS ============
  
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100000000
    Space capacity: 8192 words
    Currently used: 69 words
    Live objects: 12
  
  Statistics:
    Total allocations: 12
    Total allocated words: 69
    Collections performed: 2
  ============ GC STATUS ============
  
  $ cat ../main.anf
  let f__0 = fun x__1 ->
    fun y__2 ->
    x__1 * y__2 
  
  
  let id__3 = fun x__4 ->
    x__4 
  
  
  let h__5 = fun a__6 ->
    fun b__7 ->
    fun k__8 ->
    k__8 a__6 b__7 
  
  
  let m__9 = let anf_t6 = h__5 12 in
    let c1__10 = anf_t6 in
    let anf_t5 = c1__10 13 in
    let c2__11 = anf_t5 in
    let anf_t4 = gc_collect () in
    let anf_t3 = h__5 f__0 in
    let c3__12 = anf_t3 in
    print_gc_stats () 
  
  
  let _ = gc_collect () 
  
  
  let _ = print_gc_stats () 
  $ cat ../main.s
  .text
  .globl f__0
  f__0:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd fp, 0(sp)
    addi fp, sp, 16
    ld t0, 0(fp)
    ld t1, 8(fp)
    srai t0, t0, 1
    srai t1, t1, 1
    mul a0, t0, t1
    slli a0, a0, 1
    ori a0, a0, 1
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
  .globl h__5
  h__5:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd fp, 0(sp)
    addi fp, sp, 16
  # Application to k__8 with 2 args
  # Load args on stack
    addi sp, sp, -32
    ld t0, 16(fp)
    sd t0, 0(sp)
    li t0, 5
    sd t0, 8(sp)
    ld t0, 0(fp)
    sd t0, 16(sp)
    ld t0, 8(fp)
    sd t0, 24(sp)
  # End loading args on stack
    call apply_closure_chain
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to k__8 with 2 args
    ld ra, 8(sp)
    ld fp, 0(sp)
    addi sp, sp, 16
    ret
  .globl _start
  _start:
    mv fp, sp
    mv a0, sp
    call init_GC
    addi sp, sp, -56
    call init_closures
  # Application to h__5 with 1 args
  # Load args on stack
    addi sp, sp, -32
    la t0, closure_h__5
    ld t0, 0(t0)
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    li t0, 25
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to h__5 with 1 args
    sd t0, -8(fp)
    ld t0, -8(fp)
    sd t0, -16(fp)
  # Application to c1__10 with 1 args
  # Load args on stack
    addi sp, sp, -32
    ld t0, -16(fp)
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    li t0, 27
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to c1__10 with 1 args
    sd t0, -24(fp)
    ld t0, -24(fp)
    sd t0, -32(fp)
    call gc_collect
    sd t0, -40(fp)
  # Application to h__5 with 1 args
  # Load args on stack
    addi sp, sp, -32
    la t0, closure_h__5
    ld t0, 0(t0)
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    la t0, closure_f__0
    ld t0, 0(t0)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure_chain
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Application to h__5 with 1 args
    sd t0, -48(fp)
    ld t0, -48(fp)
    sd t0, -56(fp)
  # Application to print_gc_stats with 1 args
  # Load args on stack
    addi sp, sp, -32
    la t0, closure_print_gc_stats
    ld t0, 0(t0)
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
    la a1, m__9
    sd a0, 0(a1)
    call gc_collect
    la a1, _
    sd a0, 0(a1)
  # Application to print_gc_stats with 1 args
  # Load args on stack
    addi sp, sp, -32
    la t0, closure_print_gc_stats
    ld t0, 0(t0)
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
  .globl m__9
  m__9: .dword 0

( a lot of collector )
  $ make compile FIXADDR=1 opts=-gen_mid --no-print-directory -C .. << 'EOF'
  > let gleb a b = a + b
  > let homs = gleb 7
  > let _1 = print_gc_status ()
  > let _2 = gc_collect ()
  > let _3 = print_gc_status ()
  > let _4 = gleb 6
  > let _5  = print_gc_status ()
  > let _6 = gc_collect ()
  > let _7 = print_gc_status ()
  > let _8 = gc_collect ()
  > let _9 = print_gc_status ()
  > let main = print_int 5
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe 
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100000000
    Space capacity: 8192 words
    Currently used: 42 words
    Live objects: 8
  
  Statistics:
    Total allocations: 8
    Total allocated words: 42
    Collections performed: 0
  
  New space layout:
  	(0x0) 0x0: [size: 4]
  	(0x8) 0x1: [data: 0x400cbe]
  	(0x10) 0x2: [data: 0x1]
  	(0x18) 0x3: [data: 0x0]
  	(0x20) 0x4: [data: 0x0]
  	(0x28) 0x5: [size: 4]
  	(0x30) 0x6: [data: 0x400f34]
  	(0x38) 0x7: [data: 0x1]
  	(0x40) 0x8: [data: 0x0]
  	(0x48) 0x9: [data: 0x0]
  	(0x50) 0xa: [size: 4]
  	(0x58) 0xb: [data: 0x400ef2]
  	(0x60) 0xc: [data: 0x1]
  	(0x68) 0xd: [data: 0x0]
  	(0x70) 0xe: [data: 0x0]
  	(0x78) 0xf: [size: 5]
  	(0x80) 0x10: [data: 0x400000]
  	(0x88) 0x11: [data: 0x2]
  	(0x90) 0x12: [data: 0x0]
  	(0x98) 0x13: [data: 0x0]
  	(0xa0) 0x14: [data: 0x0]
  	(0xa8) 0x15: [size: 4]
  	(0xb0) 0x16: [data: 0x400294]
  	(0xb8) 0x17: [data: 0x1]
  	(0xc0) 0x18: [data: 0x0]
  	(0xc8) 0x19: [data: 0x0]
  	(0xd0) 0x1a: [size: 4]
  	(0xd8) 0x1b: [data: 0x4002ca]
  	(0xe0) 0x1c: [data: 0x1]
  	(0xe8) 0x1d: [data: 0x0]
  	(0xf0) 0x1e: [data: 0x0]
  	(0xf8) 0x1f: [size: 4]
  	(0x100) 0x20: [data: 0x400116]
  	(0x108) 0x21: [data: 0x1]
  	(0x110) 0x22: [data: 0x0]
  	(0x118) 0x23: [data: 0x0]
  	(0x120) 0x24: [size: 5]
  	(0x128) 0x25: [data: 0x400000]
  	(0x130) 0x26: [data: 0x2]
  	(0x138) 0x27: [data: 0x1]
  	(0x140) 0x28: [data: 0xf]
  	(0x148) 0x29: [data: 0x0]
  ============ GC STATUS ============
  
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100010000
    Space capacity: 8192 words
    Currently used: 42 words
    Live objects: 8
  
  Statistics:
    Total allocations: 8
    Total allocated words: 42
    Collections performed: 1
  
  New space layout:
  	(0x10000) 0x0: [size: 4]
  	(0x10008) 0x1: [data: 0x400cbe]
  	(0x10010) 0x2: [data: 0x1]
  	(0x10018) 0x3: [data: 0x0]
  	(0x10020) 0x4: [data: 0x0]
  	(0x10028) 0x5: [size: 4]
  	(0x10030) 0x6: [data: 0x400f34]
  	(0x10038) 0x7: [data: 0x1]
  	(0x10040) 0x8: [data: 0x0]
  	(0x10048) 0x9: [data: 0x0]
  	(0x10050) 0xa: [size: 4]
  	(0x10058) 0xb: [data: 0x400ef2]
  	(0x10060) 0xc: [data: 0x1]
  	(0x10068) 0xd: [data: 0x0]
  	(0x10070) 0xe: [data: 0x0]
  	(0x10078) 0xf: [size: 5]
  	(0x10080) 0x10: [data: 0x400000]
  	(0x10088) 0x11: [data: 0x2]
  	(0x10090) 0x12: [data: 0x0]
  	(0x10098) 0x13: [data: 0x0]
  	(0x100a0) 0x14: [data: 0x0]
  	(0x100a8) 0x15: [size: 4]
  	(0x100b0) 0x16: [data: 0x400294]
  	(0x100b8) 0x17: [data: 0x1]
  	(0x100c0) 0x18: [data: 0x0]
  	(0x100c8) 0x19: [data: 0x0]
  	(0x100d0) 0x1a: [size: 4]
  	(0x100d8) 0x1b: [data: 0x4002ca]
  	(0x100e0) 0x1c: [data: 0x1]
  	(0x100e8) 0x1d: [data: 0x0]
  	(0x100f0) 0x1e: [data: 0x0]
  	(0x100f8) 0x1f: [size: 4]
  	(0x10100) 0x20: [data: 0x400116]
  	(0x10108) 0x21: [data: 0x1]
  	(0x10110) 0x22: [data: 0x0]
  	(0x10118) 0x23: [data: 0x0]
  	(0x10120) 0x24: [size: 5]
  	(0x10128) 0x25: [data: 0x400000]
  	(0x10130) 0x26: [data: 0x2]
  	(0x10138) 0x27: [data: 0x1]
  	(0x10140) 0x28: [data: 0xf]
  	(0x10148) 0x29: [data: 0x0]
  ============ GC STATUS ============
  
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100010000
    Space capacity: 8192 words
    Currently used: 48 words
    Live objects: 9
  
  Statistics:
    Total allocations: 9
    Total allocated words: 48
    Collections performed: 1
  
  New space layout:
  	(0x10000) 0x0: [size: 4]
  	(0x10008) 0x1: [data: 0x400cbe]
  	(0x10010) 0x2: [data: 0x1]
  	(0x10018) 0x3: [data: 0x0]
  	(0x10020) 0x4: [data: 0x0]
  	(0x10028) 0x5: [size: 4]
  	(0x10030) 0x6: [data: 0x400f34]
  	(0x10038) 0x7: [data: 0x1]
  	(0x10040) 0x8: [data: 0x0]
  	(0x10048) 0x9: [data: 0x0]
  	(0x10050) 0xa: [size: 4]
  	(0x10058) 0xb: [data: 0x400ef2]
  	(0x10060) 0xc: [data: 0x1]
  	(0x10068) 0xd: [data: 0x0]
  	(0x10070) 0xe: [data: 0x0]
  	(0x10078) 0xf: [size: 5]
  	(0x10080) 0x10: [data: 0x400000]
  	(0x10088) 0x11: [data: 0x2]
  	(0x10090) 0x12: [data: 0x0]
  	(0x10098) 0x13: [data: 0x0]
  	(0x100a0) 0x14: [data: 0x0]
  	(0x100a8) 0x15: [size: 4]
  	(0x100b0) 0x16: [data: 0x400294]
  	(0x100b8) 0x17: [data: 0x1]
  	(0x100c0) 0x18: [data: 0x0]
  	(0x100c8) 0x19: [data: 0x0]
  	(0x100d0) 0x1a: [size: 4]
  	(0x100d8) 0x1b: [data: 0x4002ca]
  	(0x100e0) 0x1c: [data: 0x1]
  	(0x100e8) 0x1d: [data: 0x0]
  	(0x100f0) 0x1e: [data: 0x0]
  	(0x100f8) 0x1f: [size: 4]
  	(0x10100) 0x20: [data: 0x400116]
  	(0x10108) 0x21: [data: 0x1]
  	(0x10110) 0x22: [data: 0x0]
  	(0x10118) 0x23: [data: 0x0]
  	(0x10120) 0x24: [size: 5]
  	(0x10128) 0x25: [data: 0x400000]
  	(0x10130) 0x26: [data: 0x2]
  	(0x10138) 0x27: [data: 0x1]
  	(0x10140) 0x28: [data: 0xf]
  	(0x10148) 0x29: [data: 0x0]
  	(0x10150) 0x2a: [size: 5]
  	(0x10158) 0x2b: [data: 0x400000]
  	(0x10160) 0x2c: [data: 0x2]
  	(0x10168) 0x2d: [data: 0x1]
  	(0x10170) 0x2e: [data: 0xd]
  	(0x10178) 0x2f: [data: 0x0]
  ============ GC STATUS ============
  
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100000000
    Space capacity: 8192 words
    Currently used: 48 words
    Live objects: 9
  
  Statistics:
    Total allocations: 9
    Total allocated words: 48
    Collections performed: 2
  
  New space layout:
  	(0x0) 0x0: [size: 4]
  	(0x8) 0x1: [data: 0x400cbe]
  	(0x10) 0x2: [data: 0x1]
  	(0x18) 0x3: [data: 0x0]
  	(0x20) 0x4: [data: 0x0]
  	(0x28) 0x5: [size: 4]
  	(0x30) 0x6: [data: 0x400f34]
  	(0x38) 0x7: [data: 0x1]
  	(0x40) 0x8: [data: 0x0]
  	(0x48) 0x9: [data: 0x0]
  	(0x50) 0xa: [size: 4]
  	(0x58) 0xb: [data: 0x400ef2]
  	(0x60) 0xc: [data: 0x1]
  	(0x68) 0xd: [data: 0x0]
  	(0x70) 0xe: [data: 0x0]
  	(0x78) 0xf: [size: 5]
  	(0x80) 0x10: [data: 0x400000]
  	(0x88) 0x11: [data: 0x2]
  	(0x90) 0x12: [data: 0x0]
  	(0x98) 0x13: [data: 0x0]
  	(0xa0) 0x14: [data: 0x0]
  	(0xa8) 0x15: [size: 4]
  	(0xb0) 0x16: [data: 0x400294]
  	(0xb8) 0x17: [data: 0x1]
  	(0xc0) 0x18: [data: 0x0]
  	(0xc8) 0x19: [data: 0x0]
  	(0xd0) 0x1a: [size: 4]
  	(0xd8) 0x1b: [data: 0x4002ca]
  	(0xe0) 0x1c: [data: 0x1]
  	(0xe8) 0x1d: [data: 0x0]
  	(0xf0) 0x1e: [data: 0x0]
  	(0xf8) 0x1f: [size: 4]
  	(0x100) 0x20: [data: 0x400116]
  	(0x108) 0x21: [data: 0x1]
  	(0x110) 0x22: [data: 0x0]
  	(0x118) 0x23: [data: 0x0]
  	(0x120) 0x24: [size: 5]
  	(0x128) 0x25: [data: 0x400000]
  	(0x130) 0x26: [data: 0x2]
  	(0x138) 0x27: [data: 0x1]
  	(0x140) 0x28: [data: 0xf]
  	(0x148) 0x29: [data: 0x0]
  	(0x150) 0x2a: [size: 5]
  	(0x158) 0x2b: [data: 0x400000]
  	(0x160) 0x2c: [data: 0x2]
  	(0x168) 0x2d: [data: 0x1]
  	(0x170) 0x2e: [data: 0xd]
  	(0x178) 0x2f: [data: 0x0]
  ============ GC STATUS ============
  
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100010000
    Space capacity: 8192 words
    Currently used: 48 words
    Live objects: 9
  
  Statistics:
    Total allocations: 9
    Total allocated words: 48
    Collections performed: 3
  
  New space layout:
  	(0x10000) 0x0: [size: 4]
  	(0x10008) 0x1: [data: 0x400cbe]
  	(0x10010) 0x2: [data: 0x1]
  	(0x10018) 0x3: [data: 0x0]
  	(0x10020) 0x4: [data: 0x0]
  	(0x10028) 0x5: [size: 4]
  	(0x10030) 0x6: [data: 0x400f34]
  	(0x10038) 0x7: [data: 0x1]
  	(0x10040) 0x8: [data: 0x0]
  	(0x10048) 0x9: [data: 0x0]
  	(0x10050) 0xa: [size: 4]
  	(0x10058) 0xb: [data: 0x400ef2]
  	(0x10060) 0xc: [data: 0x1]
  	(0x10068) 0xd: [data: 0x0]
  	(0x10070) 0xe: [data: 0x0]
  	(0x10078) 0xf: [size: 5]
  	(0x10080) 0x10: [data: 0x400000]
  	(0x10088) 0x11: [data: 0x2]
  	(0x10090) 0x12: [data: 0x0]
  	(0x10098) 0x13: [data: 0x0]
  	(0x100a0) 0x14: [data: 0x0]
  	(0x100a8) 0x15: [size: 4]
  	(0x100b0) 0x16: [data: 0x400294]
  	(0x100b8) 0x17: [data: 0x1]
  	(0x100c0) 0x18: [data: 0x0]
  	(0x100c8) 0x19: [data: 0x0]
  	(0x100d0) 0x1a: [size: 4]
  	(0x100d8) 0x1b: [data: 0x4002ca]
  	(0x100e0) 0x1c: [data: 0x1]
  	(0x100e8) 0x1d: [data: 0x0]
  	(0x100f0) 0x1e: [data: 0x0]
  	(0x100f8) 0x1f: [size: 4]
  	(0x10100) 0x20: [data: 0x400116]
  	(0x10108) 0x21: [data: 0x1]
  	(0x10110) 0x22: [data: 0x0]
  	(0x10118) 0x23: [data: 0x0]
  	(0x10120) 0x24: [size: 5]
  	(0x10128) 0x25: [data: 0x400000]
  	(0x10130) 0x26: [data: 0x2]
  	(0x10138) 0x27: [data: 0x1]
  	(0x10140) 0x28: [data: 0xf]
  	(0x10148) 0x29: [data: 0x0]
  	(0x10150) 0x2a: [size: 5]
  	(0x10158) 0x2b: [data: 0x400000]
  	(0x10160) 0x2c: [data: 0x2]
  	(0x10168) 0x2d: [data: 0x1]
  	(0x10170) 0x2e: [data: 0xd]
  	(0x10178) 0x2f: [data: 0x0]
  ============ GC STATUS ============
  
  5

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
    Currently used: 48 words
    Live objects: 9
  
  Statistics:
    Total allocations: 9
    Total allocated words: 48
    Collections performed: 0
  
  New space layout:
  	(0x0) 0x0: [size: 5]
  	(0x8) 0x1: [data: 0x400000]
  	(0x10) 0x2: [data: 0x2]
  	(0x18) 0x3: [data: 0x0]
  	(0x20) 0x4: [data: 0x0]
  	(0x28) 0x5: [data: 0x0]
  	(0x30) 0x6: [size: 4]
  	(0x38) 0x7: [data: 0x400cbc]
  	(0x40) 0x8: [data: 0x1]
  	(0x48) 0x9: [data: 0x0]
  	(0x50) 0xa: [data: 0x0]
  	(0x58) 0xb: [size: 4]
  	(0x60) 0xc: [data: 0x400f32]
  	(0x68) 0xd: [data: 0x1]
  	(0x70) 0xe: [data: 0x0]
  	(0x78) 0xf: [data: 0x0]
  	(0x80) 0x10: [size: 4]
  	(0x88) 0x11: [data: 0x400ef0]
  	(0x90) 0x12: [data: 0x1]
  	(0x98) 0x13: [data: 0x0]
  	(0xa0) 0x14: [data: 0x0]
  	(0xa8) 0x15: [size: 4]
  	(0xb0) 0x16: [data: 0x400292]
  	(0xb8) 0x17: [data: 0x1]
  	(0xc0) 0x18: [data: 0x0]
  	(0xc8) 0x19: [data: 0x0]
  	(0xd0) 0x1a: [size: 4]
  	(0xd8) 0x1b: [data: 0x4002c8]
  	(0xe0) 0x1c: [data: 0x1]
  	(0xe8) 0x1d: [data: 0x0]
  	(0xf0) 0x1e: [data: 0x0]
  	(0xf8) 0x1f: [size: 4]
  	(0x100) 0x20: [data: 0x400114]
  	(0x108) 0x21: [data: 0x1]
  	(0x110) 0x22: [data: 0x0]
  	(0x118) 0x23: [data: 0x0]
  	(0x120) 0x24: [size: 5]
  	(0x128) 0x25: [data: 0x400000]
  	(0x130) 0x26: [data: 0x2]
  	(0x138) 0x27: [data: 0x1]
  	(0x140) 0x28: [data: 0xb]
  	(0x148) 0x29: [data: 0x0]
  	(0x150) 0x2a: [size: 5]
  	(0x158) 0x2b: [data: 0x400000]
  	(0x160) 0x2c: [data: 0x2]
  	(0x168) 0x2d: [data: 0x1]
  	(0x170) 0x2e: [data: 0x7]
  	(0x178) 0x2f: [data: 0x0]
  ============ GC STATUS ============
  
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100010000
    Space capacity: 8192 words
    Currently used: 48 words
    Live objects: 9
  
  Statistics:
    Total allocations: 9
    Total allocated words: 48
    Collections performed: 1
  
  New space layout:
  	(0x10000) 0x0: [size: 5]
  	(0x10008) 0x1: [data: 0x400000]
  	(0x10010) 0x2: [data: 0x2]
  	(0x10018) 0x3: [data: 0x0]
  	(0x10020) 0x4: [data: 0x0]
  	(0x10028) 0x5: [data: 0x0]
  	(0x10030) 0x6: [size: 4]
  	(0x10038) 0x7: [data: 0x400cbc]
  	(0x10040) 0x8: [data: 0x1]
  	(0x10048) 0x9: [data: 0x0]
  	(0x10050) 0xa: [data: 0x0]
  	(0x10058) 0xb: [size: 4]
  	(0x10060) 0xc: [data: 0x400f32]
  	(0x10068) 0xd: [data: 0x1]
  	(0x10070) 0xe: [data: 0x0]
  	(0x10078) 0xf: [data: 0x0]
  	(0x10080) 0x10: [size: 4]
  	(0x10088) 0x11: [data: 0x400ef0]
  	(0x10090) 0x12: [data: 0x1]
  	(0x10098) 0x13: [data: 0x0]
  	(0x100a0) 0x14: [data: 0x0]
  	(0x100a8) 0x15: [size: 4]
  	(0x100b0) 0x16: [data: 0x400292]
  	(0x100b8) 0x17: [data: 0x1]
  	(0x100c0) 0x18: [data: 0x0]
  	(0x100c8) 0x19: [data: 0x0]
  	(0x100d0) 0x1a: [size: 4]
  	(0x100d8) 0x1b: [data: 0x4002c8]
  	(0x100e0) 0x1c: [data: 0x1]
  	(0x100e8) 0x1d: [data: 0x0]
  	(0x100f0) 0x1e: [data: 0x0]
  	(0x100f8) 0x1f: [size: 4]
  	(0x10100) 0x20: [data: 0x400114]
  	(0x10108) 0x21: [data: 0x1]
  	(0x10110) 0x22: [data: 0x0]
  	(0x10118) 0x23: [data: 0x0]
  	(0x10120) 0x24: [size: 5]
  	(0x10128) 0x25: [data: 0x400000]
  	(0x10130) 0x26: [data: 0x2]
  	(0x10138) 0x27: [data: 0x1]
  	(0x10140) 0x28: [data: 0xb]
  	(0x10148) 0x29: [data: 0x0]
  	(0x10150) 0x2a: [size: 5]
  	(0x10158) 0x2b: [data: 0x400000]
  	(0x10160) 0x2c: [data: 0x2]
  	(0x10168) 0x2d: [data: 0x1]
  	(0x10170) 0x2e: [data: 0x7]
  	(0x10178) 0x2f: [data: 0x0]
  ============ GC STATUS ============
  
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100010000
    Space capacity: 8192 words
    Currently used: 48 words
    Live objects: 9
  
  Statistics:
    Total allocations: 9
    Total allocated words: 48
    Collections performed: 1
  
  New space layout:
  	(0x10000) 0x0: [size: 5]
  	(0x10008) 0x1: [data: 0x400000]
  	(0x10010) 0x2: [data: 0x2]
  	(0x10018) 0x3: [data: 0x0]
  	(0x10020) 0x4: [data: 0x0]
  	(0x10028) 0x5: [data: 0x0]
  	(0x10030) 0x6: [size: 4]
  	(0x10038) 0x7: [data: 0x400cbc]
  	(0x10040) 0x8: [data: 0x1]
  	(0x10048) 0x9: [data: 0x0]
  	(0x10050) 0xa: [data: 0x0]
  	(0x10058) 0xb: [size: 4]
  	(0x10060) 0xc: [data: 0x400f32]
  	(0x10068) 0xd: [data: 0x1]
  	(0x10070) 0xe: [data: 0x0]
  	(0x10078) 0xf: [data: 0x0]
  	(0x10080) 0x10: [size: 4]
  	(0x10088) 0x11: [data: 0x400ef0]
  	(0x10090) 0x12: [data: 0x1]
  	(0x10098) 0x13: [data: 0x0]
  	(0x100a0) 0x14: [data: 0x0]
  	(0x100a8) 0x15: [size: 4]
  	(0x100b0) 0x16: [data: 0x400292]
  	(0x100b8) 0x17: [data: 0x1]
  	(0x100c0) 0x18: [data: 0x0]
  	(0x100c8) 0x19: [data: 0x0]
  	(0x100d0) 0x1a: [size: 4]
  	(0x100d8) 0x1b: [data: 0x4002c8]
  	(0x100e0) 0x1c: [data: 0x1]
  	(0x100e8) 0x1d: [data: 0x0]
  	(0x100f0) 0x1e: [data: 0x0]
  	(0x100f8) 0x1f: [size: 4]
  	(0x10100) 0x20: [data: 0x400114]
  	(0x10108) 0x21: [data: 0x1]
  	(0x10110) 0x22: [data: 0x0]
  	(0x10118) 0x23: [data: 0x0]
  	(0x10120) 0x24: [size: 5]
  	(0x10128) 0x25: [data: 0x400000]
  	(0x10130) 0x26: [data: 0x2]
  	(0x10138) 0x27: [data: 0x1]
  	(0x10140) 0x28: [data: 0xb]
  	(0x10148) 0x29: [data: 0x0]
  	(0x10150) 0x2a: [size: 5]
  	(0x10158) 0x2b: [data: 0x400000]
  	(0x10160) 0x2c: [data: 0x2]
  	(0x10168) 0x2d: [data: 0x1]
  	(0x10170) 0x2e: [data: 0x7]
  	(0x10178) 0x2f: [data: 0x0]
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
    call init_closures
  # Application to add__0 with 1 args
  # Load args on stack
    addi sp, sp, -32
    la t0, closure_add__0
    ld t0, 0(t0)
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
    la t0, closure_add__0
    ld t0, 0(t0)
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
  > let main = print_int (fib 12 (fun x -> x))
  > let _ = gc_collect ()
  > let _ = print_gc_stats ()
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe 
  144
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100010000
    Space capacity: 8192 words
    Currently used: 55 words
    Live objects: 10
  
  Statistics:
    Total allocations: 474
    Total allocated words: 3303
    Collections performed: 1
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
    Currently used: 42 words
    Live objects: 8
  
  Statistics:
    Total allocations: 8
    Total allocated words: 42
    Collections performed: 0
  
  New space layout:
  	(0x0) 0x0: [size: 5]
  	(0x8) 0x1: [data: 0x400000]
  	(0x10) 0x2: [data: 0x2]
  	(0x18) 0x3: [data: 0x0]
  	(0x20) 0x4: [data: 0x0]
  	(0x28) 0x5: [data: 0x0]
  	(0x30) 0x6: [size: 4]
  	(0x38) 0x7: [data: 0x400c9e]
  	(0x40) 0x8: [data: 0x1]
  	(0x48) 0x9: [data: 0x0]
  	(0x50) 0xa: [data: 0x0]
  	(0x58) 0xb: [size: 4]
  	(0x60) 0xc: [data: 0x400f14]
  	(0x68) 0xd: [data: 0x1]
  	(0x70) 0xe: [data: 0x0]
  	(0x78) 0xf: [data: 0x0]
  	(0x80) 0x10: [size: 4]
  	(0x88) 0x11: [data: 0x400ed2]
  	(0x90) 0x12: [data: 0x1]
  	(0x98) 0x13: [data: 0x0]
  	(0xa0) 0x14: [data: 0x0]
  	(0xa8) 0x15: [size: 4]
  	(0xb0) 0x16: [data: 0x400274]
  	(0xb8) 0x17: [data: 0x1]
  	(0xc0) 0x18: [data: 0x0]
  	(0xc8) 0x19: [data: 0x0]
  	(0xd0) 0x1a: [size: 4]
  	(0xd8) 0x1b: [data: 0x4002aa]
  	(0xe0) 0x1c: [data: 0x1]
  	(0xe8) 0x1d: [data: 0x0]
  	(0xf0) 0x1e: [data: 0x0]
  	(0xf8) 0x1f: [size: 4]
  	(0x100) 0x20: [data: 0x4000f6]
  	(0x108) 0x21: [data: 0x1]
  	(0x110) 0x22: [data: 0x0]
  	(0x118) 0x23: [data: 0x0]
  	(0x120) 0x24: [size: 5]
  	(0x128) 0x25: [data: 0x400000]
  	(0x130) 0x26: [data: 0x2]
  	(0x138) 0x27: [data: 0x1]
  	(0x140) 0x28: [data: 0xf5]
  	(0x148) 0x29: [data: 0x0]
  ============ GC STATUS ============
  
  65536
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100010000
    Space capacity: 8192 words
    Currently used: 42 words
    Live objects: 8
  
  Statistics:
    Total allocations: 8
    Total allocated words: 42
    Collections performed: 1
  
  New space layout:
  	(0x10000) 0x0: [size: 5]
  	(0x10008) 0x1: [data: 0x400000]
  	(0x10010) 0x2: [data: 0x2]
  	(0x10018) 0x3: [data: 0x0]
  	(0x10020) 0x4: [data: 0x0]
  	(0x10028) 0x5: [data: 0x0]
  	(0x10030) 0x6: [size: 4]
  	(0x10038) 0x7: [data: 0x400c9e]
  	(0x10040) 0x8: [data: 0x1]
  	(0x10048) 0x9: [data: 0x0]
  	(0x10050) 0xa: [data: 0x0]
  	(0x10058) 0xb: [size: 4]
  	(0x10060) 0xc: [data: 0x400f14]
  	(0x10068) 0xd: [data: 0x1]
  	(0x10070) 0xe: [data: 0x0]
  	(0x10078) 0xf: [data: 0x0]
  	(0x10080) 0x10: [size: 4]
  	(0x10088) 0x11: [data: 0x400ed2]
  	(0x10090) 0x12: [data: 0x1]
  	(0x10098) 0x13: [data: 0x0]
  	(0x100a0) 0x14: [data: 0x0]
  	(0x100a8) 0x15: [size: 4]
  	(0x100b0) 0x16: [data: 0x400274]
  	(0x100b8) 0x17: [data: 0x1]
  	(0x100c0) 0x18: [data: 0x0]
  	(0x100c8) 0x19: [data: 0x0]
  	(0x100d0) 0x1a: [size: 4]
  	(0x100d8) 0x1b: [data: 0x4002aa]
  	(0x100e0) 0x1c: [data: 0x1]
  	(0x100e8) 0x1d: [data: 0x0]
  	(0x100f0) 0x1e: [data: 0x0]
  	(0x100f8) 0x1f: [size: 4]
  	(0x10100) 0x20: [data: 0x4000f6]
  	(0x10108) 0x21: [data: 0x1]
  	(0x10110) 0x22: [data: 0x0]
  	(0x10118) 0x23: [data: 0x0]
  	(0x10120) 0x24: [size: 5]
  	(0x10128) 0x25: [data: 0x400000]
  	(0x10130) 0x26: [data: 0x2]
  	(0x10138) 0x27: [data: 0x1]
  	(0x10140) 0x28: [data: 0xf5]
  	(0x10148) 0x29: [data: 0x0]
  ============ GC STATUS ============
  
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
    Currently used: 36059 words
    Live objects: 1508
  
  Statistics:
    Total allocations: 1508
    Total allocated words: 36059
    Collections performed: 3
  ============ GC STATUS ============
  
  30001
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100000000
    Space capacity: 65536 words
    Currently used: 36059 words
    Live objects: 1508
  
  Statistics:
    Total allocations: 1508
    Total allocated words: 36059
    Collections performed: 3
  ============ GC STATUS ============
  
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100080000
    Space capacity: 65536 words
    Currently used: 59 words
    Live objects: 8
  
  Statistics:
    Total allocations: 1508
    Total allocated words: 36059
    Collections performed: 4
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
    la t0, closure_print_gc_stats
    ld t0, 0(t0)
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
    la t0, closure_sum__0
    ld t0, 0(t0)
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
    la t0, closure_f__21
    ld t0, 0(t0)
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
    call init_closures
  # Application to f__21 with 1 args
  # Load args on stack
    addi sp, sp, -32
    la t0, closure_f__21
    ld t0, 0(t0)
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
    la t0, closure_print_gc_stats
    ld t0, 0(t0)
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
    la t0, closure_print_gc_stats
    ld t0, 0(t0)
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

(realloc)
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
    Currently used: 56 words
    Live objects: 10
  
  Statistics:
    Total allocations: 10
    Total allocated words: 56
    Collections performed: 1
  
  New space layout:
  	(0x10000) 0x0: [size: 5]
  	(0x10008) 0x1: [data: 0x400000]
  	(0x10010) 0x2: [data: 0x2]
  	(0x10018) 0x3: [data: 0x0]
  	(0x10020) 0x4: [data: 0x0]
  	(0x10028) 0x5: [data: 0x0]
  	(0x10030) 0x6: [size: 6]
  	(0x10038) 0x7: [data: 0x40002a]
  	(0x10040) 0x8: [data: 0x3]
  	(0x10048) 0x9: [data: 0x0]
  	(0x10050) 0xa: [data: 0x0]
  	(0x10058) 0xb: [data: 0x0]
  	(0x10060) 0xc: [data: 0x0]
  	(0x10068) 0xd: [size: 4]
  	(0x10070) 0xe: [data: 0x400cfa]
  	(0x10078) 0xf: [data: 0x1]
  	(0x10080) 0x10: [data: 0x0]
  	(0x10088) 0x11: [data: 0x0]
  	(0x10090) 0x12: [size: 4]
  	(0x10098) 0x13: [data: 0x400f70]
  	(0x100a0) 0x14: [data: 0x1]
  	(0x100a8) 0x15: [data: 0x0]
  	(0x100b0) 0x16: [data: 0x0]
  	(0x100b8) 0x17: [size: 4]
  	(0x100c0) 0x18: [data: 0x400f2e]
  	(0x100c8) 0x19: [data: 0x1]
  	(0x100d0) 0x1a: [data: 0x0]
  	(0x100d8) 0x1b: [data: 0x0]
  	(0x100e0) 0x1c: [size: 4]
  	(0x100e8) 0x1d: [data: 0x4002d0]
  	(0x100f0) 0x1e: [data: 0x1]
  	(0x100f8) 0x1f: [data: 0x0]
  	(0x10100) 0x20: [data: 0x0]
  	(0x10108) 0x21: [size: 4]
  	(0x10110) 0x22: [data: 0x400306]
  	(0x10118) 0x23: [data: 0x1]
  	(0x10120) 0x24: [data: 0x0]
  	(0x10128) 0x25: [data: 0x0]
  	(0x10130) 0x26: [size: 4]
  	(0x10138) 0x27: [data: 0x400152]
  	(0x10140) 0x28: [data: 0x1]
  	(0x10148) 0x29: [data: 0x0]
  	(0x10150) 0x2a: [data: 0x0]
  	(0x10158) 0x2b: [size: 5]
  	(0x10160) 0x2c: [data: 0x400000]
  	(0x10168) 0x2d: [data: 0x2]
  	(0x10170) 0x2e: [data: 0x1]
  	(0x10178) 0x2f: [data: 0x29]
  	(0x10180) 0x30: [data: 0x0]
  	(0x10188) 0x31: [size: 6]
  	(0x10190) 0x32: [data: 0x40002a]
  	(0x10198) 0x33: [data: 0x3]
  	(0x101a0) 0x34: [data: 0x2]
  	(0x101a8) 0x35: [data: 0x15]
  	(0x101b0) 0x36: [data: 0x414400]
  	(0x101b8) 0x37: [data: 0x0]
  ============ GC STATUS ============
  
  60
  ============ GC STATUS ============
  Heap Info:
    Heap base address: 0x100000000
    New space address: 0x100000000
    Space capacity: 8192 words
    Currently used: 56 words
    Live objects: 10
  
  Statistics:
    Total allocations: 10
    Total allocated words: 56
    Collections performed: 2
  
  New space layout:
  	(0x0) 0x0: [size: 5]
  	(0x8) 0x1: [data: 0x400000]
  	(0x10) 0x2: [data: 0x2]
  	(0x18) 0x3: [data: 0x0]
  	(0x20) 0x4: [data: 0x0]
  	(0x28) 0x5: [data: 0x0]
  	(0x30) 0x6: [size: 6]
  	(0x38) 0x7: [data: 0x40002a]
  	(0x40) 0x8: [data: 0x3]
  	(0x48) 0x9: [data: 0x0]
  	(0x50) 0xa: [data: 0x0]
  	(0x58) 0xb: [data: 0x0]
  	(0x60) 0xc: [data: 0x0]
  	(0x68) 0xd: [size: 4]
  	(0x70) 0xe: [data: 0x400cfa]
  	(0x78) 0xf: [data: 0x1]
  	(0x80) 0x10: [data: 0x0]
  	(0x88) 0x11: [data: 0x0]
  	(0x90) 0x12: [size: 4]
  	(0x98) 0x13: [data: 0x400f70]
  	(0xa0) 0x14: [data: 0x1]
  	(0xa8) 0x15: [data: 0x0]
  	(0xb0) 0x16: [data: 0x0]
  	(0xb8) 0x17: [size: 4]
  	(0xc0) 0x18: [data: 0x400f2e]
  	(0xc8) 0x19: [data: 0x1]
  	(0xd0) 0x1a: [data: 0x0]
  	(0xd8) 0x1b: [data: 0x0]
  	(0xe0) 0x1c: [size: 4]
  	(0xe8) 0x1d: [data: 0x4002d0]
  	(0xf0) 0x1e: [data: 0x1]
  	(0xf8) 0x1f: [data: 0x0]
  	(0x100) 0x20: [data: 0x0]
  	(0x108) 0x21: [size: 4]
  	(0x110) 0x22: [data: 0x400306]
  	(0x118) 0x23: [data: 0x1]
  	(0x120) 0x24: [data: 0x0]
  	(0x128) 0x25: [data: 0x0]
  	(0x130) 0x26: [size: 4]
  	(0x138) 0x27: [data: 0x400152]
  	(0x140) 0x28: [data: 0x1]
  	(0x148) 0x29: [data: 0x0]
  	(0x150) 0x2a: [data: 0x0]
  	(0x158) 0x2b: [size: 5]
  	(0x160) 0x2c: [data: 0x400000]
  	(0x168) 0x2d: [data: 0x2]
  	(0x170) 0x2e: [data: 0x1]
  	(0x178) 0x2f: [data: 0x29]
  	(0x180) 0x30: [data: 0x0]
  	(0x188) 0x31: [size: 6]
  	(0x190) 0x32: [data: 0x40002a]
  	(0x198) 0x33: [data: 0x3]
  	(0x1a0) 0x34: [data: 0x2]
  	(0x1a8) 0x35: [data: 0x15]
  	(0x1b0) 0x36: [data: 0x404400]
  	(0x1b8) 0x37: [data: 0x0]
  ============ GC STATUS ============
  

