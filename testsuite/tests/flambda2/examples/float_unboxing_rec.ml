(* TEST
 compile_only = "true";
 flambda2;
 setup-ocamlopt.byte-build-env;
 ocamlopt.byte with check_simplify;
 check_fexpr_dump;
*)

let f n x =
  let r = ref x in
  for i = 0 to n do
    r := !r +. x
  done;
  !r +. 0.
