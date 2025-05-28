#ifndef GEO_OPS_H
#define GEO_OPS_H

#include <libpq-fe.h>

// Structure representing a Tetramino piece
typedef struct {
    char letter;
    int seq;
    char *wkt;
} Tetramino;

// Initialization and cleanup of the database connection
int init_db(void);
void cleanup_db(void);
void exit_on_error(PGresult *res, const char *msg);

// Geometric operations with PostGIS via libpq

// Translates the geometry (wkt) by (dx, dy) and returns the new geometry in result (allocated string)
void transpose_geometry(const char *wkt, double dx, double dy, char **result);

// Checks if two geometries (wkt1, wkt2) are disjoint (returns 1 if yes, 0 if no)
int disjoint_geometry(const char *wkt1, const char *wkt2);

// Unites two geometries and returns the resulting geometry in result (allocated string)
void union_geometry(const char *wkt1, const char *wkt2, char **result);

// Functions to implement for loading and saving puzzle and tetramino data

// Loads the list of tetraminoes from the database and returns a dynamic array and count
Tetramino *load_db_tetraminoes_list(int *count);

// Loads the puzzle identified by puzzle_id and returns the geometry WKT (allocated string)
char *load_db_puzzle(int puzzle_id);

// Saves the puzzle solution (puzzle_id) represented as a multipolygon WKT
void save_db_solution(int puzzle_id, const char *wkt_solution);

// Frees resources and closes the connection
void finalize(void);

#endif /* GEO_OPS_H */
