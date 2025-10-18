[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

open Angstrom
open Ast
open Base
open TypedTree
open Keywords

(* TECHNICAL FUNCTIONS *)

let is_ws = function
  | ' ' -> true
  | '\n' -> true
  | '\t' -> true
  | '\r' -> true
  | _ -> false
;;

let skip_ws = skip_while is_ws
let p_parens p = skip_ws *> char '(' *> skip_ws *> p <* skip_ws <* char ')'

let peek_sep1 =
  peek_char
  >>= function
  | None -> return None
  | Some c ->
    (match c with
     | '(' | ')' | '[' | ']' | ';' | ':' | ',' -> return (Some c)
     | _ -> if is_ws c then return (Some c) else fail "need a delimiter")
;;

let skip_ws_sep1 = peek_sep1 *> skip_ws

let chainl1 e op =
  let rec go acc = lift2 (fun f x -> f acc x) op e >>= go <|> return acc in
  e >>= go
;;

let rec chainr1 e op =
  let* left = e in
  (let* f = op in
   let* right = chainr1 e op in
   return (f left right))
  <|> return left
;;

let rec unary_chain op e =
  op >>= (fun unexpr -> unary_chain op e >>= fun expr -> return (unexpr expr)) <|> e
;;

(* SIMPLE PARSERS *)
let expr_const p = p >>| fun lit -> Const lit
let pat_const p = p >>| fun lit -> PConst lit

let p_int =
  skip_ws
  *> let* sign = option "" (string "+" <|> string "-") in
     let* number = take_while1 Char.is_digit in
     Int.of_string (sign ^ number) |> return
;;

let p_int_expr = expr_const (p_int >>| fun x -> Int_lt x)
let p_int_pat = pat_const (p_int >>| fun x -> Int_lt x)

let p_bool =
  skip_ws *> string "true"
  <|> skip_ws *> string "false"
  >>| fun s -> Bool_lt (Bool.of_string s)
;;

let p_bool_expr = expr_const p_bool
let p_bool_pat = pat_const p_bool
let p_unit = skip_ws *> string "(" *> skip_ws *> string ")" *> return Unit_lt
let p_unit_expr = expr_const p_unit
let p_unit_pat = pat_const p_unit

let p_oper =
  let* oper = skip_ws *> take_while1 (String.contains op_chars) in
  if is_keyword oper
  then fail "keywords are not allowed as variable names"
  else return oper
;;

let p_varname =
  let p_fst_letter =
    take_while1 (function
      | 'a' .. 'z' | '_' -> true
      | _ -> false)
  in
  let* name =
    skip_ws
    *> lift2
         ( ^ )
         p_fst_letter
         (take_while (function
            | 'a' .. 'z' | 'A' .. 'Z' | '_' | '0' .. '9' -> true
            | _ -> false))
  in
  if is_keyword name
  then fail "keywords are not allowed as variable names"
  else return name
;;

let p_var_expr = p_varname >>| fun ident -> Variable ident
let p_var_pat = p_varname >>| fun ident -> PVar ident
let p_oper_expr = p_parens p_oper >>| fun s -> Variable s
let p_oper_pat = p_parens p_oper >>| fun s -> PVar s
let p_wild_pat = skip_ws *> string "_" *> return Wild
let p_pat_atom = choice [ p_int_pat; p_bool_pat; p_unit_pat; p_var_pat; p_wild_pat ]
let p_expr_atom = choice [ p_var_expr; p_oper_expr; p_int_expr; p_unit_expr; p_bool_expr ]

(* COMPLEX PARSERS *)

let p_type_primitive = skip_ws *> p_varname >>| fun s -> Primitive s

let p_type_var =
  skip_ws
  *> char '\''
  *> let* n = p_int in
     return (Type_var n)
;;

let p_suffix_type =
  choice
    [ skip_ws *> string "list" *> return (fun t -> Type_list t)
    ; skip_ws *> string "option" *> return (fun t -> TOption t)
    ]
;;

let chain_postfix term suffix =
  term
  >>= fun t0 -> many suffix >>| fun sl -> List.fold sl ~init:t0 ~f:(fun acc f -> f acc)
;;

let p_type =
  skip_ws
  *> string ":"
  *> fix (fun self ->
    let atom = choice [ p_type_primitive; p_type_var; p_parens self ] in
    let list_option = chain_postfix atom p_suffix_type in
    let tuple =
      list_option
      >>= fun fst ->
      many (skip_ws *> string "*" *> list_option)
      >>| function
      | [] -> fst
      | snd :: rest -> Type_tuple (fst, snd, rest)
    in
    let arrow =
      chainr1 tuple (skip_ws *> string "->" *> return (fun t1 t2 -> Arrow (t1, t2)))
    in
    arrow)
;;

let p_semicolon_list p_elem =
  skip_ws
  *> string "["
  *> skip_ws
  *> let+ list = sep_by (skip_ws *> string ";") p_elem <* skip_ws <* string "]" in
     list
;;

let p_semicolon_list_expr p_expr = p_semicolon_list p_expr >>| fun l -> List l
let p_semicolon_list_pat p_pat = p_semicolon_list p_pat >>| fun l -> PList l

let p_cons_list_pat p_pat =
  chainr1 p_pat (skip_ws *> string "::" *> return (fun l r -> PCons (l, r)))
;;

let uminus = skip_ws *> (string "-" <|> string "~-") *> return euminus

let p_tuple make p =
  let tuple =
    let* fst = p in
    let* snd = skip_ws *> string "," *> p in
    let* rest = many (skip_ws *> string "," *> p) in
    return (make fst snd rest)
  in
  tuple <|> p_parens tuple
;;

let p_tuple_expr p_expr = p_tuple (fun e1 e2 rest -> Tuple (e1, e2, rest)) p_expr
let p_tuple_pat p_pat = p_tuple (fun p1 p2 rest -> PTuple (p1, p2, rest)) p_pat

let p_if p_expr =
  lift3
    (fun cond th el -> If_then_else (cond, th, el))
    (skip_ws *> string "if" *> peek_sep1 *> p_expr)
    (skip_ws *> string "then" *> peek_sep1 *> p_expr)
    (skip_ws
     *> string "else"
     *> peek_sep1
     *> (p_expr <* peek_sep1 >>= fun e -> return (Some e))
     <|> return None)
;;

let p_option p make_option =
  skip_ws *> string "None" *> peek_sep1 *> return (make_option None)
  <|> let+ inner = skip_ws *> string "Some" *> peek_sep1 *> p in
      make_option (Some inner)
;;

let p_option_expr p = p_option p (fun e -> Option e)
let p_option_pat p = p_option p (fun e -> POption e)

let p_constraint_pat p_pat =
  let* pat = p_pat in
  let* typ = p_type in
  return (PConstraint (pat, typ))
;;

let p_pat =
  skip_ws
  *> fix (fun self ->
    let atom =
      choice [ p_pat_atom; p_oper_pat; p_parens self; p_parens (p_constraint_pat self) ]
    in
    let semicolon_list = p_semicolon_list_pat (self <|> atom) <|> atom in
    let opt = p_option_pat semicolon_list <|> semicolon_list in
    let cons = p_cons_list_pat opt in
    let tuple = p_tuple_pat cons <|> cons in
    tuple)
;;

let p_binding p_expr : binding t =
  let* name = p_pat in
  let* args = many p_pat in
  let* body = skip_ws *> string "=" *> p_expr in
  match name, args with
  | PVar _, args -> return (name, elambda body args)
  | _, args when List.length args <> 0 ->
    fail "Args in let bind are only allowed when binding a variable name "
  | _ -> return (name, elambda body args)
;;

let p_letin p_expr =
  skip_ws
  *> string "let"
  *> skip_ws_sep1
  *>
  let* rec_flag = string "rec" *> peek_sep1 *> return Rec <|> return Nonrec in
  let* bind = p_binding p_expr in
  let* inner_expr = skip_ws *> string "in" *> peek_sep1 *> p_expr in
  LetIn (rec_flag, bind, inner_expr) |> return
;;

let p_apply p_expr self =
  chainl1
    (p_parens (p_expr <|> self) <|> (p_expr <* peek_sep1))
    (return (fun expr1 expr2 -> Apply (expr1, expr2)))
;;

let p_lambda p_expr =
  skip_ws
  *> string "fun"
  *> peek_sep1
  *>
  let* arg1 = p_pat in
  let* args = many p_pat <* skip_ws <* string "->" in
  let* body = p_expr in
  return (elambda body (arg1 :: args))
;;

let p_case p_expr =
  let* pat = skip_ws *> string "|" *> p_pat <* skip_ws <* string "->" in
  let* expr = p_expr in
  return (pat, expr)
;;

let p_first_case p_expr =
  let* pat = skip_ws *> (string "|" *> p_pat <|> p_pat) <* skip_ws <* string "->" in
  let* expr = p_expr in
  return (pat, expr)
;;

let p_match p_expr =
  let* value = skip_ws *> string "match" *> p_expr <* skip_ws <* string "with" in
  let* pat1, expr1 = p_first_case p_expr in
  let* cases = many (p_case p_expr) in
  Match (value, (pat1, expr1), cases) |> return
;;

let p_function p_expr =
  skip_ws
  *> string "function"
  *>
  let* pat1, expr1 = p_first_case p_expr in
  let* cases = many (p_case p_expr) in
  Function ((pat1, expr1), cases) |> return
;;

let p_constraint_expr p_expr =
  let* expr = p_expr in
  let* typ = p_type in
  EConstraint (expr, typ) |> return
;;

let infix_op (op, func) = skip_ws *> string op *> return func

type associativity =
  | L
  | R
[@@deriving eq]

let infix_precedence_list =
  let default =
    [ [ "*", emul; "/", ediv ], L
    ; [ "+", eadd; "-", esub ], L
    ; [ "::", econs ], R
    ; [ "=", eeq; ">=", egte; ">", egt; "<=", elte; "<", elt; "<>", eneq ], L
    ; [ "&&", eland ], L
    ; [ "||", elor ], L
    ]
    |> List.map ~f:(fun (l, assoc) -> List.map l ~f:infix_op, assoc)
  in
  let custom = [ [ (p_oper >>| fun s -> eapp2 (Variable s)) ], L ] in
  default @ custom
;;

let p_infix_expr p_expr =
  fix (fun self ->
    let atom = p_expr <|> p_parens self in
    List.fold_left infix_precedence_list ~init:atom ~f:(fun acc (ops, assoc) ->
      match assoc with
      | L -> chainl1 acc (choice ops)
      | R -> chainr1 acc (choice ops)))
;;

let p_expr =
  skip_ws
  *> fix (fun self ->
    let simple =
      fix (fun simple ->
        let atom =
          choice
            [ p_expr_atom
            ; p_parens self
            ; p_semicolon_list_expr self
            ; p_parens (p_constraint_expr self)
            ]
        in
        let option = p_option_expr simple <|> atom in
        option)
    in
    let heavy =
      choice [ p_if self; p_letin self; p_function self; p_match self; p_lambda self ]
    in
    let apply = p_apply simple self <|> simple <|> heavy in
    let unary = unary_chain uminus apply in
    let infix = p_infix_expr unary in
    let tuple = p_tuple_expr infix <|> infix in
    tuple)
;;

let str_item : structure_item t =
  skip_ws
  *> string "let"
  *> skip_ws_sep1
  *>
  let* rec_flag = string "rec" *> peek_sep1 *> return Rec <|> return Nonrec in
  let* bind = p_binding p_expr in
  let* binds_rest = many (skip_ws *> string "and" *> peek_sep1 *> p_binding p_expr) in
  let* () = option () (skip_ws <* string ";;") in
  return (rec_flag, bind, binds_rest)
;;

let program : program t = many1 str_item <* skip_ws
let parse (str : string) = parse_string ~consume:All program str
