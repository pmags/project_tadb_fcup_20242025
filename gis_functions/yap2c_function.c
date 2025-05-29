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

// YAP wrapper for within_geometry/3
YAP_Bool yap_within_geometry(void) {
    const char *wkt1 = YAP_AtomName(YAP_AtomOfTerm(YAP_ARG1));
    const char *wkt2 = YAP_AtomName(YAP_AtomOfTerm(YAP_ARG2));

    int result = within_geometry(wkt1, wkt2);
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

// Helper: additional function to export tetrominoes as list
static YAP_Term create_tetramino_list(Tetramino *tetramino_array, int count){
    YAP_Term yap_list_being_built = YAP_MkAtomTerm(YAP_LookupAtom("[]")); // empty list
    YAP_Atom atom_tetromino_functor = YAP_LookupAtom("tetramino"); // create data type or structure?

    for (int i = count -1; i >= 0; i--){
        
        // fetch and add letter
        char letter_str[2];
        letter_str[0] = tetramino_array[i].letter;
        // random C strange stuff that does not know where a letter ends... intro EOS at second char
        letter_str[1] = '\0';
        YAP_Term term_letter = YAP_MkAtomTerm(YAP_LookupAtom(letter_str));
        
        // fetch the tetromino version or rotation. The data model calls it seq but database has it as var_id. 
        YAP_Term term_seq = YAP_MkIntTerm(tetramino_array[i].seq);

        // fetch the WKT geometry. Following same logic as create_wkt_list
        YAP_Term term_wkt = YAP_MkAtomTerm(YAP_LookupAtom(tetramino_array[i].wkt));
        
        // Add this to the data structure. 
        // strange C stuff -Some how this is already initialized?
        
        YAP_Term args[3] = {term_letter, term_seq, term_wkt};
        YAP_Functor functor_tetromino = YAP_MkFunctor(atom_tetromino_functor, 3); //it initializes instance or variable?
        YAP_Term tetromino_term = YAP_MkApplTerm(functor_tetromino, 3, args);

        yap_list_being_built = YAP_MkPairTerm(tetromino_term, yap_list_being_built);
        free(tetramino_array[i].wkt);
        tetramino_array[i].wkt = NULL; // AI told me to do this and i did...
    }
    return yap_list_being_built;
}


// Wrapper for load_tetrominoes_list(-List)
YAP_Bool yap_load_tetrominoes_list(void) {
    // 1 argument: output list
    if (!YAP_IsVarTerm(YAP_ARG1)) {
        return FALSE;
    }

    int count = 0;
    Tetramino *list = load_db_tetraminoes_list(&count);
    if (!list || count == 0) {
        free(list);
        return FALSE;
    }

    YAP_Term tetramino_list_term = create_tetramino_list(list ,count);
    free(list);
    return YAP_Unify(YAP_ARG1, tetramino_list_term);

    // Assuming Tetramino struct has a member `char *wkt` for geometry
    /*char **wkt_array = malloc(sizeof(char *) * count);
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

    return YAP_Unify(YAP_ARG1, wkt_list);*/

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
    
    YAP_UserCPredicate("within_geometry", yap_within_geometry, 3);
    printf(">>> YAP_UserCPredicate within_geometry called\n");

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
