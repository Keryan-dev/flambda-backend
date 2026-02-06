(* TEST
 compile_only = "true";
 flambda2;
 setup-ocamlopt.byte-build-env;
 ocamlopt.byte with check_simplify;
 check_fexpr_dump;
*)

module GPR_109 = struct
  let f () =
    let r = ref 0. in
    for i = 1 to 1000 do
      let x = float i in
      let y = if i mod 2 = 0 then x else x +. 1. in
      r := !r +. y
    done;
    !r
end
