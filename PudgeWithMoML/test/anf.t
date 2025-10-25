(fact)
  $ make compile opts=-anf --no-print-directory -C .. << 'EOF'
  > let rec fac n = if n <= 1 then 1 else n * fac (n-1)
  > 
  > let main = fac 4
  > EOF
  > cat ../main.anf
  let rec fac__0 = fun n__1 ->
    let anf_t1 = n__1 <= 1 in
    if anf_t1 then (1)
    else let anf_t2 = n__1 - 1 in
    let anf_t3 = fac__0 anf_t2 in
    n__1 * anf_t3 
  
  
  let main__2 = fac__0 4 

(fact v3)
  $ make compile opts=-anf --no-print-directory -C .. << 'EOF'
  > let id x = x
  > let fresh_1 n k p = k (p * n)
  > 
  > let rec fac_cps n k =
  >   if n = 1
  >   then k 1
  >   else fac_cps (n-1) (fresh_1 n k)
  > 
  > let main =
  >   let _ = print_int (fac_cps 4 id) in
  >   0
  > EOF
  > cat ../main.anf
  let id__0 = fun x__1 ->
    x__1 
  
  
  let fresh_1__2 = fun n__3 ->
    fun k__4 ->
    fun p__5 ->
    let anf_t7 = p__5 * n__3 in
    k__4 anf_t7 
  
  
  let rec fac_cps__6 = fun n__7 ->
    fun k__8 ->
    let anf_t2 = n__7 = 1 in
    if anf_t2 then (k__8 1)
    else let anf_t4 = n__7 - 1 in
    let anf_t5 = fresh_1__2 n__7 k__8 in
    fac_cps__6 anf_t4 anf_t5 
  
  
  let main__9 = let anf_t0 = fac_cps__6 4 id__0 in
    let anf_t1 = print_int anf_t0 in
    0 

(add)
  $ make compile opts=-anf --no-print-directory -C .. << 'EOF'
  > let add x y = x + y
  > let main = add 5 2
  > EOF
  > cat ../main.anf
  let add__0 = fun x__1 ->
    fun y__2 ->
    x__1 + y__2 
  
  
  let main__3 = add__0 5 2 

(nested letin)
  $ make compile opts=-anf --no-print-directory -C .. << 'EOF'
  > let main = let x = 1 + 2 in let y = 3 - 4 + 1 in x * y
  > EOF
  >  cat ../main.anf
  let main__0 = let anf_t3 = 1 + 2 in
    let x__1 = anf_t3 in
    let anf_t1 = 3 - 4 in
    let anf_t2 = anf_t1 + 1 in
    let y__2 = anf_t2 in
    x__1 * y__2 

(sum)
  $ make compile opts=-anf --no-print-directory -C .. << 'EOF'
  > let sum x y = x + y
  > 
  > let main = sum (1 + 2) (3 - 4)
  > EOF
  > cat ../main.anf
  let sum__0 = fun x__1 ->
    fun y__2 ->
    x__1 + y__2 
  
  
  let main__3 = let anf_t0 = 1 + 2 in
    let anf_t1 = 3 - 4 in
    sum__0 anf_t0 anf_t1 

  $ make compile opts=-anf --no-print-directory -C .. << 'EOF'
  > let x = let y = 1 + 2 in y
  > EOF
  > cat ../main.anf
  let x__0 = 1 + 2 

(wildcard)
  $ make compile opts=-anf --no-print-directory -C .. << 'EOF'
  > let _ = 5
  > EOF
  > 
  > cat ../main.anf
  let _ = 5 

  $ make compile opts=-anf --no-print-directory -C .. << 'EOF'
  > let main = let _ = print_int 4 in let _ = print_int 3 in 0
  > EOF
  > cat ../main.anf
  let main__0 = let anf_t1 = print_int 4 in
    let anf_t0 = print_int 3 in
    0 
