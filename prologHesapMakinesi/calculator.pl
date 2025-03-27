% Prolog Calculator Implementation
% Supports arithmetic operations, variables, and error handling

% Dynamic predicate for storing variables
:- dynamic variable/2.

% Helper predicates for error handling
print_error(Message) :-
    write('Error: '), write(Message), nl, fail.

% Evaluate arithmetic expressions
evaluate(Expr, Result) :-
    (number(Expr) -> Result = Expr ;  % Handle numbers
    atom(Expr) -> (                   % Handle variables
        variable(Expr, Value) -> Result = Value ;
        print_error('Undefined variable')
    ) ;
    Expr = [Op|Args] ->              % Handle operations
    (
        maplist(evaluate, Args, EvalArgs),
        evaluate_op(Op, EvalArgs, Result)
    ) ;
    print_error('Invalid expression')
    ).

% Evaluate operators
evaluate_op('+', Args, Result) :- sum_list(Args, Result).
evaluate_op('-', [X], Result) :- Result is -X.
evaluate_op('-', [X,Y|Rest], Result) :- 
    foldl(subtract, [Y|Rest], X, Result).
evaluate_op('*', Args, Result) :- product_list(Args, Result).
evaluate_op('/', [_,0|_], _) :- print_error('Division by zero').
evaluate_op('/', [X,Y|Rest], Result) :- 
    foldl(divide, [Y|Rest], X, Result).
evaluate_op('^', [X,Y], Result) :- 
    (length([X,Y], 2) -> Result is X ** Y ;
    print_error('Power operation requires exactly 2 arguments')).
evaluate_op(Op, _, _) :- 
    print_error('Unknown operator'), fail.

% Helper predicates for arithmetic operations
subtract(Y, X, Result) :- Result is X - Y.
divide(Y, X, Result) :- Result is X / Y.

product_list([], 1).
product_list([H|T], Result) :-
    product_list(T, TempResult),
    Result is H * TempResult.

% Set variable value
set_variable(Name, Value) :-
    retractall(variable(Name, _)),
    asserta(variable(Name, Value)),
    write(Name), write(' = '), write(Value), nl.

% Main calculator loop
calculator :-
    write('Prolog Calculator (Type "exit." to quit)'), nl,
    write('Examples:'), nl,
    write('  Addition: [+, 2, 3].'), nl,
    write('  Subtraction: [-, 5, 2].'), nl,
    write('  Multiplication: [*, 4, 3].'), nl,
    write('  Division: [/, 10, 2].'), nl,
    write('  Power: [^, 2, 3].'), nl,
    write('  Variable assignment: set_variable(x, 5).'), nl,
    write('  Using variables: [+, x, 3].'), nl,
    write('  Complex expressions: [*, [+, 2, 3], 4].'), nl,
    calculator_loop.

calculator_loop :-
    write('> '),
    read(Input),
    (Input = exit -> true ;
     (Input = set_variable(Name, Value) ->
        (evaluate(Value, EvalValue) ->
            set_variable(Name, EvalValue) ;
            true) ;
        (evaluate(Input, Result) ->
            write(Result), nl ;
            true)),
     calculator_loop).

% Start the calculator
:- calculator. 