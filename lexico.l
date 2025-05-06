%{
#include <string>
%}

ESPACO [ \t]
DIGITO [0-9]
LETRA [A-Za-z_]
DELIM {ESPACO}+
NUM {DIGITO}+
REAL {NUM}+("."{NUM}+)?
CHAR \'({LETRA}|{NUM})\'
ID {LETRA}({LETRA}|{NUM})*

%%

"\n"           {}
{DELIM}        {}
"principal"         { return TK_MAIN; }
"inteiro"          { return TK_TIPO_INT; }
"flutuante"        { return TK_TIPO_FLOAT; }
"caractere"         { return TK_TIPO_CHAR; }
"booleano"         { return TK_TIPO_BOOLEAN; }
"verdadeiro"         { yylval.label = "true"; return TK_TRUE; }
"falso"        { yylval.label = "false"; return TK_FALSE; }
[(){}[\];,]    { return *yytext; }
[+\-*/]        { return *yytext; }
"<"            { return '<'; }
"<="           { return TK_MENOR_IGUAL; }
">"            { return '>'; }
">="           { return TK_MAIOR_IGUAL; }
"=="           { return TK_IGUAL_IGUAL; }
"!="           { return TK_DIFERENTE; }
"="            { return '='; }
"&&"           { return TK_AND; }
"||"           { return TK_OR; }
"!"            { return '!'; }
{NUM}          { yylval.label = yytext; return TK_NUM; }
{ID}           { yylval.label = yytext; return TK_ID; }
{REAL}         { yylval.label = yytext; return TK_FLOAT_VAL; }
{CHAR}         { yylval.label = yytext; return TK_CHAR_VAL; }
.              { *yytext; }

%%
