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
let free_vars (exp : expr) : varidset =
  failwith "free_vars not implemented" ;;

(* new_varname : unit -> varid
   Return a fresh variable, constructed with a running counter a la
   gensym. Assumes no variable names use the prefix "var". (Otherwise,
   they might accidentally be the same as a generated variable name.) *)
let new_varname () : varid =
  failwith "new_varname not implemented" ;;

(*......................................................................
  Substitution

  Substitution of expressions for free occurrences of variables is the
  cornerstone of the substitution model for functional programming
  semantics.
 *)

(* subst : varid -> expr -> expr -> expr
   Substitute repl for free occurrences of var_name in exp *)
let subst (var_name : varid) (repl : expr) (exp : expr) : expr =
  failwith "subst not implemented" ;;

(*......................................................................
  String representations of expressions
*)

(* exp_to_concrete_string : expr -> string
   Returns a concrete syntax string representation of the expr *)
let rec exp_to_concrete_string (exp : expr) : string =
  let binop_conc (op : binop) : string =
    (* two helper abstractions *)
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
  match exp with
  | Var s -> s
  | Num i -> string_of_int i
  | Bool b -> string_of_bool b
  | Unop (_, e) -> "-" ^ exp_to_concrete_string e
  | Binop (op, e1, e2) ->
    exp_to_concrete_string e1 ^ binop_conc op ^ exp_to_concrete_string e2
  | Conditional (e1, e2, e3) ->
    "if " ^ exp_to_concrete_string e1 ^ " then " ^ exp_to_concrete_string e2 ^
    " else " ^ exp_to_concrete_string e3
  | Fun (s, e) -> "fun " ^ s ^ " -> " ^ exp_to_concrete_string e
  | Let (s, e1, e2)
  | Letrec (s, e1, e2) ->
    let_letrec exp ^ s ^ " = " ^ exp_to_concrete_string e1 ^ " in " ^
    exp_to_concrete_string e2
  | Raise -> "Exception "
  | Unassigned -> "Error: Unbound value "
  | App (e1, e2) -> exp_to_concrete_string e1 ^ exp_to_concrete_string e2
;;

(* exp_to_abstract_string : expr -> string
   Returns a string representation of the abstract syntax of the expr *)
let rec exp_to_abstract_string (exp : expr) : string =
  (* five helper abstractions *)
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
  match exp with
  | Var s -> "Var" ^ par s
  | Num i -> "Num" ^ par (string_of_int i)
  | Bool b -> "Bool" ^ par (string_of_bool b)
  | Unop (_, e) -> "Negate" ^ par (exp_to_abstract_string e)
  | Binop (op, e1, e2) ->
    "Binop" ^ three_arg (binop_abstr op) (exp_to_abstract_string e1)
                        (exp_to_abstract_string e2)
  | Conditional (e1, e2, e3) ->
    "Conditional" ^ three_arg (exp_to_abstract_string e1)
                              (exp_to_abstract_string e2)
                              (exp_to_abstract_string e3)
  | Fun (s, e) -> "Fun" ^ two_arg s (exp_to_abstract_string e)
  | Let (s, e1, e2)
  | Letrec (s, e1, e2) ->
    let_lr_abstr exp ^ three_arg s (exp_to_abstract_string e1)
                                 (exp_to_abstract_string e2)
  | Raise -> "Raise"
  | Unassigned -> "Unassigned"
  | App (e1, e2) -> "App" ^ two_arg (exp_to_abstract_string e1)
                                    (exp_to_abstract_string e2)
;;
