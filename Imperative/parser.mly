 /* File parser.mly */

        %{
          open Ast;; 
        %}

        %token EOF
        %token <int> INT
        %token <string> VAR
        %token PLUS MINUS TIMES
        %token TRUE FALSE 
        %token AND OR NOT
        %token EQ NE GT LT LE GE
        %token ASSIGN SEMI
        %token IF WHILE ELSE SKIP PRINT ASSERT  
        %token LPAREN RPAREN LBRACE RBRACE
        %left SEMI
        %left PLUS MINUS OR        /* lowest precedence */
        %left TIMES AND         /* medium precedence */
        %nonassoc UMINUS NOT       /* highest precedence */
        %start main             /* the entry point */
        %type <Ast.prog_type> main
        %%
        main:
            prog EOF             {  
	    $1}
        ;

        prog:
	  stmt                   { Prog($1)  } 
	;

	stmt:
                              {  Skip  } 
         | SKIP                { Skip } 
         |  VAR ASSIGN aexp       { Assign($1,$3) }
         |  stmt SEMI stmt         { Seq($1, $3) }
         |  IF LPAREN bexp RPAREN LBRACE stmt RBRACE ELSE LBRACE stmt RBRACE { Ite($3,$6,$10) }
         |  IF LPAREN bexp RPAREN LBRACE stmt RBRACE   { Ite($3,$6,Skip) }
         |  WHILE LPAREN bexp RPAREN LBRACE stmt RBRACE { While($3, $6) }
	 |  ASSERT LPAREN bexp RPAREN   { Assert($3) }
         |  PRINT LPAREN aexp RPAREN    { Print($3) }
             
        aexp:
            INT                    { Int_const($1) }
	  | VAR                     { Var_exp($1) }
          | LPAREN aexp RPAREN      { $2 }
          | aexp PLUS aexp          { Sum_exp($1, $3) }
          | aexp MINUS aexp         { Diff_exp($1, $3) }
          | aexp TIMES aexp         { Mult_exp($1, $3) }
          | MINUS aexp %prec UMINUS { Unneg_exp($2) }
        ;

        bexp:
             TRUE                   { Bool_const(true) }
          |  FALSE                  { Bool_const(false)}
          |  aexp GT aexp           { Gt_exp($1, $3) }
          |  aexp GE aexp           { Ge_exp($1, $3) }
          |  aexp LT aexp           { Lt_exp($1, $3) }
          |  aexp LE aexp           { Le_exp($1, $3) }
          |  aexp EQ aexp           { Eq_exp($1, $3) }
	  |  aexp NE aexp           { Ne_exp($1, $3) }
          |  bexp OR bexp           { Or_exp($1, $3) }
          |  bexp AND bexp          { And_exp($1, $3) }
          |  NOT bexp               { Not_exp ($2) }
        ;    
