(* TEST
 compile_only = "true";
 flambda2;
 setup-ocamlopt.byte-build-env;
 ocamlopt.byte with check_simplify;
 check_fexpr_dump;
*)

type 'a foo = Foo of 'a

let[@inline never] id lam = lam

let foo v opt =
  let x = match opt with None -> Foo v | Some _ -> id (Foo v) in
  Foo v, x
