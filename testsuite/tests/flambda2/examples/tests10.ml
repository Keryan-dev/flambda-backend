(* TEST
 compile_only = "true";
 flambda2;
 ocamlopt_flags = "-rectypes";
 setup-ocamlopt.byte-build-env;
 ocamlopt.byte with check_raw, check_simplify;
 check_fexpr_dump;
*)

(* needs -rectypes *)

let rec f () = f, f
