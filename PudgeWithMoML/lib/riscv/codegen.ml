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
    let init = { env = Map.empty (module String); fresh = 0 } in
    m init
  ;;

  let fresh : string t =
    fun st -> "L" ^ Int.to_string st.fresh, { st with fresh = st.fresh + 1 }
  ;;

  let get_env : env t = fun st -> st.env, st
  let put_env env : unit t = fun st -> (), { st with env }
  let modify_env f : unit t = fun st -> (), { st with env = f st.env }

  let add_binding name loc : unit t =
    modify_env (fun env -> Map.set env ~key:name ~data:loc)
  ;;

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

let gen_infix_op dst

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
       @ [ Label l_end ])
  | Apply (Variable f, arg) ->
    let* arg_code = gen_expr (A 0) arg in
    let instrs =
      arg_code @ [ Call f ] @ (if dst = A 0 then [] else [ Mv (dst, A 0)]) in
    M.return instrs
  | _ -> failwith "gen_expr: not implemented"
;;

let gen_structure_item = function
  | Nonrec, [ (PVar f, Lambda (PVar x, body)) ] ->
    let env = Map.singleton (module String) x (A 0) in
    let body_code = gen_expr env (A 0) body in
    [ Label f ] @ body_code @ [ Ret ]
  | Nonrec, [ (PVar "main", e) ] ->
    let body_code = gen_expr (Map.empty (module String)) (A 0) e in
    [ Label "_start" ] @ body_code @ [ Ret ]
  | _ -> failwith "unsupported structure item"
;;
