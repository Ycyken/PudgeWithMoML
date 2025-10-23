[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open Frontend.Ast
open Machine
open Middle_end
open Middle_end.Anf

type location =
  | Stack of int
  | Function of string
[@@deriving eq] [@@warning "-37"]

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

  (* let save_vars_on_stack names : int t =
    let rec helper = function
      | hd :: tl ->
        let* off = alloc_frame_slot in
        let* _ = add_binding hd (Stack off) >>| fun _ -> off in
        helper tl
      | [] -> get_frame_offset
    in
    helper names
  ;; *)

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
     | Some (Stack off) -> [ ld dst (-off) fp ]
     | _ -> failwith ("unbound variable: " ^ x))
;;

let load_args_on_stack (args : imm list) : instr list t =
  let argc = List.length args in
  let* current_stack = get_frame_offset in
  let stack_size = (if argc mod 2 = 0 then argc else argc + 1) * word_size in
  let* () = set_frame_offset (current_stack + stack_size) in
  let* load_variables_code =
    let rec helper num acc = function
      | arg :: args ->
        let* load_arg = gen_imm (T 0) arg in
        helper
          (num + 1)
          (acc @ load_arg @ [ sd (T 0) (stack_size - (word_size * num)) Sp ])
          args
      | [] -> return acc
    in
    helper 1 [] args
  in
  [ addi Sp Sp (-stack_size) ] @ load_variables_code |> return
;;

let free_args_on_stack (args : imm list) : instr list t =
  let argc = List.length args in
  let stack_size = (if argc mod 2 = 0 then argc else argc + 1) * word_size in
  return [ addi Sp Sp stack_size ]
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
     | ">=" -> c1 @ c2 @ [ slt dst (T 0) (T 1); xori dst dst 1 ]
     | ">" -> c1 @ c2 @ [ slt dst (T 1) (T 0) ]
     | "+" -> c1 @ c2 @ [ add dst (T 0) (T 1) ]
     | "-" -> c1 @ c2 @ [ sub dst (T 0) (T 1) ]
     | "*" -> c1 @ c2 @ [ mul dst (T 0) (T 1) ]
     | "/" -> c1 @ c2 @ [ div dst (T 0) (T 1) ]
     | "<>" -> c1 @ c2 @ [ sub dst (T 0) (T 1); snez dst dst ]
     | "=" -> c1 @ c2 @ [ sub dst (T 0) (T 1); seqz dst dst ]
     | "&&" -> c1 @ c2 @ [ and_ dst (T 0) (T 1) ]
     | "||" -> c1 @ c2 @ [ or_ dst (T 0) (T 1) ]
     | _ -> failwith ("std binop is not implemented yet: " ^ op))
  | CBinop (op, e1, e2) ->
    let* e1_c = gen_imm (A 0) e1 in
    let+ e2_c = gen_imm (A 1) e2 in
    e1_c @ e2_c @ [ call op ] @ if dst = A 0 then [] else [ mv dst (A 0) ]
  | CApp (ImmVar "print_int", arg, []) ->
    let+ arg_c = gen_imm (A 0) arg in
    arg_c @ [ call "print_int" ] @ if dst = A 0 then [] else [ mv dst (A 0) ]
  | CApp (ImmVar f, arg, args) ->
    let* load_code = load_args_on_stack (arg :: args) in
    let+ free_code = free_args_on_stack (arg :: args) in
    load_code @ [ call f ] @ free_code @ if dst = A 0 then [] else [ mv dst (A 0) ]
  | CLambda (arg, body) ->
    let args, body =
      let rec helper acc = function
        | ACExpr (CLambda (arg, body)) -> helper (arg :: acc) body
        | e -> List.rev acc, e
      in
      helper [ arg ] body
    in
    let argc = List.length args in
    let argc = if argc mod 2 = 0 then argc else argc + 1 in
    let* current_sp = M.get_frame_offset in
    (* get args from stack *)
    let* () =
      let rec helper num = function
        | arg :: args ->
          let* () = add_binding arg (Stack (current_sp - (num * word_size))) in
          helper (num - 1) args
        | [] -> return ()
      in
      helper (argc - 1) args
    in
    (* ra and sp *)
    let* () = M.set_frame_offset 16 in
    let* body_code = gen_aexpr (A 0) body in
    let* locals = M.get_frame_offset in
    let frame = locals + (locals mod 8) in
    let* () = M.set_frame_offset current_sp in
    let prologue =
      [ addi Sp Sp (-frame)
      ; sd Ra (frame - 8) Sp
      ; sd fp (frame - 16) Sp
      ; addi fp Sp frame
      ]
    in
    let epilogue =
      [ ld Ra (frame - 8) Sp; ld fp (frame - 16) Sp; addi Sp Sp frame; ret ]
    in
    prologue @ body_code @ epilogue |> return
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

(* let common_prologue frame =
  [ addi Sp Sp (-frame); sd Ra (frame - 8) Sp; sd fp (frame - 16) Sp ]
;; *)

let gen_astr_item : astr_item -> instr list M.t = function
  | _, (f, ACExpr (CLambda (_, _) as lam)), [] ->
    let+ code = gen_cexpr (T 0) lam in
    [ label (Format.asprintf ".globl %s" f); label f ] @ code
  | Nonrec, (_, e), [] -> gen_aexpr (A 0) e
  | i ->
    (* TODO: replace it with Anf.pp_astr_item without \n prints *)
    failwith (Format.asprintf "not implemented codegen for astr item: %a" pp_astr_item i)
;;

let rec gather : aprogram -> instr list M.t = function
  | [] -> M.return []
  | [ item ] ->
    let* code = gen_astr_item item in
    let+ frame = M.get_frame_offset in
    [ label "_start"; mv fp Sp; addi Sp Sp (-frame) ]
    @ code
    @ [ call "flush"; li (A 0) 0; li (A 7) 94; ecall ]
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
    | Label l when String.starts_with ~prefix:".globl " l -> fprintf fmt "%s\n" l
    | Label l -> fprintf fmt "%s:\n" l
    | i -> fprintf fmt "  %a\n" pp_instr i)
;;
