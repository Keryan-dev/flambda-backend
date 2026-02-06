(* TEST
 compile_only = "true";
 flambda2;
 ocamlopt_flags = "-g";
 setup-ocamlopt.byte-build-env;
 ocamlopt.byte with check_simplify;
 check_fexpr_dump;
*)

(* build with -g *)

let to_string context t =
  let paren ?(cond = false) f = f in
  let cond = Some (context = `Plop) in
  match t with None -> paren ?cond "plop" | Some _ -> paren ?cond "plip"
