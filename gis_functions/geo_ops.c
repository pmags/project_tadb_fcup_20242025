#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libpq-fe.h>


// missing functions:
- load_db_tetraminoes_list()   returns the list of geoms of the tetraminoes (the 19, with the letter and seq)
- load_db_puzzle(puzzle_id)    returns the puzzle at its initial state (my view, it would be better to be a multipolygon, that is, the puzzle is a rectangle + the holes in its initial state
- save_db_solution(sol)        saves a multipoligon that represents the solution (the rectangle, the holes, and the tetrominoes inside it too. it saves in the solutions table.




PGconn *conn = NULL;

void exit_on_error(PGresult *res, const char *msg) {
    fprintf(stderr, "%s: %s\n", msg, PQerrorMessage(conn));
    if (res) PQclear(res);
    PQfinish(conn);
    exit(1);
}

// Transpose a geometry by Dx, Dy, and translate to WKT and return WKT in Result
void transpose_geometry(const char *wkt, double dx, double dy, char **result) {
    char sql[1024];
    snprintf(sql, sizeof(sql),
        "SELECT ST_AsText(ST_Translate(ST_GeomFromText($1, 4326), $2::float8, $3::float8))");

    const char *paramValues[3] = { wkt };
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





// Check if two geometries are disjoint
int disjoint_geometry(const char *wkt1, const char *wkt2) {
    const char *sql =
        "SELECT ST_Disjoint(ST_GeomFromText($1, 4326), ST_GeomFromText($2, 4326))";
    const char *paramValues[2] = { wkt1, wkt2 };

    PGresult *res = PQexecParams(conn, sql, 2, NULL, paramValues, NULL, NULL, 0);
    if (PQresultStatus(res) != PGRES_TUPLES_OK)
        exit_on_error(res, "disjoint_geometry failed");

    int is_disjoint = strcmp(PQgetvalue(res, 0, 0), "t") == 0;
    PQclear(res);
    return is_disjoint;
}





// Union two geometries and return WKT in Result
void union_geometry(const char *wkt1, const char *wkt2, char **result) {
    const char *sql =
        "SELECT ST_AsText(ST_Union(ST_GeomFromText($1, 4326), ST_GeomFromText($2, 4326)))";
    const char *paramValues[2] = { wkt1, wkt2 };

    PGresult *res = PQexecParams(conn, sql, 2, NULL, paramValues, NULL, NULL, 0);
    if (PQresultStatus(res) != PGRES_TUPLES_OK)
        exit_on_error(res, "union_geometry failed");

    *result = strdup(PQgetvalue(res, 0, 0));
    PQclear(res);
}





// Example usage
int main() {
    const char *conninfo = "dbname=postgres user=postgres password=postgres host=localhost";
    conn = PQconnectdb(conninfo);

    if (PQstatus(conn) != CONNECTION_OK) {
        fprintf(stderr, "Connection failed: %s\n", PQerrorMessage(conn));
        PQfinish(conn);
        return 1;
    }

    const char *poly1 = "POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))";
    const char *poly2 = "POLYGON((2 2, 2 3, 3 3, 3 2, 2 2))";

    char *translated = NULL;
    transpose_geometry(poly1, 1.0, 1.0, &translated);
    printf("Transposed Polygon: %s\n", translated);

    int disjoint = disjoint_geometry(translated, poly2);
    printf("Disjoint: %s\n", disjoint ? "true" : "false");

    char *merged = NULL;
    union_geometry(translated, poly2, &merged);
    printf("Union Geometry: %s\n", merged);

    free(translated);
    free(merged);

    PQfinish(conn);
    return 0;
}
