%{
#include <iostream>
#include <string>
#include <sstream>
#include <set>
#include <map>

#define YYSTYPE atributos
using namespace std;

struct atributos {
    string label;
    string traducao;
    string tipoExp;
};

struct tab {
    string tipo;
    string palavra;
};

int var_temp_qnt = 0;
set<string> variaveisNome;
map<string, tab> tabelaSimbolos;

int yylex(void);
void yyerror(string);
string gentempcode(string tipo);
string tipoResult(string tipo1, string tipo2);
string conversao(string var, string tipoOrigem, string tipoDest, string &codigo);
%}

%token TK_NUM
%token TK_MAIN TK_ID
%token TK_FIM TK_ERROR
%token TK_TIPO_CHAR TK_TIPO_BOOLEAN TK_TIPO_INT TK_TIPO_FLOAT
%token TK_CHAR_VAL TK_INT_VAL TK_FLOAT_VAL
%token TK_TRUE TK_FALSE
%token TK_MENOR_IGUAL TK_MAIOR_IGUAL TK_IGUAL_IGUAL TK_DIFERENTE
%token TK_AND TK_OR 

%start S
%left '+' '-'
%left '*' '/'
%right '(' ')'

%%

    S : TK_TIPO_INT TK_MAIN '(' ')' BLOCO {
        string codigo = "/*Compilador CCP*/\n"
                        "#include <iostream>\n"
                        "#include<string.h>\n"
                        "#define true 1\n"
                        "#define false 0\n"
                        "#include<stdio.h>\n"
                        "int main(void) {\n";

        for (auto& par : tabelaSimbolos) {
            codigo += "\t" + par.second.tipo + " " + par.second.palavra + ";\n"; 
        }

        codigo += "\n";
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
       		 if (tabelaSimbolos.count($2.label)) {
            	cout << "Erro: Variável '" << $2.label << "' já foi declarada." << endl;
            	exit(1);
        }
        	tabelaSimbolos[$2.label] = { $1.label, $2.label };
        	variaveisNome.insert($2.label);
        	$$.traducao = ""; 
    };
    
    TIPO
        : TK_TIPO_INT     { $$.label = "int"; $$.tipoExp = "int";}
        | TK_TIPO_FLOAT   { $$.label = "float"; $$.tipoExp = "float"; }
        | TK_TIPO_CHAR    { $$.label = "char"; $$.tipoExp = "char"; }
        | TK_TIPO_BOOLEAN { $$.label = "bool"; $$.tipoExp = "bool"; };
    
    E
        : E '+' E {
            string tipoEsq = tabelaSimbolos[$1.label].tipo;
            string tipoDir = tabelaSimbolos[$3.label].tipo;
            string tipoTemp = tipoResult(tipoEsq, tipoDir);
           
            string codConv = "";

            string esqConv = conversao($1.label, tipoEsq, tipoTemp, codConv);
            string dirConv = conversao($3.label, tipoDir, tipoTemp, codConv);

            $$.label = gentempcode(tipoTemp);
            $$.traducao = $1.traducao + $3.traducao + codConv + "\t" + $$.label + " = " + esqConv + " + " + dirConv + ";\n";
        }
        | E '-' E {
            string tipoEsq = tabelaSimbolos[$1.label].tipo;
            string tipoDir = tabelaSimbolos[$3.label].tipo;
            string tipoTemp = tipoResult(tipoEsq, tipoDir);
           
            string codConv = "";

            string esqConv = conversao($1.label, tipoEsq, tipoTemp, codConv);
            string dirConv = conversao($3.label, tipoDir, tipoTemp, codConv);

            $$.label = gentempcode(tipoTemp);
            $$.traducao = $1.traducao + $3.traducao + codConv + "\t" + $$.label + " = " + esqConv + " - " + dirConv + ";\n";
        }
        | E '*' E {
            string tipoEsq = tabelaSimbolos[$1.label].tipo;
            string tipoDir = tabelaSimbolos[$3.label].tipo;
            string tipoTemp = tipoResult(tipoEsq, tipoDir);
           
            string codConv = "";

            string esqConv = conversao($1.label, tipoEsq, tipoTemp, codConv);
            string dirConv = conversao($3.label, tipoDir, tipoTemp, codConv);

            $$.label = gentempcode(tipoTemp);
            $$.traducao = $1.traducao + $3.traducao + codConv + "\t" + $$.label + " = " + esqConv + " * " + dirConv + ";\n";
        }
        | E '/' E {
            string tipoEsq = tabelaSimbolos[$1.label].tipo;
            string tipoDir = tabelaSimbolos[$3.label].tipo;
            string tipoTemp = tipoResult(tipoEsq, tipoDir);
           
            string codConv = "";

            string esqConv = conversao($1.label, tipoEsq, tipoTemp, codConv);
            string dirConv = conversao($3.label, tipoDir, tipoTemp, codConv);

            $$.label = gentempcode(tipoTemp);
            $$.traducao = $1.traducao + $3.traducao + codConv + "\t" + $$.label + " = " + esqConv + " / " + dirConv + ";\n";
        }
        | '(' E ')' {
            $$ = $2;
        }
		| E '<' E {
            $$.label = gentempcode("bool");
            $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " < " + $3.label + ";\n";
		}
		| E TK_MENOR_IGUAL E {
            $$.label = gentempcode("bool");
            $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " <= " + $3.label + ";\n";
		}
		| E '>' E {
            $$.label = gentempcode("bool");
            $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " > " + $3.label + ";\n";
		}
		| E TK_MAIOR_IGUAL E {
            $$.label = gentempcode("bool");
            $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " >= " + $3.label + ";\n";
		}
		| E TK_IGUAL_IGUAL E {
            $$.label = gentempcode("bool");
            $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " == " + $3.label + ";\n";
		}
		| E TK_DIFERENTE E {
            $$.label = gentempcode("bool");
            $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " != " + $3.label + ";\n";
		}
		| E TK_AND E {
            $$.label = gentempcode("bool");
            $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " && " + $3.label + ";\n";
		}
		| E TK_OR E {
            $$.label = gentempcode("bool");
            $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " || " + $3.label + ";\n";
		}
		| '!' E {
            $$.label = gentempcode("bool");
            $$.traducao = $2.traducao + "\t" + $$.label + " = !" + $2.label + ";\n";
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
            string tipoVar = tabelaSimbolos[$1.label].tipo;
            string tipoExpr = tabelaSimbolos[$3.label].tipo;
            if(tipoVar == "bool") tipoVar = "int";
            if(tipoExpr == "bool") tipoExpr = "int";

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
            if (!tabelaSimbolos.count($1.label)) {
                tabelaSimbolos[$1.label] = {"int", $1.label };
                variaveisNome.insert($1.label);
            }
            string tipo = tabelaSimbolos[$1.label].tipo;
            $$.label = gentempcode(tipo);
            $$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
        }
        | '(' TIPO ')' E {
            string tipoOrigem = tabelaSimbolos[$4.label].tipo;
            string tipoDest = $2.tipoExp;

            string codConv = "";
            string convertido = conversao($4.label, tipoOrigem, tipoDest, codConv);

            $$.label = convertido;
            $$.traducao = $4.traducao + codConv;

            tabelaSimbolos[$$.label].tipo = tipoDest;
        }

%%

#include "lex.yy.c"

int yyparse();

string gentempcode(string tipo) {
    
    if(tipo == "bool") tipo = "int";
    
    var_temp_qnt++;
    string nomeTemp = "t" + to_string(var_temp_qnt);
    variaveisNome.insert(nomeTemp);
    tabelaSimbolos[nomeTemp] = { tipo, nomeTemp };
    return nomeTemp;
}

string tipoResult(string tipo1, string tipo2){
    if(tipo1 == "float" || tipo2 == "float") return "float";
    else if(tipo1 == "int" || tipo2 == "int") return "int";
    else if(tipo1 == "char" || tipo2 == "char") return "char";
    else return "int";
}

string conversao(string var, string tipoOrigem, string tipoDest, string &codigo){
    if(tipoOrigem == tipoDest) return var;

    string temp = gentempcode(tipoDest);
    codigo += "\t" + temp + " = (" + tipoDest + ") " + var + ";\n";
    return temp;
}

int main(int argc, char* argv[]) {
    var_temp_qnt = 0;
    yyparse();
    return 0;
}

void yyerror(string MSG) {
    cout << MSG << endl;
    exit(0);
}
