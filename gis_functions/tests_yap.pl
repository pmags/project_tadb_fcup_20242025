% tests_yap.pl - Tests for YAP-C predicates

% Changelog:
% - Initial version
% - Added tests for transpose, disjoint, and union geometry functions
% - Added comments for clarity
% - Exact WKT string comparison in unions to make sure the result is exactly what you expect.



% How to:
% 1. cd gis_functions
% 2. make clean
% 3. make
% 4. yap 
% 5. ?- [export_functions_yap].
% 6, ?- [tests_yap].


:- initialization(run_tests).

run_tests :-
    test_transpose,
    test_disjoint,
    test_union,
    test_load_tetrominoes,
    test_load_puzzle,
    test_save_solution,
    writeln('All tests completed.').

% Helper to pretty print geometries in a tabular way
print_geoms_table(Geoms) :-
    writeln('Index | Geometry'),
    writeln('------+------------------------------------------------'),
    print_geoms_table(Geoms, 1).

print_geoms_table([], _).
print_geoms_table([G|Rest], I) :-
    format('~3d   | ~w~n', [I, G]),
    I1 is I + 1,
    print_geoms_table(Rest, I1).

test_transpose :-
    writeln('--- transpose_geometry/4 ---'),
    transpose_geometry('POINT(1 1)', 2.0, 3.0, R1),
    ( R1 = 'POINT(3 4)' -> writeln('POINT translate: OK') ; format('POINT translate: FAIL (Got ~w)~n', [R1]) ),

    transpose_geometry('POLYGON((0 0,1 0,1 1,0 1,0 0))', 2.0, 3.0, R2),
    ( R2 = 'POLYGON((2 3,3 3,3 4,2 4,2 3))' -> writeln('POLYGON translate: OK') ; format('POLYGON translate: FAIL (Got ~w)~n', [R2]) ),

    transpose_geometry('MULTIPOLYGON(((0 0,1 0,1 1,0 1,0 0)),((2 2,3 2,3 3,2 3,2 2)))', 1.0, 1.0, R3),
    ( R3 = 'MULTIPOLYGON(((1 1,2 1,2 2,1 2,1 1)),((3 3,4 3,4 4,3 4,3 3)))' -> writeln('MULTIPOLYGON translate: OK') ; format('MULTIPOLYGON translate: FAIL (Got ~w)~n', [R3]) ),
    nl.

test_disjoint :-
    writeln('--- disjoint_geometry/3 ---'),
    disjoint_geometry('POINT(1 1)', 'POINT(2 2)', R1),
    ( R1 = true -> writeln('Point vs Point disjoint (different): OK') ; writeln('Point vs Point disjoint (different): FAIL') ),

    disjoint_geometry('POINT(1 1)', 'POINT(1 1)', R2),
    ( R2 = false -> writeln('Point vs Point disjoint (same): OK') ; writeln('Point vs Point disjoint (same): FAIL') ),

    disjoint_geometry('POLYGON((0 0,1 0,1 1,0 1,0 0))',
                      'POLYGON((2 2,3 2,3 3,2 3,2 2))', R3),
    ( R3 = true -> writeln('Polygon vs Polygon disjoint: OK') ; writeln('Polygon vs Polygon disjoint: FAIL') ),

    disjoint_geometry('POLYGON((0 0,1 0,1 1,0 1,0 0))',
                      'MULTIPOLYGON(((0.5 0.5,1.5 0.5,1.5 1.5,0.5 1.5,0.5 0.5)))', R4),
    ( R4 = false -> writeln('Polygon vs Multipolygon overlapping (not disjoint): OK') ; writeln('Polygon vs Multipolygon overlapping: FAIL') ),

    disjoint_geometry('POLYGON((0 0,1 0,1 1,0 1,0 0))',
                      'MULTIPOLYGON(((2 2,3 2,3 3,2 3,2 2)))', R5),
    ( R5 = true -> writeln('Polygon vs Multipolygon disjoint: OK') ; writeln('Polygon vs Multipolygon disjoint: FAIL') ),
    nl.

test_union :-
    writeln('--- union_geometry/3 ---'),
    union_geometry('POINT(1 1)', 'POINT(2 2)', U1),
    ( U1 = 'MULTIPOINT((1 1),(2 2))' -> writeln('Point vs Point union: OK') ; format('Point vs Point union: FAIL (Got ~w)~n', [U1]) ),

    union_geometry('POLYGON((0 0,1 0,1 1,0 1,0 0))',
                   'POLYGON((1 0,2 0,2 1,1 1,1 0))', U2),
    ( U2 = 'POLYGON((0 0,1 0,2 0,2 1,1 1,1 0,1 1,0 1,0 0))'
      -> writeln('Polygon vs Polygon union: OK')
      ; format('Polygon vs Polygon union: FAIL (Got ~w)~n', [U2])
    ),

    union_geometry('POLYGON((0 0,1 0,1 1,0 1,0 0))',
                   'MULTIPOLYGON(((1 0,2 0,2 1,1 1,1 0)))', U3),
    ( U3 = 'MULTIPOLYGON(((0 0,1 0,1 1,0 1,0 0)),((1 0,2 0,2 1,1 1,1 0)))'
      -> writeln('Polygon vs Multipolygon union: OK')
      ; format('Polygon vs Multipolygon union: FAIL (Got ~w)~n', [U3])
    ),
    nl.

test_load_tetrominoes :-
    writeln('--- load_tetrominoes_list/1 ---'),
    load_tetrominoes_list(Geoms),
    ( nonvar(Geoms) ->
        length(Geoms, Count),
        format('Loaded ~d tetromino geometries:~n', [Count]),
        print_geoms_table(Geoms),
        writeln('load_tetrominoes_list: OK')
    ; writeln('load_tetrominoes_list: FAIL')
    ),
    nl.


test_load_puzzle :-
     load_puzzle(1, PuzzleWKT),
     writeln('load_puzzle/2:'),
     ( nonvar(PuzzleWKT) -> writeln('OK') ; writeln('FAIL') ),
     nl.

test_save_solution :-
     save_solution(1, 'MULTIPOLYGON(((0 0,1 0,1 1,0 1,0 0)))'),
     writeln('save_solution/2: OK'),
     nl.