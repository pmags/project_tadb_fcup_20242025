

:- use_module(library(maplist)).
:- use_module(library(system)).

:- format('Loading solver.pl...~n'),
   consult('../../solver/solver_def.pl'),
   format('****** Loaded solver.pl successfully ******.~n').

% ----------------------------------------------------------------------
% Human-readable puzzle printer
% ----------------------------------------------------------------------

print_human_readable_puzzle(WKT) :-
    open('solution_output.txt', append, Stream),
    split_geometrycollection(WKT, Geoms),
    length(Geoms, N),
    format(Stream, '------------------------~n', []),
    format(Stream, 'Puzzle contains ~d pieces:~n', [N]),
    print_geometries(Stream, Geoms, 1),
    format(Stream, '------------------------~n~n', []),
    close(Stream).

split_geometrycollection(WKT, Geoms) :-
    atom_string(WKT, WKTStr),
    (   sub_string(WKTStr, _, _, _, "GEOMETRYCOLLECTION(")
    ->  sub_string(WKTStr, 21, _, 1, Inside),
        split_string(Inside, "),(", "),(", Parts),
        maplist(clean_geom, Parts, Geoms)
    ;   Geoms = [WKTStr]  % Single geometry
    ).

clean_geom(Str, Cleaned) :-
    (sub_string(Str, 0, _, _, "(") -> Cleaned = Str ; string_concat("(", Str, Tmp), string_concat(Tmp, ")", Cleaned)).

print_geometries(_, [], _).
print_geometries(Stream, [G|Gs], N) :-
    format(Stream, '  Piece ~d: ~s~n', [N, G]),
    N1 is N + 1,
    print_geometries(Stream, Gs, N1).



% ----------------------------------------------------------------------
% Plot a WKT geometry using Python script
% ----------------------------------------------------------------------


plot_wkt_from_prolog(WKT) :-
    format(atom(Cmd), "python3 ..\tests\devcontainer\test_wkt_plot.py '~w'", [WKT]),
    shell(Cmd).


% ----------------------------------------------------------------------
% Main test predicate
% ----------------------------------------------------------------------

test_solver :-
    
    load_puzzle(1, P),
    format('\n{test1} load_puzzle(1, P) returned: ~w~n', [P]),
    plot_wkt_from_prolog(P),

    format('\n{test2} load tetrominoes list:\n'),
    load_tetrominoes_list(Ts),
    format('\n{test2} load_tetrominoes_list(Ts) returned: ~w~n', [Ts]),

    format('\n{test3} run_solver:\n', [Ts]),
    run_solver(P, InitialPlacedGeom, Ts, Final),
    Final = FinalPuzzle,

    % Final state print
    plot_wkt_from_prolog(FinalPuzzle),

    format('\n{test3} run_solver returned: ~w~n', [FinalPuzzle]),
    export_solution_geojson(FinalPuzzle),
    format('Exported solution to GeoJSON successfully!~n'),

    format('Backtrack statistics: ~n'),
    (stat_backtracks(Backtracks) -> true ; Backtracks = 0),
    format('Total backtracks: ~w~n', [Backtracks]),

    format('Saving solution...~n'),
    convert_tuples_to_tetraminoes(Ts, TetList),
    format('Converted tetrominoes: ~w~n', [TetList]),
    save_solution(1, Ts),
    format('\n{test4} Solution saved successfully!~n'),

    assertz(solved(FinalPuzzle)).

% ----------------------------------------------------------------------

:- initialization(test_solver).

