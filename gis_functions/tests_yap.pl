

% tests_yap.pl - Testes para predicados YAP-C

:- initialization(run_tests).


run_tests :-
    test_transpose,
    test_disjoint,
    test_union,
    test_load_tetrominoes,
    test_load_puzzle,
    test_save_solution,
    writeln('Todos os testes concluídos.').


test_transpose :-
    transpose_geometry('POINT(1 1)', 2.0, 3.0, Result),
    writeln('transpose_geometry/4:'),
    writeln(Result),
    ( Result = 'POINT(3 4)' -> writeln('OK') ; writeln('FALHOU') ),
    nl.


test_disjoint :-
    writeln('disjoint_geometry/3:'),
    disjoint_geometry('POINT(1 1)', 'POINT(2 2)', R1),
    writeln(R1),
    ( R1 = true -> writeln('OK') ; writeln('FALHOU') ),
    disjoint_geometry('POINT(1 1)', 'POINT(1 1)', R2),
    writeln(R2),
    ( R2 = false -> writeln('OK') ; writeln('FALHOU') ),
    nl.

test_union :-
    union_geometry('POINT(1 1)', 'POINT(2 2)', Result),
    writeln('union_geometry/3:'),
    writeln(Result),
    ( sub_atom(Result, 0, _, _, 'MULTIPOINT') -> writeln('OK') ; writeln('FALHOU') ),
    nl.

test_load_tetrominoes :-
    load_tetrominoes_list(Geoms),
    writeln('load_tetrominoes_list/1:'),
    writeln(Geoms),
    ( nonvar(Geoms) -> writeln('OK') ; writeln('FALHOU') ),
    nl.


test_load_puzzle :-
    load_puzzle(1, PuzzleWKT),
    writeln('load_puzzle/2:'),
    writeln(PuzzleWKT),
    ( nonvar(PuzzleWKT) -> writeln('OK') ; writeln('FALHOU') ),
    nl.


test_save_solution :-
    save_solution(1, 'MULTIPOLYGON(((0 0,1 0,1 1,0 1,0 0)))'),
    writeln('save_solution/2: OK'),
    nl.
