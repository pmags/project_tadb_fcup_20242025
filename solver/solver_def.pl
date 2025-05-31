:- use_module(library(lists)).
:- use_module(library(maplist)).
:- use_module(library(geometry)).

:- consult('../gis_functions/export_functions_yap.pl').
:- consult('../tests/devcontainer/tests_yap.pl').

% ----------------------------------------------------------------------
% Main solve predicate with result printing
% ----------------------------------------------------------------------

solve(_, AccGeom, [], PlacedList, FinalPuzzle) :-
    FinalPuzzle = AccGeom,
    writeln('\******************** \nPuzzle solved lourenco!'),
    print_solution(PlacedList),
    !.

solve(Puzzle, AccGeom, [group(Letter, Variations) | RestGroups], PlacedList, FinalPuzzle) :-
    member(tetramino(Letter, Seq, TetWKT), Variations),
    try_place(TetWKT, Puzzle, AccGeom, PlacedTet),
    union_geometry(AccGeom, PlacedTet, NewAccGeom),
    solve(Puzzle, NewAccGeom, RestGroups, [placed(Letter, Seq, PlacedTet) | PlacedList], FinalPuzzle),
    !.

% ----------------------------------------------------------------------
% Try placing a tetromino without overlap, using smart offsets
% ----------------------------------------------------------------------

try_place(TetWKT, Puzzle, OccupiedGeom, PlacedTet) :-
    grid_offset(Puzzle, Dx, Dy),
    transpose_geometry(TetWKT, Dx, Dy, CandidatePlacedTetWKT),
    disjoint_geometry(CandidatePlacedTetWKT, OccupiedGeom, IsDisjointAtom),
    IsDisjointAtom == true,
    within_geometry(CandidatePlacedTetWKT, Puzzle, IsWithinAtom),
    IsWithinAtom == true,
    PlacedTet = CandidatePlacedTetWKT,
    !.

% ----------------------------------------------------------------------
% Generate translation offsets within puzzle bounds
% ----------------------------------------------------------------------

grid_offset(Puzzle, Dx, Dy) :-
    geometry_bbox(Puzzle, MinX, MinY, MaxX, MaxY),
    Step = 0.5,
    StepsX is floor((MaxX - MinX) / Step),
    StepsY is floor((MaxY - MinY) / Step),
    between(0, StepsX, IX),
    between(0, StepsY, IY),
    Dx is MinX + IX * Step,
    Dy is MinY + IY * Step.

% ----------------------------------------------------------------------
% Pretty print of the solution
% ----------------------------------------------------------------------

print_solution(PlacedList) :-
    reverse(PlacedList, OrderedPlaced),
    writeln('\n Placed Tetrominoes:'),
    forall(member(placed(Letter, Seq, WKT), OrderedPlaced),
           format('\n  ~w (Seq ~w): ~w~n', [Letter, Seq, WKT])).

% ----------------------------------------------------------------------
% Utility: Group tetrominoes by letter
% ----------------------------------------------------------------------

group_tetrominoes_by_letter(TetList, Grouped) :-
    findall(L, member(tetramino(L, _, _), TetList), Letters),
    sort(Letters, UniqueLetters),
    maplist(collect_group(TetList), UniqueLetters, Grouped).

collect_group(TetList, Letter, group(Letter, Variants)) :-
    include(same_letter(Letter), TetList, Variants).

same_letter(L, tetramino(L, _, _)).