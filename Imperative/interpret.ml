open Ast

exception NotHandled of string

(******* Printing a program *****************
*********************************************)

let rec aexp_to_string e =
  match e with
    Int_const r -> (string_of_int r)
  | Var_exp x -> x
  | Mult_exp (e1, e2) ->
    String.concat ""
      ["("; aexp_to_string e1; " * ";
       aexp_to_string e2; ")"]
  | Sum_exp (e1, e2) ->
    String.concat ""
      [aexp_to_string e1; " + ";
       aexp_to_string e2]
  | Diff_exp (e1, e2) ->
    String.concat ""
      [aexp_to_string e1; " - ";
       aexp_to_string e2]
  | Unneg_exp (e1) ->
    String.concat ""
      ["(-";
       aexp_to_string e1; ")"]
and
aexp_list_to_string lst =
  match lst with
    [] -> ""
  | [x] -> aexp_to_string x
  | head :: rest ->
    String.concat ""
      [aexp_to_string head;
       ", ";
       aexp_list_to_string rest]

let rec bexp_to_string b =
  match b with
  | Bool_const (true) -> " 0 <= 0"
  | Bool_const (false) -> " 1 <= 0"
  | Gt_exp (e1, e2) ->
    String.concat ""
      [aexp_to_string e1; " > ";
       aexp_to_string e2]
  | Lt_exp (e1, e2) ->
    String.concat ""
      [aexp_to_string e1; " < ";
       aexp_to_string e2]
  | Ge_exp (e1, e2) ->
    String.concat ""
      [aexp_to_string e1; " >= ";
       aexp_to_string e2]
  | Le_exp (e1, e2) ->
    String.concat ""
      [aexp_to_string e1; " <= ";
       aexp_to_string e2]
  | Eq_exp (e1, e2) ->
     String.concat ""
      [aexp_to_string e1; " == ";
       aexp_to_string e2]
  | Ne_exp (e1, e2) ->
     String.concat ""
      [aexp_to_string e1; " != ";
       aexp_to_string e2]
  | And_exp (b1, b2) ->
    String.concat ""
      ["("; bexp_to_string b1; " && ";
       bexp_to_string b2; ")"]
  | Not_exp b1  ->
    String.concat ""
      ["!("; bexp_to_string b1; ")"]
  | Or_exp (b1, b2) ->
    String.concat ""
      ["("; bexp_to_string b1; " || ";
       bexp_to_string b2; ")"]

let rec stmt_to_string s =
  match s with
    Skip -> "skip"
  | Assign (var, e) ->
    String.concat "" [var; " := "; aexp_to_string e]
  | Seq (s1, s2) ->
    (match s1 with
      Skip -> (stmt_to_string s2)
    | _  ->
          (match s2 with
         Skip -> (stmt_to_string s1)
          | _ -> (String.concat "" [stmt_to_string s1; ";\n"; stmt_to_string s2])))
  | Ite (b, s1, s2) ->
    String.concat ""
      ["if ("; (bexp_to_string b); ") { \n";
       stmt_to_string s1; "\n}\nelse { \n";
       stmt_to_string s2; "\n}"]
  | While (b, s1) ->
    String.concat ""
      ["while ("; bexp_to_string b; ") { \n";
       stmt_to_string s1; "\n}\n"]
  | Print(e) ->
    String.concat ""
      ["print ("; aexp_to_string e; ")"]
  | Assert b ->
    String.concat ""
      ["assert ("; bexp_to_string b; ")"]


let print_prog p =
  print_string "\nPrinting program:\n";
  match p with
    Prog s -> (print_string (stmt_to_string s));
  (print_string "\n")


(******* Interpreter for programs **********
*********************************************)

(* Store type *)

type env_type = (string * int) list

(* Auxiliary function *)

(* Works even if list doesn't contain binding for var *)
let update_store store var value =
  (var, value)::(List.remove_assoc var store)

exception AssertionViolation

(* Interpreter for arithmetic expressions *)

let rec interpret_aexp e store =
  match e with
    Int_const r -> r
  | Var_exp x ->
    List.assoc x store
  | Mult_exp (e1, e2) -> (interpret_aexp e1 store) * (interpret_aexp e2 store)
  | Sum_exp (e1, e2) -> (interpret_aexp e1 store) + (interpret_aexp e2 store)
  | Diff_exp (e1, e2) -> (interpret_aexp e1 store) - (interpret_aexp e2 store)
  | Unneg_exp (e1) -> - (interpret_aexp e1 store)
 

(* Interpreter for boolean expressions *)

let rec interpret_bexp b store =
  match b with
  | Bool_const (bc) -> bc
  | Gt_exp (e1, e2) ->
      (interpret_aexp e1 store) > (interpret_aexp e2 store)
  | Lt_exp (e1, e2) ->
    (interpret_aexp e1 store) < (interpret_aexp e2 store)
  | Ge_exp (e1, e2) ->
      (interpret_aexp e1 store) >= (interpret_aexp e2 store)
  | Le_exp (e1, e2) ->
    (interpret_aexp e1 store) <= (interpret_aexp e2 store)
  | Eq_exp (e1, e2) ->
    (interpret_aexp e1 store) == (interpret_aexp e2 store)
  | Ne_exp (e1, e2) ->
    (interpret_aexp e1 store) != (interpret_aexp e2 store)
  | And_exp (b1, b2) ->
    (interpret_bexp b1 store) && (interpret_bexp b2 store)
  | Not_exp b1  ->
    not (interpret_bexp b1 store)
  | Or_exp (b1, b2) ->
    (interpret_bexp b1 store) || (interpret_bexp b2 store)
 

(* Interpreter for statements *)

let rec interpret_stmt s store =
  match s with
     Skip -> store
  |  Assign (var, e) -> (update_store store var (interpret_aexp e store))
  | Seq (s1, s2) -> (interpret_stmt s2 (interpret_stmt s1 store))
  | Ite (b, s1, s2) ->
    let bv = interpret_bexp b store in
    if bv then (interpret_stmt s1 store)
    else (interpret_stmt s2 store)
  | While (b, s1) ->
    let bv = interpret_bexp b store in
    if bv then (interpret_stmt s (interpret_stmt s1 store))
    else store
  | Assert b ->
    if (interpret_bexp b store)
    then store
    else raise AssertionViolation
  | Print e ->
    (print_int (interpret_aexp e store));
    (print_string "\n");
    store
 
let interpret_prog p =
  (print_string "\nInterpreting program:\n");
  (ignore (match p with
    Prog s -> interpret_stmt s []));
  (print_string "\n")


(*********** Main function ****************
*******************************************)

let read_and_process infile =
   let lexbuf  = Lexing.from_channel infile in
   let result = Parser.main Lexer.token lexbuf in
   print_prog result;
   interpret_prog result

let _ =
  if Array.length Sys.argv <> 2 then
    Printf.fprintf stderr "usage: %s input_filename\n" Sys.argv.(0)
  else
    let  infile = open_in Sys.argv.(1) in
    read_and_process infile;
    close_in infile

