#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libpq-fe.h>


// missing functions: @GiuseppePitruzzella
//- load_db_tetraminoes_list()   returns the list of geoms of the tetraminoes (the 19, with the letter and seq)
//- load_db_puzzle(puzzle_id)    returns the puzzle at its initial state (my view, it would be better to be a multipolygon, that is, the puzzle is a rectangle + the holes in its initial state
//- save_db_solution(sol)        saves a multipoligon that represents the solution (the rectangle, the holes, and the tetrominoes inside it too. it saves in the solutions table.


static PGconn *conn = NULL;
const char *conninfo = "dbname=postgres user=postgres password=postgres host=localhost";


typedef struct {
    char letter;
    int seq;
    char *wkt;
} Tetramino;



int init_db() {
    if (!conn) {
        conn = PQconnectdb(conninfo);
        if (PQstatus(conn) != CONNECTION_OK) {
            fprintf(stderr, "Connection failed: %s\n", PQerrorMessage(conn));
            PQfinish(conn);
            conn = NULL;
            return 1;
        }
    }
return 0;
}




// --------------------------------------------------
// load_db_tetraminoes_list/1
Tetramino *load_db_tetraminoes_list(int *count) {
    init_db();

    const char *sql = "SELECT letter, var_id, ST_AsText(geom) FROM tetrominoes ORDER BY id";
    PGresult *res = PQexecParams(conn, sql, 0, NULL, NULL, NULL, NULL, 0);

    if (PQresultStatus(res) != PGRES_TUPLES_OK)
        exit_on_error(res, "Failed to load tetrominoes");

    int rows = PQntuples(res);
    Tetramino *list = malloc(sizeof(Tetramino) * rows);
    if (!list) exit_on_error(res, "Memory allocation failed");

    for (int i = 0; i < rows; i++) {
        list[i].letter = PQgetvalue(res, i, 0)[0];
        list[i].seq = atoi(PQgetvalue(res, i, 1));
        list[i].wkt = strdup(PQgetvalue(res, i, 2));
    }

    PQclear(res);
    *count = rows;
    return list;
}





// --------------------------------------------------
// load_db_puzzle/1
char *load_db_puzzle(int puzzle_id) {
    init_db();

    const char *sql = "SELECT ST_AsText(geom) FROM puzzles WHERE id = $1";
    char id_str[16];
    snprintf(id_str, sizeof(id_str), "%d", puzzle_id);
    const char *params[1] = { id_str };

    PGresult *res = PQexecParams(conn, sql, 1, NULL, params, NULL, NULL, 0);

    if (PQresultStatus(res) != PGRES_TUPLES_OK || PQntuples(res) == 0)
        exit_on_error(res, "Puzzle not found");

    char *geom = strdup(PQgetvalue(res, 0, 0));
    PQclear(res);
    return geom;
}

// --------------------------------------------------
// save_db_solution/2
void save_db_solution(int puzzle_id, const char *wkt_solution) {
    init_db();

    const char *sql =
        "INSERT INTO solutions (solution_id, puzzle_id, geom) "
        "VALUES (DEFAULT, $1::int, ST_GeomFromText($2, 4326))";

    char id_str[16];
    snprintf(id_str, sizeof(id_str), "%d", puzzle_id);
    const char *params[2] = { id_str, wkt_solution };

    PGresult *res = PQexecParams(conn, sql, 2, NULL, params, NULL, NULL, 0);

    if (PQresultStatus(res) != PGRES_COMMAND_OK)
        exit_on_error(res, "Failed to save puzzle solution");

    PQclear(res);
}



void cleanup_db() {
    if (conn) {
        PQfinish(conn);
        conn = NULL;
    }
}



void exit_on_error(PGresult *res, const char *msg) {
    fprintf(stderr, "%s: %s\n", msg, PQerrorMessage(conn));
    if (res) PQclear(res);
    cleanup_db();
    exit(1);
}


// transpose_geometry/4
// Transpose a geometry by Dx, Dy, and translate to WKT and return WKT in Result
void transpose_geometry(const char *wkt, double dx, double dy, char **result) {
    char sql[1024];

    init_db();
    snprintf(sql, sizeof(sql),
        "SELECT ST_AsText(ST_Translate(ST_GeomFromText($1, 4326), $2::float8, $3::float8))");

    char *paramValues[3] = { wkt };
    char dx_str[64], dy_str[64];
    snprintf(dx_str, sizeof(dx_str), "%lf", dx);
    snprintf(dy_str, sizeof(dy_str), "%lf", dy);
    paramValues[1] = dx_str;
    paramValues[2] = dy_str;

    PGresult *res = PQexecParams(conn, sql, 3, NULL, paramValues, NULL, NULL, 0);
    if (PQresultStatus(res) != PGRES_TUPLES_OK)
        exit_on_error(res, "translate_geometry failed");

    *result = strdup(PQgetvalue(res, 0, 0));
    PQclear(res);
}




// --------------------------------------------------
// disjoint_geometry/3
// Check if two geometries are disjoint
int disjoint_geometry(const char *wkt1, const char *wkt2) {
    const char *sql =
        "SELECT ST_Disjoint(ST_GeomFromText($1, 4326), ST_GeomFromText($2, 4326))";
    const char *paramValues[2] = { wkt1, wkt2 };

    init_db();
    PGresult *res = PQexecParams(conn, sql, 2, NULL, paramValues, NULL, NULL, 0);
    if (PQresultStatus(res) != PGRES_TUPLES_OK)
        exit_on_error(res, "disjoint_geometry failed");

    int is_disjoint = strcmp(PQgetvalue(res, 0, 0), "t") == 0;
    PQclear(res);
    return is_disjoint;
}




// --------------------------------------------------
// union_geometry/3
// Union two geometries and return WKT in Result
void union_geometry(const char *wkt1, const char *wkt2, char **result) {
    const char *sql =
        "SELECT ST_AsText(ST_Union(ST_GeomFromText($1, 4326), ST_GeomFromText($2, 4326)))";
    const char *paramValues[2] = { wkt1, wkt2 };

    init_db();
    PGresult *res = PQexecParams(conn, sql, 2, NULL, paramValues, NULL, NULL, 0);
    if (PQresultStatus(res) != PGRES_TUPLES_OK)
        exit_on_error(res, "union_geometry failed");

    *result = strdup(PQgetvalue(res, 0, 0));
    PQclear(res);
}



// --------------------------------------------------
void finalize(void) {
    cleanup_db();
}








