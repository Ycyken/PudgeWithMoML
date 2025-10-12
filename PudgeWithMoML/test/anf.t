(fac)
  $ ./run_anf.exe <<'EOF'
  > let rec fac n = if n <= 1 then 1 else n * fac (n-1)
  > 
  > let main = fac 4
  let rec fac__0 = fun n__1 ->
  let anf_t1 = n__1 <= 1 in
  if anf_t1 then (1)
  else let anf_t2 = n__1 - 1 in
  let anf_t3 = fac__0 anf_t2 in
  let anf_t4 = n__1 * anf_t3 in
  anf_t4 
  
  let main__2 = fac__0 4 

(fib)
  $ ./run_anf.exe <<'EOF'
  > let rec fib n =
  > if n<2
  > then n
  > else fib (n - 1) + fib (n - 2) 
  let rec fib__0 = fun n__1 ->
  let anf_t0 = n__1 < 2 in
  if anf_t0 then (n__1)
  else let anf_t1 = n__1 - 1 in
  let anf_t2 = fib__0 anf_t1 in
  let anf_t3 = n__1 - 2 in
  let anf_t4 = fib__0 anf_t3 in
  let anf_t5 = anf_t2 + anf_t4 in
  anf_t5 

(nested letin)
  $ ./run_anf.exe <<'EOF'
  > let main = let x = 1 + 2 in let y = 3 - 4 + 1 in x * y
  let main__0 = let anf_t3 = 1 + 2 in
  let x__1 = anf_t3 in
  let anf_t1 = 3 - 4 in
  let anf_t2 = anf_t1 + 1 in
  let y__2 = anf_t2 in
  let anf_t0 = x__1 * y__2 in
  anf_t0 

(sum)
  $ ./run_anf.exe <<'EOF'
  > let sum x y = x + y
  > 
  > let main = sum (1 + 2) (3 - 4)
  let sum__0 = fun x__1 ->
  fun y__2 ->
  x__1 + y__2 
  
  let main__3 = let anf_t0 = 1 + 2 in
  let anf_t1 = sum__0 anf_t0 in
  let anf_t2 = 3 - 4 in
  let anf_t3 = anf_t1 anf_t2 in
  anf_t3 


