(* TEST
 compile_only = "true";
 flambda2;
 setup-ocamlopt.byte-build-env;
 ocamlopt.byte with check_simplify;
 check_fexpr_dump;
*)

type t =
  | Sheep
  | Cow
  | Goat
  | Horse

let of_string str =
  match str with
  | "Sheep" -> Sheep
  | "Cow" -> Cow
  | "Goat" -> Goat
  | "Horse" -> Horse
  | _ -> assert false
