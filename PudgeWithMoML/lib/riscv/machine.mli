type reg =
  | Zero
  | Ra
  | Sp
  | A of int
  | S of int
  | T of int

val equal_reg : reg -> reg -> bool
val fp : reg
val pp_reg : Format.formatter -> reg -> unit

type offset = int

type instr =
  | Addi of reg * reg * offset
  | Add of reg * reg * reg
  | Sub of reg * reg * reg
  | Mul of reg * reg * reg
  | Li of reg * offset
  | Ld of reg * offset * reg
  | Slt of reg * reg * reg
  | Seqz of reg * reg
  | Snez of reg * reg
  | Mv of reg * reg
  | Sd of reg * offset * reg
  | Xori of reg * reg * offset
  | Xor of reg * reg * reg
  | Beq of reg * reg * string
  | Ble of reg * reg * string
  | J of string
  | Ecall
  | Call of string
  | Ret
  | Label of string

val pp_instr : Format.formatter -> instr -> unit
val addi : reg -> reg -> int -> instr
val add : reg -> reg -> reg -> instr
val sub : reg -> reg -> reg -> instr
val mul : reg -> reg -> reg -> instr
val li : reg -> int -> instr
val ld : reg -> offset -> reg -> instr
val slt : reg -> reg -> reg -> instr
val seqz : reg -> reg -> instr
val snez : reg -> reg -> instr
val mv : reg -> reg -> instr
val sd : reg -> offset -> reg -> instr
val xori : reg -> reg -> int -> instr
val xor : reg -> reg -> reg -> instr
val beq : reg -> reg -> string -> instr
val ble : reg -> reg -> string -> instr
val j : string -> instr
val ecall : instr
val call : string -> instr
val ret : instr
val label : string -> instr
