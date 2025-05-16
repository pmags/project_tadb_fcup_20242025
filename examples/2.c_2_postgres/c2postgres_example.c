



// This code connects to a PostgreSQL database and retrieves data from a table.
// It uses the libpq library, which is the C API for PostgreSQL.

// Make sure to install the PostgreSQL development package to use libpq.

// Example command to compile the code:
// gcc -I/usr/include/postgresql c2postgres_example.c -o c2postgres_example -lpq

// Example command to run the code:
// ./c2postgres_example

// Example code to connect to a PostgreSQL database and retrieve data using C
// This code connects to a PostgreSQL database and retrieves data from a table.
// It uses the libpq library, which is the C API for PostgreSQL.
// Make sure to install the PostgreSQL development package to use libpq.            




#include <stdio.h>
#include <stdlib.h>
#include <libpq-fe.h>  // libpq is the PostgreSQL C API

// Function to handle errors
void exit_on_error(PGconn *conn, PGresult *res, const char *msg) {
    if (PQstatus(conn) != CONNECTION_OK) {
        fprintf(stderr, "Connection to database failed: %s", PQerrorMessage(conn));
        exit(1);
    }
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        fprintf(stderr, "%s failed: %s", msg, PQerrorMessage(conn));
        exit(1);
    }
}

int main() {
    // Connection parameters
    const char *conninfo = "dbname=postgres user=postgres password=postgres host=localhost port=5432";

    // Connect to the PostgreSQL database
    PGconn *conn = PQconnectdb(conninfo);

    // Check the connection status
    if (PQstatus(conn) != CONNECTION_OK) {
        fprintf(stderr, "Connection to database failed: %s", PQerrorMessage(conn));
        exit(1);
    }

    // Execute a simple query to fetch all rows from a table
    const char *sql = "SELECT * FROM products";
    PGresult *res = PQexec(conn, sql);
    
    // Check if the query was successful
    exit_on_error(conn, res, "SELECT");

    // Get the number of rows and columns
    int nrows = PQntuples(res);
    int ncols = PQnfields(res);

    // Print the query result
    for (int row = 0; row < nrows; row++) {
        for (int col = 0; col < ncols; col++) {
            printf("%s = %s\n", PQfname(res, col), PQgetvalue(res, row, col));
        }
        printf("\n");
    }

    // Clean up
    PQclear(res);
    PQfinish(conn);

    return 0;
}

