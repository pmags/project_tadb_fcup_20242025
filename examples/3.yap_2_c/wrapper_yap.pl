:- yap_flag(language, c).

% Carrega a biblioteca compartilhada e chama init_my_lib()
:- load_foreign_files(['./diga_ola.so'], [], init_my_lib).

% Declaração dos predicados que mapeiam para funções C
:- foreign(diga_ola, c, diga_ola()).


