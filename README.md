
## MiniML: A Small Subset of an OCaml-like Language and a REPL (Read-Eval-Print Loop)

Completed as a final project for Harvard's course CS51 on Abstraction and Design in Computing. MiniML implements only a subset of OCaml constructs and has only limited support for types. Still, it is a Turing-complete language. The implementation of MiniML is a series of metacircular interpreters, since they are written in OCaml itself.

# Code Layout
evaluation.ml implements a small untyped ML-like language under
various operational semantics.

miniml.ml implements the REPL (read-eval-print loop).

# Functionality
When a user inputs MiniML code into the REPL (followed by `;;`), the subsequent printouts display

```
--> the abstract syntax tree of the input concrete syntax
s=> the evaluation using [substitution model semantics](https://book.cs51.io/pdfs/abstraction-13-substitution.pdf)
d=> the evaluation using [dynamically scoped environment model semantics](https://book.cs51.io/pdfs/abstraction-19-environments.pdf)
```

For example, a recursive factorial function:
```
<==  let rec f = fun x -> if x = 0 then 1 else x * f (x - 1) in f 4 ;;
--> Letrec(f, Fun(x, Conditional(Binop(Equals, Var(x), Num(0)), Num(1), Binop(Times, Var(x), App(Var(f), Binop(Minus, Var(x), Num(1)))))), App(Var(f), Num(4)))
s=> 24
d=> 24
```

Another example to demonstrate the difference between substitution semantics and dynamic scoped environment semantics:
```
<== let x = 2 in let f = fun y -> x * y in let x = 1 in f 21 ;;
--> Let(x, Num(2), Let(f, Fun(y, Binop(Times, Var(x), Var(y))), Let(x, Num(1), App(Var(f), Num(21)))))
s=> 42 
d=> 21
```

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

Now, you can compile using 
```
ocamlbuild -use-ocamlfind miniml.byte
```
If that doesn't work and you get a graphics error, try 
```
ocamlbuild -pkg graphics miniml.byte
```
Once compiled, run the program with 
```
./minimal.byte
```
