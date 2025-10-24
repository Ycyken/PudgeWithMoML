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
  (* arity of function *)
  | Function of int
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

  let save_fun_on_stack name arity : unit t =
    let+ () = add_binding name (Function arity) in
    ()
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
     | Some (Function arity) ->
       [ addi Sp Sp (-16)
       ; la (T 0) x
       ; li (T 1) arity
       ; sd (T 0) 0 Sp
       ; sd (T 1) 8 Sp
         (* ; mv (T 5) (A 0) *)
         (* ; mv (T 6) (A 1) *)
         (* ; la (A 0) x *)
         (* ; li (A 1) arity *)
       ; call "alloc_closure"
       ; mv dst (A 0)
         (* ; mv (A 0) (T 5) *)
         (* ; mv (A 1) (T 6) *)
       ]
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
        helper (num + 1) (acc @ load_arg @ [ sd (T 0) (word_size * num) Sp ]) args
      | [] -> return acc
    in
    helper 0 [] args
  in
  [ comment "Load args on stack"; addi Sp Sp (-stack_size) ]
  @ load_variables_code
  @ [ comment "End loading args on stack" ]
  |> return
;;

let pp_instrs code fmt =
  let open Format in
  Base.List.iter code ~f:(function
    | Label l when String.starts_with ~prefix:".globl " l -> fprintf fmt "%s\n" l
    | Label l -> fprintf fmt "%s:\n" l
    | Comment c -> fprintf fmt "# %s\n" c
    | i -> fprintf fmt "  %a\n" pp_instr i)
;;

let%expect_test "even args" =
  let code =
    load_args_on_stack
      [ ImmConst (Int_lt 5)
      ; ImmConst (Int_lt 2)
      ; ImmConst (Int_lt 1)
      ; ImmConst (Int_lt 4)
      ]
  in
  let _, code = run code default in
  pp_instrs code Format.std_formatter;
  [%expect
    {|
    # Load args on stack
      addi sp, sp, -32
      li t0, 5
      sd t0, 0(sp)
      li t0, 2
      sd t0, 8(sp)
      li t0, 1
      sd t0, 16(sp)
      li t0, 4
      sd t0, 24(sp)
    # End loading args on stack
     |}]
;;

let%expect_test "not even args" =
  let code =
    load_args_on_stack [ ImmConst (Int_lt 4); ImmConst (Int_lt 2); ImmConst (Int_lt 1) ]
  in
  let _, code = run code default in
  pp_instrs code Format.std_formatter;
  [%expect
    {|
    # Load args on stack
      addi sp, sp, -32
      li t0, 4
      sd t0, 0(sp)
      li t0, 2
      sd t0, 8(sp)
      li t0, 1
      sd t0, 16(sp)
    # End loading args on stack
     |}]
;;

(* add binding in env with arguments of functions and their values *)
(* argument values keeps on stack *)
(* use this function before save ra and fp registers *)
let get_args_from_stack (args : ident list) : unit t =
  (* let argc = List.length args in *)
  (* let argc = argc + (argc mod 2) in *)
  let* current_sp = get_frame_offset in
  let* () =
    let rec helper num = function
      | arg :: args ->
        let* () = add_binding arg (Stack (current_sp - (num * word_size))) in
        helper (num + 1) args
      | [] -> return ()
    in
    helper 0 args
  in
  return ()
;;

let free_args_on_stack (args : imm list) : instr list t =
  let argc = List.length args in
  let stack_size = (if argc mod 2 = 0 then argc else argc + 1) * word_size in
  let* current = get_frame_offset in
  let* () = set_frame_offset (current - stack_size) in
  return
    [ comment "Free args on stack"
    ; addi Sp Sp stack_size
    ; comment "End free args on stack"
    ]
;;

(* Put arguments on stack and exec alloc_closure function *)
let alloc_closure func arity =
  let args = [ ImmVar func; ImmConst (Int_lt arity) ] in
  let* load_code = load_args_on_stack args in
  let* free_code = free_args_on_stack args in
  load_code @ [ call "alloc_closure" ] @ free_code |> return
;;

let%expect_test _ =
  let code = alloc_closure "homka" 5 in
  let open Base in
  let env = Map.empty (module String) in
  let env = Map.add_exn env ~key:"homka" ~data:(Function 5) in
  let _, code = run code { frame_offset = 0; env; fresh = 0 } in
  pp_instrs code Stdlib.Format.std_formatter;
  [%expect
    {|
    # Load args on stack
      addi sp, sp, -16
      addi sp, sp, -16
      la t0, homka
      li t1, 5
      sd t0, 0(sp)
      sd t1, 8(sp)
      call alloc_closure
      mv t0, a0
      sd t0, 0(sp)
      li t0, 5
      sd t0, 8(sp)
    # End loading args on stack
      call alloc_closure
    # Free args on stack
      addi sp, sp, 16
    # End free args on stack |}]
;;

let rec gen_cexpr (is_top_level : string -> bool * int) dst = function
  | CImm imm -> gen_imm dst imm
  | CIte (c, th, el) ->
    let* cond_code = gen_imm (T 0) c in
    let* then_code = gen_aexpr is_top_level dst th in
    let* else_code = gen_aexpr is_top_level dst el in
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
  | CApp (ImmVar f, arg, args) when fst @@ is_top_level f ->
    let argc_f = is_top_level f |> snd in
    let argc_actual = List.length (arg :: args) in
    let* load_code = load_args_on_stack (arg :: args) in
    let* free_code = free_args_on_stack (arg :: args) in
    if argc_actual = argc_f
    then
      return
      @@ load_code
      @ [ call f ]
      @ free_code
      @ if dst = A 0 then [] else [ mv dst (A 0) ]
    else (
      let alloc_code =
        [ la (A 0) f; li (A 1) argc_f; call "alloc_closure"; mv dst (A 0) ]
      in
      let* load_args =
        let rec helper num acc = function
          | arg :: args ->
            let* load_arg_code = gen_imm (T 0) arg in
            helper (num + 1) (acc @ load_arg_code @ [ mv (A num) (T 0) ]) args
          | [] -> return acc
        in
        helper 1 [] (arg :: args)
      in
      let apply_f_name = "apply_" ^ string_of_int argc_actual in
      return
      @@ alloc_code
      @ load_args
      @ [ call apply_f_name ]
      @ [ mv dst (A 0) ]
      @ free_code)
  | CApp ((ImmVar _ as imm), arg, args) ->
    let argc_actual = List.length (arg :: args) in
    let* load_code = load_args_on_stack (arg :: args) in
    let* free_code = free_args_on_stack (arg :: args) in
    let* get_f = gen_imm (T 0) imm in
    let alloc_code = get_f @ [ mv (A 0) (T 0) ] in
    let* load_args =
      let rec helper num acc = function
        | arg :: args ->
          let* load_arg_code = gen_imm (T 0) arg in
          helper (num + 1) (acc @ load_arg_code @ [ mv (A num) (T 0) ]) args
        | [] -> return acc
      in
      helper 1 [] (arg :: args)
    in
    let apply_f_name = "apply_" ^ string_of_int argc_actual in
    return
    @@ load_code
    @ alloc_code
    @ load_args
    @ [ call apply_f_name ]
    @ [ mv dst (A 0) ]
    @ free_code
    (* let+ fun_addr = lookup f in
    (match fun_addr with
     | None -> failwith "Unbound function"
     | Some (Stack offset) ->
       load_code
       @ [ ld (T 0) offset Sp; jalr Ra (T 0) 0 ]
       @ free_code
       @ if dst = A 0 then [] else [ mv dst (A 0) ]) *)
  | CLambda (arg, body) ->
    let args, body =
      let rec helper acc = function
        | ACExpr (CLambda (arg, body)) -> helper (arg :: acc) body
        | e -> List.rev acc, e
      in
      helper [ arg ] body
    in
    (* let argc = List.length args in *)
    (* let argc = if argc mod 2 = 0 then argc else argc + 1 in *)
    let* current_sp = M.get_frame_offset in
    (* get args from stack *)
    let* () = get_args_from_stack args in
    (* ra and sp *)
    let* () = M.set_frame_offset 16 in
    let* body_code = gen_aexpr is_top_level (A 0) body in
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

and gen_aexpr (is_top_level : string -> bool * int) dst = function
  | ACExpr cexpr -> gen_cexpr is_top_level dst cexpr
  | ALet (Nonrec, name, cexpr, body) ->
    let* cexpr_c = gen_cexpr is_top_level (T 0) cexpr in
    let* off = save_var_on_stack name in
    let+ body_c = gen_aexpr is_top_level dst body in
    cexpr_c @ [ sd (T 0) (-off) fp ] @ body_c
  | _ -> failwith "gen_aexpr case not implemented yet"
;;

(* let common_prologue frame =
  [ addi Sp Sp (-frame); sd Ra (frame - 8) Sp; sd fp (frame - 16) Sp ]
;; *)

let gen_astr_item (is_top_level : string -> bool * int) : astr_item -> instr list M.t
  = function
  | _, (f, ACExpr (CLambda (_, _) as lam)), [] ->
    let arity = is_top_level f |> snd in
    let* () = save_fun_on_stack f arity in
    let+ code = gen_cexpr is_top_level (T 0) lam in
    [ label (Format.asprintf ".globl %s" f); label f ] @ code
  | Nonrec, (name, e), [] ->
    let* off = save_var_on_stack name in
    let+ code = gen_aexpr is_top_level (A 0) e in
    [ sd (A 0) (-off) fp ] @ code
  | i ->
    (* TODO: replace it with Anf.pp_astr_item without \n prints *)
    failwith (Format.asprintf "not implemented codegen for astr item: %a" pp_astr_item i)
;;

let rec gather is_top_level : aprogram -> instr list M.t = function
  | [] -> M.return []
  | [ item ] ->
    let* code = gen_astr_item is_top_level item in
    let+ frame = M.get_frame_offset in
    [ label "_start"; mv fp Sp; addi Sp Sp (-frame) ]
    @ code
    @ [ call "flush"; li (A 0) 0; li (A 7) 94; ecall ]
  | item :: rest ->
    let* code1 = gen_astr_item is_top_level item in
    let+ code2 = gather is_top_level rest in
    code1 @ code2
;;

let gen_aprogram (pr : aprogram) fmt =
  let open Format in
  (* If function top-level or it's just, for example, argument *)
  let get_list_args arg body =
    let rec helper acc = function
      | ACExpr (CLambda (arg, body)) -> helper (arg :: acc) body
      | e -> List.rev acc, e
    in
    helper [ arg ] body |> fst
  in
  let is_top_level name =
    let rec helper (astr : astr_item list) =
      match astr with
      | (_, (f, ACExpr (CLambda (arg, body))), []) :: tl ->
        let list = get_list_args arg body in
        let arity = List.length list in
        if f = name then true, arity else helper tl
      | _ -> false, 0
    in
    helper pr
  in
  fprintf fmt ".text\n";
  fprintf fmt ".globl _start\n";
  let _, code = M.run (gather is_top_level pr) M.default in
  Base.List.iter code ~f:(function
    | Label l when String.starts_with ~prefix:".globl " l -> fprintf fmt "%s\n" l
    | Label l -> fprintf fmt "%s:\n" l
    | Comment c -> fprintf fmt "# %s\n" c
    | i -> fprintf fmt "  %a\n" pp_instr i)
;;
