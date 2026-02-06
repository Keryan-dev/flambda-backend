(* TEST
 compile_only = "true";
 flambda2;
 setup-ocamlopt.byte-build-env;
 ocamlopt.byte with check_simplify;
 check_fexpr_dump;
*)

let f b x =
  let y = if b then x +. 1. else x +. 42. in
  y +. 0.
