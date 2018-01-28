open Calcast;;

let _ =
  try
    let lexbuf = Lexing.from_channel stdin in
    while true do
      let result = Parser.main Lexer.token lexbuf in
      print_endline ("Printing expression back: "^(Calcast.string_of_exp result)); print_newline(); flush stdout
    done
  with Lexer.Eof ->
    exit 0
