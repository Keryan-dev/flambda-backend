(* TEST
 compile_only = "true";
 flambda2;
 setup-ocamlopt.byte-build-env;
 ocamlopt.byte with check_simplify;
 check_fexpr_dump;
*)

let x = (fun () -> (fun _ -> Lazy.force (lazy "")) ()) ()

let rec foo = lazy (fun x : int -> x)

and t = lazy (Lazy.force foo)
