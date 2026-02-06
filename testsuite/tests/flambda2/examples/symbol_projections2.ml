(* TEST
 compile_only = "true";
 flambda2;
 setup-ocamlopt.byte-build-env;
 ocamlopt.byte with check_simplify;
 check_fexpr_dump;
*)

(* From pchambart 2020-07-22, ocaml-flambda/ocaml issue #214 *)

external opaque_identity : 'a -> 'a = "%opaque"

external ( + ) : int -> int -> int = "%addint"

let[@inline never] ignore _ = ()

let v = opaque_identity 33

let g () =
  let () = ignore () in
  let f x = x + v in
  f
