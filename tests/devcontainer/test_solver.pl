:- use_module(library(lists)).
% This is the name of the lists library in YAP https://www.dcc.fc.up.pt/~vsc/yap/group__maplist.html
:- use_module(library(maplist)). 

:- format('Loading solver.pl...~n'),
   consult('../../solver/solver.pl'),
   format('****** Loaded solver.pl successfully ******.~n').

% ----------------------------------------------------------------------
% instructions to test the solver:
% 0. go to gis_functions and execute makefile if needed; invoque YAP.
% 1. ?- [export_functions_yap].
% 2. ?- consult('../tests/devcontainer/tests_yap.pl').
% 3. ?- consult('../tests/devcontainer/test_solver_def.pl').
% ----------------------------------------------------------------------



% ----------------------------------------------------------------------
% main test
% ----------------------------------------------------------------------

test_solver :-
    load_puzzle(1,P),
    format('\n {test1} load puzzle(1, P) returned: ~w~n', [P]),
    load_tetrominoes_list(Ts),
    format('\n {test2} load_tetrominoes_list(Ts) returned: ~w~n', [Ts]),
    InitialPlacedGeom = 'GEOMETRYCOLLECTION EMPTY',
    solve(P, InitialPlacedGeom, Ts, Final),
    format('\n {test3} Final puzzle WKT: ~w~n', [Ts]).
    save_solution(1, Ts),
    format('\n {test4} Solution saved successfully!~n'),
    assertz(solved(Final)).

:- initialization(test_solver).