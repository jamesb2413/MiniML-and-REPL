(* Testing for functions in Expr *)

open Expr ;;
open Miniml ;;

(* testing free_vars *)
let _ =
  let same exp lst = same_vars (free_vars exp) (vars_of_list lst) in
  let e = str_to_exp "let x = r in x + y ;;" in
  assert (same e ["r"; "y"]);
  let e = str_to_exp "let y = fun z -> 8 - y in y 5 ;;" in
  assert (same e ["y"]);
  let e = str_to_exp "let z = let y = 4 in y + 8 in z - y ;;" in
  assert (same e ["y"]);
  let e = str_to_exp "let z = let y = 4 in y + 8 in z - 11 ;;" in
  assert (same e []);
  let e = str_to_exp "fun x -> x ;;" in
  assert (same e []);
  let e = str_to_exp "let x = 3 in (fun n -> n + y - z * x) 7 ;;" in
  assert (same e ["y"; "z"]);
  let e = str_to_exp "x + y ;;" in
  assert (same e ["x"; "y"]);
  let e = str_to_exp "let x = fun n -> n * 2 in x x 4 ;;" in
  assert (same e []);
  let e = str_to_exp "let f = fun x -> x in f f 3 ;;" in
  assert (same e [])
;;

(* testing subst *)
let _ =
  let e = subst "x" (Num 3) (Binop (Plus, Var ("x"), Var ("y"))) in
  assert (e = Binop (Plus, Num 3, Var "y"));
  let e = subst "y" (Num 3) (Binop (Plus, Var ("x"), Var ("y"))) in
  assert (e = Binop (Plus, Var "x", Num 3));
  let e = subst "z" (Num 3) (Binop (Plus, Var ("x"), Var ("y"))) in
  assert (e = Binop (Plus, Var "x", Var "y"));
  let e = subst "n" (Num 10)
                (Conditional (Binop (Equals, Var "n", Num 0), Num 1,
                                     Binop (Times, Var "n", Num 10))) in
  assert (e = Conditional (Binop (Equals, Num 10, Num 0), Num 1,
                            Binop (Times, Num 10, Num 10)));
  let e = subst "f" (Fun ("x", Binop (Times, Var "x", Var "y")))
                (App (Var "f", Num 15)) in
  assert (e = App (Fun ("x", Binop (Times, Var "x", Var "y")), Num 15));
  let e = subst "n" (Num 10)
                (Letrec ("fact",
                         Fun ("n",
                              Conditional (Binop (Equals, Var "n", Num 0),
                                           Num 1,
                                           Binop (Times,
                                                  Var "n",
                                                  App (Var "fact",
                                                       Binop (Minus,
                                                              Var "n",
                                                              Num 1))))),
                         App (Var "fact", Var "n"))) in
  assert (e = (Letrec ("fact",
                       Fun ("n",
                            Conditional (Binop (Equals, Var "n", Num 0),
                                         Num 1,
                                         Binop (Times,
                                                Var "n",
                                                App (Var "fact",
                                                     Binop (Minus,
                                                            Var "n",
                                                            Num 1))))),
                       App (Var "fact", Num 10))));
  let e = subst "f" (Fun ("z", Var "y")) (Fun ("y", App (Var "f", Num 3))) in
  assert (e != Fun ("y", App (Fun ("z", Var "y"), Num 3)));
  let e = subst "x" (Num 3) (Fun ("x", Var "y")) in
  assert (e = Fun ("x", Var "y"));
;;

(* tested eval_s manually *)
