#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <libpq-fe.h>
#include <Yap/YapInterface.h>
#include "geom_ops.h"



void init(void) {}



void get_products() {
    PGconn *conn = PQconnectdb("dbname=postgres user=postgres password=postgres host=localhost port=5432");
    if (PQstatus(conn) != CONNECTION_OK) {
        fprintf(stderr, "Connection to database failed: %s", PQerrorMessage(conn));
        PQfinish(conn);
        return;
    }

    PGresult *res = PQexec(conn, "SELECT 'nome é: ', name, price FROM products;");
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        fprintf(stderr, "Query failed: %s", PQerrorMessage(conn));
        PQclear(res);
        PQfinish(conn);
        return;
    }

    int rows = PQntuples(res);
    for (int i = 0; i < rows; i++) {
        char *name = PQgetvalue(res, i, 0);
        char *price = PQgetvalue(res, i, 1);
        printf("Product: %s | Price: %s\n", name, price);
    }

    PQclear(res);
    PQfinish(conn);
}





// YAP wrapper for translate_geometry/4
static YAP_Bool yap_translate_geometry(void) {
    char *wkt;
    double dx, dy;
    char *result = NULL;

    wkt = YAP_AtomName(YAP_AtomOfTerm(YAP_ARG1));
    dx = YAP_FloatOfTerm(YAP_ARG2);
    dy = YAP_FloatOfTerm(YAP_ARG3);

    translate_geometry(wkt, dx, dy, &result);

    if (!result)
        return false;

    YAP_Term output = YAP_MkAtomTerm(YAP_LookupAtom(result));
    free(result);
    return YAP_Unify(YAP_ARG4, output);
}




// YAP wrapper for disjoint_geometry/3
static YAP_Bool yap_disjoint_geometry(void) {
    char *wkt1 = YAP_AtomName(YAP_AtomOfTerm(YAP_ARG1));
    char *wkt2 = YAP_AtomName(YAP_AtomOfTerm(YAP_ARG2));

    int result = disjoint_geometry(wkt1, wkt2);
    return YAP_Unify(YAP_ARG3, result ? YAP_MkAtomTerm(YAP_LookupAtom("true")) : YAP_MkAtomTerm(YAP_LookupAtom("false")));
}





// YAP wrapper for union_geometry/3
static YAP_Bool yap_union_geometry(void) {
    char *wkt1 = YAP_AtomName(YAP_AtomOfTerm(YAP_ARG1));
    char *wkt2 = YAP_AtomName(YAP_AtomOfTerm(YAP_ARG2));
    char *result = NULL;

    union_geometry(wkt1, wkt2, &result);

    if (!result)
        return false;

    YAP_Term output = YAP_MkAtomTerm(YAP_LookupAtom(result));
    free(result);
    return YAP_Unify(YAP_ARG3, output);
}





// Install function to register predicates with YAP
void install(void) {
    YAP_UserCPredicate("translate_geometry", yap_translate_geometry, 4);
    YAP_UserCPredicate("disjoint_geometry", yap_disjoint_geometry, 3);
    YAP_UserCPredicate("union_geometry", yap_union_geometry, 3);
}

