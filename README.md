
## MiniML: A Small Subset of an OCaml-like Language and a REPL (Read-Eval-Print Loop)

Completed as a final project for Harvard's course CS51 on Abstraction and Design in Computing. MiniML implements only a subset of OCaml constructs and has only limited support for types. Still, it is a Turing-complete language. The implementation of MiniML is in the form of a metacircular interpreter since it is written in OCaml itself.

# Environment
This project works in the [environment setup for Harvard's CS51 course](https://cs51.io/handouts/setup/). If you have any problems with the instructions here, visit that site to follow a more detailed setup tutorial.

First, install `opam`, OCaml's package manager:
```
brew install opam
opam init -a
opam update
opam switch create 4.12.0
opam switch 4.12.0
```

This project uses ocamlbuild and ocamlfind to compile. The graphics package is also needed for the CS51 Utils package which helps us compile the code. Install with
```
opam install -y ocamlbuild
opam install -y ocamlfind
opam install -y graphics
```

The parser in _miniml_lex.mll_ makes use of the OCaml package _menhir_, which is a parser generator for OCaml. 
Install with 
```
opam install -y menhir
```

Finally, connect to CS51's Utils package:
```
opam pin add CS51Utils https://github.com/cs51/utils.git -y
```

Finish by running this command, which should have no output:
```
eval $(opam env)
```

evaluation.ml implements a small untyped ML-like language under
various operational semantics.

miniml.ml implements the REPL (read-eval-print loop).
