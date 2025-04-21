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
"main"         { return TK_MAIN; }
"int"          { return TK_TIPO_INT; }
"float"        { return TK_TIPO_FLOAT; }
"char"         { return TK_TIPO_CHAR; }
"bool"         { return TK_TIPO_BOOLEAN; }
"true"         { yylval.label = "true"; return TK_TRUE; }
"false"        { yylval.label = "false"; return TK_FALSE; }
[(){}[\];,]    { return *yytext; }
[+\-*/]        { return *yytext; }
"<"            { return '<'; }
"<="           { return TK_MENOR_IGUAL; }
">"            { return '>'; }
">="           { return TK_MAIOR_IGUAL; }
"=="           { return TK_IGUAL_IGUAL; }
"!="           { return TK_DIFERENTE; }
"="            { return '='; }
{NUM}          { yylval.label = yytext; return TK_NUM; }
{ID}           { yylval.label = yytext; return TK_ID; }
{REAL}         { yylval.label = yytext; return TK_FLOAT_VAL; }
{CHAR}         { yylval.label = yytext; return TK_CHAR_VAL; }
.              { *yytext; }

%%
