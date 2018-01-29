
(* The type of tokens. *)

type token = 
  | WHILE
  | VAR of (string)
  | TRUE
  | TIMES
  | SKIP
  | SEMI
  | RPAREN
  | RBRACE
  | PRINT
  | PLUS
  | OR
  | NOT
  | NE
  | MINUS
  | LT
  | LPAREN
  | LE
  | LBRACE
  | INT of (int)
  | IF
  | GT
  | GE
  | FALSE
  | EQ
  | EOF
  | ELSE
  | ASSIGN
  | ASSERT
  | AND

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val main: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Ast.prog_type)
