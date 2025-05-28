:- use_module(library(lists)).
:- use_module(library(geometry)).  % Geometry predicates via C FFI

% Load geometry export bindings and test definitions
:- consult('../gis_functions/export_functions_yap.pl').
:- consult('../tests/devcontainer/tests_yap.pl').

% ----------------------------------------------------------------------
% Main solve predicate
% ----------------------------------------------------------------------

% Base case: no more tetrominoes to place, puzzle is solved
solve(Puzzle, [], Puzzle) :-
    format('Puzzle solved! Final puzzle WKT: ~w~n', [Puzzle]).

solve(Puzzle, [tetromino(Letter, Seq, TetWKT) | Rest], FinalPuzzle) :-
    try_place(TetWKT, Puzzle, PlacedTet),
    union_geometry(Puzzle, PlacedTet, NewPuzzle),
    format('Placed tetromino ~w (seq ~w), new puzzle shape: ~w~n', [Letter, Seq, NewPuzzle]),
    % Remove all tetrominoes with the same Letter before continuing
    exclude(same_letter(Letter), Rest, FilteredRest),
    solve(NewPuzzle, FilteredRest, FinalPuzzle).


% ----------------------------------------------------------------------
% same_letter
% ----------------------------------------------------------------------

same_letter(Letter, tetromino(Letter, _, _)).

% ----------------------------------------------------------------------
% Try placing a tetromino without overlap
% ----------------------------------------------------------------------

try_place(Tet, Occupied, Placed) :-
    grid_offset(Dx, Dy),
    transpose_geometry(Tet, Dx, Dy, Placed),
    disjoint_geometry(Placed, Occupied, Disjoint),
    Disjoint == true,
    !.

try_place(Tet, Occupied, Placed) :-
    grid_offset(Dx, Dy),
    format('Trying offset Dx=~w, Dy=~w~n', [Dx, Dy]),
    transpose_geometry(Tet, Dx, Dy, Placed),
    disjoint_geometry(Placed, Occupied, Disjoint),
    (Disjoint == true ->
        format('✔ Disjoint: can place at (~w,~w)~n', [Dx, Dy])
    ;
        format('❌ Not disjoint at (~w,~w)~n', [Dx, Dy]), fail),
    !.


% ----------------------------------------------------------------------
% Generate translation offsets
% ----------------------------------------------------------------------

grid_offset(Dx, Dy) :-
    between(0, 5, X),
    between(0, 5, Y),
    Dx is X * 0.5,
    Dy is Y * 0.5.

