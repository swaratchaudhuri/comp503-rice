#!/bin/sh
ocamllex lexer.mll       # generates lexer.ml
menhir parser.mly     # generates parser.ml and parser.mli
ocamlc -c ast.ml
ocamlc -c parser.mli
ocamlc -c lexer.ml
ocamlc -c parser.ml
ocamlc -c interpret.ml
ocamlc -o imperative ast.cmo lexer.cmo parser.cmo interpret.cmo  # generates an executable called "imperative"

