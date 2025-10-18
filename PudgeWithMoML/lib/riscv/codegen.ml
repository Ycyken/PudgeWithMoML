[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open Frontend.Ast
open Machine
open Middle_end
open Middle_end.Anf

type location =
  | Reg of reg
  | Stack of int
[@@deriving eq]

let code : (instr * string) Queue.t = Queue.create ()
let emit ?(comm = "") instr = instr (fun i -> Queue.add (i, comm) code)
let word_size = 8

module M = struct
  open Base

  type env = (string, location, String.comparator_witness) Map.t

  type st =
    { env : env
    ; frame_offset : int
    ; fresh : int
    }

  include Common.Monad.State (struct
      type state = st
    end)

  let default = { env = Map.empty (module String); frame_offset = 0; fresh = 0 }

  let fresh : string t =
    let* st = get in
    let+ _ = put { st with fresh = st.fresh + 1 } in
    "L" ^ Int.to_string st.fresh
  ;;

  let alloc_frame_slot : int t =
    let* st = get in
    let off = st.frame_offset + word_size in
    put { st with frame_offset = off } >>| fun _ -> off
  ;;

  let add_binding name loc : unit t =
    modify (fun st -> { st with env = Map.set st.env ~key:name ~data:loc })
  ;;

  let get_frame_offset : int t =
    let+ st = get in
    st.frame_offset
  ;;

  let set_frame_offset (off : int) : unit t =
    modify (fun st -> { st with frame_offset = off })
  ;;

  let save_var_on_stack name : int t =
    let* off = alloc_frame_slot in
    add_binding name (Stack off) >>| fun _ -> off
  ;;

  let lookup name : location option t = get >>| fun st -> Map.find st.env name
end

open M

let imm_of_literal : literal -> int = function
  | Int_lt n -> n
  | Bool_lt true -> 1
  | Bool_lt false -> 0
  | Unit_lt -> 1
;;

let gen_imm dst = function
  | ImmConst lt ->
    let imm = imm_of_literal lt in
    M.return [ li dst imm ]
  | ImmVar x ->
    let+ loc = M.lookup x in
    (match loc with
     | Some (Reg r) when r = dst -> []
     | Some (Reg r) -> [ mv dst r ]
     | Some (Stack off) -> [ ld dst (-off) fp ]
     | _ -> failwith ("unbound variable: " ^ x))
;;

let rec gen_cexpr dst = function
  | CImm imm -> gen_imm dst imm
  | CIte (c, th, el) ->
    let* cond_code = gen_imm (T 0) c in
    let* then_code = gen_aexpr dst th in
    let* else_code = gen_aexpr dst el in
    let* l_else = M.fresh in
    let+ l_end = M.fresh in
    cond_code
    @ [ beq (T 0) Zero l_else ]
    @ then_code
    @ [ j l_end; label l_else ]
    @ else_code
    @ [ label l_end ]
  | CBinop (op, e1, e2) when Base.List.mem std_binops op ~equal:String.equal ->
    let* c1 = gen_imm (T 0) e1 in
    let+ c2 = gen_imm (T 1) e2 in
    (match op with
     | "<=" -> c1 @ c2 @ [ slt dst (T 1) (T 0); xori dst dst 1 ]
     | "<" -> c1 @ c2 @ [ slt dst (T 0) (T 1) ]
     | "+" -> c1 @ c2 @ [ add dst (T 0) (T 1) ]
     | "-" -> c1 @ c2 @ [ sub dst (T 0) (T 1) ]
     | "*" -> c1 @ c2 @ [ mul dst (T 0) (T 1) ]
     | "<>" -> c1 @ c2 @ [ sub dst (T 0) (T 1); snez dst dst ]
     | "=" -> c1 @ c2 @ [ sub dst (T 0) (T 1); seqz dst dst ]
     | _ -> failwith ("std binop is not implemented yet: " ^ op))
  | CBinop (op, e1, e2) ->
    let* e1_c = gen_imm (A 0) e1 in
    let+ e2_c = gen_imm (A 1) e2 in
    e1_c @ e2_c @ [ call op ] @ if dst = A 0 then [] else [ mv dst (A 0) ]
  | CApp (ImmVar f, arg) ->
    let+ arg_c = gen_imm (A 0) arg in
    arg_c @ [ call f ] @ if dst = A 0 then [] else [ mv dst (A 0) ]
  | cexpr ->
    (* TODO: replace it with Anf.pp_cexpr without \n prints *)
    failwith
      (Format.asprintf "gen_cexpr case not implemented yet: %a" AnfPP.pp_cexpr cexpr)

and gen_aexpr dst = function
  | ACExpr cexpr -> gen_cexpr dst cexpr
  | ALet (Nonrec, name, cexpr, body) ->
    let* cexpr_c = gen_cexpr (T 0) cexpr in
    let* off = save_var_on_stack name in
    let+ body_c = gen_aexpr dst body in
    cexpr_c @ [ sd (T 0) (-off) fp ] @ body_c
  | _ -> failwith "gen_aexpr case not implemented yet"
;;

let gen_astr_item : astr_item -> instr list M.t = function
  | _, (f, ACExpr (CLambda (arg, body))), [] ->
    let* saved_off = M.get_frame_offset in
    let* () = M.set_frame_offset 16 in
    let* x_off = save_var_on_stack arg in
    let* body_code = gen_aexpr (A 0) body in
    let* locals = M.get_frame_offset in
    (* for ra and fp *)
    let frame = locals + (2 * word_size) in
    let+ () = M.set_frame_offset saved_off in
    let prologue =
      [ addi Sp Sp (-frame)
      ; sd Ra (frame - 8) Sp
      ; sd fp (frame - 16) Sp
      ; addi fp Sp frame
      ; sd (A 0) (-x_off) fp
      ]
    in
    let epilogue =
      [ ld Ra (frame - 8) Sp; ld fp (frame - 16) Sp; addi Sp Sp frame; ret ]
    in
    [ label f ] @ prologue @ body_code @ epilogue
  | Nonrec, (_, e), [] ->
    let+ body_code = gen_aexpr (A 0) e in
    [ label "_start"; mv fp Sp ]
    @ body_code
    @ [ call "flush"; li (A 0) 0; li (A 7) 94; ecall ]
  | i ->
    (* TODO: replace it with Anf.pp_astr_item without \n prints *)
    failwith (Format.asprintf "not implemented codegen for astr item: %a" pp_astr_item i)
;;

let rec gather : aprogram -> instr list M.t = function
  | [] -> M.return []
  | item :: rest ->
    let* code1 = gen_astr_item item in
    let+ code2 = gather rest in
    code1 @ code2
;;

let gen_aprogram (pr : aprogram) fmt =
  let open Format in
  fprintf fmt ".text\n";
  fprintf fmt ".globl _start\n";
  let _, code = M.run (gather pr) M.default in
  Base.List.iter code ~f:(function
    | Label l -> fprintf fmt "%s:\n" l
    | i -> fprintf fmt "  %a\n" pp_instr i)
;;
