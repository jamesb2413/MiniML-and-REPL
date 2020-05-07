(*
                         CS 51 Final Project
                        MiniML -- Expressions
*)

(*......................................................................
  Abstract syntax of MiniML expressions
 *)

type unop =
  | Negate
;;

type binop =
  | Plus
  | Minus
  | Times
  | Equals
  | LessThan
;;

type varid = string ;;

type expr =
  | Var of varid                         (* variables *)
  | Num of int                           (* integers *)
  (*| Float of float                       (* floats *) *)
  | Bool of bool                         (* booleans *)
  | Unop of unop * expr                  (* unary operators *)
  | Binop of binop * expr * expr         (* binary operators *)
  | Conditional of expr * expr * expr    (* if then else *)
  | Fun of varid * expr                  (* function definitions *)
  | Let of varid * expr * expr           (* local naming *)
  | Letrec of varid * expr * expr        (* recursive local naming *)
  | Raise                                (* exceptions *)
  | Unassigned                           (* (temporarily) unassigned *)
  | App of expr * expr                   (* function applications *)
;;

(*......................................................................
  Manipulation of variable names (varids)
 *)

(* varidset -- Sets of varids *)
module SS = Set.Make (struct
                       type t = varid
                       let compare = String.compare
                     end ) ;;

type varidset = SS.t ;;

(* same_vars :  varidset -> varidset -> bool
   Test to see if two sets of variables have the same elements (for
   testing purposes) *)
let same_vars : varidset -> varidset -> bool =
  SS.equal;;

(* vars_of_list : string list -> varidset
   Generate a set of variable names from a list of strings (for
   testing purposes) *)
let vars_of_list : string list -> varidset =
  SS.of_list ;;

(* free_vars : expr -> varidset
   Return a set of the variable names that are free in expression
   exp *)
let rec free_vars (exp : expr) : varidset =
  let init = SS.empty in
  (* Helper abstractions *)
  let plus : varidset -> varidset = SS.union init in
  let comb (e1 : expr) (e2 : expr) : varidset =
    SS.union (free_vars e1) (free_vars e2) in
  match exp with
  | Var s -> plus (vars_of_list [s])
  | Unop (_, e) -> free_vars e
  | Conditional (e1, e2, e3) ->
    plus (SS.union (comb e1 e2) (free_vars e3))
  | Fun (s, e) -> plus (SS.remove s (free_vars e))
  | Let (s, e1, e2)
  | Letrec (s, e1, e2) ->
    plus (SS.union (free_vars e1) (SS.remove s (free_vars e2)))
  | Binop (_, e1, e2)
  | App (e1, e2) -> plus (comb e1 e2)
  | _ -> init
;;

(* new_varname : unit -> varid
   Return a fresh variable, constructed with a running counter a la
   gensym. Assumes no variable names use the prefix "var". (Otherwise,
   they might accidentally be the same as a generated variable name.) *)
let new_varname () : varid =
  let suffix = ref 0 in
  let sym = "var" ^ string_of_int !suffix in
  suffix := !suffix + 1;
  sym ;;

(*......................................................................
  Substitution

  Substitution of expressions for free occurrences of variables is the
  cornerstone of the substitution model for functional programming
  semantics.
 *)

(* subst : varid -> expr -> expr -> expr
   Substitute repl for free occurrences of var_name in exp *)
let rec subst (var_name : varid) (repl : expr) (exp : expr) : expr =
  if not (SS.exists ((=) var_name) (free_vars exp)) then exp
  else
    (* helper abstractions *)
    let r : expr -> expr = subst var_name repl in
    let free (v : varid) : bool = SS.exists ((=) v) (free_vars repl) in
    (* output *)
    match exp with
    | Var s -> if s = var_name then repl else exp
    | Unop (n, e) -> Unop (n, r e)
    | Binop (op, e1, e2) -> Binop (op, r e1, r e2)
    | Conditional (e1, e2, e3) -> Conditional (r e1, r e2, r e3)
    | Fun (s, e) ->
      if s = var_name then exp
      else if not (free s) then Fun (s, r e)
      (* using fresh variable to fix variable capture *)
      else let fresh = new_varname () in
        Fun (fresh, r (subst s (Var fresh) e))
    | Let (s, e1, e2) ->
      if s = var_name then Let (s, r e1, e2)
      else if not (free s) then Let (s, r e1, r e2)
      (* using fresh variable to fix variable capture *)
      else let fresh = new_varname () in
        Let (fresh, r e1, r (subst s (Var fresh) e2))
    | Letrec (s, e1, e2) ->
      if s = var_name then exp
      else if not (free s) then Letrec (s, r e1, r e2)
      (* using fresh variable to fix variable capture *)
      else let fresh = new_varname () in
        Letrec (s, r (subst s (Var fresh) e1), r (subst s (Var fresh) e2))
    | App (e1, e2) -> App (r e1, r e2)
    | _ -> exp
;;

(*......................................................................
  String representations of expressions
*)

(* exp_to_concrete_string : expr -> string
   Returns a concrete syntax string representation of the expr *)
let rec exp_to_concrete_string (exp : expr) : string =
  (* helper abstractions *)
  let r = exp_to_concrete_string in
  let binop_conc (op : binop) : string =
    match op with
    | Plus -> " + "
    | Minus -> " - "
    | Times -> " * "
    | Equals -> " = "
    | LessThan -> " < " in
  let let_letrec (l_lr : expr) : string =
    match l_lr with
    | Let (_) -> "let "
    | Letrec (_) -> "let rec "
    | _ -> raise (Invalid_argument "let_letrec called on non-let expr ") in
  (* output *)
  match exp with
  | Var s -> s
  | Num i -> string_of_int i
  (*| Float f -> string_of_float f *)
  | Bool b -> string_of_bool b
  | Unop (_, e) -> "-" ^ r e
  | Binop (op, e1, e2) -> r e1 ^ binop_conc op ^ r e2
  | Conditional (e1, e2, e3) ->
    "if " ^ r e1 ^ " then " ^ r e2 ^ " else " ^ r e3
  | Fun (s, e) -> "fun " ^ s ^ " -> " ^ r e
  | Let (s, e1, e2)
  | Letrec (s, e1, e2) -> let_letrec exp ^ s ^ " = " ^ r e1 ^ " in " ^ r e2
  | Raise -> "Raise "
  | Unassigned -> "Unassigned "
  | App (e1, e2) -> r e1 ^ r e2
;;

(* exp_to_abstract_string : expr -> string
   Returns a string representation of the abstract syntax of the expr *)
let rec exp_to_abstract_string (exp : expr) : string =
  (* helper abstractions *)
  let r = exp_to_abstract_string in
  let par str = "(" ^ str ^ ")" in
  let two_arg a b = par (a ^ ", " ^ b) in
  let three_arg a b c = par (a ^ ", " ^ b ^ ", " ^ c) in
  let binop_abstr (op : binop) : string =
    match op with
    | Plus -> "Plus"
    | Minus -> "Minus"
    | Times -> "Times"
    | Equals -> "Equals"
    | LessThan -> "LessThan" in
  let let_lr_abstr (l_lr : expr) : string =
    match l_lr with
    | Let (_) -> "Let"
    | Letrec (_) -> "Letrec"
    | _ -> raise (Invalid_argument "let_lr_abstr called on non-let expr") in
  (* output *)
  match exp with
  | Var s -> "Var" ^ par s
  | Num i -> "Num" ^ par (string_of_int i)
  (*| Float f -> "Float" ^ par (string_of_float f)*)
  | Bool b -> "Bool" ^ par (string_of_bool b)
  | Unop (_, e) -> "Negate" ^ par (r e)
  | Binop (op, e1, e2) -> "Binop" ^ three_arg (binop_abstr op) (r e1) (r e2)
  | Conditional (e1, e2, e3) -> "Conditional" ^ three_arg (r e1) (r e2) (r e3)
  | Fun (s, e) -> "Fun" ^ two_arg s (r e)
  | Let (s, e1, e2)
  | Letrec (s, e1, e2) -> let_lr_abstr exp ^ three_arg s (r e1) (r e2)
  | Raise -> "Raise"
  | Unassigned -> "Unassigned"
  | App (e1, e2) -> "App" ^ two_arg (r e1) (r e2)
;;
