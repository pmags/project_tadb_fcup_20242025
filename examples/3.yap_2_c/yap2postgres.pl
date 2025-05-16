
% Load the compiled C shared library (without .so extension)
:- load_foreign_files(['./c2postgres_yap'], [], init).

% Declare the external predicate (ensure it matches the C function signature)
foreign(get_products, void, get_products).

% Export it to Prolog so you can call it
:- export(get_products/0).