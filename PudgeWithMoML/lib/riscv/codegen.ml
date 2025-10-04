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
    ; free_s : int (* free s register *)
    ; free_t : int (* free t register *)
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
    let init = { env = Map.empty (module String); free_s = 1; free_t = 0; fresh = 0 } in
    m init
  ;;

  let fresh : string t =
    fun st -> "L" ^ Int.to_string st.fresh, { st with fresh = st.fresh + 1 }
  ;;

  let free_s : reg t =
    fun st ->
    if st.free_s > 11
    then failwith "ran out of s registers"
    else S st.free_s, { st with free_s = st.free_s + 1 }
  ;;

  let free_t : reg t =
    fun st ->
    if st.free_t > 6
    then failwith "ran out of t registers"
    else T st.free_t, { st with free_t = st.free_t + 1 }
  ;;

  let liberate_t : unit t = fun st -> (), { st with free_t = 0 }
  let get_env : env t = fun st -> st.env, st
  let put_env env : unit t = fun st -> (), { st with env }
  let modify_env f : unit t = fun st -> (), { st with env = f st.env }

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

let rec gen_expr dst e : instr list M.t =
  match e with
  | Const lt ->
    let imm = imm_of_literal lt in
    M.return [ li dst imm ]
  | Variable x ->
    let* loc = M.lookup x in
    (match loc with
     | Some (Reg r) when r = dst -> M.return []
     | Some (Reg r) -> M.return [ mv dst r ]
     | Some (Stack off) ->
       let* () = M.add_binding x (Reg dst) in
       M.return [ ld dst off Sp ]
     | _ -> failwith ("unbound variable: " ^ x))
  | If_then_else (c, th, Some el) ->
    let* s = M.free_s in
    let* cond_code = gen_expr s c in
    let* then_code = gen_expr dst th in
    let* else_code = gen_expr dst el in
    let* l_else = M.fresh in
    let* l_end = M.fresh in
    M.return
      (cond_code
       @ [ beq s Zero l_else ]
       @ then_code
       @ [ j l_end; label l_else ]
       @ else_code
       @ [ label l_end ])
  | Apply (Apply (Variable op, e1), e2) when List.mem op [ "<="; "+"; "-"; "*" ] ->
    let* t0 = M.free_t in
    let* t1 = M.free_t in
    let* c1 = gen_expr t0 e1 in
    let* c2 = gen_expr t1 e2 in
    (match op with
     | "<=" -> M.return (c1 @ c2 @ [ slt dst t1 t0; xori dst dst 1 ])
     | "+" -> M.return (c1 @ c2 @ [ add dst t0 t1 ])
     | "-" -> M.return (c1 @ c2 @ [ sub dst t0 t1 ])
     | "*" -> M.return (c1 @ c2 @ [ mul dst t0 t1 ])
     | _ -> failwith ("unsupported infix operator: " ^ op))
  | Apply (Variable f, arg) ->
    let* arg_code = gen_expr (A 0) arg in
    let instrs = arg_code @ [ Call f ] @ if dst = A 0 then [] else [ Mv (dst, A 0) ] in
    M.return instrs
  | _ -> failwith "gen_expr: not implemented"
;;

let gen_structure_item str_item : instr list M.t =
  match str_item with
  | Rec, [ (PVar f, Lambda (PVar x, body)) ] ->
    let* body_code =
      let* () = M.add_binding x (Reg (A 0)) in
      gen_expr (A 0) body
    in
    M.return ([ label f ] @ body_code @ [ Ret ])
  | Nonrec, [ (PVar "main", e) ] ->
    let* body_code = gen_expr (A 0) e in
    M.return ([ label "_start" ] @ body_code @ [ li (A 7) 94; ecall ])
  | _ -> failwith "unsupported structure item"
;;

let rec gather pr : instr list M.t =
  match pr with
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
