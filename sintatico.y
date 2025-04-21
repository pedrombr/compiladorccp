%{
#include <iostream>
#include <string>
#include <sstream>
#include <set>
#include <map>

#define YYSTYPE atributos
using namespace std;

int var_temp_qnt = 0;
set<string> variaveisTemps;
map<string, string> tiposVarTemps;

struct atributos {
    string label;
    string traducao;
};

struct tab {
    string tipo;
    string palavra;
    string valor;
};

int yylex(void);
void yyerror(string);
string gentempcode(string tipo);
%}

%token TK_NUM
%token TK_MAIN TK_ID
%token TK_FIM TK_ERROR
%token TK_TIPO_CHAR TK_TIPO_BOOLEAN TK_TIPO_INT TK_TIPO_FLOAT
%token TK_CHAR_VAL TK_INT_VAL TK_FLOAT_VAL
%token TK_TRUE TK_FALSE

%start S
%left '+' '-'
%left '*' '/'
%right '(' ')'

%%

    S : TK_TIPO_INT TK_MAIN '(' ')' BLOCO {
        string codigo = "/*Compilador FOCA*/\n"
                        "#include <iostream>\n"
                        "#include<string.h>\n"
                        "#define true 1\n"
                        "#define false 0\n"
                        "#include<stdio.h>\n"
                        "int main(void) {\n";
        codigo += $5.traducao;
        codigo += "\treturn 0;\n}";
        cout << codigo << endl;
    };
    
    BLOCO : '{' COMANDOS '}' {
        $$.traducao = $2.traducao;
    };
    
    COMANDOS
        : COMANDO COMANDOS {
            $$.traducao = $1.traducao + $2.traducao;
        }
        | {
            $$.traducao = "";
        };
    
    COMANDO
        : E ';' {
            $$ = $1;
        }
        | TIPO TK_ID ';' {
       		 if (tiposVarTemps.count($2.label)) {
            	cout << "Erro: Variável '" << $2.label << "' já foi declarada." << endl;
            	exit(1);
        }
        	tiposVarTemps[$2.label] = $1.label;
        	variaveisTemps.insert($2.label);
        	$$.traducao = ""; 
    };
    
    TIPO
        : TK_TIPO_INT     { $$.label = "int"; }
        | TK_TIPO_FLOAT   { $$.label = "float"; }
        | TK_TIPO_CHAR    { $$.label = "char"; }
        | TK_TIPO_BOOLEAN { $$.label = "bool"; };
    
    E
        : E '+' E {
            string tipoTemp = (tiposVarTemps[$1.label] == "float" || tiposVarTemps[$3.label] == "float") ? "float" : "int";
            $$.label = gentempcode(tipoTemp);
            $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " + " + $3.label + ";\n";
        }
        | E '-' E {
            string tipoTemp = (tiposVarTemps[$1.label] == "float" || tiposVarTemps[$3.label] == "float") ? "float" : "int";
            $$.label = gentempcode(tipoTemp);
            $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " - " + $3.label + ";\n";
        }
        | E '*' E {
            string tipoTemp = (tiposVarTemps[$1.label] == "float" || tiposVarTemps[$3.label] == "float") ? "float" : "int";
            $$.label = gentempcode(tipoTemp);
            $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " * " + $3.label + ";\n";
        }
        | E '/' E {
            string tipoTemp = (tiposVarTemps[$1.label] == "float" || tiposVarTemps[$3.label] == "float") ? "float" : "int";
            $$.label = gentempcode(tipoTemp);
            $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " / " + $3.label + ";\n";
        }
        | '(' E ')' {
            $$ = $2;
        }
    	|TK_FLOAT_VAL{
        
    		 $$.label = gentempcode("float");
       		 $$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
    	}
    
        |TK_CHAR_VAL{

    		 $$.label = gentempcode("char");
       		 $$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";

        }

        |TK_TRUE{

    		 $$.label = gentempcode("bool");
       		 $$.traducao = "\t" + $$.label + " = 1;\n";
        }
        |TK_FALSE{

    		 $$.label = gentempcode("bool");
       		 $$.traducao = "\t" + $$.label + " = 0;\n";
        }

        | TK_ID '=' E {
            string tipoVar = tiposVarTemps[$1.label];
            string tipoExpr = tiposVarTemps[$3.label];
            if (tipoVar != tipoExpr) {
                cout << "Erro: Tipos incompatíveis na atribuição!" << endl;
            }
            $$.traducao = $1.traducao + $3.traducao + "\t" + $1.label + " = " + $3.label + ";\n";
        }
        | TK_NUM {
            $$.label = gentempcode("int");
            $$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
        }
        | TK_ID {
            if (!tiposVarTemps.count($1.label)) {
                cout << "Erro: Variável '" << $1.label << "' não foi declarada." << endl;
                exit(1);
            }
            string tipo = tiposVarTemps[$1.label];
            $$.label = gentempcode(tipo);
            $$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
        };

%%

#include "lex.yy.c"

int yyparse();

string gentempcode(string tipo) {
    
    if(tipo == "bool") tipo = "int";
    
    var_temp_qnt++;
    string nomeTemp = "t" + to_string(var_temp_qnt);
    variaveisTemps.insert(nomeTemp);
    tiposVarTemps[nomeTemp] = tipo;
    return nomeTemp;
}

int main(int argc, char* argv[]) {
    var_temp_qnt = 0;
    yyparse();
    for (auto& par : tiposVarTemps) {
        cout << par.second << " " << par.first << ";" << endl;
    }
    return 0;
}

void yyerror(string MSG) {
    cout << MSG << endl;
    exit(0);
}
