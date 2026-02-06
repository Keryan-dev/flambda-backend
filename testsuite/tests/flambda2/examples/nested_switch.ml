(* TEST
 compile_only = "true";
 flambda2;
 setup-ocamlopt.byte-build-env;
 ocamlopt.byte with check_simplify;
 check_fexpr_dump;
*)

(* Check that the nested switch (after inlining) is simplified away *)
type foo =
  | Foo
  | Bar

let[@inline] test foo x y = match foo with Foo -> x > y | Bar -> x < y

let f foo x y = match foo with Foo -> test foo x y | Bar -> false
