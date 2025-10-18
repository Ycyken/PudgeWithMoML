[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open Machine
open Middle_end.Anf

type location =
  | Reg of reg
  | Stack of int
[@@deriving eq]

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

open Frontend.Ast
open M

let imm_of_literal = function
  | Int_lt n -> n
  | Bool_lt true -> 1
  | Bool_lt false -> 0
  | Unit_lt -> 1
;;

let gen_imm_anf dst : imm -> instr list M.t = function
  | ImmConst lt ->
    let imm = imm_of_literal lt in
    M.return [ li dst imm ]
  | ImmVar x ->
    let* loc = M.lookup x in
    (match loc with
     | Some (Reg r) when r = dst -> M.return []
     | Some (Reg r) -> M.return [ mv dst r ]
     | Some (Stack off) -> M.return [ ld dst (-off) fp ]
     | _ -> failwith ("unbound variable: " ^ x))
;;

let rec gen_expr_anf dst : aexpr -> instr list M.t = function
  | ACExpr (CImm imm) -> gen_imm_anf dst imm
  | ACExpr (CBinop (op, imm1, imm2)) ->
    let* c1 = gen_imm_anf (T 0) imm1 in
    let* c2 = gen_imm_anf (T 1) imm2 in
    (match op with
     | "<=" -> c1 @ c2 @ [ slt dst (T 1) (T 0); xori dst dst 1 ] |> M.return
     | "+" -> c1 @ c2 @ [ add dst (T 0) (T 1) ] |> M.return
     | "-" -> c1 @ c2 @ [ sub dst (T 0) (T 1) ] |> M.return
     | "*" -> c1 @ c2 @ [ mul dst (T 0) (T 1) ] |> M.return
     | _ -> failwith ("unsupported infix operator: " ^ op))
  | ACExpr (CNot _) -> failwith "Not operator not implemented"
  | ACExpr (CIte (c, th, el)) ->
    let* cond_code = gen_imm_anf (T 0) c in
    let* then_code = gen_expr_anf dst th in
    let* else_code = gen_expr_anf dst el in
    let* l_else = M.fresh in
    let* l_end = M.fresh in
    M.return
      (cond_code
       @ [ beq (T 0) Zero l_else ]
       @ then_code
       @ [ j l_end; label l_else ]
       @ else_code
       @ [ label l_end ])
  | ACExpr (CApp (ImmVar x, imm2)) ->
    let* arg_code = gen_imm_anf (A 0) imm2 in
    let instrs = arg_code @ [ Call x ] @ if dst = A 0 then [] else [ Mv (dst, A 0) ] in
    M.return instrs
    (* | ACExpr (CLambda (ImmVar x, aexpr)) -> *)
    (* let* body_code = gen_expr_anf (A 0) aexpr in *)
    (* M.return [ label x ] *)
  | _ -> failwith "gen_expr: not implemented"
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
     | Some (Stack off) -> M.return [ ld dst (-off) fp ]
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
     | "<=" -> c1 @ c2 @ [ slt dst (T 1) (T 0); xori dst dst 1 ] |> M.return
     | "+" -> c1 @ c2 @ [ add dst (T 0) (T 1) ] |> M.return
     | "-" -> c1 @ c2 @ [ sub dst (T 0) (T 1) ] |> M.return
     | "*" -> c1 @ c2 @ [ mul dst (T 0) (T 1) ] |> M.return
     | _ -> failwith ("unsupported infix operator: " ^ op))
  | Apply (Variable f, arg) ->
    let* arg_code = gen_expr (A 0) arg in
    let instrs = arg_code @ [ Call f ] @ if dst = A 0 then [] else [ Mv (dst, A 0) ] in
    M.return instrs
  | LetIn (Nonrec, (PVar x, expr), inner_expr) ->
    let* code1 = gen_expr (T 0) expr in
    let* off = save_var_on_stack x in
    let* code2 = gen_expr dst inner_expr in
    M.return (code1 @ [ sd (T 0) (-off) fp ] @ code2)
  | _ -> failwith "gen_expr: not implemented"
;;

let gen_structure_item_anf : astr_item -> instr list M.t = function
  | Nonrec, ("main", e), [] ->
    let* body_code = gen_expr_anf (A 0) e in
    [ label "_start" ] @ body_code @ [ li (A 7) 94; ecall ] |> M.return
  | Nonrec, (f, ACExpr (CLambda (ImmVar x, body))), [] ->
    let* saved_off = M.get_frame_offset in
    let* () = M.set_frame_offset (saved_off + 16) in
    let* x_off = save_var_on_stack x in
    let* body_code = gen_expr_anf (A 0) body in
    let* locals = M.get_frame_offset in
    (* for ra and fp *)
    let frame = locals + (2 * word_size) in
    let* () = M.set_frame_offset saved_off in
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
    [ label f ] @ prologue @ body_code @ epilogue |> M.return
  | Nonrec, (name, (ACExpr _ as aexpr)), [] ->
    let* saved_off = M.get_frame_offset in
    let* () = M.set_frame_offset (saved_off + word_size) in
    let* x_off = save_var_on_stack name in
    let* body_code = gen_expr_anf (T 0) aexpr in
    [ addi Sp Sp (-word_size) ] @ body_code @ [ sd (T 0) (-x_off) fp ] |> M.return
  | _, (name, _), [] -> failwith (Format.asprintf "%s homka" name)
  | _ -> failwith "df"
;;

let gen_structure_item : structure_item -> instr list M.t = function
  | Rec, (PVar f, Lambda (PVar x, body)), [] ->
    let* saved_off = M.get_frame_offset in
    let* () = M.set_frame_offset 16 in
    let* x_off = save_var_on_stack x in
    let* body_code = gen_expr (A 0) body in
    let* locals = M.get_frame_offset in
    (* for ra and fp *)
    let frame = locals + (2 * word_size) in
    let* () = M.set_frame_offset saved_off in
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
    [ label f ] @ prologue @ body_code @ epilogue |> M.return
  | Nonrec, (PVar "main", e), [] ->
    let* body_code = gen_expr (A 0) e in
    body_code |> M.return
  | _ -> failwith "unsupported structure item"
;;

(* Get all top level let and reserve space at stack *)
let reserve_top_level (pr : aprogram) : unit M.t =
  let rec helper = function
    | [] -> M.return ()
    | (_, (name, _), []) :: tl when name <> "main" ->
      let* _ = M.save_var_on_stack name in
      helper tl
    | _ :: tl -> helper tl
  in
  helper pr
;;

let gen_lambda_code (pr : aprogram) : instr list M.t =
  let rec helper acc = function
    | [] -> M.return acc
    | (Nonrec, ("main", _), []) :: rest -> helper acc rest
    | (Nonrec, (_, ACExpr (CLambda (_, _))), []) :: rest -> helper acc rest
    | (Nonrec, (name, (ACExpr _ as aexpr)), []) :: rest ->
      let* code = gen_expr_anf (T 0) aexpr in
      let* loc = lookup name in
      (match loc with
       | Some (Stack off) ->
         let instrs = code @ [ sd (T 0) (-off) fp ] in
         helper (instrs @ acc) rest
       | _ -> failwith "expected stack slot for top-level")
    | _ -> failwith "unsupported top-level form"
  in
  helper [] pr
;;

let gen_top_level_inits (pr : aprogram) : instr list M.t =
  let rec helper acc = function
    | [] -> M.return acc
    | (Nonrec, ("main", _), []) :: rest -> helper acc rest
    | (Nonrec, (_, ACExpr (CLambda (_, _))), []) :: rest -> helper acc rest
    | (Nonrec, (name, (ACExpr _ as aexpr)), []) :: rest ->
      let* code = gen_expr_anf (T 0) aexpr in
      let* loc = lookup name in
      (match loc with
       | Some (Stack off) ->
         let instrs = code @ [ sd (T 0) (-off) fp ] in
         helper (instrs @ acc) rest
       | _ -> failwith "expected stack slot for top-level")
    | _ -> failwith "unsupported top-level form"
  in
  helper [] pr
;;

let gather_anf pr : instr list M.t =
  let* () = reserve_top_level pr in
  let* off = M.get_frame_offset in
  let prologue = [ label "_start"; addi Sp Sp (-off); addi fp Sp off ] in
  let* top_level_code = gen_top_level_inits pr in
  let* main_code =
    let rec helper = function
      | [] -> M.return []
      | (Nonrec, ("main", e), []) :: _ ->
        let* body = gen_expr_anf (A 0) e in
        M.return (body @ [ li (A 7) 94; ecall ])
      | _ :: tl -> helper tl
    in
    helper pr
  in
  prologue @ top_level_code @ main_code |> M.return
;;

let rec gather : program -> instr list M.t = function
  | [] -> M.return []
  | item :: rest ->
    let* code1 = gen_structure_item item in
    let* code2 = gather rest in
    M.return (code1 @ code2)
;;

let gen_program_anf (pr : aprogram) fmt =
  let open Format in
  fprintf fmt ".text\n";
  fprintf fmt ".globl _start\n";
  let _, code = M.run (gather_anf pr) M.default in
  Base.List.iter code ~f:(function
    | Label l -> fprintf fmt "%s:\n" l
    | i -> fprintf fmt "  %a\n" pp_instr i)
;;

let gen_program (pr : program) fmt =
  let open Format in
  fprintf fmt ".text\n";
  fprintf fmt ".globl _start\n";
  let _, code = M.run (gather pr) M.default in
  Base.List.iter code ~f:(function
    | Label l -> fprintf fmt "%s:\n" l
    | i -> fprintf fmt "  %a\n" pp_instr i)
;;
