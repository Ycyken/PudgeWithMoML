[@@@ocaml.text "/*"]

(** Copyright 2023-2024, Kakadu and contributors *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

(* run this test via `dune test  --force` *)

module AST = struct
  type t =
    | Const of (int[@gen QCheck.Gen.return 1])
    | Add of t * t
  [@@deriving qcheck, show { with_path = false }]
end

module PP = struct
  let rec pp ppf = function
    | AST.Const n -> Format.fprintf ppf "%d" n
    (* | Add (l, r) -> Format.fprintf ppf "%a+%a" pp l pp r *)
    | Add (l, r) -> Format.fprintf ppf "(%a+%a)" pp l pp r
  ;;
end

module Parser = struct
  open Angstrom

  let prio expr table =
    let len = Array.length table in
    let rec helper level =
      if level >= len
      then expr
      else (
        let xs = table.(level) in
        return (List.fold_left (fun acc (op, r) -> op acc r))
        <*> helper (level + 1)
        <*> many
              (choice
                 (List.map
                    (fun (op, f) -> op *> helper (level + 1) >>= fun r -> return (f, r))
                    xs)))
    in
    helper 0
  ;;

  let expr_small =
    let code0 = Char.code '0' in
    Angstrom.satisfy (function
      | '0' .. '9' -> true
      | _ -> false)
    >>| fun c -> AST.Const (Char.code c - code0)
  ;;

  let expr =
    fix (fun self ->
      let add a b = AST.Add (a, b) in
      prio (expr_small <|> (char '(' *> self <* char ')')) [| [ char '+', add ] |])
  ;;
end

let rec shrink_expr =
  let open QCheck.Iter in
  (* fun _ -> empty *)
  function
  | AST.Const _ -> empty
  | Add (l, r) ->
    of_list [ l; r ]
    <+> (shrink_expr l >>= fun l -> return (AST.Add (l, r)))
    <+> (shrink_expr r >>= fun r -> return (AST.Add (l, r)))
;;

let arbitrary_expr =
  (* let open QCheck.Iter in *)
  QCheck.make AST.gen ~print:(Format.asprintf "%a" PP.pp) ~shrink:shrink_expr
;;

let _ =
  QCheck_runner.run_tests
    [ QCheck.(
        Test.make arbitrary_expr (fun l ->
          match
            Angstrom.parse_string
              ~consume:Angstrom.Consume.All
              Parser.expr
              (Format.asprintf "%a" PP.pp l)
          with
          | Result.Ok after when after = l -> true
          | Result.Ok after ->
            Format.printf "before : %a\n%!" AST.pp l;
            (* Format.printf "       : `%a`\n%!" PP.pp l; *)
            Format.printf "`%a`\n%!" AST.pp after;
            false
          | Result.Error _ ->
            (* Format.printf "failed on : %a\n%!" Lam.pp l; *)
            false))
    ]
;;
