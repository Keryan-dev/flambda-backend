(* TEST
 compile_only = "true";
 flambda2;
 setup-ocamlopt.byte-build-env;
 ocamlopt.byte with check_simplify;
 check_fexpr_dump;
*)

(* A statically-allocated block in a recursive loop with a closure *)

let rec foo x = `Foo foo
