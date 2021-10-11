(**************************************************************************)
(*                                                                        *)
(*                                 OCaml                                  *)
(*                                                                        *)
(*                       Pierre Chambart, OCamlPro                        *)
(*           Mark Shinwell and Leo White, Jane Street Europe              *)
(*                                                                        *)
(*   Copyright 2013--2019 OCamlPro SAS                                    *)
(*   Copyright 2014--2019 Jane Street Group LLC                           *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

[@@@ocaml.warning "+a-30-40-41-42"]

(* CR mshinwell: Fix warning 60 *)
[@@@ocaml.warning "-60"]

open! Simplify_import

(* -- module rec binding here -- *)

type simplify_result =
  { cmx : Flambda_cmx_format.t option;
    unit : Flambda_unit.t;
    all_code : Exported_code.t
  }

let run ~backend ~cmx_loader ~round unit =
  let return_continuation = FU.return_continuation unit in
  let exn_continuation = FU.exn_continuation unit in
  let module_symbol = FU.module_symbol unit in
  let resolver = Flambda_cmx.load_cmx_file_contents cmx_loader in
  let get_imported_names = Flambda_cmx.get_imported_names cmx_loader in
  let get_imported_code = Flambda_cmx.get_imported_code cmx_loader in
  let denv =
    DE.create ~round ~backend ~resolver ~get_imported_names ~get_imported_code
      ~float_const_prop:(Flambda_features.float_const_prop ())
      ~unit_toplevel_return_continuation:return_continuation
      ~unit_toplevel_exn_continuation:exn_continuation
  in
  let return_cont_scope = DE.get_continuation_scope_level denv in
  let denv = DE.increment_continuation_scope_level denv in
  let exn_cont_scope = DE.get_continuation_scope_level denv in
  let denv = DE.increment_continuation_scope_level denv in
  let dacc = DA.create denv Continuation_uses_env.empty in
  let body, uacc =
    let exn_continuation =
      Exn_continuation.create ~exn_handler:exn_continuation ~extra_args:[]
    in
    Simplify_expr.simplify_toplevel dacc (FU.body unit) ~return_continuation
      ~return_arity:[K.With_subkind.any_value] exn_continuation
      ~return_cont_scope ~exn_cont_scope
  in
  let body = Rebuilt_expr.to_expr body (UA.are_rebuilding_terms uacc) in
  let name_occurrences = UA.name_occurrences uacc in
  Name_occurrences.fold_names name_occurrences ~init:() ~f:(fun () name ->
      Name.pattern_match name
        ~var:(fun var ->
          Misc.fatal_errorf
            "Variable %a not expected to be free in whole-compilation-unit \
             term:@ %a"
            Variable.print var Expr.print body)
        ~symbol:(fun _symbol -> ()));
  let return_cont_env = DA.continuation_uses_env (UA.creation_dacc uacc) in
  let all_code =
    Exported_code.merge (UA.all_code uacc)
      (Exported_code.mark_as_imported (get_imported_code ()))
  in
  let used_closure_vars =
    UA.name_occurrences uacc |> Name_occurrences.closure_vars
  in
  let cmx =
    Flambda_cmx.prepare_cmx_file_contents ~return_cont_env ~return_continuation
      ~module_symbol ~used_closure_vars all_code
  in
  let unit =
    FU.create ~return_continuation ~exn_continuation ~module_symbol ~body
      ~used_closure_vars:(Known used_closure_vars)
  in
  { cmx; unit; all_code }
