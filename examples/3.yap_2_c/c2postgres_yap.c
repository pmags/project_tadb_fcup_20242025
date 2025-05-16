#include <stdio.h>
#include <Yap.h> 
#include <libpq-fe.h>


void hello(void) {
    YAP_Term t = YAP_MkAtomTerm(YAP_LookupAtom("hello_from_c"));
    YAP_PutValue(YAP_LookupAtom("last_message"), t);
}

void get_products() {
    printf("get_products foi chamado!\n");
}
