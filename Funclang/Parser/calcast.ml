type exp =
  Int_const of int
| Sum_exp of exp * exp
| Diff_exp of exp * exp
| Mult_exp of exp * exp
| Div_exp of exp * exp 
| Unary_minus_exp of exp
;;


let rec string_of_exp e = 
  match e with
    Int_const(z) -> string_of_int z
  | Sum_exp(e1, e2) -> "("^(string_of_exp e1)^" + "^(string_of_exp e2)^")"
  | Diff_exp(e1, e2) -> "("^(string_of_exp e1)^" - "^(string_of_exp e2)^")"
  | Mult_exp(e1, e2) -> "("^(string_of_exp e1)^" * "^(string_of_exp e2)^")"
  | Div_exp(e1, e2) -> "("^(string_of_exp e1)^" / "^(string_of_exp e2)^")"
  | Unary_minus_exp(e0) -> "- ("^(string_of_exp e0)^")"
;;
