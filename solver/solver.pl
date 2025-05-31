:- use_module(library(maplist)). % This is the name of the lists library in YAP https://www.dcc.fc.up.pt/~vsc/yap/group__maplist.html
:- use_module(library(geometry)).  % Geometry predicates via C FFI

% Load geometry export bindings and test definitions
:- consult('../gis_functions/export_functions_yap.pl').
:- consult('../tests/devcontainer/tests_yap.pl').

% ----------------------------------------------------------------------
% Main solve predicate
% ----------------------------------------------------------------------

% Base case: no more tetrominoes to place, puzzle is solved
solve(Puzzle, AccumulatedPlacedGeom, [], Puzzle) :-
    format('Puzzle solved! Final puzzle WKT: ~w~n', [AccumulatedPlacedGeom]).

solve(Puzzle, AccumulatedPlacedGeom, AllTetrominoes, FinalPuzzle) :-
    AllTetrominoes = [tetramino(CurrentLetter, _, _) | _], 
    format('[solve] Attempting to place a tetromino of type ~w.~n', [CurrentLetter]),
    format('  Current Accumulated Geometry: ~w~n', [AccumulatedPlacedGeom]),
    format('  All available tetrominoes: ~w~n', [AllTetrominoes]),

    % Separate all variations of the CurrentLetter from other tetromino types

    partition(same_letter(CurrentLetter), AllTetrominoes, VariationsOfCurrentLetter, TetrominoesOfOtherLetters),
    format('  Variations for letter ~w: ~w~n', [CurrentLetter, VariationsOfCurrentLetter]),
    format('  Remaining tetromino types to process later: ~w~n', [TetrominoesOfOtherLetters]),

    % Iterate through each variation of the CurrentLetter (backtracks)

    member(tetramino(CurrentLetter, Seq, TetWKTToTry), VariationsOfCurrentLetter),
    format('  Attempting to place variation: ~w (Seq ~w), WKT: ~w~n', [CurrentLetter, Seq, TetWKTToTry]),
    
    try_place(TetWKTToTry, Puzzle, AccumulatedPlacedGeom, PlacedTet), % Attempt to place this specific variation
    format('  Successfully placed tetromino ~w (Seq ~w) as ~w~n', [CurrentLetter, Seq, PlacedTet]),
    
    union_geometry(AccumulatedPlacedGeom, PlacedTet, NewAccumulatedGeom),
    format('  New accumulated geometry after placing ~w (Seq ~w): ~w~n', [CurrentLetter, Seq, NewAccumulatedGeom]),

    % Recursively solve for the remaining types of tetrominoes
    format('  Proceeding to solve for remaining tetromino types: ~w~n', [TetrominoesOfOtherLetters]),
    solve(Puzzle, NewAccumulatedGeom, TetrominoesOfOtherLetters, FinalPuzzle).

# solve(Puzzle, AccumulatedPlacedGeom, [tetramino(Letter, Seq, TetWKT) | Rest], FinalPuzzle) :-
#     format('[solve recursive] Called. Tet: ~w (~w),  ~w~n; Puzzle: ~w~n', [Letter, Seq, TetWKT, Puzzle]),
    
#     % try_place(TetWKT, Puzzle,  PlacedTet),
#     try_place(TetWKT, Puzzle, AccumulatedPlacedGeom, PlacedTet),
#     format('Successfully placed tetromino ~w (Seq ~w) as ~w~n', [Letter, Seq, PlacedTet]),
    
#     union_geometry(AccumulatedPlacedGeom, PlacedTet, NewAccumulatedGeom),

#     format('\n New accumulated geometry: ~w~n', [NewAccumulatedGeom]),

#     % Remove all tetrominoes with the same Letter before continuing
#     exclude(same_letter(Letter), Rest, FilteredRest),
#     format('\n Filtered rest (removed same letter ~q): ~q~n', [Letter, FilteredRest]),
#     solve(Puzzle, NewAccumulatedGeom, FilteredRest, FinalPuzzle).


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
    format('  Trying offset Dx=~w, Dy=~w. Candidate: ~w~n', [Dx, Dy, CandidatePlacedTetWKT]),

    % Condition 1: Must be disjoint from already occupied geometry
    disjoint_geometry(CandidatePlacedTetWKT, OccupiedGeom, IsDisjointAtom),
    ( IsDisjointAtom == true ->
        format('    Disjoint from occupied: YES~n')
    ;
        format('    Disjoint from occupied: NO~n'),
        fail % Backtrack to try next offset or fail this try_place_tetromino call
    ),

    % Condition 2: Must be within the puzzle boundary
    within_geometry(CandidatePlacedTetWKT, Puzzle, IsWithinAtom),
    ( IsWithinAtom == true ->
        format('    Within boundary: YES~n'),
        PlacedTet = CandidatePlacedTetWKT % Success for this offset
    ;
        format('    Within boundary: NO~n'),
        fail % Backtrack to try next offset or fail
    ),
    !. % Cut: Found a valid placement for this TetWKT, commit to this offset.

# try_place(Tet, Occupied, Placed) :-
#     grid_offset(Dx, Dy),
#     transpose_geometry(Tet, Dx, Dy, Placed),
#     disjoint_geometry(Placed, Occupied, Disjoint),
#     Disjoint == true,
#     !.

# try_place(Tet, Occupied, Placed) :-
#     grid_offset(Dx, Dy),
#     format('Trying offset Dx=~w, Dy=~w~n', [Dx, Dy]),
#     transpose_geometry(Tet, Dx, Dy, Placed),
#     disjoint_geometry(Placed, Occupied, Disjoint),
#     (Disjoint == true ->
#         format('Disjoint: can place at (~w,~w)~n', [Dx, Dy])
#     ;
#         format('Not disjoint at (~w,~w)~n', [Dx, Dy]), fail),
#     !.


% ----------------------------------------------------------------------
% Generate translation offsets
% ----------------------------------------------------------------------

grid_offset(Dx, Dy) :-
    between(0, 10, X),
    between(0, 10, Y),
    Dx is X * 0.5,
    Dy is Y * 0.5.