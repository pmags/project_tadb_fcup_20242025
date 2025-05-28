#ifndef GEO_OPS_H
#define GEO_OPS_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libpq-fe.h>


// Struct Tetramino
typedef struct {
    char letter;
    int seq;
    char *wkt;
} Tetramino;

// Inicialização e limpeza da conexão à base de dados
int init_db(void);
void cleanup_db(void);
void exit_on_error(PGresult *res, const char *msg);

// Operações geométricas com PostGIS via libpq

// Translada a geometria (wkt) por (dx, dy) e devolve a nova geometria em result (string alocada)
void transpose_geometry(const char *wkt, double dx, double dy, char **result);

// Verifica se duas geometrias (wkt1, wkt2) são disjuntas (retorna 1 se sim, 0 se não)
int disjoint_geometry(const char *wkt1, const char *wkt2);

// Une duas geometrias e devolve a geometria resultado em result (string alocada)
void union_geometry(const char *wkt1, const char *wkt2, char **result);

// Funções a implementar para carregar e salvar dados do puzzle e tetraminós

// Carrega a lista de tetraminós da base e devolve array dinâmico e count
Tetramino *load_db_tetraminoes_list(int *count);

// Carrega o puzzle identificado por puzzle_id e devolve a geometria WKT (string alocada)
char *load_db_puzzle(int puzzle_id);

// Salva a solução do puzzle (puzzle_id) representada como WKT multipolygon
void save_db_solution(int puzzle_id, const char *wkt_solution);

// Liberta recursos e fecha conexão
void finalize(void);

#endif /* GEO_OPS_H */