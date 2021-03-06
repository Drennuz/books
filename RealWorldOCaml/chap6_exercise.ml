(* intro to ocaml chap6 *)

(* ex 6.1 *)
type 'a mylist = Nil | Cons of 'a * 'a mylist

let rec map f ml = match ml with
    Nil -> Nil
    |Cons (h, t) -> Cons (f h, map f t)

(* TODO: tail-recursive version? *)
let rec append l1 l2 = match l1 with
    Nil -> l2
    |Cons(h,t) -> Cons(h, append t l2)

let rev ml = 
let rec aux acc l = match l with
Nil -> acc
|Cons (h, t) -> aux (Cons(h, acc)) t in
aux Nil ml

(* ex 6.2 *)
type unary_number = Z | S of unary_number

(* TODO: tail-recursive? *)
let rec add_unary m n = match n with
    Z -> m
    |S i -> S (add_unary m i)
    
let mult_unary m n = 
    let rec aux res i j = match j with
        Z -> Z
        |S Z -> add_unary res i
        |S k -> aux (add_unary res i) i k
    in aux Z m n

(* ex 6.3 *)
type small = Four | Three | Two | One

let lt_small s1 s2 = match s1,s2 with
    Four, _ -> false
    |Three, Four -> true
    |Three, _ -> false
    |Two, Three -> true
    |Two, _ -> false
    |One, _ -> true
(* lt_small is O(n) *)

(* ex 6.4 *)
type unop = Neg
type binop = Add | Sub | Mul | Div
type exp = 
    Constant of int
    |Unary of unop * exp
    |Binary of exp * binop * exp

let rec eval ex = match ex with
    Constant n -> n
    |Unary (op, e) -> (-1) * (eval e)
    |Binary (e1, op, e2) -> match op with
        Add -> (eval e1) + (eval e2)
        |Sub -> (eval e1) - (eval e2)
        |Mul -> (eval e1) * (eval e2)
        |Div -> (eval e1) / (eval e2)

(* ex 6.5 *)

type ('key, 'value) dictionary = 
    Leaf | Node of 'key * 'value * ('key, 'value) dictionary * ('key, 'value) dictionary

let empty = Leaf
let rec add dic key value = match dic with
    Leaf -> Node (key, value, Leaf, Leaf)
    |Node (k,v,lt,rt) -> if key = k then Node(k, value, lt, rt)
        else if key < k then Node(k, v, (add lt key value), rt)
            else Node(k, v, lt, (add rt key value))

let rec find dic key = match dic with
    Leaf -> failwith "not found"
    |Node (k, v, lt, rt) -> if key = k then v
        else if key < k then find lt key
            else find rt key

(* ex 6.6 *)
type vertex = int
type graph = (vertex, vertex list) dictionary

let rec reacheable g v1 v2 = 
    let neighbors = List.map (find g v1) ~f:snd in
    if List.mem neighbors v2 then true
    else List.fold_left neighbors ~init:false ~f:(fun acc e -> acc || (reacheable g e v2))

(* ex 6.7 *)
type 'a tree = Leaf | Node of 'a * 'a tree * 'a tree
type comparison = LessThan | Equal | GreaterThan

let rec insert f a t = match t with
    Leaf -> Node (a, Leaf, Leaf)
    |Node(b, lt, rt) as node-> if f a b = LessThan then Node(b, insert f a lt, rt) 
        else if f a b = Equal then node
        else Node (b, lt, insert f a rt)

(* ex 6.8 *)
type 'a heap = Leaf | Node of 'a * 'a heap * 'a heap

let makeheap i = Node(i, Leaf, Leaf)

let findmin h = match h with
    Leaf -> failwith "empty heap"
    |Node (e, lt, rt) -> e

let rec meld h1 h2 = match h1, h2 with
    _, Leaf -> h1
    |Leaf, _ -> h2
    |Node (e1, l1, r1), Node(e2, l2, r2) -> 
        if e1 < e2 then Node (e1,meld l1 h2, r1)
        else Node(e2, meld h1 l2, r2)

let insert h i = meld h (makeheap i)

let deletemin h = match h with
    Leaf -> failwith "empty heap"
    |Node (e, lt, rt) -> meld lt rt

let empty = Leaf

let heap_from_list l = List.fold_left insert empty l

let heapsort l = 
    let rec aux res = function
        Leaf -> res
        |Node(e, l, r) as h -> aux (e :: res) (meld l r) in
    aux [] (heap_from_list l)

