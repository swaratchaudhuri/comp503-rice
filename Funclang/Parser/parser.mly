/* File parser.mly */

%{
open Calcast
%}

%token <int> INT
%token PLUS MINUS TIMES DIV
%token LPAREN RPAREN
%token EOL
%left PLUS MINUS        /* lowest precedence */
%left TIMES DIV         /* medium precedence */
%nonassoc UMINUS        /* highest precedence */
%start main             /* the entry point */
%type <Calcast.exp> main
%%

main:
	expr EOL                { $1 }
;

expr:
	INT                     { Int_const $1 }
	| LPAREN expr RPAREN      { $2 }
	| expr PLUS expr          { Sum_exp ($1, $3) }
	| expr MINUS expr         { Diff_exp ($1, $3) }
	| expr TIMES expr         { Mult_exp ($1, $3) }
	| expr DIV expr           { Div_exp ($1, $3) }
	| MINUS expr %prec UMINUS { Unary_minus_exp ($2) }
;