/*+=============================================================
/*2 | UNIFAL = Universidade Federal de Alfenas.
/*3 | BACHARELADO EM CIENCIA DA COMPUTACAO.
/*4 | Trabalho . . : Funcao com retorno
/*5 | Disciplina . : Teoria de Linguagens e Compiladores
/*6 | Professor. . : Luiz Eduardo da Silva
/*7 | Aluno . . . .: Gabriel Francelino Nascimento
/*8 | Data . . . . : 16/02/2023
/*9 +=============================================================*/


%{
#include "sintatico.h"
char atomo[100];
int nlin = 1;
int yyerror (char *s);
%}

identificador [_a-zA-Z]([a-zA-Z0-9])*
numero [0-9]+
espaco [ \t]+
novanlinha [\n]

%x coment

/* acrescentar a palavra chave retorne */
%%
programa                    return T_PROGRAMA;
inicio                      return T_INICIO;
fimprograma                 return T_FIM;
leia                        return T_LEIA;
escreva                     return T_ESCREVA;
se                          return T_SE;
entao                       return T_ENTAO;
senao                       return T_SENAO;
fimse                       return T_FIMSE;
enquanto                    return T_ENQUANTO;
faca                        return T_FACA;
fimenquanto                 return T_FIMENQUANTO;
inteiro                     return T_INTEIRO;
logico                      return T_LOGICO;
func                        return T_FUNC;
fimfunc                     return T_FIMFUNC;
retorne                     return T_RETORNE;


"+"                         return T_MAIS;
"-"                         return T_MENOS;
"*"                         return T_VEZES;
div                         return T_DIV;
">"                         return T_MAIOR;
"<"                         return T_MENOR;
"="                         return T_IGUAL;
e                           return T_E;
ou                          return T_OU;
nao                         return T_NAO;

"("                         return T_ABRE;
")"                         return T_FECHA;
"<-"                        return T_ATRIBUICAO;

"V"                         return T_V;
"F"                         return T_F;

"//".*                      ;
"/*"                        BEGIN(coment);
<coment>"*/"                BEGIN(INITIAL);
<coment>.                   ;
<coment>\n                  nlin++;

{identificador}             { strcpy(atomo, yytext); return T_IDENTIFICADOR; }
{numero}                    { strcpy(atomo, yytext); return T_NUMERO; }
{espaco}                    ;
{novanlinha}                nlin++;
.                           yyerror("Erro lexico");

%%

int yyerror (char *s) {
    printf("ERRO na linha %d: %s\n", nlin, s);
    exit(10);
}

int yywrap () { return 1; }