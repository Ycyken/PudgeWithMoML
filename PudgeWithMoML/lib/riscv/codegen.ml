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
  | Function of int (* arity of function *)
  | Global (* bss section *)

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

  let lookup name : location option t = get >>| fun st -> Map.find st.env name
end

open M

let imm_of_literal : literal -> int = function
  | Int_lt n -> n
  | Bool_lt true -> 1
  | Bool_lt false -> 0
  | Unit_lt -> 1
;;

(* Generate code that puts imm value to dst reg *)
(* Note: gen_imm overwrite **regs t5 and t6** for internal work *)
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
     (* if we meet function (it's top level) -- call alloc_closure function *)
     | Some (Function arity) ->
       return
         [ addi Sp Sp (-16)
         ; la (T 5) x
         ; li (T 6) arity
         ; sd (T 5) 0 Sp
         ; sd (T 6) 8 Sp
         ; call "alloc_closure"
         ; mv dst (A 0)
         ; addi Sp Sp 16
         ]
     | Some Global -> return [ la (T 5) x; ld dst 0 (T 5) ]
     | Some (Reg reg) -> return [ mv dst reg ]
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
  match run code default |> snd with
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
  match run code default |> snd with
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

(* Put arguments on stack and exec alloc_closure function *)
(* Result of function stay in a0 register *)
let alloc_closure func arity =
  let args = [ ImmVar func; ImmConst (Int_lt arity) ] in
  let* load_code = load_args_on_stack args in
  let* free_code = free_args_on_stack args in
  load_code @ [ call "alloc_closure" ] @ free_code |> return
;;

let%expect_test "alloc_closure_test" =
  let code =
    let* curr_off = get_frame_offset in
    let* code = alloc_closure "homka" 5 in
    let* prev_off = get_frame_offset in
    assert (curr_off = prev_off);
    return code
  in
  let env = Base.Map.empty (module Base.String) in
  let env = Base.Map.add_exn env ~key:"homka" ~data:(Function 5) in
  match run code { frame_offset = 0; env; fresh = 0 } |> snd with
  | Error msg -> Format.eprintf "Error: %s\n" msg
  | Ok code ->
    pp_instrs code Format.std_formatter;
    [%expect
      {|
    # Load args on stack
      addi sp, sp, -16
      addi sp, sp, -16
      la t5, homka
      li t6, 5
      sd t5, 0(sp)
      sd t6, 8(sp)
      call alloc_closure
      mv t0, a0
      addi sp, sp, 16
      sd t0, 0(sp)
      li t0, 11
      sd t0, 8(sp)
    # End loading args on stack
      call alloc_closure
    # Free args on stack
      addi sp, sp, 16
    # End free args on stack |}]
;;

let comment_wrap str code = [ comment str ] @ code @ [ comment ("End " ^ str) ]

let rec gen_cexpr (var_arity : string -> int) dst = function
  | CImm imm -> gen_imm dst imm
  | CIte (c, th, el) ->
    let* cond_code = gen_imm (T 0) c in
    let* then_code = gen_aexpr var_arity dst th in
    let* else_code = gen_aexpr var_arity dst el in
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
  | CApp (ImmVar f, arg, args)
  (* it is full application *)
    when List.length (arg :: args) = var_arity f ->
    let args = arg :: args in
    let comment = Format.asprintf "Apply %s with %d args" f (List.length args) in
    let* load_code, free_code =
      let* load_code = load_args_on_stack args in
      let+ free_code = free_args_on_stack args in
      load_code, free_code
    in
    (load_code @ [ call f ] @ free_code @ if dst = A 0 then [] else [ mv dst (A 0) ])
    |> comment_wrap comment
    |> return
  | CApp (ImmVar f, arg, args)
  (* it is partial application *)
    when List.length (arg :: args) < var_arity f ->
    let argc = List.length (arg :: args) in
    let comment = Format.asprintf "Partial application %s with %d args" f argc in
    let args = ImmVar f :: ImmConst (Int_lt argc) :: arg :: args in
    let* load_code = load_args_on_stack args in
    let* free_code = free_args_on_stack args in
    load_code @ [ call "apply_closure"; mv dst (A 0) ] @ free_code
    |> comment_wrap comment
    |> return
  | CApp ((ImmVar f as imm), arg, args)
  (* f is not top level, so apply arguments one by one *) ->
    (* TODO: closure keep argc, so we can group them by that number *)
    let argc = List.length (arg :: args) in
    let comment = Format.asprintf "Apply %s with %d args" f argc in
    let rec helper imm acc = function
      | [] -> return acc
      | arg :: args ->
        let* temp = fresh in
        let* get_closure_code =
          let* get_f = gen_imm (T 0) imm in
          let+ off = save_var_on_stack temp in
          get_f @ [ sd (T 0) (-off) fp ]
        in
        let* load_code, free_code =
          let args = [ ImmVar temp; ImmConst (Int_lt 1); arg ] in
          let* load_code = load_args_on_stack args in
          let+ free_code = free_args_on_stack args in
          load_code, free_code
        in
        let code = get_closure_code @ load_code @ [ call "apply_closure" ] @ free_code in
        let* () = add_binding temp (Reg (A 0)) in
        helper (ImmVar temp) (acc @ code) args
    in
    let* result = helper imm [] (arg :: args) in
    let load_result =
      match dst with
      | A 0 -> []
      | _ -> [ mv dst (A 0) ]
    in
    result @ load_result |> comment_wrap comment |> return
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
    let* body_code = gen_aexpr var_arity (A 0) body in
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

and gen_aexpr (var_arity : string -> int) dst = function
  | ACExpr cexpr -> gen_cexpr var_arity dst cexpr
  | ALet (Nonrec, name, cexpr, body) ->
    let* cexpr_c = gen_cexpr var_arity (T 0) cexpr in
    let* off = save_var_on_stack name in
    let+ body_c = gen_aexpr var_arity dst body in
    cexpr_c @ [ sd (T 0) (-off) fp ] @ body_c
  | _ -> fail "gen_aexpr case not implemented yet"
;;

let gen_astr_item (var_arity : string -> int) : astr_item -> instr list M.t = function
  | _, (f, ACExpr (CLambda (_, _) as lam)), [] ->
    let arity = var_arity f in
    let* () = save_fun_on_stack f arity in
    let+ code = gen_cexpr var_arity (T 0) lam in
    [ directive (Format.asprintf ".globl %s" f); label f ] @ code
  | Nonrec, (name, e), [] ->
    (* let* off = save_var_on_stack name in *)
    let* () = add_binding name Global in
    let+ code = gen_aexpr var_arity (T 0) e in
    code @ [ la (T 1) name; sd (T 0) 0 (T 1) ]
  | i ->
    (* TODO: replace it with Anf.pp_astr_item without \n prints *)
    fail (Format.asprintf "not implemented codegen for astr item: %a" pp_astr_item i)
;;

let gen_bss_section (pr : aprogram) : instr list t =
  let module StringSet = Set.Make (String) in
  (* get list of global variables that are not functions and generate bss section (local variables) *)
  let get_globals_variables (pr : aprogram) =
    let rec helper acc (astrs : astr_item list) =
      (* After lambda lifting we don't have inner functions that make our life mush easy :) *)
      match astrs with
      | [] -> acc |> return
      | (_, (_, ACExpr (CLambda (_, _))), []) :: tl -> helper acc tl
      | (_, (name, _), []) :: tl -> helper (StringSet.add name acc) tl
      | (_, (_, _), _ :: _) :: _ ->
        fail "Multiple bindings in astr_item not implemented yet"
    in
    helper StringSet.empty pr
  in
  let+ vars = get_globals_variables pr in
  StringSet.fold (fun v acc -> DWord v :: acc) vars []
;;

let is_function = function
  | _, (_, ACExpr (CLambda (_, _))), [] -> true
  | _ -> false
;;

let func_arity =
  let rec helper acc = function
    | ACExpr (CLambda (_, body)) -> helper (acc + 1) body
    | _ -> acc
  in
  helper 0
;;

let program_arities (pr : aprogram) =
  let open Base in
  let binds = pr |> List.concat_map ~f:(fun (_, bind, binds) -> bind :: binds) in
  let arities =
    List.fold
      binds
      ~init:(Map.empty (module String))
      ~f:(fun acc -> function
        | f, ACExpr (CLambda (_, body)) -> Map.set acc ~key:f ~data:(1 + func_arity body)
        | _ -> acc)
  in
  fun name -> Map.find arities name |> Option.value ~default:0
;;

(* Go through list of astr_item, generates three types of code:
  1) Code for variables initialization of the bss section (exec in _start)
  2) Code for functions *)
let gather pr : instr list t =
  let program_arities = program_arities pr in
  let* main_code, functions_code =
    let rec helper acc = function
      | [] -> M.return acc
      | item :: rest ->
        let main_code, functions_code = acc in
        let* code = gen_astr_item program_arities item in
        if is_function item
        then helper (main_code, functions_code @ code) rest
        else helper (main_code @ code, functions_code) rest
    in
    helper ([], []) pr
  in
  let+ frame = M.get_frame_offset in
  [ directive ".text" ]
  @ functions_code
  @ [ directive ".globl _start"; label "_start" ]
  @ [ mv fp Sp ]
  @ [ mv (A 0) Sp; call "init_GC" ]
  @ [ addi Sp Sp (-frame) ]
  @ main_code
  @ [ call "flush"; li (A 0) 0; li (A 7) 94; ecall ]
;;

let gen_aprogram fmt (pr : aprogram) =
  let code =
    let* bss_section = gen_bss_section pr in
    let+ main_code = gather pr in
    main_code, bss_section
  in
  match M.run code M.default |> snd with
  | Error msg -> Error msg
  | Ok (main_code, bss_section) ->
    pp_instrs main_code fmt;
    if Base.List.is_empty bss_section
    then Ok ()
    else Ok (pp_instrs (Directive ".data" :: bss_section) fmt)
;;
