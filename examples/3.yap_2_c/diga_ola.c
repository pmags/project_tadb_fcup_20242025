// diga_ola.c

// gcc -fPIC -shared -o diga_ola.so diga_ola.c

#include <stdio.h>

// Função de inicialização chamada automaticamente
void init_my_lib(void) {
    YAP_UserCPredicate("diga_ola", 0, 0, 0, 0, "diga_ola", 0);
    printf(">> Biblioteca C carregada com sucesso no YAP!\n");
}

// Outras funções exportadas
void diga_ola() {
    printf("Olá do C!\n");
}

int soma(int a, int b) {
    return a + b;
}