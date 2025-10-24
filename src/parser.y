%{
    #include "symbol.h" // Inclua o arquivo de cabeçalho para a tabela de símbolos

    // Definição da estrutura para a tabela de símbolos
    Simbolo * symbol_table = NULL; // Ponteiro para a tabela de símbolos

    int current_scope = 0; // 0 = global, 1 = local
    
    void yyerror(const char *s); // Declaração da função de erro do Bison
    extern int yylex(void); // Declaração da função do scanner, gerada pelo Flex
    extern FILE *yyin;      // Para definir o arquivo de entrada
    extern char *yytext;    // Para acessar o texto do token atual
%}

// Definições de tipos de valores semânticos

%union {
    int      ival;       // Para números inteiros e tipos
    float    fval;       // Para valores float 
    char   * sval;       // Para identificadores e strings
    char     cval;       // Para caracteres
    // outros tipos que você usar
    Simbolo * sym;        // Para parâmetros individuais
    Simbolo * symlist;    // Para listas de parâmetros
}

 // Seção de definições de token.
 // O Bison precisa saber quais tokens ele pode receber do Flex.
%token <sval> IDENTIFIER
%token INT
%token <ival> NUMBER
%token FLOAT
%token <fval> FLOAT_LITERAL
%token CHAR
%token <cval> CHAR_LITERAL
%token STRING
%token <sval> STRING_LITERAL
%token IF ELSE WHILE RETURN
%token PLUS MINUS TIMES DIVIDE ASSIGN EQUAL NEQ LT GT LTE GTE
%token SEMICOLON LPAREN RPAREN LBRACE RBRACE COMMA

// Definição dos tipos de valores semânticos para os tokens
%type <ival> type_specifier // Tipo de dado (int, float, etc.)
%type <sym> parameter_declaration
%type <symlist> parameter_list

/* 
%type <sym> function_declaration
%type <symlist> declaration_list
%type <sym> declaration
%type <sym> statement_list
%type <sym> statement
%type <sym> expression_statement
%type <sym> if_statement
%type <sym> while_statement
%type <sym> return_statement
%type <sym> expression
%type <sym> assignment_expression
%type <sym> logical_expression
%type <sym> relational_expression
%type <sym> additive_expression
%type <sym> multiplicative_expression
%type <sym> unary_expression
*/

 // Seção de precedência de operadores
%right ASSIGN
%left EQUAL NEQ
%left LT GT LTE GTE
%left PLUS MINUS
%left TIMES DIVIDE


 // Definição da gramática
%%

 // A regra de início da gramática. Um programa é uma lista de declarações.
program: 
    declaration_list
;

type_specifier:
      INT     { $$ = INT; }
    | FLOAT   { $$ = FLOAT; }
    | CHAR    { $$ = CHAR; }
    | STRING  { $$ = STRING; }
;

declaration_list:
    declaration
    | declaration_list declaration
;

declaration:
    variable_declaration
    | function_declaration
;

 // Exemplo de uma declaração de variável
variable_declaration:
    type_specifier IDENTIFIER SEMICOLON {
        insert_symbol($2, $1);  // $1 é o tipo, $2 é o nome
    }
;

 // Exemplo de uma declaração de função
parameter_list:
      /* vazio */ { $$ = NULL; }
    | parameter_declaration { $$ = $1; }
    | parameter_list COMMA parameter_declaration {
        $1->next = $3;
        $$ = $1;
    }
;

parameter_declaration:
    type_specifier IDENTIFIER {
        
        if (!( $$ = malloc(sizeof(Simbolo)) )) { 
            fprintf(stderr, "malloc failed\n"); 
            exit(1); 
        }

        $$->name = strdup($2);
        if (! $$->name) { 
            fprintf(stderr, "strdup failed\n"); 
            exit(1); 
        }

        $$->type = $1;
        $$->scope = 1; // escopo local
        $$->is_function = 0;
        $$->next = NULL;
        insert_symbol($2, $1); // insere na tabela de símbolos
    }
;


function_declaration:
    type_specifier IDENTIFIER LPAREN parameter_list RPAREN LBRACE statement_list RBRACE {
        current_scope = 1; // Escopo local
        insert_function($2, $1, $4); // $2 = nome, $1 = tipo, $4 = parâmetros
        current_scope = 0; // Volta para escopo global
    }
;

 // Lista de comandos (statements)
statement_list:
    statement
    | statement_list statement
;

statement:
    variable_declaration
    | expression_statement
    | if_statement
    | while_statement
    | return_statement
;

 // Um comando de expressão
expression_statement:
    expression SEMICOLON
;

 // Comando 'if'
if_statement:
    IF LPAREN expression RPAREN LBRACE statement_list RBRACE
    | IF LPAREN expression RPAREN LBRACE statement_list RBRACE ELSE LBRACE statement_list RBRACE
;

 // Comando 'while'
while_statement:
    WHILE LPAREN expression RPAREN LBRACE statement_list RBRACE
;

 // Comando 'return'
return_statement:
    RETURN expression SEMICOLON
;

 // Expressões
expression:
    assignment_expression
;

assignment_expression:
    IDENTIFIER ASSIGN expression %prec ASSIGN
    | logical_expression
;

logical_expression:
    relational_expression
    | logical_expression EQUAL relational_expression
    | logical_expression NEQ relational_expression
;

relational_expression:
    additive_expression
    | relational_expression LT additive_expression
    | relational_expression GT additive_expression
    | relational_expression LTE additive_expression
    | relational_expression GTE additive_expression
;

additive_expression:
    multiplicative_expression
    | additive_expression PLUS multiplicative_expression
    | additive_expression MINUS multiplicative_expression
;

multiplicative_expression:
    unary_expression
    | multiplicative_expression TIMES unary_expression
    | multiplicative_expression DIVIDE unary_expression
;

unary_expression:
      NUMBER
    | FLOAT_LITERAL
    | CHAR_LITERAL
    | STRING_LITERAL
    | IDENTIFIER {
        // Ação Semântica: Verifica se o identificador já foi declarado.
        Simbolo *sym = find_symbol($1);
        if (sym == NULL) {
            fprintf(stderr, "Erro semântico: Variável '%s' não declarada.\n", $1);
            exit(1);
        }
    }

    | LPAREN expression RPAREN
;

%%

// Funções C de suporte para o parser
int main(int argc, char **argv) {

    #ifdef DEBUG 
    printf("[DEBUG] parametros = %d\n", argc);
    #endif
    
    FILE *file = NULL;
    if (argc > 1) {
        file = fopen(argv[1], "r");
        if (!file) {
            perror("Não foi possível abrir o arquivo");
            return 1;
        }
        yyin = file;
    }
    
    printf("Iniciando a análise...\n");
    printf("Analisando o arquivo: %s\n", argc > 1 ? argv[1] : "entrada padrão");

    // Inicia o processo de parsing
    if (yyparse() == 0) {
        printf("Análise sintática bem-sucedida!\n");
    } else {
        printf("Análise sintática falhou.\n");
    }

    // Imprime a tabela de símbolos ao final da análise
    printf("\n\nAnálise concluída. Tabela de Símbolos:\n");
    print_symbol_table();

    if (file) {
        fclose(file);
    }

    return 0;
}

// Função de erro para o Bison.
void yyerror(const char *s) {
    fprintf(stderr, "Erro de sintaxe: %s\n", s);
}

// Funções para manipulação da Tabela de Símbolos

void insert_symbol(char *name, int type) {
    // Implementação simples de lista encadeada.
    // Verifica se o símbolo já existe
    if (find_symbol(name) != NULL) {
        fprintf(stderr, "Erro semântico: Identificador '%s' já declarado.\n", name);
        exit(1);
    }
    Simbolo * new_symbol = (Simbolo *) malloc(sizeof(Simbolo));

    if (! new_symbol) { 
        fprintf(stderr, "malloc failed\n"); 
        exit(1); 
    }

    new_symbol->name = strdup(name);
    if (! new_symbol->name) { 
        fprintf(stderr, "strdup failed\n"); 
        exit(1); 
    }

    new_symbol->type = type;
    new_symbol->scope = current_scope; // variavel global/local
    new_symbol->is_function = 0;       // por padrão, é uma variável
    new_symbol->params = NULL;         // não é uma função, então sem parâmetros
    new_symbol->next = symbol_table;
    symbol_table = new_symbol;
}

Simbolo *find_symbol(char *name) {
    Simbolo *current = symbol_table;
    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            return current;
        }
        current = current->next;
    }
    return NULL;
}

Simbolo * find_symbol_in_scope(char *name, int scope) {
    Simbolo * current = symbol_table;
    while (current != NULL) {
        if (strcmp(current->name, name) == 0 && current->scope == scope) {
            return current;
        }
        current = current->next;
    }
    return NULL;
}

const char* type_to_string(int type) {
    switch (type) {
        case INT:    return "INT";
        case FLOAT:  return "FLOAT";
        case CHAR:   return "CHAR";
        case STRING: return "STRING";
        default:     return "desconhecido";
    }
}

void print_symbol_table() {
    Simbolo *current = symbol_table;
    printf("\n\nTabela de Símbolos:\n");
    printf("Nome\tTipo\tEscopo\tCategoria\tParâmetros\n");
    while (current != NULL) {
        if (current->is_function) {
            printf("%s\t%s\t%s\tfunção\t", current->name, type_to_string(current->type), current->scope == 0 ? "global" : "local");
            Simbolo *p = current->params;
            while (p) {
                printf("%s:%s ", p->name, type_to_string(p->type));
                p = p->next;
            }
            printf("\n");
        } else {
            printf("%s\t%s\t%d\n", current->name, type_to_string(current->type), current->scope);
        }
        current = current->next;
    }
}

void insert_function(char *name, int return_type, Simbolo *params) {
    if (find_symbol(name)) {
        fprintf(stderr, "Erro: função '%s' já declarada.\n", name);
        exit(1);
    }
    
    Simbolo *func = malloc(sizeof(Simbolo));
    
    if (! func) { 
        fprintf(stderr, "malloc failed\n"); 
        exit(1); 
    }

    func->name = strdup(name);
    if (! func->name) { 
        fprintf(stderr, "strdup failed\n"); 
        exit(1); 
    }

    func->type = return_type;
    func->scope = current_scope; // da variavel global
    func->is_function = 1;
    func->params = params;
    func->next = symbol_table;
    symbol_table = func;
}

Simbolo* create_param(char *name, int type) {
    Simbolo *param = malloc(sizeof(Simbolo));
    if (! param) { 
        fprintf(stderr, "malloc failed\n"); 
        exit(1); 
    }

    param->name = strdup(name);
    if (! param->name) { 
        fprintf(stderr, "strdup failed\n"); 
        exit(1); 
    }

    param->type = type;
    param->scope = current_scope; // da variavel global
    param->is_function = 0;
    param->params = NULL;
    param->next = NULL;
    return param;
}