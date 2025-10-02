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
