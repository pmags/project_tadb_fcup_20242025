



% Tell YAP about the shared object and which predicates it defines
:- load_foreign_library('./yap2c_function.so').
:- foreign_file('./yap2c_function', [
    transpose_geometry/4,
    disjoint_geometry/3,
    union_geometry/3
]).

% Load it into memory
:- load_foreign_files.

% Export the predicates if you want to use them in other modules
:- export(transpose_geometry/4).
:- export(disjoint_geometry/3).
:- export(union_geometry/3).


