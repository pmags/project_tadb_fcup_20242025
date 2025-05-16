// c2postgres_yap.c
#include <stdio.h>
#include <libpq-fe.h>


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


