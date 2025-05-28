

:- consult('../solver/solver.pl').


% ----------------------------------------------------------------------
% TEMP DATA
% ----------------------------------------------------------------------

% Define list_tetrominoes

list_tetrominoes([
    tetromino('T', 1, 'POLYGON((0 0,1 0,1 1,0 1,0 0))'),
    tetromino('T', 2, 'POLYGON((0 0,1 0,1 1,0 1,0 0))'),
    tetromino('I', 1, 'POLYGON((0 0,2 0,2 1,0 1,0 0))'),
    tetromino('L', 1, 'POLYGON((0 0,1 0,1 2,0 2,0 0))'),
    tetromino('S', 1, 'POLYGON((0 0,2 0,2 1,0 1,0 0))'),
    tetromino('Z', 1, 'POLYGON((0 0,2 0,2 1,0 1,0 0))')
]).

% Initial puzzle area as a WKT polygon
initial_puzzle(
    'MULTIPOLYGON(('
      '(0 0, 5 0, 5 5, 0 5, 0 0),'
      '(1 1, 1 2, 2 2, 2 1, 1 1)'  % This inner polygon is a hole inside the bigger polygon
    '))'
).


% ----------------------------------------------------------------------
% main test
% ----------------------------------------------------------------------

test_solver :-
    initial_puzzle(P),
    list_tetrominoes(Tetrominoes),
    solve(P, Tetrominoes, Final),
    format('Final puzzle WKT: ~w~n', [Final]),
    assertz(solved(Final)).

:- dynamic solved/1.
:- initialization(test_solver).
