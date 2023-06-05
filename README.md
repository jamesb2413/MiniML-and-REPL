
## MiniML: A Small Subset of an OCaml-like Language and a REPL (Read-Eval-Print Loop)

Completed as a final project for Harvard's course on Abstraction and Design in Computing.

# Environment
First, [Install OCaml](https://ocaml.org/docs/up-and-running#installing-ocaml). These commands should work, but if you have a problem, visit the linked ocaml.org tutorial above. With Homebrew:
```
brew install opam
opam init -a
opam update
opam switch create 4.12.0
opam switch 4.12.0
```

This project uses ocamlbuild and ocamlfind to compile. The graphics package is also needed for the compiler to work. Install with
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

evaluation.ml implements a small untyped ML-like language under
various operational semantics.

miniml.ml implements the REPL (read-eval-print loop).
