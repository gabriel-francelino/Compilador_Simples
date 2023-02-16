%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "lexico.c"
#include "utils.c"

int contaVar;       // conta o número de variáveis globais
int contaVarL;      // conta número de variáveis locais
int rotulo = 0;     // marcar lugares no código
int tipo;           // captura o tipo
char escopo;        // marca o escopo
int npar = 0;       // conta o número de parâmetros
int posFunc;        // captura a posição atual da função
int verificaRetorno = 0;    // verifica se o uso do 'retorne' está correto
int verTipoPar = 0; // usado para verificar os tipos de parâmetros.
int qArgs = 0;      // conta número de argumentos
int chamaFun;
int npc = 0;
%}

%token T_PROGRAMA
%token T_INICIO
%token T_FIM
%token T_LEIA
%token T_ESCREVA
%token T_SE
%token T_ENTAO
%token T_SENAO
%token T_FIMSE
%token T_ENQUANTO
%token T_FACA
%token T_FIMENQUANTO
%token T_INTEIRO
%token T_LOGICO
%token T_MAIS
%token T_MENOS
%token T_VEZES
%token T_DIV
%token T_MAIOR
%token T_MENOR
%token T_IGUAL
%token T_E 
%token T_OU 
%token T_NAO
%token T_ABRE
%token T_FECHA
%token T_ATRIBUICAO
%token T_V 
%token T_F 
%token T_IDENTIFICADOR
%token T_NUMERO

%token T_FUNC
%token T_FIMFUNC
%token T_RETORNE

%start programa
%expect 1

%left T_E T_OU
%left T_IGUAL
%left T_MAIOR T_MENOR
%left T_MAIS T_MENOS
%left T_VEZES T_DIV

%%

programa 
    :   cabecalho 
        { 
            contaVar = 0; 
            contaVarL = 0;
            escopo = 'G';
        }
        variaveis 
        {
            empilhar(contaVar, 'n'); 
            if (contaVar) 
                fprintf(yyout,"\tAMEM\t%d\n", contaVar); 
        }
        rotinas 
        T_INICIO
        {
            // mostraTabelaCompleta();
            escopo = 'L';
        }   
        lista_comandos 
        {
            if(verificaRetorno == 1)
                yyerror("Retorno inesperado!");
        }
        T_FIM
        { 
            int conta = desempilha('n');
            if (conta)
                fprintf(yyout, "\tDMEM\t%d\n", conta); 
            fprintf(yyout, "\tFIMP\n");
            // mostraPilha();
        }
    ;

cabecalho
    : T_PROGRAMA T_IDENTIFICADOR
        { fprintf(yyout,"\tINPP\n"); }
    ;

variaveis
    :   /* vazio */
    |   declaracao_variaveis
    ;

declaracao_variaveis
    :   tipo lista_variaveis declaracao_variaveis
    |   tipo lista_variaveis
    ;

tipo        
    :   T_LOGICO
        { tipo = LOG; }     
    |   T_INTEIRO
        { tipo = INT; }
    ;

lista_variaveis
    :   lista_variaveis T_IDENTIFICADOR 
        {  
            strcpy(elemTab.id, atomo);
            elemTab.esc = escopo;
            if(escopo == 'G'){
                elemTab.end = contaVar;
                contaVar++;
            }else{
                elemTab.end = contaVarL;
                contaVarL++;
            }
            elemTab.rot = -1;
            elemTab.cat = 'V';
            elemTab.tip = tipo;
            elemTab.npa = -1;
            insereSimbolo(elemTab);
                        
        }
    |   T_IDENTIFICADOR
        { 
            elemTab.esc = escopo;
            strcpy(elemTab.id, atomo);
             if(escopo == 'G'){
                elemTab.end = contaVar;
                contaVar++;
            }else{
                elemTab.end = contaVarL;
                contaVarL++;
            }
            elemTab.rot = -1;
            elemTab.cat = 'V';
            elemTab.tip = tipo;
            elemTab.npa = -1;
            insereSimbolo(elemTab);               
        }
    ;

rotinas
    :   /* vazio */
    |   {
            fprintf(yyout, "\tDSVS\tL0\n");
        }
    funcoes
        {
            fprintf(yyout, "L0\tNADA\n");
        }
    ;

funcoes
    :   funcao
    |   funcao funcoes
    ;

funcao  
    :   T_FUNC 
        tipo T_IDENTIFICADOR
        {
            strcpy(elemTab.id, atomo);
            elemTab.esc = escopo;
            elemTab.end = contaVar;
            elemTab.rot = ++rotulo;
            elemTab.cat = 'F';
            elemTab.tip = tipo;
            insereSimbolo(elemTab);
            posFunc = buscaSimbolo(atomo);  // guarda a posição da função
            contaVar++;
            fprintf(yyout,"L%d\tENSP\n", rotulo);     
            escopo = 'L';           
        }
        T_ABRE parametros T_FECHA
        { 
            int pos = buscaSimbolo(atomo);
            ajustaParam(pos, npar);     // ajusta o endereço dos parâmetros
        }
        variaveis 
        {
            // mostraTabelaCompleta();
            if (contaVarL) 
                fprintf(yyout,"\tAMEM\t%d\n", contaVarL); 
        } 
        T_INICIO lista_comandos T_FIMFUNC
        {
            if(verificaRetorno == 0)    // 0 = Não tem 'retorne' | 1 = Tem 'retorne'
                yyerror("Esperado comando de retorno!");
            verificaRetorno = 0;
            escopo = 'G';
            removeSimbolosLocais(posFunc, npar+contaVarL);  // remove os símbolos locais da tabela de simbolos
            npar = 0;
            contaVarL = 0;
            //mostraTabelaCompleta();
        } 

parametros
    :
    |   parametro parametros
    ;

parametro
    :   tipo 
        T_IDENTIFICADOR
        {
            strcpy(elemTab.id, atomo);
            elemTab.esc = escopo;
            elemTab.end = contaVar;
            elemTab.rot = -1;
            elemTab.cat = 'P';
            elemTab.tip = tipo;
            insereSimbolo(elemTab);
            tabSimb[posFunc].par[npar] = tipo;
            contaVar++;
            npar++;
        }
    ;

lista_comandos
    :   /* vazio */
    |   comando lista_comandos
    ;

comando 
    :   entrada_saida
    |   repeticao
    |   selecao
    |   atribuicao 
    |   retorno
    ;

retorno
    :   T_RETORNE expressao
        {
            // int ret = buscaSimbolo(atomo);
            // if(tabSimb[ret].esc == 'G')
            //     yyerror("Variável global sendo retornada!");            
            int tip = desempilha('t');          // desempilha o tipo da expresssão
            if (tabSimb[posFunc].tip != tip)    // compara se o tipo é igual da função
                yyerror("Incompatibilidade de tipo!");
            fprintf(yyout,"\tARZL\t%d\n", tabSimb[posFunc].end);
            if (contaVarL)
                fprintf(yyout, "\tDMEM\t%d\n", contaVarL); 
            fprintf(yyout,"\tRTSP\t%d\n", npar);
            verificaRetorno = 1;  // atribui 1 se tiver retorno
        }
    ;

entrada_saida
    :   leitura
    |   escrita
    ;

leitura 
    :   T_LEIA T_IDENTIFICADOR
        { 
            int pos = buscaSimbolo(atomo);
            if(tabSimb[pos].esc == 'G')         
                fprintf(yyout,"\tLEIA\n\tARZG\t%d\n", tabSimb[pos].end);
            else 
                fprintf(yyout,"\tLEIA\n\tARZL\t%d\n", tabSimb[pos].end);
        }
    ;

escrita 
    :   T_ESCREVA expressao
        { 
            desempilha('t');
            fprintf(yyout,"\tESCR\n"); 
        }
    ;

repeticao
    :   T_ENQUANTO 
        { 
            fprintf(yyout,"L%d\tNADA\n", ++rotulo);
            empilhar(rotulo, 'r');
        } 
        expressao T_FACA 
        { 
            int tip = desempilha('t');
            if (tip != LOG)
                yyerror ("Incompatibilidade de tipo");
            fprintf(yyout,"\tDSVF\tL%d\n", ++rotulo); 
            empilhar(rotulo, 'r');
        }
        lista_comandos 
        T_FIMENQUANTO
        { 
            int rot1 = desempilha('r');
            int rot2 = desempilha('r');
            fprintf(yyout,"\tDSVS\tL%d\n", rot2); 
            fprintf(yyout,"L%d\tNADA\n", rot1); 
        }
    ;

selecao
    :   T_SE expressao T_ENTAO 
        { 
            int tip = desempilha('t');
            if (tip != LOG)
                yyerror("Incompatibilidade de tipo!");
            fprintf(yyout,"\tDSVF\tL%d\n", ++rotulo); 
            empilhar(rotulo, 'r');
        }
        lista_comandos T_SENAO
        { 
            int rot = desempilha('r');
            fprintf(yyout,"\tDSVS\tL%d\n", ++rotulo); 
            fprintf(yyout,"L%d\tNADA\n", rot); 
            empilhar(rotulo, 'r');
        }
        lista_comandos T_FIMSE
        { 
            int rot = desempilha('r');
            fprintf(yyout,"L%d\tNADA\n", rot); 
        }
    ;

atribuicao
    :   T_IDENTIFICADOR
        {
            int pos = buscaSimbolo(atomo);
            empilhar(pos, 'p');
        }
        T_ATRIBUICAO expressao
        { 
            int tip = desempilha('t');
            int pos = desempilha('p');
            if (tabSimb[pos].tip != tip)
                yyerror("Incompatibilidade de tipo!");
            if (tabSimb[pos].esc == 'G')
                fprintf(yyout,"\tARZG\t%d\n", tabSimb[pos].end); 
            else
                fprintf(yyout,"\tARZL\t%d\n", tabSimb[pos].end);
        }
    ;

expressao
    :   expressao T_VEZES expressao
        { 
            testaTipo(INT, INT, INT);
            fprintf(yyout,"\tMULT\n"); 
        }
    |   expressao T_DIV expressao
        { 
            testaTipo(INT, INT, INT);
            fprintf(yyout,"\tDIVI\n"); 
        }
    |   expressao T_MAIS expressao
        { 
            testaTipo(INT, INT, INT);
            fprintf(yyout,"\tSOMA\n"); 
        }
    |   expressao T_MENOS expressao
        { 
            testaTipo(INT, INT, INT);
            fprintf(yyout,"\tSUBT\n"); 
        }
    |   expressao T_MAIOR expressao
        { 
            testaTipo(INT, INT, LOG);
            fprintf(yyout,"\tCMMA\n"); 
        }
    |   expressao T_MENOR expressao
        { 
            testaTipo(INT, INT, LOG);
            fprintf(yyout,"\tCMME\n"); 
        }
    |   expressao T_IGUAL expressao
        { 
            testaTipo(INT, INT, LOG);
            fprintf(yyout,"\tCMIG\n"); 
        }
    |   expressao T_E expressao
        { 
            testaTipo(LOG, LOG, LOG);
            fprintf(yyout,"\tCONJ\n"); 
        }
    |   expressao T_OU expressao
        { 
            testaTipo(LOG, LOG, LOG);
            fprintf(yyout,"\tDISJ\n"); 
        }
    |   termo
    ;



identificador
    :   T_IDENTIFICADOR
        {
            // int pos = buscaSimbolo(atomo);  
            // fprintf(yyout,"\tCRVG\t%d\n", tabSimb[pos].end); 
            // empilhar(tabSimb[pos].tip);
            int pos = buscaSimbolo(atomo);
            empilhar(pos, 'p');
        }
    ;

chamada
    :   // sem parametros eh uma variavel
        {
            int pos = desempilha('p');
            if(tabSimb[pos].cat == 'F')
                yyerror("Função sem parâmetros!");
            if(tabSimb[pos].esc == 'G')
                fprintf(yyout,"\tCRVG\t%d\n", tabSimb[pos].end); 
            else
                fprintf(yyout,"\tCRVL\t%d\n", tabSimb[pos].end); 
            empilhar(tabSimb[pos].tip, 't');
        }
    |   T_ABRE 
        {
            // mostraPilha();
            fprintf(yyout,"\tAMEM\t%d\n", 1);
            posFunc = desempilha('p');  
            npc = 1;
            //empilhar(posFunc, 'p');
        }
        lista_argumentos 
        {
            verTipoPar = 0; // atribui com zero para recomeçar a contagem na próxima chamada
        }
        T_FECHA
        {
            int np;
            //chamaFun = desempilha('p');
            //mostraPilha();
            posFunc = desempilha('p');
            printf("npc=%d\n", npc);
            if(npc == 0)
                np = tabSimb[posFunc-1].npa;
            else 
                np = tabSimb[posFunc].npa;
            npc = 0;
            printf("np=%d\n", np);

            for(int i=0; i < np; i++){
                //mostraPilha();
                desempilha('a');
            }
            //mostraPilha();

            // int np = tabSimb[chamaFun].npa;
            // printf("Função: %s, qPar: %d, qArgs: %d\n", tabSimb[chamaFun].id, np, qArgs);
            // if(qArgs != np)
            //     yyerror("Erro na quantidade de parametros.");
            qArgs = 0;
            //int pos = desempilha('p');
            fprintf(yyout,"\tSVCP\n");
            fprintf(yyout,"\tDSVS\tL%d\n", tabSimb[chamaFun].rot);
            empilhar(tabSimb[chamaFun].tip, 't');
            
        }
    ;

lista_argumentos
    :
        {
            empilhar(posFunc, 'p');
        }
    |   {
            qArgs++;
            empilhar(-9, 'a');  //empilha os argumentos
            //printf("\nArgumento: %s\n qArgs: %d\n", atomo, qArgs);
        }
        expressao
        {
            // a partir de cada expressao do argumento desempilha tipo e compara 
            int t = desempilha('t');
            if(tabSimb[posFunc].par[verTipoPar] != t)
                yyerror("Incompatibilidade no tipo dos parametros.");
            verTipoPar++;
            // qArgs++;
            // printf("\nArgumento: %s\n qArgs: %d\n", atomo, qArgs);
        }
        lista_argumentos
        {
            
        }
    ;

termo
    :   identificador chamada
    |   T_NUMERO
        { 
            fprintf(yyout,"\tCRCT\t%s\n", atomo); 
            empilhar(INT,'t');
        }
    |   T_V
        { 
            fprintf(yyout,"\tCRCT\t1\n"); 
            empilhar(LOG, 't');
        }
    |   T_F
        { 
            fprintf(yyout,"\tCRCT\t0\n"); 
            empilhar(LOG, 't');
        }
    |   T_NAO termo
        { 
            int t = desempilha('t');
            if (t != LOG) yyerror ("Incompatibilidade de tipo!");     
            fprintf(yyout,"\tNEGA\n"); 
            empilhar(LOG, 't');
        }
    |   T_ABRE expressao T_FECHA
    ;

%%

int main (int argc, char *argv[]) {
    char *p, nameIn[100], nameOut[100]; // Duas variáveis para guardar os nomes de saida e entrada
    argv++;
    if (argc < 2) {
        puts("\n Compilador Simples");
        puts("\n\tUso:./simples <NOME>[.simples]\n\n");
        exit(10);
    }
    p = strstr(argv[0], ".simples"); // Função que procura uma string na string e posiciona no início
    if (p) *p = 0;
    strcpy(nameIn, argv[0]);
    strcat(nameIn, ".simples");
    strcpy(nameOut, argv[0]);
    strcat(nameOut, ".mvs");
    yyin = fopen (nameIn, "rt");
    if (!yyin) {
        puts("Programa fonte não encontrado!");
        exit(20);
    }
    yyout = fopen(nameOut, "wt");
    yyparse();
    puts ("Programa ok!");
}