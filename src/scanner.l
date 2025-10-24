%option nounput 
%option noinput
%option noyywrap
%option nodefault
%option yylineno

%{
    #include "symbol.h" // Inclua o arquivo de cabeçalho para a tabela de símbolos
    #include "parser.tab.h" // Inclua o arquivo gerado pelo Bison para as definições dos tokens
%}


 // Definições para as regras
%%

"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return TIMES; }
"/"             { return DIVIDE; }
"="             { return ASSIGN; }
"=="            { return EQUAL; }
"!="            { return NEQ; }
"<"             { return LT; }
">"             { return GT; }
"<="            { return LTE; }
">="            { return GTE; }

";"             { return SEMICOLON; }
"("             { return LPAREN; }
")"             { return RPAREN; }
"{"             { return LBRACE; }
"}"             { return RBRACE; }
","             { return COMMA; }

"if"            { return IF; }
"else"          { return ELSE; }
"while"         { return WHILE; }
"return"        { return RETURN; }

"float"         { return FLOAT; }
"int"           { return INT; }
"char"          { return CHAR; }   // Tipo char adicionado
"string"        { return STRING; } // Tipo string adicionado

[a-zA-Z][a-zA-Z0-9]* {
                  // Lida com identificadores.
                  // Você pode adicionar um passo para verificar se o identificador é uma palavra-chave
                  // se não for feito nas regras acima.
                  yylval.sval = strdup(yytext);
                  return IDENTIFIER;
                }

[0-9]+\.[0-9]+([eE][-+]?[0-9]+)?   { yylval.fval = atof(yytext); return FLOAT_LITERAL; }

[0-9]+                             { yylval.ival = atoi(yytext); return NUMBER; }

'\\.'                              { yylval.cval = yytext[1]; return CHAR_LITERAL; }
'[^\\\n]'                          { yylval.cval = yytext[1]; return CHAR_LITERAL; }


\"([^\\\"]|\\.)*\"                 { yylval.sval = strdup(yytext); return STRING_LITERAL; }


[ \t\n]+                           { /* Ignora espaços em branco, tabulações e quebras de linha */ }

"/*"([^*]|\*+[^*/])*\*+"/"         { /* ignora comentário de bloco */ }

"//".*                             { /* ignora comentário de linha */ }



. { // Caractere desconhecido. Você pode adicionar uma rotina de tratamento de erro aqui.
    fprintf(stderr,"Erro léxico: caractere desconhecido '%s' (linha %d)\n", yytext, yylineno); /* continue */ 
  }


%%
