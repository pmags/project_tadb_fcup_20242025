#ifndef GEOM_OPS_H
#define GEOM_OPS_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libpq-fe.h>

// Global connection to PostgreSQL/PostGIS
extern PGconn *conn;

// Error handling helper
void exit_on_error(PGresult *res, const char *msg);

// Translate a geometry (in WKT) by dx and dy, return WKT result (allocated string)
void translate_geometry(const char *wkt, double dx, double dy, char **result);

// Return 1 if WKT1 and WKT2 are disjoint, 0 otherwise
int disjoint_geometry(const char *wkt1, const char *wkt2);

// Return the union of WKT1 and WKT2 as a new WKT string
void union_geometry(const char *wkt1, const char *wkt2, char **result);

#endif  // GEOM_OPS_H
