To  compile code


Explanations:

+ geo_ops.c / geo_ops.h → funções C core (ex: transpose_geometry, disjoint_geometry...)
+ yap2c_functions.c → wrapper YAP que inclui "geo_ops.h" e faz o binding com YAP
+ export_functions_yap.pl → wrapper Prolog que carrega o .so e declara os predicados foreign

