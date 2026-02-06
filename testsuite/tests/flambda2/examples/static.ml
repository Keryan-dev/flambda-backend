(* TEST
 compile_only = "true";
 flambda2;
 setup-ocamlopt.byte-build-env;
 ocamlopt.byte with check_simplify;
 check_fexpr_dump;
*)

let f x l =
  let g b = if b then x else 42 in
  let h acc x = acc + x + g false in
  List.fold_left h 0 l
