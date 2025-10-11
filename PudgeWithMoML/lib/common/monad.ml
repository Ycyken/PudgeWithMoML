[@@@ocaml.text "/*"]

(** Copyright 2025-2026, Gleb Nasretdinov, Ilhom Kombaev *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

[@@@ocaml.text "/*"]

module type Monad = sig
  type 'a t

  val return : 'a -> 'a t
  val ( >>= ) : 'a t -> ('a -> 'b t) -> 'b t
  val ( >>| ) : 'a t -> ('a -> 'b) -> 'b t
  val ( let* ) : 'a t -> ('a -> 'b t) -> 'b t
  val ( let+ ) : 'a t -> ('a -> 'b) -> 'b t
end

module type State = sig
  include Monad

  type state

  val get : state t
  val put : state -> state t
  val modify : (state -> state) -> unit t
  val run : 'a t -> state -> state * 'a
end

module State (S : sig
    type state
  end) : State with type state = S.state = struct
  type state = S.state
  type 'a t = state -> state * 'a

  let return v st = st, v

  let ( >>= ) m f st =
    let s1, v = m st in
    f v s1
  ;;

  let ( >>| ) m f = m >>= fun x -> return (f x)
  let ( let* ) = ( >>= )
  let ( let+ ) = ( >>| )
  let get s = s, s
  let put s v = s, v

  let modify f =
    let* s = get in
    put (f s) >>| fun _ -> ()
  ;;

  let run m = m
end

module Counter = State (struct
    type state = int
  end)
