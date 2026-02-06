(* TEST
 compile_only = "true";
 flambda2;
 setup-ocamlopt.byte-build-env;
 ocamlopt.byte with check_raw, check_simplify;
 check_fexpr_dump;
*)

type t =
  | A
  | B of int
  | C of int

let f () =
  let x = A in
  match x with A -> 0 | B _ -> 1 | C _ -> 2
