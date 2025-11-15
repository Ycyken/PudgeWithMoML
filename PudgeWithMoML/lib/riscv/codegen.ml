[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open Frontend.Ast
open Machine
open Middle_end
open Middle_end.Anf
module StringSet = Set.Make (String)

let func_arity =
  let rec helper acc = function
    | ACExpr (CLambda (_, body)) -> helper (acc + 1) body
    | _ -> acc
  in
  helper 0
;;

let program_binds (pr : aprogram) =
  Base.List.concat_map pr ~f:(fun (_, bind, binds) -> bind :: binds)
;;

type location =
  | Stack of int (* offset from fp *)
  | Global of int
(* Global and it's arity. Arity includes only the number of explicit arguments. 
  Arity > 0 <=> It's function. 
  Arity = 0 <=> it's global variable.*)

let word_size = 8

module M = struct
  open Base

  type env = (string, location, String.comparator_witness) Map.t

  type st =
    { env : env
    ; frame_offset : int
    ; fresh : int
    }

  include Common.Monad.StateR (struct
      type state = st
      type error = string
    end)

  let init_globals (pr : aprogram) =
    let open Base in
    let binds = program_binds pr in
    List.fold
      binds
      ~init:(Map.empty (module String))
      ~f:(fun acc -> function
        | f, (ACExpr (CLambda _) as body) ->
          Map.set acc ~key:f ~data:(Global (func_arity body))
        | f, _ -> Map.set acc ~key:f ~data:(Global 0))
  ;;

  let default pr =
    let open Base in
    let arities = init_globals pr in
    let std =
      Map.of_alist_exn
        (module String)
        [ "print_int", Global 1
        ; "gc_collect", Global 1
        ; "get_heap_start", Global 1
        ; "get_heap_fin", Global 1
        ; "print_gc_status", Global 1
        ; "print_gc_stats", Global 1
        ]
    in
    let env =
      Map.merge arities std ~f:(fun ~key:_ -> function
        | `Left loc -> Some loc
        | `Right loc -> Some loc
        | `Both (v1, _) -> Some v1)
    in
    { env; frame_offset = 0; fresh = 0 }
  ;;

  let get_global_vars : StringSet.t t =
    let+ st = get in
    Map.fold st.env ~init:StringSet.empty ~f:(fun ~key ~data acc ->
      match data with
      | Global arity when arity = 0 -> StringSet.add key acc
      | _ -> acc)
  ;;

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

(** Generate code that puts imm value to dst reg.

For global functions allocates closure, for global variables load it's value.*)
let gen_imm dst = function
  | ImmConst (Int_lt _ as lt) ->
    let imm = imm_of_literal lt in
    M.return [ li dst (Int.shift_left imm 1 + 1) ]
  | ImmConst lt ->
    let imm = imm_of_literal lt in
    M.return [ li dst imm ]
  | ImmVar x ->
    let* loc = M.lookup x in
    (match loc with
     | Some (Stack off) -> return [ ld dst (-off) fp ]
     | Some (Global arity) when arity > 0 ->
       return
         [ addi Sp Sp (-16)
         ; la (T 5) x
         ; li (T 6) (Int.shift_left arity 1 + 1)
         ; sd (T 5) 0 Sp
         ; sd (T 6) 8 Sp
         ; call "alloc_closure"
         ; mv dst (A 0)
         ; addi Sp Sp 16
         ]
     | Some (Global _) -> return [ la (T 5) x; ld dst 0 (T 5) ]
     | _ -> fail ("unbound variable: " ^ x))
;;

(* Get args list and put these args on stack for future function exec *)
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
    | (Label _ | Directive _ | Comment _ | DWord _) as i -> fprintf fmt "%a\n" pp_instr i
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
  match run code (default []) |> snd with
  | Error msg -> Format.eprintf "Error: %s\n" msg
  | Ok code ->
    pp_instrs code Format.std_formatter;
    [%expect
      {|
    # Load args on stack
      addi sp, sp, -32
      li t0, 11
      sd t0, 0(sp)
      li t0, 5
      sd t0, 8(sp)
      li t0, 3
      sd t0, 16(sp)
      li t0, 9
      sd t0, 24(sp)
    # End loading args on stack
     |}]
;;

let%expect_test "not even args" =
  let code =
    load_args_on_stack [ ImmConst (Int_lt 4); ImmConst (Int_lt 2); ImmConst (Int_lt 1) ]
  in
  match run code (default []) |> snd with
  | Error msg -> Format.eprintf "Error: %s\n" msg
  | Ok code ->
    pp_instrs code Format.std_formatter;
    [%expect
      {|
    # Load args on stack
      addi sp, sp, -32
      li t0, 9
      sd t0, 0(sp)
      li t0, 5
      sd t0, 8(sp)
      li t0, 3
      sd t0, 16(sp)
    # End loading args on stack
     |}]
;;

(** Add binding in env with arguments of functions and their values
argument values keeps on stack
use this function before save ra and fp registers *)
let get_args_from_stack (args : ident list) : unit t =
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

(* Get args lists and free stack space that these argument taken *)
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

(* Call function with arguments on stack and move result to the destination register *)
let call_function ?(dst = A 0) f args =
  let* load = load_args_on_stack args in
  let+ free = free_args_on_stack args in
  load @ [ call f ] @ (if dst = A 0 then [] else [ mv dst (A 0) ]) @ free
;;

let comment_wrap str code = [ comment str ] @ code @ [ comment ("End " ^ str) ]

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
    let* c2 = gen_imm (T 1) e2 in
    (match op with
     | "<=" -> c1 @ c2 @ [ slt dst (T 1) (T 0); xori dst dst 1 ] |> return
     | "<" -> c1 @ c2 @ [ slt dst (T 0) (T 1) ] |> return
     | ">=" -> c1 @ c2 @ [ slt dst (T 0) (T 1); xori dst dst 1 ] |> return
     | ">" -> c1 @ c2 @ [ slt dst (T 1) (T 0) ] |> return
     | "+" ->
       c1
       @ c2
       @ [ srai (T 0) (T 0) 1
         ; srai (T 1) (T 1) 1
         ; add dst (T 0) (T 1)
         ; slli dst dst 1
         ; ori dst dst 1
         ]
       |> return
     | "-" ->
       c1
       @ c2
       @ [ srai (T 0) (T 0) 1
         ; srai (T 1) (T 1) 1
         ; sub dst (T 0) (T 1)
         ; slli dst dst 1
         ; ori dst dst 1
         ]
       |> return
     | "*" ->
       c1
       @ c2
       @ [ srai (T 0) (T 0) 1
         ; srai (T 1) (T 1) 1
         ; mul dst (T 0) (T 1)
         ; slli dst dst 1
         ; ori dst dst 1
         ]
       |> return
     | "/" ->
       c1
       @ c2
       @ [ srai (T 0) (T 0) 1
         ; srai (T 1) (T 1) 1
         ; div dst (T 0) (T 1)
         ; slli dst dst 1
         ; ori dst dst 1
         ]
       |> return
     | "<>" -> c1 @ c2 @ [ sub dst (T 0) (T 1); snez dst dst ] |> return
     | "=" -> c1 @ c2 @ [ sub dst (T 0) (T 1); seqz dst dst ] |> return
     | "&&" -> c1 @ c2 @ [ and_ dst (T 0) (T 1) ] |> return
     | "||" -> c1 @ c2 @ [ or_ dst (T 0) (T 1) ] |> return
     | _ -> fail ("std binop is not implemented yet: " ^ op))
  | CApp (ImmVar "print_int", arg, []) ->
    let+ arg_c = gen_imm (A 0) arg in
    (arg_c @ [ call "print_int" ] @ if dst = A 0 then [] else [ mv dst (A 0) ])
    |> comment_wrap "Apply print_int"
  | CApp (ImmVar name, ImmConst Unit_lt, [])
    when Base.List.mem [ "print_gc_status"; "gc_collect" ] name ~equal:String.equal ->
    [ call name ] |> return
  | CApp (ImmVar name, ImmConst Unit_lt, [])
    when Base.List.mem [ "get_heap_start"; "get_heap_fin" ] name ~equal:String.equal ->
    ([ call name ] @ if dst = A 0 then [] else [ mv dst (A 0) ]) |> return
  | CApp (ImmVar f, arg, args) ->
    let argc = List.length (arg :: args) in
    let comment = Format.asprintf "Application to %s with %d args" f argc in
    let+ apply_chain =
      call_function
        "apply_closure_chain"
        (ImmVar f :: ImmConst (Int_lt argc) :: arg :: args)
        ~dst
    in
    apply_chain |> comment_wrap comment
  | CLambda (arg, body) ->
    let args, body =
      let rec helper acc = function
        | ACExpr (CLambda (arg, body)) -> helper (arg :: acc) body
        | e -> List.rev acc, e
      in
      helper [ arg ] body
    in
    let* current_sp = M.get_frame_offset in
    let* () = get_args_from_stack args in
    (* ra and sp *)
    let* () = M.set_frame_offset 16 in
    let* body_code = gen_aexpr (A 0) body in
    let* locals = M.get_frame_offset in
    let frame = if locals mod 16 = 0 then locals else locals + (16 - (locals mod 16)) in
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
  | CNot imm ->
    let* code = gen_imm (T 0) imm in
    code @ [ xori dst (T 0) (-1) ] |> return
  | cexpr ->
    (* TODO: replace it with Anf.pp_cexpr without \n prints *)
    fail (Format.asprintf "gen_cexpr case not implemented yet: %a" AnfPP.pp_cexpr cexpr)

and gen_aexpr dst = function
  | ACExpr cexpr -> gen_cexpr dst cexpr
  | ALet (Nonrec, name, cexpr, body) ->
    let* cexpr_c = gen_cexpr (T 0) cexpr in
    let* off = save_var_on_stack name in
    let+ body_c = gen_aexpr dst body in
    cexpr_c @ [ sd (T 0) (-off) fp ] @ body_c
  | _ -> fail "gen_aexpr case not implemented yet"
;;

(* Generate code for all global functions and for the _start entry point.
   The _start function computes the initial values of global variables and stores them. *)
let gen_funcs (pr : aprogram) : (instr list * instr list) M.t =
  let binds = program_binds pr in
  let rec helper acc (binds : binding list) =
    let funcs, main = acc in
    match binds with
    | [] -> return acc
    | (f, ACExpr (CLambda _ as lam)) :: tl ->
      let* code = gen_cexpr (A 0) lam in
      let func = [ directive (Format.asprintf ".globl %s" f); label f ] @ code in
      helper (funcs @ func, main) tl
    | (f, e) :: tl ->
      let* gen_var = gen_aexpr (A 0) e in
      let store_var = [ la (A 1) f; sd (A 0) 0 (A 1) ] in
      helper (funcs, main @ gen_var @ store_var) tl
  in
  let+ funcs, main = helper ([], []) binds in
  funcs, main
;;

(** Generate global_vars section with global variables. *)
let gen_vars_section : instr list t =
  let+ gl_vars = get_global_vars in
  let gl_vars =
    List.concat_map
      (fun v -> [ Directive (Format.sprintf ".globl %s" v); DWord v ])
      (StringSet.elements gl_vars)
  in
  [ Directive ".section global_vars, \"aw\", @progbits"; Directive ".balign 8" ] @ gl_vars
;;

(* Generate code for the entire program: functions, _start, global_vars section. *)
let gen_code pr : instr list M.t =
  let* funcs, main = gen_funcs pr in
  let* vars_section = gen_vars_section in
  let+ frame = M.get_frame_offset in
  [ directive ".text" ]
  @ funcs
  @ [ directive ".globl _start"; label "_start" ]
  @ [ mv fp Sp ]
  @ [ mv (A 0) Sp; call "init_GC" ]
  @ [ addi Sp Sp (-frame) ]
  @ main
  @ [ call "flush"; li (A 0) 0; li (A 7) 94; ecall ]
  @ vars_section
;;

let gen_aprogram fmt (pr : aprogram) =
  let code = gen_code pr in
  match M.run code (M.default pr) |> snd with
  | Error msg -> Error msg
  | Ok res -> Ok (pp_instrs res fmt)
;;
