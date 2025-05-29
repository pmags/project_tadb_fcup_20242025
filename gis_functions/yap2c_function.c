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



// Helper: create a YAP list from array of WKT strings (Tetramino *)
static YAP_Term create_wkt_list(char **wkt_array, int count) {
    YAP_Term list = YAP_MkAtomTerm(YAP_LookupAtom("[]")); // empty list
    for (int i = count - 1; i >= 0; i--) {
        YAP_Term head = YAP_MkAtomTerm(YAP_LookupAtom(wkt_array[i]));
        list = YAP_MkPairTerm(head, list);
    }
    return list;
}


// Wrapper for load_tetrominoes_list(-List)
YAP_Bool yap_load_tetrominoes_list(void) {
    // 1 argument: output list
    if (!YAP_IsVarTerm(YAP_ARG1)) {
        return FALSE;
    }

    int count = 0;
    Tetramino *tets = load_db_tetraminoes_list(&count);
    if (!tets || count == 0) {
        return FALSE;
    }

    // Assuming Tetramino struct has a member `char *wkt` for geometry
    char **wkt_array = malloc(sizeof(char *) * count);
    if (!wkt_array) {
        free(tets);
        return FALSE;
    }

    for (int i = 0; i < count; i++) {
        wkt_array[i] = tets[i].wkt; // Assuming 'wkt' is a null-terminated string
    }

    YAP_Term wkt_list = create_wkt_list(wkt_array, count);
    free(wkt_array);
    free(tets);

    return YAP_Unify(YAP_ARG1, wkt_list);
}







// Wrapper for load_puzzle(+PuzzleID, -WKT)
YAP_Bool yap_load_puzzle(void) {
    if (!YAP_IsIntTerm(YAP_ARG1)) return FALSE;
    if (!YAP_IsVarTerm(YAP_ARG2)) return FALSE;

    int puzzle_id = YAP_IntOfTerm(YAP_ARG1);
    char *wkt = load_db_puzzle(puzzle_id);

    if (!wkt)
        return FALSE;

    YAP_Term wkt_term = YAP_MkAtomTerm(YAP_LookupAtom(wkt));
    free(wkt);
    return YAP_Unify(YAP_ARG2, wkt_term);
}








// Wrapper for save_solution(+PuzzleID, +WKT)
YAP_Bool yap_save_solution(void) {
    if (!YAP_IsIntTerm(YAP_ARG1)) return FALSE;
    if (!YAP_IsAtomTerm(YAP_ARG2)) return FALSE;

    int puzzle_id = YAP_IntOfTerm(YAP_ARG1);
    const char *wkt = YAP_AtomName(YAP_AtomOfTerm(YAP_ARG2));

    save_db_solution(puzzle_id, wkt);
    // Assume always succeeds, return TRUE
    return TRUE;
}








// Register foreign predicates with YAP
void init_my_lib(void) {

     printf(">>> init_my_lib called\n");

    YAP_UserCPredicate("transpose_geometry", yap_transpose_geometry, 4);
    printf(">>> YAP_UserCPredicate transpose_geometry called\n");

    YAP_UserCPredicate("disjoint_geometry", yap_disjoint_geometry, 3);
    printf(">>> YAP_UserCPredicate disjoint_geometry called\n");

    YAP_UserCPredicate("union_geometry", yap_union_geometry, 3);
    printf(">>> YAP_UserCPredicate - union_geometry called\n");

    YAP_UserCPredicate("load_tetrominoes_list", yap_load_tetrominoes_list, 1);
    printf(">>> YAP_UserCPredicate - load_tetrominoes_list called\n");
    
    YAP_UserCPredicate("load_puzzle", yap_load_puzzle, 2);
    printf(">>> YAP_UserCPredicate - load_puzzle called\n");

    YAP_UserCPredicate("save_solution", yap_save_solution, 2);
    printf(">>> YAP_UserCPredicate - save_solution called\n");


    printf(">>> init_my_lib ended\n");
}


void init(void) {
    // fallback to YAP initialization
    init_my_lib();
}
