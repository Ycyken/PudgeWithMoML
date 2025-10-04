(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

type reg =
  | Zero
  | Ra
  | Sp
  | A of int
  | S of int
  | T of int
[@@deriving eq]

let pp_reg fmt =
  let open Format in
  function
  | Zero -> fprintf fmt "zero"
  | Ra -> fprintf fmt "ra"
  | Sp -> fprintf fmt "sp"
  | A n when n >= 0 && n <= 7 -> fprintf fmt "a%d" n
  | S n when n >= 1 && n <= 11 -> fprintf fmt "s%d" n
  | S n when n = 0 -> fprintf fmt "fp"
  | T n when n >= 0 && n <= 6 -> fprintf fmt "t%d" n
  | _ -> failwith "invalid register"
;;

type offset = int

type instr =
  | Addi of reg * reg * int
  | Add of reg * reg * reg
  | Sub of reg * reg * reg
  | Mul of reg * reg * reg
  | Li of reg * int
  | Ld of reg * offset * reg
  | Slt of reg * reg * reg
  | Seqz of reg * reg
  | Snez of reg * reg
  | Mv of reg * reg
  | Sd of reg * offset * reg
  | Xori of reg * reg * int
  | Beq of reg * reg * string
  | Ble of reg * reg * string
  | J of string
  | Ecall
  | Call of string
  | Ret
  | Label of string

let pp_instr fmt =
  let open Format in
  function
  | Addi (rd, rs, n) -> fprintf fmt "addi %a, %a, %d" pp_reg rd pp_reg rs n
  | Add (rd, rs1, rs2) -> fprintf fmt "add %a, %a, %a" pp_reg rd pp_reg rs1 pp_reg rs2
  | Sub (rd, rs1, rs2) -> fprintf fmt "sub %a, %a, %a" pp_reg rd pp_reg rs1 pp_reg rs2
  | Mul (rd, rs1, rs2) -> fprintf fmt "mul %a, %a, %a" pp_reg rd pp_reg rs1 pp_reg rs2
  | Li (rd, n) -> fprintf fmt "li %a, %d" pp_reg rd n
  | Ld (rd, offset, rs) -> fprintf fmt "ld %a, %d(%a)" pp_reg rd offset pp_reg rs
  | Slt (rd, rs1, rs2) -> fprintf fmt "slt %a, %a, %a" pp_reg rd pp_reg rs1 pp_reg rs2
  | Seqz (rd, rs) -> fprintf fmt "seqz %a, %a" pp_reg rd pp_reg rs
  | Snez (rd, rs) -> fprintf fmt "snez %a, %a" pp_reg rd pp_reg rs
  | Mv (rd, rs) -> fprintf fmt "mv %a, %a" pp_reg rd pp_reg rs
  | Sd (rs1, offset, rs2) -> fprintf fmt "sd %a, %d(%a)" pp_reg rs1 offset pp_reg rs2
  | Xori (rd, rs, n) -> fprintf fmt "xori %a, %a, %d" pp_reg rd pp_reg rs n
  | Beq (rs1, rs2, label) -> fprintf fmt "beq %a, %a, %s" pp_reg rs1 pp_reg rs2 label
  | Ble (rs1, rs2, label) -> fprintf fmt "ble %a, %a, %s" pp_reg rs1 pp_reg rs2 label
  | J label -> fprintf fmt "j %s" label
  | Ecall -> fprintf fmt "ecall"
  | Call symbol -> fprintf fmt "call %s" symbol
  | Ret -> fprintf fmt "ret"
  | Label label -> fprintf fmt "%s:" label
;;

let addi r1 r2 n = Addi (r1, r2, n)
let add r1 r2 r3 = Add (r1, r2, r3)
let sub r1 r2 r3 = Sub (r1, r2, r3)
let mul r1 r2 r3 = Mul (r1, r2, r3)
let li r n = Li (r, n)
let ld r off base = Ld (r, off, base)
let slt r1 r2 r3 = Slt (r1, r2, r3)
let seqz r1 r2 = Seqz (r1, r2)
let snez r1 r2 = Snez (r1, r2)
let mv r1 r2 = Mv (r1, r2)
let sd r1 off base = Sd (r1, off, base)
let xori r1 r2 n = Xori (r1, r2, n)
let beq r1 r2 label = Beq (r1, r2, label)
let ble r1 r2 label = Ble (r1, r2, label)
let j label = J label
let ecall = Ecall
let call symbol = Call symbol
let ret = Ret
let label l = Label l
