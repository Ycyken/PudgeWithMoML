(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

open Machine

type location =
  | Reg of reg
  | Stack of int
[@@deriving eq]

let word_size = 8

module M = struct
  open Base

  type env = (string, location, String.comparator_witness) Map.t

  type state =
    { env : env
    ; stack_offset : int
    ; fresh : int
    }

  type 'a t = state -> 'a * state

  let return x st = x, st

  let bind m f st =
    let x, st' = m st in
    f x st'
  ;;

  let ( let* ) = bind

  let run m =
    let init = { env = Map.empty (module String); stack_offset = 0; fresh = 0 } in
    m init
  ;;

  let fresh : string t =
    fun st -> "L" ^ Int.to_string st.fresh, { st with fresh = st.fresh + 1 }
  ;;

  let get_env : env t = fun st -> st.env, st
  let put_env env : unit t = fun st -> (), { st with env }
  let modify_env f : unit t = fun st -> (), { st with env = f st.env }

  let alloc_stack_slot : int t =
    fun st ->
    let off = st.stack_offset + word_size in
    off, { st with stack_offset = off }
  ;;

  let get_stack_offset : int t = fun st -> st.stack_offset, st
  let set_stack_offset (off : int) : unit t = fun st -> (), { st with stack_offset = off }

  let add_binding name loc : unit t =
    modify_env (fun env -> Map.set env ~key:name ~data:loc)
  ;;

  let put_on_stack name offset : unit t = add_binding name (Stack offset)
  let lookup name : location option t = fun st -> Map.find st.env name, st
end

open Frontend.Ast
open M

let imm_of_literal = function
  | Int_lt n -> n
  | Bool_lt true -> 1
  | Bool_lt false -> 0
  | Unit_lt -> 1
;;

let rec gen_expr dst : expr -> instr list M.t = function
  | Const lt ->
    let imm = imm_of_literal lt in
    M.return [ li dst imm ]
  | Variable x ->
    let* loc = M.lookup x in
    (match loc with
     | Some (Reg r) when r = dst -> M.return []
     | Some (Reg r) -> M.return [ mv dst r ]
     | Some (Stack off) -> M.return [ ld dst off Sp ]
     | _ -> failwith ("unbound variable: " ^ x))
  | If_then_else (c, th, Some el) ->
    let* cond_code = gen_expr (T 0) c in
    let* then_code = gen_expr dst th in
    let* else_code = gen_expr dst el in
    let* l_else = M.fresh in
    let* l_end = M.fresh in
    M.return
      (cond_code
       @ [ beq (T 0) Zero l_else ]
       @ then_code
       @ [ j l_end; label l_else ]
       @ else_code
       @ [ label l_end ])
  | Apply (Apply (Variable op, e1), e2) when List.mem op [ "<="; "+"; "-"; "*" ] ->
    let* c1 = gen_expr (T 0) e1 in
    let* c2 = gen_expr (T 1) e2 in
    (match op with
     | "<=" -> M.return (c1 @ c2 @ [ slt dst (T 1) (T 0); xori dst dst 1 ])
     | "+" -> M.return (c1 @ c2 @ [ add dst (T 0) (T 1) ])
     | "-" -> M.return (c1 @ c2 @ [ sub dst (T 0) (T 1) ])
     | "*" -> M.return (c1 @ c2 @ [ mul dst (T 0) (T 1) ])
     | _ -> failwith ("unsupported infix operator: " ^ op))
  | Apply (Variable f, arg) ->
    let* arg_code = gen_expr (A 0) arg in
    let instrs = arg_code @ [ Call f ] @ if dst = A 0 then [] else [ Mv (dst, A 0) ] in
    M.return instrs
  | LetIn (Nonrec, [ (PVar x, expr) ], inner_expr) ->
    let* code1 = gen_expr (T 0) expr in
    let* off = alloc_stack_slot in
    let* () = M.add_binding x (Stack off) in
    let* code2 = gen_expr dst inner_expr in
    M.return (code1 @ [ sd (T 0) off Sp ] @ code2)
  | _ -> failwith "gen_expr: not implemented"
;;

let gen_structure_item : structure_item -> instr list M.t = function
  | Rec, [ (PVar f, Lambda (PVar x, body)) ] ->
    let* saved_off = M.get_stack_offset in
    let* () = M.set_stack_offset 0 in
    let* x_off = alloc_stack_slot in
    let* () = M.add_binding x (Stack x_off) in
    let* body_code = gen_expr (A 0) body in
    let* locals = M.get_stack_offset in
    let frame = locals + word_size in
    (* for ra *)
    let* () = M.set_stack_offset saved_off in
    let prologue = [ addi Sp Sp (-frame); sd Ra 0 Sp; sd (A 0) x_off Sp ] in
    let epilogue = [ ld Ra 0 Sp; addi Sp Sp frame; ret ] in
    M.return ([ label f ] @ prologue @ body_code @ epilogue)
  | Nonrec, [ (PVar "main", e) ] ->
    let* body_code = gen_expr (A 0) e in
    M.return ([ label "_start" ] @ body_code @ [ li (A 7) 94; ecall ])
  | _ -> failwith "unsupported structure item"
;;

let rec gather : program -> instr list M.t = function
  | [] -> M.return []
  | item :: rest ->
    let* code1 = gen_structure_item item in
    let* code2 = gather rest in
    M.return (code1 @ code2)
;;

let gen_program (pr : program) fmt =
  let open Format in
  fprintf fmt ".text\n";
  fprintf fmt ".globl _start\n";
  let code, _ = M.run (gather pr) in
  Base.List.iter code ~f:(function
    | Label l -> fprintf fmt "%s:\n" l
    | i -> fprintf fmt "  %a\n" pp_instr i)
;;
