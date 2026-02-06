(* TEST
 compile_only = "true";
 flambda2;
 setup-ocamlopt.byte-build-env;
 ocamlopt.byte with check_simplify;
 check_fexpr_dump;
*)

let do_stuff env = assert false

let stuff env =
  let r = ref None in
  try (Sys.opaque_identity do_stuff) env with _ -> Sys.opaque_identity !r
