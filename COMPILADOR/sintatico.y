%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "lexico.c"
#include "utils.c"
int contaVar;       // conta o número de variáveis
int contaVarG;      // conta número de variáveis globais
int contaVarL;      // conta número de variáveis locais
int rotulo = 0;     // marcar lugares no código
int tipo;
char escopo;
int npar = 0;
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
            contaVarL = 0;  //conta variaveis locais - teste
            escopo = 'G';
        }
        variaveis 
        {
            mostraTabelaCompleta();
            empilhar(contaVar, 'n'); 
            if (contaVar) 
                fprintf(yyout,"\tAMEM\t%d\n", contaVar); 
        }
        // acrescentar as funcoes
        rotinas 
        /* variaveis //variaveis locais
        {
            mostraTabela();
            empilhar(contaVarL); 
            if (contaVarL) 
                fprintf(yyout,"\tAMEM\t%d\n", contaVarL); 
        } */
        T_INICIO
        {
            mostraTabelaCompleta();
            escopo = 'L';
        }   
        lista_comandos T_FIM
        { 
            int conta = desempilha('n');
            if (conta)
                fprintf(yyout, "\tDMEM\t%d\n", conta); 
            fprintf(yyout, "\tFIMP\n");
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

//teria que mudar aqui para adaptar para a funcao
declaracao_variaveis
    :   tipo lista_variaveis declaracao_variaveis
    |   tipo lista_variaveis
    ;

//REGRA "tipo"
tipo        
    :   T_LOGICO
        { tipo = LOG; }     // Variável "tipo"
    |   T_INTEIRO
        { tipo = INT; }
    ;

lista_variaveis
    :   lista_variaveis T_IDENTIFICADOR 
        {  
            strcpy(elemTab.id, atomo);
            if(escopo == 'G'){
                elemTab.end = contaVar;
                contaVar++;
            }else{
                elemTab.end = contaVarL;
                contaVarL++;
            }
            elemTab.rot = -1;
            elemTab.tip = tipo;
            elemTab.cat = 'V';
            elemTab.esc = escopo;
            elemTab.npa = -1;
            insereSimbolo(elemTab);
                        
        }
    |   T_IDENTIFICADOR
        { 
            strcpy(elemTab.id, atomo);
             if(escopo == 'G'){
                elemTab.end = contaVar;
                contaVar++;
            }else{
                elemTab.end = contaVarL;
                contaVarL++;
            }
            elemTab.rot = -1;
            elemTab.tip = tipo;
            elemTab.cat = 'V';
            elemTab.esc = escopo;
            elemTab.npa = -1;
            insereSimbolo(elemTab);               
        }
    ;

rotinas
    :
    |   {
            fprintf(yyout, "\tDSVS\tL0\n");
        }
    funcoes
        {
            fprintf(yyout, "L0\tNADA\n");
        }
    ;

//regras para as funcoes
funcoes
    :   funcao
    |   funcao funcoes
    ;

funcao  
    :   T_FUNC
        {
            // if(rotulo == 0)
            //     fprintf(yyout,"\tDSVS\tL%d\n", rotulo); 
            // //empilhar(rotulo,'r');
        } 
        tipo T_IDENTIFICADOR
        {
            strcpy(elemTab.id, atomo);
            elemTab.esc = escopo;
            elemTab.end = contaVar;
            elemTab.rot = ++rotulo;
            elemTab.cat = 'F';
            elemTab.tip = tipo;
            //precisa guardar a posicao que a funcao foi cadastrada na tabela de simbolos
            insereSimbolo(elemTab);
            //int pos = buscaSimbolo(atomo);
            //empilhar(pos, 'p');

            contaVar++;
            fprintf(yyout,"L%d\tENSP\n", rotulo);     
            //empilhar(rotulo,'r');
            escopo = 'L';  
            //mostraPilha();         
        }
        T_ABRE parametros T_FECHA
        { 
        //  ajustar_parametros(); depois de passar pelo fecha
            int pos = buscaSimbolo(atomo);
            ajustaParam(pos, npar);
        }
        variaveis 
        {
            mostraTabelaCompleta();
            empilhar(contaVarL, 'n'); 
            if (contaVarL) 
                fprintf(yyout,"\tAMEM\t%d\n", contaVarL); 
        } 
        T_INICIO lista_comandos T_FIMFUNC
        {
            //posso verificar o se tem retorno criando uma var booleana que ativa quando encontra 'retorno'
            //remover_var_locais()
            escopo = 'G';
            removeParametros(npar);
            npar = 0;
            mostraTabelaCompleta();
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
            elemTab.end = contaVar;
            elemTab.rot = -1;
            elemTab.tip = tipo;
            elemTab.cat = 'P';
            elemTab.esc = escopo;
            insereSimbolo(elemTab);
            contaVar++;
            npar++;
            //printf("\n %d npar \n", npar);
        }
        // {cadastrar o parametro}
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
    //|   chamada //não tenho certeza se precisa
    ;

retorno
    :   T_RETORNE expressao
        {
            mostraPilha();
            int tip = desempilha('t');
            int pos = buscaSimbolo(atomo);
            if (tabSimb[pos].tip != tip)
                yyerror("Incompatibilidade de tipo!");
            printf("posicao: %d\n", pos);
            fprintf(yyout,"\tARZL\t%d\n", tabSimb[pos].end);
            // if (tabSimb[pos-1].esc == 'G')
            //     fprintf(yyout,"\tARZG\t%d\n", tabSimb[pos-1].end); 
            // else
               
            // int contaL = desempilha('n');    //DMEM n para as variaveis locais
            // if (contaL)
            //     fprintf(yyout, "\tDMEM\t%d\n", contaL);
            fprintf(yyout,"\tRTSP\t%d\n", npar); // RTSP n => onde n é numero de parametros
        }
      // {verificar se esta no escopo local
      //  verificar se o tipo da expressao é compativel com o tipo da funcao
      //  ARZL x
      //  DMEM x
      //  RTSP x}
      // deve gerar (depois da trad da expressao)
      // ARZL (valor de retorno), DMEM (se tiver variavel local)
      // RTSP n 
    ;

entrada_saida
    :   leitura
    |   escrita
    ;

leitura 
    :   T_LEIA T_IDENTIFICADOR
        { 
            int pos = buscaSimbolo(atomo);         
            fprintf(yyout,"\tLEIA\n\tARZG\t%d\n", tabSimb[pos].end); 
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
            fprintf(yyout,"L%d\tNADA\n", ++rotulo);     // L de label 
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

// A funcao eh chamada como um termo numa expresao

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
    : // sem parametros eh uma variavel
        {
            //...
            int pos = desempilha('p');
            if(tabSimb[pos].esc == 'G')
                fprintf(yyout,"\tCRVG\t%d\n", tabSimb[pos].end); 
            else
                fprintf(yyout,"\tCRVL\t%d\n", tabSimb[pos].end); 
            empilhar(tabSimb[pos].tip, 't');
        }
    |   T_ABRE 
        {
            //....
            fprintf(yyout,"\tAMEM\t%d\n", 1); //TESTE
        }
        lista_argumentos //tratar depois de argumentos a pilha semantica
        T_FECHA
        {
            //....
            // fprintf(yyout,"\tSVCP\n");
            // fprintf(yyout,"\tDSVS\tL%d\n", rotulo);
            //duvida: precisa desempilhar?
            int pos = desempilha('p');
            fprintf(yyout,"\tSVCP\n");
            fprintf(yyout,"\tDSVS\tL%d\n", tabSimb[pos].rot);
            empilhar(tabSimb[pos].tip, 't');
            //mostraPilha();
            
        }
    ;

lista_argumentos
    :
    |   expressao
        {
            //a partir de cada expressao desempilha tipo
            desempilha('t');
        }
        lista_argumentos
    ;

termo
    :   identificador chamada
    /* : T_IDENTIFICADOR
        {
            int pos = buscaSimbolo(atomo);
            fprintf(yyout,"\tCRVG\t%d\n", tabSimb[pos].end); 
            empilhar(tabSimb[pos].tip);
            
        } */
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
            if (t != LOG) yyerror ("Incompatibilidade de tipo!");       // Verificação se o termo é lógico
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