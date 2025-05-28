
:- use_module(library(lists)).


:- consult('../solver/solver.pl').


% ----------------------------------------------------------------------
% Define list of tetrominoes
% ----------------------------------------------------------------------

list_tetrominoes([
    tetromino('T', 1, 'POLYGON((0 0,1 0,1 1,0 1,0 0))'),
    tetromino('T', 2, 'POLYGON((0 0,1 0,1 1,0 1,0 0))'),
    tetromino('I', 1, 'POLYGON((0 0,2 0,2 1,0 1,0 0))'),
    tetromino('L', 1, 'POLYGON((0 0,1 0,1 2,0 2,0 0))'),
    tetromino('S', 1, 'POLYGON((0 0,2 0,2 1,0 1,0 0))'),
    tetromino('Z', 1, 'POLYGON((0 0,2 0,2 1,0 1,0 0))')
]).



% ----------------------------------------------------------------------
% Define initial puzzle polygon with a hole (single quoted string)
% ----------------------------------------------------------------------
% Initial puzzle area as a WKT representation of a poligon with a hole

% Each polygon is written as ((outer ring), (hole1), (hole2), ...)
% The outer rings and holes are separate rings per polygon.
% If the intent is a single polygon with a hole, we use POLYGON with two rings:


initial_puzzle(
    'POLYGON((0 0, 5 0, 5 5, 0 5, 0 0)(1 1, 1 2, 2 2, 2 1, 1 1))'
).
% Note: There is no comma between the rings inside the polygon.





% ----------------------------------------------------------------------
% main test
% ----------------------------------------------------------------------


:- dynamic solved/1.

test_solver :-
    initial_puzzle(P),
    list_tetrominoes(Tetrominoes),
    solve(P, Tetrominoes, Final),
    format('Final puzzle WKT: ~w~n', [Final]),
    assertz(solved(Final)).

% Run test_solver on load (after initial_puzzle/1 is defined)
:- initialization(test_solver).
