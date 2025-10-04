(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

open Angstrom
open Ast
open Base
open TypedTree

(* TECHNICAL FUNCTIONS *)

let is_ws = function
  | ' ' -> true
  | '\n' -> true
  | '\t' -> true
  | '\r' -> true
  | _ -> false
;;

let skip_ws = skip_while is_ws

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

let is_keyword = function
  | "if"
  | "then"
  | "else"
  | "let"
  | "in"
  | "not"
  | "true"
  | "false"
  | "fun"
  | "match"
  | "with"
  | "and"
  | "Some"
  | "None"
  | "function"
  | "->"
  | "|"
  | ":"
  | "::"
  | "_" -> true
  | _ -> false
;;

(* SIMPLE PARSERS *)
let expr_const_factory parser = parser >>| fun lit -> Const lit
let pat_const_factory parser = parser >>| fun lit -> PConst lit

let p_int =
  skip_ws
  *> let* sign = string "+" <|> string "-" <|> string "" in
     let* number = take_while1 Char.is_digit in
     return (Int_lt (Int.of_string (sign ^ number)))
;;

let p_int_expr = expr_const_factory p_int
let p_int_pat = pat_const_factory p_int

let p_bool =
  skip_ws *> string "true"
  <|> skip_ws *> string "false"
  >>| fun s -> Bool_lt (Bool.of_string s)
;;

let p_bool_expr = expr_const_factory p_bool
let p_bool_pat = pat_const_factory p_bool
let p_unit = skip_ws *> string "(" *> skip_ws *> string ")" *> return Unit_lt
let p_unit_expr = expr_const_factory p_unit
let p_unit_pat = pat_const_factory p_unit

let p_oper =
  let* oper =
    skip_ws
    *> take_while1 (function
      | '+'
      | '-'
      | '<'
      | '>'
      | '*'
      | '|'
      | '!'
      | '$'
      | '%'
      | '&'
      | '.'
      | '/'
      | ':'
      | '='
      | '?'
      | '@'
      | '^'
      | '~' -> true
      | _ -> false)
  in
  if is_keyword oper
  then fail "keywords are not allowed as variable names"
  else return (PVar oper)
;;

let p_ident =
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

let p_type = skip_ws *> char ':' *> skip_ws *> p_ident >>| fun s -> Primitive s
let p_var_expr = p_ident >>| fun ident -> Variable ident
let p_var_pat = p_ident >>| fun ident -> PVar ident

let p_semicolon_list p_elem =
  skip_ws
  *> string "["
  *> skip_ws
  *> let+ list =
       fix (fun p_semi_list ->
         choice
           [ (let* hd = p_elem <* skip_ws <* string ";" in
              let* tl = p_semi_list in
              return (hd :: tl))
           ; (let* hd = p_elem <* skip_ws <* string "]" in
              return [ hd ])
           ; skip_ws *> string "]" *> return []
           ])
     in
     list
;;

let p_semicolon_list_expr p_expr = p_semicolon_list p_expr >>| fun l -> List l
let p_semicolon_list_pat p_pat = p_semicolon_list p_pat >>| fun l -> PList l

let p_cons_list_pat p_pat =
  chainr1 p_pat (skip_ws *> string "::" *> return (fun l r -> PCons (l, r)))
;;

(* EXPR PARSERS *)
let p_parens p = skip_ws *> char '(' *> skip_ws *> p <* skip_ws <* char ')'
let uminus = skip_ws *> string "-" *> return euminus

let p_tuple make p =
  let tuple =
    let* fst = p <* skip_ws <* string "," in
    let* snd = p in
    let* rest = many (skip_ws *> string "," *> p) in
    return (make fst snd rest)
  in
  p_parens tuple <|> tuple
;;

let make_tuple_expr e1 e2 rest = Tuple (e1, e2, rest)
let make_tuple_pat p1 p2 rest = PTuple (p1, p2, rest)
let p_tuple_pat p_pat = p_tuple make_tuple_pat p_pat

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

let make_option_expr expr = Option expr
let make_option_pat pat = POption pat
let p_wild_pat = skip_ws *> string "_" *> return Wild
let p_pat_const = choice [ p_int_pat; p_bool_pat; p_unit_pat; p_var_pat; p_wild_pat ]

let p_constraint_pat p_pat =
  let* pat = p_pat in
  let* typ = p_type in
  return (PConstraint (pat, typ))
;;

let p_pat =
  skip_ws
  *> fix (fun self ->
    let atom =
      choice
        [ p_pat_const; p_parens p_oper; p_parens self; p_parens (p_constraint_pat self) ]
    in
    let semicolon_list = p_semicolon_list_pat (self <|> atom) <|> atom in
    let opt = p_option semicolon_list make_option_pat <|> semicolon_list in
    let cons = p_cons_list_pat opt in
    let tuple = p_tuple_pat cons <|> cons in
    tuple)
;;

let p_binding p_expr : binding t =
  let* name = p_pat in
  let* args = many p_pat in
  let* body = skip_ws *> string "=" *> p_expr in
  return (name, elambda body args)
;;

let p_letin p_expr =
  skip_ws
  *> string "let"
  *> skip_ws_sep1
  *>
  let* rec_flag = string "rec" *> peek_sep1 *> return Rec <|> return Nonrec in
  let* bind1 = p_binding p_expr in
  let* binds_rest = many (skip_ws *> string "and" *> peek_sep1 *> p_binding p_expr) in
  let* inner_expr = skip_ws *> string "in" *> peek_sep1 *> p_expr in
  return (LetIn (rec_flag, bind1 :: binds_rest, inner_expr))
;;

let p_apply p_expr =
  chainl1
    (p_parens p_expr <|> (p_expr <* peek_sep1))
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
  return (Match (value, (pat1, expr1), cases))
;;

let p_function p_expr =
  skip_ws
  *> string "function"
  *>
  let* pat1, expr1 = p_first_case p_expr in
  let* cases = many (p_case p_expr) in
  return (Function ((pat1, expr1), cases))
;;

let p_constraint_expr p_expr =
  let* expr = p_expr in
  let* typ = p_type in
  return (EConstraint (expr, typ))
;;

let infix_op (op, func) = skip_ws *> string op *> return func

let infix_precedence_list =
  [ [ "*", emul; "/", ediv ]
  ; [ "+", eadd; "-", esub ]
  ; [ "::", econs ]
  ; [ "=", eeq; ">=", egte; ">", egt; "<=", elte; "<", elt; "<>", eneq ]
  ; [ "&&", eland ]
  ; [ "||", elor ]
  ]
  |> List.map ~f:(List.map ~f:infix_op)
;;

let p_infix_expr p_expr =
  fix (fun self ->
    let atom = p_expr <|> p_parens self in
    List.fold_left infix_precedence_list ~init:atom ~f:(fun acc ops ->
      chainl1 acc (choice ops)))
;;

let p_expr =
  skip_ws
  *> fix (fun self ->
    let atom =
      choice
        [ p_var_expr
        ; p_int_expr
        ; p_unit_expr
        ; p_bool_expr
        ; p_parens self
        ; p_semicolon_list_expr self
        ; p_parens (p_constraint_expr self)
        ]
    in
    let if_expr = p_if (self <|> atom) <|> atom in
    let letin_expr = p_letin (self <|> if_expr) <|> if_expr in
    let option = p_option letin_expr make_option_expr <|> letin_expr in
    let apply = p_apply option <|> option in
    let unary = unary_chain uminus apply in
    let infix = p_infix_expr unary in
    let tuple = p_tuple make_tuple_expr infix <|> infix in
    let p_function = p_function (self <|> tuple) <|> tuple in
    let ematch = p_match (self <|> p_function) <|> p_function in
    let efun = p_lambda (self <|> ematch) <|> ematch in
    efun)
;;

let str_item : structure_item t =
  skip_ws
  *> string "let"
  *> skip_ws_sep1
  *>
  let* rec_flag = string "rec" *> peek_sep1 *> return Rec <|> return Nonrec in
  let* bind1 = p_binding p_expr in
  let* binds_rest = many (skip_ws *> string "and" *> peek_sep1 *> p_binding p_expr) in
  return (rec_flag, bind1 :: binds_rest)
;;

let program : program t = many1 str_item <* skip_ws
let parse (str : string) = parse_string ~consume:All program str
