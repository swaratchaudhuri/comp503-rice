#!/bin/sh
ocamllex lexer.mll       # generates lexer.ml
menhir parser.mly     # generates parser.ml and parser.mli
ocamlc -c calcast.ml
ocamlc -c parser.mli
ocamlc -c lexer.ml
ocamlc -c parser.ml
ocamlc -c calc.ml
ocamlc -o calc calcast.cmo lexer.cmo parser.cmo calc.cmo  # generates an executable called "calc"
