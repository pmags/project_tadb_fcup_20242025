:- use_module(library(lists)).
:- use_module(library(maplist)).
:- use_module(library(geometry)).

:- consult('../gis_functions/export_functions_yap.pl').
:- consult('../tests/devcontainer/tests_yap.pl').

% ----------------------------------------------------------------------
% Main solve predicate
% ----------------------------------------------------------------------

solve(_, AccumulatedPlacedGeom, [], AccumulatedPlacedGeom).

solve(Puzzle, AccumulatedPlacedGeom, AllTetrominoes, FinalPuzzle) :-
    AllTetrominoes = [tetramino(CurrentLetter, _, _) | _], 
    partition(same_letter(CurrentLetter), AllTetrominoes, VariationsOfCurrentLetter, TetrominoesOfOtherLetters),
    member(tetramino(CurrentLetter, Seq, TetWKTToTry), VariationsOfCurrentLetter),
    try_place(TetWKTToTry, Puzzle, AccumulatedPlacedGeom, PlacedTet),
    union_geometry(AccumulatedPlacedGeom, PlacedTet, NewAccumulatedGeom),
    solve(Puzzle, NewAccumulatedGeom, TetrominoesOfOtherLetters, FinalPuzzle).

% ----------------------------------------------------------------------
% same_letter
% ----------------------------------------------------------------------

same_letter(Letter, tetramino(Letter, _, _)).

% ----------------------------------------------------------------------
% Try placing a tetromino without overlap
% ----------------------------------------------------------------------

try_place(TetWKT, Puzzle, OccupiedGeom, PlacedTet) :-
    grid_offset(Dx, Dy),
    transpose_geometry(TetWKT, Dx, Dy, CandidatePlacedTetWKT),
    disjoint_geometry(CandidatePlacedTetWKT, OccupiedGeom, IsDisjointAtom),
    IsDisjointAtom == true,
    within_geometry(CandidatePlacedTetWKT, Puzzle, IsWithinAtom),
    IsWithinAtom == true,
    PlacedTet = CandidatePlacedTetWKT.

% ----------------------------------------------------------------------
% Generate translation offsets
% ----------------------------------------------------------------------

grid_offset(Dx, Dy) :-
    step_size(Step),
    grid_size(MaxX, MaxY),
    between(0, MaxX, X),
    between(0, MaxY, Y),
    Dx is X * Step,
    Dy is Y * Step.

step_size(0.5).
grid_size(10, 10).
