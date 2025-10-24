    #define DEBUG 1

    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdbool.h>
    #include <ctype.h>
    #include <stddef.h>
    
        // Estrutura para a Tabela de Símbolos
    struct _simbolo {
        char *name;              // Nome do identificador
        int type;                // Ex: INT, FLOAT, etc.

        int scope;               // Ex: 0 para global, 1 para local, etc.
                                 // TODO enum { SCOPE_GLOBAL, SCOPE_LOCAL }

        int is_function;         // 1 se for função, 0 se for variável
        struct _simbolo *params; // Lista de parâmetros (se for função)
        struct _simbolo *next;   // Ponteiro para o próximo símbolo na li'sta
    };
    typedef struct _simbolo Simbolo;



    // Funções para a tabela de símbolos
    void insert_symbol(char * name, int type);
    
    // retorna NULL se não encontrar
    Simbolo * find_symbol(char * name);

    Simbolo * find_symbol_in_scope(char * name, int scope);
    const char * type_to_string(int type);
    void print_symbol_table();
    void insert_function(char * name, int return_type, Simbolo * params);
    Simbolo * create_param(char * name, int type);

    void free_symbol(Simbolo *s);
    void free_symbol_table();
    void free_params(Simbolo *s);