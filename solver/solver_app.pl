:- use_module(library(maplist)).
:- use_module(library(system)).
% :- use_module(library(process)).
:- use_module(library(lists)).
:- consult('../gis_functions/export_functions_yap.pl').

% 1. ?- [export_functions_yap].
% ps: you will get some errors...foreign(...) does not exists. this is a false positive.

% if tests_yap.pl is in the same directory as export_functions_yap.pl, you can load it directly:
% 2, ?- [tests_yap].

% if tests_yap.pl is in /tests/devcontainer/    
% 2. ?- consult('../tests/devcontainer/tests_yap.pl').
% 2. ?- consult('../tests/devcontainer/test_solver.pl').


:- format('Loading solver.pl...~n'),
    consult('solver_def.pl'),
   format('****** Loaded solver.pl successfully ******.~n').



% ------------------------
% Plotting WKT using Python script with debug prints
% ------------------------

plot_wkt_from_prolog(WKT) :-
    format('DEBUG: Preparing to plot WKT geometry~n'),
    format(atom(Cmd), "python3 ../tests/devcontainer/test_wkt_plot.py  '~w'", [WKT]),
    format('DEBUG: Executing shell command: ~w~n', [Cmd]),
    shell(Cmd).

plot_tetromino(tetramino(Id, N, WKT)) :-
    format('DEBUG: Plotting tetromino ~w (variation ~w)...~n', [Id, N]),
    format(atom(Cmd), "python3 ../tests/devcontainer/test_wkt_plot.py '~w' '~w_~w'", [WKT, Id, N]),
    format('DEBUG: Executing shell command: ~w~n', [Cmd]),
    shell(Cmd).

plot_tetromino_unblockGUI(tetramino(Id, N, WKT)) :-
    format('DEBUG: Plotting tetromino ~w (variation ~w) synchronously (fallback)...~n', [Id, N]),
    format(atom(Fn), '~w_~w', [Id, N]),
    format(atom(Cmd), "python3 ../tests/devcontainer/test_wkt_plot.py '~w' '~w'", [WKT, Fn]),
    shell(Cmd),
    format('DEBUG: Finished synchronous plotting fallback~n').



% ------------------------
% Helpers
% ------------------------


group_tetrominoes_by_letter(TetList, Grouped) :-
    findall(L, member(tetramino(L, _, _), TetList), Letters),
    sort(Letters, UniqueLetters),
    maplist(collect_group(TetList), UniqueLetters, Grouped).

collect_group(TetList, Letter, group(Letter, Variants)) :-
    include(same_letter(Letter), TetList, Variants).

same_letter(L, tetramino(L, _, _)).





% ----------------------------------------------------------------------
% Main test predicate with debug prints
% ----------------------------------------------------------------------

test_solver(PuzzleID) :-  % Accept PuzzleID as a parameter

    load_puzzle(PuzzleID, P), % Use the PuzzleID parameter
    format('load_puzzle(~w, P) returned: ~w~n', [PuzzleID, P]),
    writeln('[DEBUG_SOLVER] 🚀 Loading tetrominoes from DB...'),

    load_tetrominoes_list(TetList),  % já é lista de tetramino/3
    format('[DEBUG_SOLVER] ✅ Loaded tetrominoes: ~w~n', [TetList]),
    group_tetrominoes_by_letter(TetList, TetrosGrouped),
    format('[DEBUG_SOLVER] Tetrominoes List by letter - INPUT: ~w~n', [TetList]),
    format('[DEBUG_SOLVER] Tetrominoes List by letter - OUTPUT: ~w~n', [TetrosGrouped]),
    
    solve(P, 'GEOMETRYCOLLECTION EMPTY', TetrosGrouped, [], FinalPuzzle),
    format('[DEBUG_SOLVER] 🧩 Final puzzle geometry: ~w~n', [FinalPuzzle]),
    save_solution(PuzzleID, FinalPuzzle).

% To run automatically with a default ID (e.g., 1) when the file is loaded:
% :- initialization(test_solver(1)).