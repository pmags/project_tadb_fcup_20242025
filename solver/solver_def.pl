:- use_module(library(lists)).
:- use_module(library(maplist)).
:- use_module(library(geometry)).
:- use_module(library(filesex)).

:- consult('../gis_functions/export_functions_yap.pl').
:- consult('../tests/devcontainer/tests_yap.pl').

% ----------------------------------------------------------------------
% Entry point
% ----------------------------------------------------------------------

run_solver(Puzzle) :-
    load_tetrominoes(Tuples),
    convert_tuples_to_tetraminoes(Tuples, TetList),
    group_tetrominoes_by_letter(TetList, Grouped),
    retractall(stat_backtracks(_)),
    solve(Puzzle, '', Grouped, [], _).

convert_tuples_to_tetraminoes([], []).
convert_tuples_to_tetraminoes([(L, S, WKT) | Rest], [tetramino(L, S, WKT) | TetRest]) :-
    convert_tuples_to_tetraminoes(Rest, TetRest).

% ----------------------------------------------------------------------
% Main solve predicate with result printing and statistics
% ----------------------------------------------------------------------

:- dynamic(stat_backtracks/1).

solve(_, AccGeom, [], PlacedList, FinalPuzzle) :-
    FinalPuzzle = AccGeom,
    writeln('puzzle solved lourenco!'),
    print_solution_to_file(PlacedList),
    export_solution_geojson(PlacedList),
    print_backtrack_statistics,
    !.

solve(Puzzle, AccGeom, [group(Letter, Variations) | RestGroups], PlacedList, FinalPuzzle) :-
    member(tetramino(Letter, Seq, TetWKT), Variations),
    increment_backtrack,
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
% Pretty print solution to file with separators
% ----------------------------------------------------------------------

print_solution_to_file(PlacedList) :-
    reverse(PlacedList, OrderedPlaced),
    open('solution.txt', write, Stream),
    write(Stream, '==== Puzzle Solution ====\n'),
    forall(member(placed(Letter, Seq, WKT), OrderedPlaced), (
        format(Stream, 'Tetromino ~w (Seq ~w):~n', [Letter, Seq]),
        format(Stream, '~w~n', [WKT]),
        write(Stream, '-------------------------\n')
    )),
    write(Stream, '==== End of Solution ====\n'),
    close(Stream).

% ----------------------------------------------------------------------
% Export result as GeoJSON for visualisation
% ----------------------------------------------------------------------

export_solution_geojson(PlacedList) :-
    reverse(PlacedList, OrderedPlaced),
    maplist(placed_to_feature, OrderedPlaced, Features),
    GeoJSON = json([type='FeatureCollection', features=Features]),
    open('solution.geojson', write, Stream),
    json_write(Stream, GeoJSON),
    close(Stream),
    writeln('GeoJSON exported to solution.geojson').

placed_to_feature(placed(Letter, Seq, WKT), json([
    type='Feature',
    properties=json([letter=Letter, seq=Seq]),
    geometry=json([type='Polygon', coordinates=Coords])
])) :-
    wkt_to_coords(WKT, Coords).

wkt_to_coords(WKT, Coords) :-
    % Assuming helper exists to parse WKT to coordinate lists
    wkt_to_prolog(WKT, MultiPolygon),
    MultiPolygon =.. [_, Outer],
    Coords = Outer.

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

% ----------------------------------------------------------------------
% Backtrack counter
% ----------------------------------------------------------------------

increment_backtrack :-
    (   stat_backtracks(N) -> N1 is N + 1 ; N1 = 1),
    retractall(stat_backtracks(_)),
    assertz(stat_backtracks(N1)).

print_backtrack_statistics :-
    (   stat_backtracks(N) -> true ; N = 0),
    format('Backtracking attempts: ~d~n', [N]).




% ----------------------------------------------------------------------
% print_human_readable_puzzle/1
% Converts a GEOMETRYCOLLECTION WKT to a human-readable format
% for puzzle pieces, printing each piece on a new line.
% This is useful for debugging and understanding the puzzle structure.
% ----------------------------------------------------------------------



% Example predicate to parse and print a WKT geometry collection nicely
print_human_readable_puzzle(WKT) :-
    % Split the GEOMETRYCOLLECTION WKT into individual geometries
    split_geometrycollection(WKT, Geoms),
    format('Puzzle contains ~d pieces:~n', [length(Geoms)]),
    print_geometries(Geoms, 1).

% Splits a GEOMETRYCOLLECTION WKT string into list of WKT polygons
split_geometrycollection(WKT, Geoms) :-
    % Remove the prefix "GEOMETRYCOLLECTION(" and the trailing ")"
    atom_string(WKTAtom, WKT),
    atom_concat('GEOMETRYCOLLECTION(', Rest1, WKTAtom),
    sub_atom(Rest1, 0, _, 1, Inside),  % remove trailing ')'
    % Now split by "),(" or "), ("
    split_geoms(Inside, Geoms).

split_geoms(String, Geoms) :-
    split_string(String, "),(", "),(", Parts),
    maplist(clean_geom, Parts, Geoms).

clean_geom(Str, Cleaned) :-
    % Add parentheses back if they were removed during split
    string_concat('(', Str0, Str),
    string_concat(Clean, ')', Str0),
    string_concat('(', Clean, Cleaned), !.
clean_geom(Str, Str).

print_geometries([], _).
print_geometries([G|Gs], N) :-
    format('  Piece ~d: ~s~n', [N, G]),
    N1 is N + 1,
    print_geometries(Gs, N1).

