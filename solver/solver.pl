



try_place(Poly, Occupied, Placed) :-
    grid_offset(Dx, Dy),                                         % Generate movement steps
    translate_geometry(Poly, Dx, Dy, Placed),                    % Move tetromino
    disjoint_geometry(Placed, Occupied).                         % Check no overlap

grid_offset(Dx, Dy) :-
    between(-10, 10, X),
    between(-10, 10, Y),
    Dx is X * 0.1,
    Dy is Y * 0.1.

% solve(Puzzle, Tetrominoes, PlacedTetrominoes)
% Puzzle is the current state of the puzzle
% Tetrominoes is the list of tetrominoes to place
% PlacedTetrominoes is the list of tetrominoes that have been successfully placed

solve(_, [], []).  % No tetrominoes left to place.

solve(Puzzle, [Tetromino|Rest], [Placed|RestPlaced]) :-
    try_place(Tetromino, Puzzle, Placed),            % Try placing the current tetromino
    union_geometry(Puzzle, Placed, NewPuzzle),       % Add it to the puzzle space
    solve(NewPuzzle, Rest, RestPlaced).              % Recurse with updated puzzle

