
% Load the compiled C shared library (without .so extension)
:- load_foreign_files(['./yap2c_functions'], [], init).

% Declare the external predicate (ensure it matches the C function signature)
foreign(get_products, void, get_products).

% Export it to Prolog so you can call it
:- export(get_products/0).
:- export(translate_geometry/3).
:- export(disjoint_geometry/2). 
:- export(union_geometry/3).