


% Load the shared object and initialize predicates by calling init_my_lib/0
:- load_foreign_files(['./yap2c_functions.so'], [], init_my_lib).
:- consult(sqlcompiler).



% transpose_geometry(+InputWKT, +Dx, +Dy, -OutputWKT)
:- foreign(transpose_geometry, c, transpose_geometry(+atom, +float, +float, -atom)).

% disjoint_geometry(+WKT1, +WKT2, -ResultAtom) where ResultAtom = 'true' or 'false'
:- foreign(disjoint_geometry, c, disjoint_geometry(+atom, +atom, -atom)).

% union_geometry(+WKT1, +WKT2, -OutputWKT)
:- foreign(union_geometry, c, union_geometry(+atom, +atom, -atom)).




% load_tetrominoes_list(-WKTMultipolygon)
:- foreign(load_tetrominoes_list, c, load_tetrominoes_list(-atom)).

% load_puzzle(+PuzzleID, -WKTMultipolygon)
:- foreign(load_puzzle, c, load_puzzle(+integer, -atom)).

% save_solution(+PuzzleID, +WKTMultipolygon)
:- foreign(save_solution, c, save_solution(+integer, +atom)).