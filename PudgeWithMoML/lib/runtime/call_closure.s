    .text
    .globl call_closure
    .type  call_closure, @function
    # a0 = code, a1 = argc, a2 = argv (argv[i] — 64-битное значение аргумента)
call_closure:
    addi    sp, sp, -64
    sd      ra, 56(sp)
    sd      s0, 48(sp)
    sd      s1, 40(sp)
    sd      s2, 32(sp)
    sd      s3, 24(sp)

    mv      s0, a0        # code
    mv      s1, a1        # argc
    mv      s2, a2        # argv

    li      t0, 8
    ble     s1, t0, .Largs_le_8    # если argc <= 8, стек под аргументы не нужен

    # ---------- argc > 8: стековые аргументы ----------
    addi    t1, s1, -8            # t1 = argc - 8 (кол-во стековых аргументов)
    andi    t2, t1, 1
    beqz    t2, 1f
    addi    t1, t1, 1             # округляем до чётного для выравнивания (16 байт)
1:
    slli    t3, t1, 3             # t3 = t1 * 8 = размер области на стеке
    mv      s3, t3                # сохраним размер, чтобы потом вернуть sp
    sub     sp, sp, s3            # выделяем место: у callee arg8 будет по 0(sp)

    # Копируем реальные стековые аргументы: argv[8..argc-1] -> [sp]
    li      t4, 8                 # i = 8
    mv      t5, sp                # dst = sp
.Lcopy_stack:
    beq     t4, s1, .Lcopy_done
    slli    t2, t4, 3             # offset = i * 8
    add     t6, s2, t2            # &argv[i]
    ld      t2, 0(t6)             # t2 = argv[i]
    sd      t2, 0(t5)             # кладём на стек
    addi    t5, t5, 8
    addi    t4, t4, 1
    j       .Lcopy_stack
.Lcopy_done:

    # Первые 8 аргументов — в регистрах a0–a7
    ld      a0, 0(s2)
    ld      a1, 8(s2)
    ld      a2,16(s2)
    ld      a3,24(s2)
    ld      a4,32(s2)
    ld      a5,40(s2)
    ld      a6,48(s2)
    ld      a7,56(s2)

    mv      t0, s0
    jalr    t0                    # вызов code(...)

    add     sp, sp, s3            # убрать область стековых аргументов
    j       .Lepilogue


    # ---------- argc <= 8: только регистры ----------
.Largs_le_8:
    mv      t0, s2                # ptr = argv
    mv      t1, s1                # remaining = argc

    beqz    t1, .Ldo_call         # нет аргументов

    ld      a0, 0(t0)
    addi    t0, t0, 8
    addi    t1, t1, -1
    beqz    t1, .Ldo_call

    ld      a1, 0(t0)
    addi    t0, t0, 8
    addi    t1, t1, -1
    beqz    t1, .Ldo_call

    ld      a2, 0(t0)
    addi    t0, t0, 8
    addi    t1, t1, -1
    beqz    t1, .Ldo_call

    ld      a3, 0(t0)
    addi    t0, t0, 8
    addi    t1, t1, -1
    beqz    t1, .Ldo_call

    ld      a4, 0(t0)
    addi    t0, t0, 8
    addi    t1, t1, -1
    beqz    t1, .Ldo_call

    ld      a5, 0(t0)
    addi    t0, t0, 8
    addi    t1, t1, -1
    beqz    t1, .Ldo_call

    ld      a6, 0(t0)
    addi    t0, t0, 8
    addi    t1, t1, -1
    beqz    t1, .Ldo_call

    ld      a7, 0(t0)
    # если аргументов меньше, чем доехали — просто не заходим в лишние участки

.Ldo_call:
    mv      t0, s0
    jalr    t0                    # вызов code(...)

.Lepilogue:
    ld      ra, 56(sp)
    ld      s0, 48(sp)
    ld      s1, 40(sp)
    ld      s2, 32(sp)
    ld      s3, 24(sp)
    addi    sp, sp, 64
    ret
