#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <libpq-fe.h>
#include <Yap/YapInterface.h>

#include "geo_ops.h"



void init(void) {}



// YAP wrapper for translate_geometry/4
static int yap_transpose_geometry(void) {
    char *wkt;
    double dx, dy;
    char *result = NULL;

    wkt = YAP_AtomName(YAP_AtomOfTerm(YAP_ARG1));
    dx = YAP_FloatOfTerm(YAP_ARG2);
    dy = YAP_FloatOfTerm(YAP_ARG3);

    transpose_geometry(wkt, dx, dy, &result);

    if (!result)
        return false;

    YAP_Term output = YAP_MkAtomTerm(YAP_LookupAtom(result));
    free(result);
    YAP_Unify(YAP_ARG4, output);
    return TRUE;
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
void YAP_UserInit(void) {
    YAP_UserCPredicate("transpose_geometry", yap_transpose_geometry, 4);
    YAP_UserCPredicate("disjoint_geometry", yap_disjoint_geometry, 3);
    YAP_UserCPredicate("union_geometry", yap_union_geometry, 3);
}

