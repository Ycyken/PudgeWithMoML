open Frontend.Ast

type imm =
  | ImmConst of literal
  | ImmVar of string

type cexpr =
  | CImm of imm
  | CTuple of imm * imm * imm list
  | CBinop of string * imm * imm
  | CNot of imm
  | CLambda of string * aexpr
  | CApp of imm * imm
  | CIte of imm * aexpr * aexpr

and aexpr =
  | ALet of is_recursive * string * cexpr * aexpr
  | ACExpr of cexpr

type binding = ident * aexpr [@@deriving show { with_path = false }]

type astr_item = is_recursive * binding * binding list
[@@deriving show { with_path = false }]

type aprogram = astr_item list [@@deriving show { with_path = false }]

val anf_str_item : structure_item -> astr_item Common.Monad.Counter.t
val anf_program : structure_item list -> aprogram
