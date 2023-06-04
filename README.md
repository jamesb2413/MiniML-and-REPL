
## MiniML: A Small Subset of an OCaml-like Language and a REPL (Read-Eval-Print Loop)

Completed as a final project for Harvard's course on Abstraction and Design in Computing.

# Environment
First, [Install OCaml](https://ocaml.org/docs/up-and-running#installing-ocaml). 

This project uses ocamlbuild to compile. Insall with
```
opam install -y ocamlbuild
```

The parser in _miniml_lex.mll_ makes use of the OCaml package _menhir_, which is a parser generator for OCaml. 
Install with 
```
opam install -y menhir
```

evaluation.ml implements a small untyped ML-like language under
various operational semantics.

miniml.ml implements the REPL (read-eval-print loop).
