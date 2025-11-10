[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

type reg =
  | Zero
  | Ra
  | Sp
  | A of int
  | S of int
  | T of int

let fp = S 0

let pp_reg fmt =
  let open Format in
  function
  | Zero -> fprintf fmt "zero"
  | Ra -> fprintf fmt "ra"
  | Sp -> fprintf fmt "sp"
  | A n -> fprintf fmt "a%d" n
  | S n when n = 0 -> fprintf fmt "fp"
  | S n -> fprintf fmt "s%d" n
  | T n -> fprintf fmt "t%d" n
;;

type offset = int

type instr =
  | Addi of reg * reg * int
  | Add of reg * reg * reg
  | Sub of reg * reg * reg
  | Mul of reg * reg * reg
  | Div of reg * reg * reg
  | Li of reg * int
  | Ld of reg * offset * reg
  | La of reg * string
  | Slt of reg * reg * reg
  | Seqz of reg * reg
  | Snez of reg * reg
  | Mv of reg * reg
  | Sd of reg * offset * reg
  | Xori of reg * reg * int
  | Xor of reg * reg * reg
  | Andi of reg * reg * int
  | And of reg * reg * reg
  | Ori of reg * reg * int
  | Or of reg * reg * reg
  | Slli of reg * reg * offset
  | Srli of reg * reg * offset
  | Slai of reg * reg * offset
  | Srai of reg * reg * offset
  | Beq of reg * reg * string
  | Ble of reg * reg * string
  | J of string
  | Jalr of reg * reg * int
  | Ecall
  | Call of string
  | Ret
  | Label of string
  | Directive of string
  | Comment of string
  (* Global 8 byte variable *)
  | DWord of string

let pp_instr fmt =
  let open Format in
  function
  | Addi (rd, rs, n) -> fprintf fmt "addi %a, %a, %d" pp_reg rd pp_reg rs n
  | Add (rd, rs1, rs2) -> fprintf fmt "add %a, %a, %a" pp_reg rd pp_reg rs1 pp_reg rs2
  | Sub (rd, rs1, rs2) -> fprintf fmt "sub %a, %a, %a" pp_reg rd pp_reg rs1 pp_reg rs2
  | Mul (rd, rs1, rs2) -> fprintf fmt "mul %a, %a, %a" pp_reg rd pp_reg rs1 pp_reg rs2
  | Div (rd, rs1, rs2) -> fprintf fmt "div %a, %a, %a" pp_reg rd pp_reg rs1 pp_reg rs2
  | Li (rd, n) -> fprintf fmt "li %a, %d" pp_reg rd n
  | Ld (rd, offset, rs) -> fprintf fmt "ld %a, %d(%a)" pp_reg rd offset pp_reg rs
  | La (rd, label) -> fprintf fmt "la %a, %s" pp_reg rd label
  | Slt (rd, rs1, rs2) -> fprintf fmt "slt %a, %a, %a" pp_reg rd pp_reg rs1 pp_reg rs2
  | Seqz (rd, rs) -> fprintf fmt "seqz %a, %a" pp_reg rd pp_reg rs
  | Snez (rd, rs) -> fprintf fmt "snez %a, %a" pp_reg rd pp_reg rs
  | Mv (rd, rs) -> fprintf fmt "mv %a, %a" pp_reg rd pp_reg rs
  | Sd (rs1, offset, rs2) -> fprintf fmt "sd %a, %d(%a)" pp_reg rs1 offset pp_reg rs2
  | Xori (rd, rs, n) -> fprintf fmt "xori %a, %a, %d" pp_reg rd pp_reg rs n
  | Xor (rd, rs1, rs2) -> fprintf fmt "xor %a, %a, %a" pp_reg rd pp_reg rs1 pp_reg rs2
  | Andi (rd, rs, n) -> fprintf fmt "andi %a, %a, %d" pp_reg rd pp_reg rs n
  | And (rd, rs1, rs2) -> fprintf fmt "and %a, %a, %a" pp_reg rd pp_reg rs1 pp_reg rs2
  | Ori (rd, rs, n) -> fprintf fmt "ori %a, %a, %d" pp_reg rd pp_reg rs n
  | Or (rd, rs1, rs2) -> fprintf fmt "or %a, %a, %a" pp_reg rd pp_reg rs1 pp_reg rs2
  | Slli (rd, rs1, imm) -> fprintf fmt "slli %a, %a, %d" pp_reg rd pp_reg rs1 imm
  | Srli (rd, rs1, imm) -> fprintf fmt "srli %a, %a, %d" pp_reg rd pp_reg rs1 imm
  | Slai (rd, rs1, imm) -> fprintf fmt "slai %a, %a, %d" pp_reg rd pp_reg rs1 imm
  | Srai (rd, rs1, imm) -> fprintf fmt "srai %a, %a, %d" pp_reg rd pp_reg rs1 imm
  | Beq (rs1, rs2, label) -> fprintf fmt "beq %a, %a, %s" pp_reg rs1 pp_reg rs2 label
  | Ble (rs1, rs2, label) -> fprintf fmt "ble %a, %a, %s" pp_reg rs1 pp_reg rs2 label
  | J label -> fprintf fmt "j %s" label
  | Jalr (rs1, rs2, imm) -> fprintf fmt "jalr %a, %a, %d" pp_reg rs1 pp_reg rs2 imm
  | Ecall -> fprintf fmt "ecall"
  | Call symbol -> fprintf fmt "call %s" symbol
  | Ret -> fprintf fmt "ret"
  | Label label -> fprintf fmt "%s:" label
  | Directive name -> fprintf fmt "%s" name
  | Comment comment -> fprintf fmt "# %s" comment
  | DWord name -> fprintf fmt "%s: .dword 0" name
;;

let addi r1 r2 n = Addi (r1, r2, n)
let add r1 r2 r3 = Add (r1, r2, r3)
let sub r1 r2 r3 = Sub (r1, r2, r3)
let mul r1 r2 r3 = Mul (r1, r2, r3)
let div r1 r2 r3 = Div (r1, r2, r3)
let li r n = Li (r, n)
let ld r off base = Ld (r, off, base)
let la r label = La (r, label)
let slt r1 r2 r3 = Slt (r1, r2, r3)
let seqz r1 r2 = Seqz (r1, r2)
let snez r1 r2 = Snez (r1, r2)
let mv r1 r2 = Mv (r1, r2)
let sd r1 off base = Sd (r1, off, base)
let xori r1 r2 n = Xori (r1, r2, n)
let xor r1 r2 r3 = Xor (r1, r2, r3)
let andi r1 r2 n = Andi (r1, r2, n)
let and_ r1 r2 r3 = And (r1, r2, r3)
let ori r1 r2 n = Ori (r1, r2, n)
let or_ r1 r2 r3 = Or (r1, r2, r3)
let slli rd rs1 imm = Slli (rd, rs1, imm)
let srli rd rs1 imm = Srli (rd, rs1, imm)
let slai rd rs1 imm = Slai (rd, rs1, imm)
let srai rd rs1 imm = Srai (rd, rs1, imm)
let beq r1 r2 label = Beq (r1, r2, label)
let ble r1 r2 label = Ble (r1, r2, label)
let j label = J label
let jalr rd rs1 imm = Jalr (rd, rs1, imm)
let ecall = Ecall
let call symbol = Call symbol
let ret = Ret
let label l = Label l
let directive l = Directive l
let comment c = Comment c
let dword name = DWord name

let%expect_test "Print all regs and instructions" =
  let open Format in
  let print_program (instr : instr list) : unit =
    pp_print_list ~pp_sep:(fun fmt () -> fprintf fmt "\n") pp_instr std_formatter instr
  in
  let program =
    [ addi (A 0) (A 2) 2
    ; add (T 0) (T 1) (T 2)
    ; sub (S 0) (S 1) (A 0)
    ; mul (A 1) (A 2) (A 3)
    ; div (A 4) (A 5) (A 6)
    ; li (A 7) 42
    ; ld (A 0) 8 Sp
    ; la (A 1) "msg"
    ; slt (T 3) (T 4) (T 5)
    ; seqz (A 2) (A 3)
    ; snez (A 4) (A 5)
    ; mv (A 6) (A 7)
    ; sd (A 0) 16 Sp
    ; xori (A 1) (A 2) 5
    ; xor (A 3) (A 4) (A 5)
    ; andi (A 6) (A 7) 7
    ; and_ (A 0) (A 1) (A 2)
    ; ori (A 3) (A 4) 9
    ; or_ (S 0) (S 1) (A 0)
    ; slai (S 0) (S 1) 4
    ; srai (S 0) (S 1) 4
    ; slli (S 0) (S 1) 4
    ; srli (S 0) (S 1) 4
    ; beq (A 0) (A 1) "label1"
    ; ble (A 2) (A 3) "label2"
    ; j "main"
    ; jalr Ra Sp 0
    ; ecall
    ; call "print_int"
    ; ret
    ; label "loop"
    ; directive ".text"
    ; comment "done"
    ; dword "val"
    ]
  in
  print_program program;
  [%expect
    {|
  addi a0, a2, 2
  add t0, t1, t2
  sub fp, s1, a0
  mul a1, a2, a3
  div a4, a5, a6
  li a7, 42
  ld a0, 8(sp)
  la a1, msg
  slt t3, t4, t5
  seqz a2, a3
  snez a4, a5
  mv a6, a7
  sd a0, 16(sp)
  xori a1, a2, 5
  xor a3, a4, a5
  andi a6, a7, 7
  and a0, a1, a2
  ori a3, a4, 9
  or fp, s1, a0
  slai fp, s1, 4
  srai fp, s1, 4
  slli fp, s1, 4
  srli fp, s1, 4
  beq a0, a1, label1
  ble a2, a3, label2
  j main
  jalr ra, sp, 0
  ecall
  call print_int
  ret
  loop:
  .text
  # done
  val: .dword 0
    |}]
;;
