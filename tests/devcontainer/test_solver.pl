:- use_module(library(lists)).

:- format('Loading solver.pl...~n'),
   consult('../../solver/solver.pl'),
   format('****** Loaded solver.pl successfully ******.~n').

% ----------------------------------------------------------------------
% instructions to test the solver:
% 0. go to gis_functions and execute makefile if needed; invoque YAP.
% 1. ?- [export_functions_yap].
% 2. ?- consult('../tests/devcontainer/tests_yap.pl').
% 3. ?- consult('../tests/devcontainer/test_solver.pl').
% ----------------------------------------------------------------------



% ----------------------------------------------------------------------
% main test
% ----------------------------------------------------------------------

test_solver :-
    load_puzzle(1,P),
    format('\n 1) load puzzle(1, P) returned: ~w~n', [P]),
    load_tetrominoes_list(Ts),
    format('\n 2) load_tetrominoes_list(Ts) returned: ~w~n', [Ts]),
    solve(P, Ts, Final),
    format('\n 3) ✅ Final puzzle WKT: ~w~n', [Final]),
    save_solution(1, Final),
    format('\n 4) 💾 Solution saved successfully!~n'),
    assertz(solved(Final)).

:- initialization(test_solver).