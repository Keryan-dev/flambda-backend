(* TEST
 compile_only = "true";
 flambda2;
 setup-ocamlopt.byte-build-env;
 ocamlopt.byte with check_simplify;
 check_fexpr_dump;
*)

type 'a ref = { mutable contents : 'a }

external ref : 'a -> 'a ref = "%makemutable"

external ( ! ) : 'a ref -> 'a = "%field0"

let id () = ()

external sys_exit : int -> 'a = "caml_sys_exit"

let exit_function = ref id

let do_at_exit () = !exit_function ()

let _at_exit _f = ()

let exit retcode =
  do_at_exit ();
  sys_exit retcode
