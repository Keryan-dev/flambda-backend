module Codepoint = struct
  type t = EntryPoint | Cont of Continuation.t

  let compare p1 p2 =
    match p1, p2 with
    | EntryPoint, EntryPoint -> 0
    | EntryPoint, _ -> 1
    | _, EntryPoint -> -1
    | Cont k1, Cont k2 -> Continuation.compare k1 k2

  module Map = Map.Make(struct type nonrec t = t let compare = compare end)

end

type basic

type terminator =
  | Jump of Codepoint.t
  | Switch of Codepoint.t Target_ocaml_int.Map.t
  | FCall of { return : Codepoint.t option }
  | Invalid of string

type instr =
  | Terminator of terminator
  | Basic of basic

type block = instr list

let empty_block : block = []

let append_to_block b i = i::b
