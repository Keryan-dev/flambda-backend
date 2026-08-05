module F = Flambda
module S = SeaMM

module Acc = struct

  type t = {
    blocks : S.block S.Codepoint.Map.t;
    current_point : S.block * S.Codepoint.t;
  }

  let enter_new_block t (codepoint : S.Codepoint.t) =
    { t with current_point = S.empty_block, codepoint }

  let push_basic t (basic : S.basic) =
    let current_point =
      S.append_to_block (fst t.current_point) (S.Basic basic),
      snd t.current_point
    in
    { t with current_point }

  let push_terminator t (term : S.terminator) =
    let block, cp = t.current_point in
    let block = S.append_to_block block (S.Terminator term) in
    let blocks = S.Codepoint.Map.add cp block t.blocks in
    { t with blocks; }

end

let apply_to_cfg acc (apply : Apply_expr.t) =
  let return =
    match Apply_expr.continuation apply with
    | Never_returns -> None
    | Return c -> Some (S.Codepoint.Cont c)
  in
  Acc.push_terminator acc (S.FCall { return })

let rec expr_to_cfg acc (e : F.Expr.t) =
  match F.Expr.descr e with
  | F.Let _ -> _
  | F.Let_cont (Non_recursive { handler; _ }) ->
      let acc, cont =
        F.Non_recursive_let_cont_handler.pattern_match handler
          ~f:(fun cont ~body -> expr_to_cfg acc body, cont)
      in
      F.Continuation_handler.pattern_match
        (F.Non_recursive_let_cont_handler.handler handler)
        ~f:(fun _params ~handler ->
            expr_to_cfg (Acc.enter_new_block acc (S.Codepoint.Cont cont)) handler)
  | F.Let_cont (Recursive _) -> _
  | F.Apply apply -> apply_to_cfg acc apply
  | F.Apply_cont apply ->
      Acc.push_terminator acc
        (S.Jump (S.Codepoint.Cont (Apply_cont_expr.continuation apply)))
  | F.Switch switch ->
      let arms =
        Target_ocaml_int.Map.map (fun apply ->
            S.Codepoint.Cont (Apply_cont_expr.continuation apply))
          (F.Switch.arms switch)
      in
      Acc.push_terminator acc (S.Switch arms)
  | F.Invalid { message } -> Acc.push_terminator acc (S.Invalid message)
