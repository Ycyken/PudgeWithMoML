let id x = x
let fresh_2 p1 k p2 =
  k (p1 + p2)

let fresh_1 n k fib p1 =
  fib (n-2) (fresh_2 p1 k)

let rec fib n k =
  if n < 2
  then k n
  else fib (n - 1) (fresh_1 n k fib)

let main =
  let z = print_int (fib 6 id)  in
  0
