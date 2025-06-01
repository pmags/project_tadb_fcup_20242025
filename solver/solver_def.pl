:- use_module(library(maplist)).

:- dynamic stat_backtracks/1.

% executing in gis_functions directory
% fazer consult('export_functions_yap.pl').



% ----------------------
% Main solver with backtrack and solution export
% ----------------------

solve(_, AccGeom, [], PlacedList, FinalPuzzle) :-
    writeln('\n[DEBUG_SOLVER] ✅ Puzzle solved! Final geometry computed.'),
    FinalPuzzle = AccGeom,
    writeln('\n[DEBUG_SOLVER] 🎉 Solver finished successfully.').

solve(Puzzle, AccGeom, [group(Letter, Variations) | RestGroups], PlacedList, FinalPuzzle) :-
    format('\n[DEBUG_SOLVER] 🔍 Exploring tetromino group ~w ...\n', [Letter]),
    member(tetramino(Letter, Seq, TetWKT), Variations),
    format('\n[DEBUG_SOLVER] ➡️  Trying tetramino ~w-~w\n', [Letter, Seq]),
    try_place(TetWKT, Puzzle, AccGeom, PlacedTet),
    format('\n[DEBUG_SOLVER] ✅ Successfully placed tetromino ~w-~w with iteration | ~w | \n', [Letter, Seq, PlacedTet]),
    union_geometry(AccGeom, PlacedTet, NewAccGeom),
    solve(Puzzle, NewAccGeom, RestGroups, [placed(Letter, Seq, PlacedTet) | PlacedList], FinalPuzzle).




% ----------------------
% Try placing tetromino with offsets inside puzzle bounds
% ----------------------

try_place(TetWKT, Puzzle, OccupiedGeom, PlacedTet) :-
    grid_offset(Dx, Dy),
    format('[DEBUG_TRY_PLACE] Testing offset Dx=~w Dy=~w~n', [Dx, Dy]),

    transpose_geometry(TetWKT, Dx, Dy, CandidatePlacedTetWKT),
    format('[DEBUG_TRY_PLACE] Transposed TetWKT: ~w~n', [CandidatePlacedTetWKT]),

    disjoint_geometry(CandidatePlacedTetWKT, OccupiedGeom, true),
    format('[DEBUG_TRY_PLACE] ✅ Disjoint with occupied geometry ~w ~w~n', [TetWKT, OccupiedGeom]),

    within_geometry(CandidatePlacedTetWKT, Puzzle, true),
    format('[DEBUG_TRY_PLACE] ✅ Within puzzle bounds ~w ~w~n', [TetWKT, OccupiedGeom]),

    PlacedTet = CandidatePlacedTetWKT,
    format('[DEBUG_TRY_PLACE] ✅ Placed Tetromino: ~w ~w ~w~n', [TetWKT, OccupiedGeom, PlacedTet]).





% ----------------------
% Generate translation offsets grid within puzzle bbox
% ----------------------

grid_offset(Dx, Dy) :-
    between(0, 10, X),
    between(-1, 4, Y),
    Dx is float(X),
    Dy is float(Y).

