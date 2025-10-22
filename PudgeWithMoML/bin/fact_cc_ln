let id x = x
let fresh_1 n k p = k (p * n)

let rec fac_cps n k =
  if n = 1
  then k 1
  else fac_cps (n-1) (fresh_1 n k)

let main =
  let _ = print_int (fac_cps 4 id) in
  0