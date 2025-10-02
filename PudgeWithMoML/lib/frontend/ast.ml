open TypedTree

type ident = string (** identifier *) [@@deriving show { with_path = false }]

type literal =
  | Int_lt of int (** [0], [1], [30] *)
  | Bool_lt of bool (** [false], [true] *)
  | String_lt of string (** ["Hello world"] *)
  | Unit_lt (** [()] *)
[@@deriving show { with_path = false }]

type pattern =
  | Wild (** [_] *)
  | PList of pattern list (**[ [], [1;2;3] ] *)
  | PCons of pattern * pattern (**[ hd :: tl ] *)
  | PTuple of pattern * pattern * pattern list (** | [(a, b)] -> *)
  | PConst of literal (** | [4] -> *)
  | PVar of ident (** | [x] -> *)
  | POption of pattern option
  | PConstraint of pattern * typ
[@@deriving show { with_path = false }]

type is_recursive =
  | Nonrec (** let factorial n = ... *)
  | Rec (** let rec factorial n = ... *)
[@@deriving show { with_path = false }]

and expr =
  | Const of literal
  | Tuple of expr * expr * expr list
  | List of expr list
  | Variable of ident
  | If_then_else of expr * expr * expr option
  | Lambda of pattern * expr
  | Apply of expr * expr
  | Function of case * case list (** [function | p1 -> e1 | p2 -> e2 | ... |]*)
  | Match of expr * case * case list (** [match x with | p1 -> e1 | p2 -> e2 | ...] *)
  | Option of expr option
  | EConstraint of expr * typ
  | LetIn of is_recursive * pattern * expr * expr
[@@deriving show { with_path = false }]

and binding = pattern * expr [@@deriving show { with_path = false }]
and case = pattern * expr [@@deriving show { with_path = false }]

type structure_item = is_recursive * binding list [@@deriving show { with_path = false }]
type structure = structure_item list [@@deriving show { with_path = false }]


let eapp func args = Base.List.fold_left args ~init:func ~f:(fun acc arg -> Apply (acc, arg))

let eq a b = eapp (Variable ("=")) [ a; b ]
let neq a b = eapp (Variable ("<>")) [ a; b ]
let lt a b = eapp (Variable ("<")) [ a; b ]
let lte a b = eapp (Variable ("<=")) [ a; b ]
let gt a b = eapp (Variable (">")) [ a; b ]
let gte a b = eapp (Variable (">=")) [ a; b ]
let add a b = eapp (Variable ("+")) [ a; b ]
let sub a b = eapp (Variable ("-")) [ a; b ]
let mul a b = eapp (Variable ("*")) [ a; b ]
let div a b = eapp (Variable ("/")) [ a; b ]
let eland a b = eapp (Variable ("&&")) [ a; b ]
let elor a b = eapp (Variable ("||")) [ a; b ]
let cons a b = eapp (Variable ("::")) [ a; b ]

let uminus a = eapp (Variable ("-")) [ a ]
let unot a = eapp (Variable ("not")) [ a ]
