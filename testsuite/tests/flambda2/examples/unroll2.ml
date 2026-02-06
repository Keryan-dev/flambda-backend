(* TEST
 compile_only = "true";
 flambda2;
 setup-ocamlopt.byte-build-env;
 ocamlopt.byte with check_raw, check_simplify;
 check_fexpr_dump;
*)

[@@@flambda.o3]

external ( + ) : int -> int -> int = "%addint"

external ( - ) : int -> int -> int = "%subint"

external opaque : 'a -> 'a = "%opaque"

let[@loop never] rec foo x = if opaque true then foo (x + 1) else foo (x - 1)

let bar x = (foo [@unrolled 2]) x
