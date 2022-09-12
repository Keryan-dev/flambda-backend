(**************************************************************************)
(*                                                                        *)
(*                                 OCaml                                  *)
(*                                                                        *)
(*            Pierre Chambart and Vincent Laviron, OCamlPro               *)
(*           Mark Shinwell and Leo White, Jane Street Europe              *)
(*                                                                        *)
(*   Copyright 2013--2020 OCamlPro SAS                                    *)
(*   Copyright 2014--2020 Jane Street Group LLC                           *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(** Approximations used for cross-module inlining in Closure_conversion *)

type 'code t =
  | Value_unknown
  | Value_symbol of Symbol.t
  | Value_int of Targetint_31_63.t
  | Closure_approximation of Code_id.t * Function_slot.t * 'code
  | Block_approximation of 'code t array * Alloc_mode.t

let rec print fmt = function
  | Value_unknown -> Format.fprintf fmt "?"
  | Value_symbol sym -> Symbol.print fmt sym
  | Value_int i -> Targetint_31_63.print fmt i
  | Closure_approximation (code_id, _, _) ->
    Format.fprintf fmt "[%a]" Code_id.print code_id
  | Block_approximation (fields, _) ->
    let len = Array.length fields in
    if len < 1
    then Format.fprintf fmt "{}"
    else (
      Format.fprintf fmt "@[<hov 2>{%a" print fields.(0);
      for i = 1 to len - 1 do
        Format.fprintf fmt "@ %a" print fields.(i)
      done;
      Format.fprintf fmt "}@]")

let is_unknown = function
  | Value_unknown -> true
  | Value_symbol _ | Value_int _ | Closure_approximation _
  | Block_approximation _ ->
    false

let rec free_names ~code_free_names approx =
  match approx with
  | Value_unknown | Value_int _ -> Name_occurrences.empty
  | Value_symbol sym -> Name_occurrences.singleton_symbol sym Name_mode.normal
  | Block_approximation (approxs, _) ->
    Array.fold_left
      (fun names approx ->
        Name_occurrences.union names (free_names ~code_free_names approx))
      Name_occurrences.empty approxs
  | Closure_approximation (code_id, function_slot, code) ->
    Name_occurrences.add_code_id
      (Name_occurrences.add_function_slot_in_types (code_free_names code)
         function_slot)
      code_id Name_mode.normal
