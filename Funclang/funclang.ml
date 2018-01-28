(****** Ocaml interpreter for a functional language. 
 ****** To compile, invoke "ocamlc funclang.ml"  ******)

(* Type definition for AST nodes *)

type exp_type = Int_const of int 
  | Bool_const of bool
  | Sum_exp of (exp_type * exp_type)
  | ITE_exp of (exp_type * exp_type * exp_type)
  | Eq_exp of (exp_type * exp_type)
  | Var_exp of string
  | Let_exp of (string * exp_type * exp_type)
  | Proc_dec_exp of (string * exp_type)
  | Proc_call_exp of (exp_type * exp_type)
;;

(* Type definition for values and environments. Note the mutual recursion. *)

type myValue =  Int of int | Bool of bool | Closure of (string * exp_type * env_type)
and env_type = (string * myValue) list;; 

(* Exceptions for runtime errors *)

exception WrongType;;
exception Unbound;; 

(* Auxiliary functions *)

let add_value v1 v2 = 
  match (v1, v2) with
    (Int i1, Int i2) -> (Int (i1 + i2))
  | _ -> raise WrongType;;

let update_env env x y = 
  (x, y)::(List.remove_assoc x env);;

(* The actual interpretation routine *)

let rec interpret e env = 
  match e with
    Int_const (n) -> (Int n)
  | Bool_const (b) -> (Bool b)
  | Sum_exp(e1, e2) -> 
    (add_value (interpret e1 env) (interpret e2 env))
  | ITE_exp(g, e1, e2) -> 
    let gv = (interpret g env) in
    (match gv with
      Bool b -> 
	(if b then 
	  (interpret e1 env)
	 else (interpret e2 env))
    | _ -> raise WrongType)
  | Eq_exp(e1, e2) -> 
    let e1v = (interpret e1 env) in
    let e2v = (interpret e2 env) in
    (match (e1v, e2v) with
      (Int i1, Int i2) -> (Bool (i1 = i2))
    | (Bool b1, Bool b2) -> (Bool (b1 = b2))
    | _ -> raise WrongType)
  | Var_exp x -> 
    if (List.mem_assoc x env) 
    then (List.assoc x env)
    else raise Unbound
  | Let_exp (x, e1, e2) ->
    let y = (interpret e1 env) in 
    let env1 = (update_env env x y) in 
    (interpret e2 env1)
  | Proc_dec_exp(x, e1) -> Closure(x, e1, env)
  | Proc_call_exp(exp1, exp2) ->
    let v2 = (interpret exp2 env) in
    let v1 = (interpret exp1 env) in
    (match v1 with
      Closure(x, e, env1) -> (interpret e (update_env env1 x v2))
    | _ -> raise WrongType)
;;

(* Tests *)

(* x *)
let env = [("x", (Int 10))] in  
interpret (Sum_exp(Var_exp "x", Int_const 5)) env;;

(* let x = 10 in x + 5 *)
let env = [] in  
interpret (Let_exp("x", Int_const 10, Sum_exp(Var_exp "x", Int_const 5))) env;;

(* ((fun x -> x + 10) 10 *)
let env = [] in
interpret (Proc_call_exp(Proc_dec_exp("x", Sum_exp(Var_exp "x",Int_const 10)), Int_const 10)) env;;

(* let x = 10 in let x = x + 10 in x + 5 *)
let env = [] in  
interpret (Let_exp("x", Int_const 10, (Let_exp("x", Sum_exp(Var_exp "x",Int_const 10), Sum_exp(Var_exp "x", Int_const 5))))) env;;

(* if x = 10 then 10 else 15 *)

let env = [("x", Int 10)] in
interpret (ITE_exp(Eq_exp (Var_exp "x", Int_const 10), Int_const 10, Int_const 15)) env;;

(* f = fun y -> y + x in let x = 20 in (f 5) *)

let env = [("x", Int 10)] in
interpret (Let_exp("f", Proc_dec_exp("y", Sum_exp(Var_exp "y", Var_exp "x")), Let_exp ("x", Int_const 20, Proc_call_exp (Var_exp "f", Int_const 5)))) env;; 

