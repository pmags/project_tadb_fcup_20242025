#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <libpq-fe.h>
#include <Yap/YapInterface.h>

#include "geo_ops.h"


// YAP wrapper for transpose_geometry/4
YAP_Bool yap_transpose_geometry(void) {
    const char *wkt = YAP_AtomName(YAP_AtomOfTerm(YAP_ARG1));
    double dx = YAP_FloatOfTerm(YAP_ARG2);
    double dy = YAP_FloatOfTerm(YAP_ARG3);
    char *result = NULL;

    transpose_geometry(wkt, dx, dy, &result);
    if (!result)
        return FALSE;

    YAP_Term output = YAP_MkAtomTerm(YAP_LookupAtom(result));
    free(result);
    return YAP_Unify(YAP_ARG4, output);
}


// YAP wrapper for disjoint_geometry/3
YAP_Bool yap_disjoint_geometry(void) {
    const char *wkt1 = YAP_AtomName(YAP_AtomOfTerm(YAP_ARG1));
    const char *wkt2 = YAP_AtomName(YAP_AtomOfTerm(YAP_ARG2));

    int result = disjoint_geometry(wkt1, wkt2);
    YAP_Term bool_atom = YAP_MkAtomTerm(YAP_LookupAtom(result ? "true" : "false"));
    return YAP_Unify(YAP_ARG3, bool_atom);
}


// YAP wrapper for union_geometry/3
YAP_Bool yap_union_geometry(void) {
    const char *wkt1 = YAP_AtomName(YAP_AtomOfTerm(YAP_ARG1));
    const char *wkt2 = YAP_AtomName(YAP_AtomOfTerm(YAP_ARG2));
    char *result = NULL;

    union_geometry(wkt1, wkt2, &result);
    if (!result)
        return FALSE;

    YAP_Term output = YAP_MkAtomTerm(YAP_LookupAtom(result));
    free(result);
    return YAP_Unify(YAP_ARG3, output);
}



// Register foreign predicates with YAP
void init_my_lib(void) {

     printf(">>> init_my_lib called\n");

    // YAP_UserCPredicate("load_tetrominoes_list", yap_load_tetrominoes_list, 1);
    // YAP_UserCPredicate("load_puzzle", yap_load_puzzle, 2);
    // YAP_UserCPredicate("save_solution", yap_save_solution, 2);

    YAP_UserCPredicate("transpose_geometry", yap_transpose_geometry, 4);
    printf(">>> YAP_UserCPredicate transpose_geometry called\n");

    YAP_UserCPredicate("disjoint_geometry", yap_disjoint_geometry, 3);
    printf(">>> YAP_UserCPredicate disjoint_geometry called\n");

    YAP_UserCPredicate("union_geometry", yap_union_geometry, 3);
    printf(">>> YAP_UserCPredicate - union_geometry called\n");

    printf(">>> init_my_lib ended\n");
}
