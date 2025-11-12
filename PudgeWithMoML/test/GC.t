( simple example )
  $ make compile FIXADDR=1 opts=-gen_mid --no-print-directory -C .. << 'EOF'
  > let add a b = a + b
  > let main = 
  >   let homka1 = add 5 in
  >   let homka2 = print_gc_status () in
  >   let homka3 = gc_collect () in
  >   let homka4 = print_gc_status () in
  >   let lol = (homka1 2) in
  >   let homka5 = print_gc_status () in
  >   print_int lol
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe 
  === GC status ===
  Start address of new space: 0
  Allocate count: 2 times
  Collect count: 0 times
  Current space capacity: 8192 words
  Total allocated memory: 12 words
  Allocated words in new space: 12 words
  Live objects in new space: 0
  Current new space:
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
  === GC status ===
  
  === GC status ===
  Start address of new space: 10000
  Allocate count: 2 times
  Collect count: 1 times
  Current space capacity: 8192 words
  Total allocated memory: 12 words
  Allocated words in new space: 6 words
  Live objects in new space: 1
  Current new space:
  	(0x10000) 0x0: [size: 5]
  	(0x10008) 0x1: [data: 0x400000]
  	(0x10010) 0x2: [data: 0x2]
  	(0x10018) 0x3: [data: 0x1]
  	(0x10020) 0x4: [data: 0xb]
  	(0x10028) 0x5: [data: 0x0]
  === GC status ===
  
  === GC status ===
  Start address of new space: 10000
  Allocate count: 3 times
  Collect count: 1 times
  Current space capacity: 8192 words
  Total allocated memory: 18 words
  Allocated words in new space: 12 words
  Live objects in new space: 1
  Current new space:
  	(0x10000) 0x0: [size: 5]
  	(0x10008) 0x1: [data: 0x400000]
  	(0x10010) 0x2: [data: 0x2]
  	(0x10018) 0x3: [data: 0x1]
  	(0x10020) 0x4: [data: 0xb]
  	(0x10028) 0x5: [data: 0x0]
  	(0x10030) 0x6: [size: 5]
  	(0x10038) 0x7: [data: 0x400000]
  	(0x10040) 0x8: [data: 0x2]
  	(0x10048) 0x9: [data: 0x2]
  	(0x10050) 0xa: [data: 0xb]
  	(0x10058) 0xb: [data: 0x5]
  === GC status ===
  
  7
  $ cat ../main.anf
  let add__0 = fun a__1 ->
    fun b__2 ->
    a__1 + b__2 
  
  
  let main__3 = let anf_t6 = add__0 5 in
    let homka1__4 = anf_t6 in
    let anf_t5 = print_gc_status () in
    let homka2__5 = anf_t5 in
    let anf_t4 = gc_collect () in
    let homka3__6 = anf_t4 in
    let anf_t3 = print_gc_status () in
    let homka4__7 = anf_t3 in
    let anf_t2 = homka1__4 2 in
    let lol__8 = anf_t2 in
    let anf_t1 = print_gc_status () in
    let homka5__9 = anf_t1 in
    print_int lol__8 
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
    addi sp, sp, -104
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
    li t0, 3
    sd t0, 8(sp)
    li t0, 11
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
    call print_gc_status
    sd t0, -24(fp)
    ld t0, -24(fp)
    sd t0, -32(fp)
    call gc_collect
    sd t0, -40(fp)
    ld t0, -40(fp)
    sd t0, -48(fp)
    call print_gc_status
    sd t0, -56(fp)
    ld t0, -56(fp)
    sd t0, -64(fp)
  # Apply homka1__4 with 1 args
    ld t0, -16(fp)
    sd t0, -72(fp)
  # Load args on stack
    addi sp, sp, -32
    ld t0, -72(fp)
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    li t0, 5
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
    mv t0, a0
  # End Apply homka1__4 with 1 args
    sd t0, -80(fp)
    ld t0, -80(fp)
    sd t0, -88(fp)
    call print_gc_status
    sd t0, -96(fp)
    ld t0, -96(fp)
    sd t0, -104(fp)
  # Apply print_int
    ld a0, -88(fp)
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
  .pushsection .gcroots,"aw",@progbits
  .balign 8
  .globl __start_gcroots
  __start_gcroots:
  .quad main__3
  .globl __stop_gcroots
  __stop_gcroots:
  .popsection

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
  === GC status ===
  Start address of new space: 0
  Allocate count: 5 times
  Collect count: 0 times
  Current space capacity: 8192 words
  Total allocated memory: 28 words
  Allocated words in new space: 28 words
  Live objects in new space: 0
  Current new space:
  	(0x0) 0x0: [size: 5]
  	(0x8) 0x1: [data: 0x400000]
  	(0x10) 0x2: [data: 0x2]
  	(0x18) 0x3: [data: 0x0]
  	(0x20) 0x4: [data: 0x0]
  	(0x28) 0x5: [data: 0x0]
  	(0x30) 0x6: [size: 4]
  	(0x38) 0x7: [data: 0x400030]
  	(0x40) 0x8: [data: 0x1]
  	(0x48) 0x9: [data: 0x0]
  	(0x50) 0xa: [data: 0x0]
  	(0x58) 0xb: [size: 5]
  	(0x60) 0xc: [data: 0x400000]
  	(0x68) 0xd: [data: 0x2]
  	(0x70) 0xe: [data: 0x1]
  	(0x78) 0xf: [data: 0x4042d8]
  	(0x80) 0x10: [data: 0x0]
  	(0x88) 0x11: [size: 5]
  	(0x90) 0x12: [data: 0x400000]
  	(0x98) 0x13: [data: 0x2]
  	(0xa0) 0x14: [data: 0x2]
  	(0xa8) 0x15: [data: 0x4042d8]
  	(0xb0) 0x16: [data: 0xb]
  	(0xb8) 0x17: [size: 4]
  	(0xc0) 0x18: [data: 0x400030]
  	(0xc8) 0x19: [data: 0x1]
  	(0xd0) 0x1a: [data: 0x1]
  	(0xd8) 0x1b: [data: 0xb]
  === GC status ===
  
  === GC status ===
  Start address of new space: 10000
  Allocate count: 5 times
  Collect count: 1 times
  Current space capacity: 8192 words
  Total allocated memory: 28 words
  Allocated words in new space: 0 words
  Live objects in new space: 0
  Current new space:
  === GC status ===
  
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
    addi sp, sp, -32
    sd ra, 24(sp)
    sd fp, 16(sp)
    addi fp, sp, 32
  # Apply f__1 with 1 args
    ld t0, 0(fp)
    sd t0, -24(fp)
  # Load args on stack
    addi sp, sp, -32
    ld t0, -24(fp)
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    ld t0, 8(fp)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Apply f__1 with 1 args
    ld ra, 24(sp)
    ld fp, 16(sp)
    addi sp, sp, 32
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
    addi sp, sp, -48
    sd ra, 40(sp)
    sd fp, 32(sp)
    addi fp, sp, 48
  # Apply wrap__7 with 1 args
    ld t0, 8(fp)
    sd t0, -24(fp)
  # Load args on stack
    addi sp, sp, -32
    ld t0, -24(fp)
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    ld t0, 16(fp)
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
    mv t0, a0
  # End Apply wrap__7 with 1 args
    sd t0, -32(fp)
  # Apply anf_t6 with 1 args
    ld t0, -32(fp)
    sd t0, -40(fp)
  # Load args on stack
    addi sp, sp, -32
    ld t0, -40(fp)
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    li t0, 11
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Apply anf_t6 with 1 args
    ld ra, 40(sp)
    ld fp, 32(sp)
    addi sp, sp, 48
    ret
  .globl _start
  _start:
    mv fp, sp
    mv a0, sp
    call init_GC
    addi sp, sp, 0
  # Apply homka__5 with 3 args
  # Load args on stack
    addi sp, sp, -32
    li t0, 5
    sd t0, 0(sp)
    addi sp, sp, -16
    la t5, wrap__0
    li t6, 2
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 8(sp)
    addi sp, sp, -16
    la t5, id__3
    li t6, 1
    sd t5, 0(sp)
    sd t6, 8(sp)
    call alloc_closure
    mv t0, a0
    addi sp, sp, 16
    sd t0, 16(sp)
  # End loading args on stack
    call homka__5
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
    mv t0, a0
  # End Apply homka__5 with 3 args
    la t1, homs__10
    sd t0, 0(t1)
    call print_gc_status
    la t1, _
    sd t0, 0(t1)
    call gc_collect
    la t1, _
    sd t0, 0(t1)
    call print_gc_status
    la t1, _
    sd t0, 0(t1)
  # Apply print_int
    la t5, homs__10
    ld a0, 0(t5)
    call print_int
    mv t0, a0
  # End Apply print_int
    la t1, main__11
    sd t0, 0(t1)
    call flush
    li a0, 0
    li a7, 94
    ecall
  .data
  main__11: .dword 0
  homs__10: .dword 0
  _: .dword 0
  .pushsection .gcroots,"aw",@progbits
  .balign 8
  .globl __start_gcroots
  __start_gcroots:
  .quad _
  .quad homs__10
  .quad main__11
  .globl __stop_gcroots
  __stop_gcroots:
  .popsection

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
  === GC status ===
  Start address of new space: 0
  Allocate count: 2 times
  Collect count: 0 times
  Current space capacity: 8192 words
  Total allocated memory: 12 words
  Allocated words in new space: 12 words
  Live objects in new space: 0
  Current new space:
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
  	(0x50) 0xa: [data: 0xf]
  	(0x58) 0xb: [data: 0x0]
  === GC status ===
  
  === GC status ===
  Start address of new space: 10000
  Allocate count: 2 times
  Collect count: 1 times
  Current space capacity: 8192 words
  Total allocated memory: 12 words
  Allocated words in new space: 6 words
  Live objects in new space: 1
  Current new space:
  	(0x10000) 0x0: [size: 5]
  	(0x10008) 0x1: [data: 0x400000]
  	(0x10010) 0x2: [data: 0x2]
  	(0x10018) 0x3: [data: 0x1]
  	(0x10020) 0x4: [data: 0xf]
  	(0x10028) 0x5: [data: 0x0]
  === GC status ===
  
  === GC status ===
  Start address of new space: 10000
  Allocate count: 4 times
  Collect count: 1 times
  Current space capacity: 8192 words
  Total allocated memory: 24 words
  Allocated words in new space: 18 words
  Live objects in new space: 1
  Current new space:
  	(0x10000) 0x0: [size: 5]
  	(0x10008) 0x1: [data: 0x400000]
  	(0x10010) 0x2: [data: 0x2]
  	(0x10018) 0x3: [data: 0x1]
  	(0x10020) 0x4: [data: 0xf]
  	(0x10028) 0x5: [data: 0x0]
  	(0x10030) 0x6: [size: 5]
  	(0x10038) 0x7: [data: 0x400000]
  	(0x10040) 0x8: [data: 0x2]
  	(0x10048) 0x9: [data: 0x0]
  	(0x10050) 0xa: [data: 0x0]
  	(0x10058) 0xb: [data: 0x0]
  	(0x10060) 0xc: [size: 5]
  	(0x10068) 0xd: [data: 0x400000]
  	(0x10070) 0xe: [data: 0x2]
  	(0x10078) 0xf: [data: 0x1]
  	(0x10080) 0x10: [data: 0xd]
  	(0x10088) 0x11: [data: 0x0]
  === GC status ===
  
  === GC status ===
  Start address of new space: 0
  Allocate count: 4 times
  Collect count: 2 times
  Current space capacity: 8192 words
  Total allocated memory: 24 words
  Allocated words in new space: 12 words
  Live objects in new space: 2
  Current new space:
  	(0x0) 0x0: [size: 5]
  	(0x8) 0x1: [data: 0x400000]
  	(0x10) 0x2: [data: 0x2]
  	(0x18) 0x3: [data: 0x1]
  	(0x20) 0x4: [data: 0xf]
  	(0x28) 0x5: [data: 0x0]
  	(0x30) 0x6: [size: 5]
  	(0x38) 0x7: [data: 0x400000]
  	(0x40) 0x8: [data: 0x2]
  	(0x48) 0x9: [data: 0x1]
  	(0x50) 0xa: [data: 0xd]
  	(0x58) 0xb: [data: 0x0]
  === GC status ===
  
  === GC status ===
  Start address of new space: 10000
  Allocate count: 4 times
  Collect count: 3 times
  Current space capacity: 8192 words
  Total allocated memory: 24 words
  Allocated words in new space: 12 words
  Live objects in new space: 2
  Current new space:
  	(0x10000) 0x0: [size: 5]
  	(0x10008) 0x1: [data: 0x400000]
  	(0x10010) 0x2: [data: 0x2]
  	(0x10018) 0x3: [data: 0x1]
  	(0x10020) 0x4: [data: 0xf]
  	(0x10028) 0x5: [data: 0x0]
  	(0x10030) 0x6: [size: 5]
  	(0x10038) 0x7: [data: 0x400000]
  	(0x10040) 0x8: [data: 0x2]
  	(0x10048) 0x9: [data: 0x1]
  	(0x10050) 0xa: [data: 0xd]
  	(0x10058) 0xb: [data: 0x0]
  === GC status ===
  
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
  === GC status ===
  Start address of new space: 0
  Allocate count: 4 times
  Collect count: 0 times
  Current space capacity: 8192 words
  Total allocated memory: 24 words
  Allocated words in new space: 24 words
  Live objects in new space: 0
  Current new space:
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
  === GC status ===
  
  === GC status ===
  Start address of new space: 10000
  Allocate count: 4 times
  Collect count: 1 times
  Current space capacity: 8192 words
  Total allocated memory: 24 words
  Allocated words in new space: 12 words
  Live objects in new space: 2
  Current new space:
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
  === GC status ===
  
  === GC status ===
  Start address of new space: 10000
  Allocate count: 5 times
  Collect count: 1 times
  Current space capacity: 8192 words
  Total allocated memory: 30 words
  Allocated words in new space: 18 words
  Live objects in new space: 2
  Current new space:
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
  	(0x10060) 0xc: [size: 5]
  	(0x10068) 0xd: [data: 0x400000]
  	(0x10070) 0xe: [data: 0x2]
  	(0x10078) 0xf: [data: 0x2]
  	(0x10080) 0x10: [data: 0xb]
  	(0x10088) 0x11: [data: 0x5]
  === GC status ===
  
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
    addi sp, sp, -120
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
    li t0, 3
    sd t0, 8(sp)
    li t0, 11
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
    li t0, 3
    sd t0, 8(sp)
    li t0, 7
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure
    mv t0, a0
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
  # End Partial application add__0 with 1 args
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
  # Apply homka1__4 with 1 args
    ld t0, -16(fp)
    sd t0, -88(fp)
  # Load args on stack
    addi sp, sp, -32
    ld t0, -88(fp)
    sd t0, 0(sp)
    li t0, 3
    sd t0, 8(sp)
    li t0, 5
    sd t0, 16(sp)
  # End loading args on stack
    call apply_closure
  # Free args on stack
    addi sp, sp, 32
  # End free args on stack
    mv t0, a0
  # End Apply homka1__4 with 1 args
    sd t0, -96(fp)
    ld t0, -96(fp)
    sd t0, -104(fp)
    call print_gc_status
    sd t0, -112(fp)
    ld t0, -112(fp)
    sd t0, -120(fp)
  # Apply print_int
    ld a0, -104(fp)
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
  .pushsection .gcroots,"aw",@progbits
  .balign 8
  .globl __start_gcroots
  __start_gcroots:
  .quad main__3
  .globl __stop_gcroots
  __stop_gcroots:
  .popsection


( many closures, heap is dynamicly resized )
  $ make compile FIXADDR=1 --no-print-directory -C .. << 'EOF'
  > let rec fib n k = if n < 2 then k n else fib (n - 1) (fun a -> fib (n - 2) (fun b -> k (a + b)))
  > let main = print_int (fib 15 (fun x -> x))
  > let _ = gc_collect ()
  > let _ = print_gc_status ()
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe 
  610
  === GC status ===
  Start address of new space: 80000
  Allocate count: 7890 times
  Collect count: 4 times
  Current space capacity: 65536 words
  Total allocated memory: 55226 words
  Allocated words in new space: 5 words
  Live objects in new space: 1
  Current new space:
  	(0x10000) 0x0: [size: 4]
  	(0x10008) 0x1: [data: 0x4001c4]
  	(0x10010) 0x2: [data: 0x1]
  	(0x10018) 0x3: [data: 0x0]
  	(0x10020) 0x4: [data: 0x0]
  === GC status ===
  

( get current capacity of heap )
  $ make compile FIXADDR=1 opts=-gen_mid --no-print-directory -C .. << 'EOF'
  > let start = get_heap_start ()
  > let end = get_heap_fin ()
  > let main = print_int (end - start)
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
  === GC status ===
  Start address of new space: 0
  Allocate count: 2 times
  Collect count: 0 times
  Current space capacity: 8192 words
  Total allocated memory: 12 words
  Allocated words in new space: 12 words
  Live objects in new space: 0
  Current new space:
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
  === GC status ===
  
  65536
  === GC status ===
  Start address of new space: 10000
  Allocate count: 2 times
  Collect count: 1 times
  Current space capacity: 8192 words
  Total allocated memory: 12 words
  Allocated words in new space: 6 words
  Live objects in new space: 1
  Current new space:
  	(0x10000) 0x0: [size: 5]
  	(0x10008) 0x1: [data: 0x400000]
  	(0x10010) 0x2: [data: 0x2]
  	(0x10018) 0x3: [data: 0x1]
  	(0x10020) 0x4: [data: 0xf5]
  	(0x10028) 0x5: [data: 0x0]
  === GC status ===
  
(realloc)
  $ make compile FIXADDR=1 --no-print-directory -C .. << 'EOF'
  > let sum x y = x + y                   
  > let rec f x = if (x <= 1) then 1 else let t = sum 5 in f (x - 1)
  > let main = print_int (f 1500)
  > let _ = gc_collect ()
  > let _ = print_gc_status ()
  > EOF
  $ qemu-riscv64 -L /usr/riscv64-linux-gnu -cpu rv64 ../main.exe 
  1
  === GC status ===
  Start address of new space: 20000
  Allocate count: 2998 times
  Collect count: 13 times
  Current space capacity: 16384 words
  Total allocated memory: 17988 words
  Allocated words in new space: 0 words
  Live objects in new space: 0
  Current new space:
  === GC status ===
  

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
  === GC status ===
  Start address of new space: 10000
  Allocate count: 4 times
  Collect count: 1 times
  Current space capacity: 8192 words
  Total allocated memory: 26 words
  Allocated words in new space: 13 words
  Live objects in new space: 2
  Current new space:
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
  === GC status ===
  
  60
  === GC status ===
  Start address of new space: 0
  Allocate count: 6 times
  Collect count: 2 times
  Current space capacity: 8192 words
  Total allocated memory: 39 words
  Allocated words in new space: 13 words
  Live objects in new space: 2
  Current new space:
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
  === GC status ===
  

