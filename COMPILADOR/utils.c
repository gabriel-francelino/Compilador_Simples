// Estrutura da Tabela de Simbolos
#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define TAM_TAB 100
#define MAX_PAR 20
enum 
{
    INT, 
    LOG
};

/**
 * Estrutura da tabela de símbolos
*/
struct elemTabSimbolos {
    char id[100];       // identificador
    char esc;           // escopo: 'G'=GLOBAL, 'L'=LOCAL
    int end;            // endereço global ou deslocamento local
    int rot;            // rotulo (especifico para funcao)
    char cat;           // categoria: 'F'=FUN, 'P'=PAR, 'V'=VAR
    int tip;            // tipo variável
    int npa;            // numero de parametros (funcao)
    int par[MAX_PAR];   // tipos dos parametros (funcao)
} tabSimb[TAM_TAB], elemTab;

int posTab = 0;

/**
 * Diferencia váriaveis minúsculas de maiúsculas
 * 
 * @param s String a ser testada
*/
void maiuscula (char *s) {
    for (int i = 0; s[i]; i++)
        s[i] = toupper(s[i]);
    
}

int retornoGlobal(char *id, int posFunc){
    int i, ret = -1;
    for (i = posFunc; i < posTab; i++){
        if(strcmp(tabSimb[i].id, id)==0 && tabSimb[i].esc == 'L'){
            //printf("\n%d\n",i);
            ret = 0;
        }
        
    }
    //printf("\n%d\n",ret);
    return ret;
}

/**
 * Busca símbolo na tabela de símbolos
 * 
 * @param id Nome do símbolo a ser buscado
 * 
 * @return Endereço da posição
*/
int buscaSimbolo (char *id) {
    int i;
    // maiuscula(id);        // para fazer diferenciação entre variáveis maiúsculas e minúsculas
    for (i = posTab - 1; strcmp(tabSimb[i].id, id) && i >= 0; i--)
        ;
    if (i == -1) {
        char msg[200];
        sprintf(msg, "Identificador [%s] não encontrado!", id);
        yyerror(msg);       // escreve a linha em que o erro foi encontrado e uma mensagem
    }
    return i;
}

/**
 * Compara se dois caracteres são iguais
 * 
 * @param a Caracter a ser comparado
 * @param b Caracter a ser comparado
 * 
 * @return 0 se for igual e 1 se for diferente
*/
int charcmp(char a, char b){
    if(a == b)
        return 0;
    else
        return 1;
}

/**
 * Insere símbolo na tabela de símbolos
 * 
 * @param elem Estrutura a ser inserida na tabela
*/
void insereSimbolo (struct elemTabSimbolos elem) {
    int i;
    // maiuscula(elem.id);       // para fazer diferenciação entre variáveis maiúsculas e minúsculas
    if (posTab == TAM_TAB)
        yyerror("Tabela de Simbolos Cheia!");
    for (i = posTab - 1; (strcmp(tabSimb[i].id, elem.id) || charcmp(tabSimb[i].esc, elem.esc) )&& i >= 0; i--)
        ;
    if (i != -1) {
        char msg[200];
        sprintf(msg, "Identificador [%s] duplicado!", elem.id);
        yyerror(msg);
    }
    tabSimb[posTab++] = elem;
}

/**
 * Remove símbolos locais da tabela de símbolos
 * 
 * @param posFunc Posição da função
 * @param nLoc Quantidade de variáveis locais a ser removidas
*/
void removeSimbolosLocais(int posFunc, int nLoc){
    int i, j;
    int n = posTab;
    if(posTab == 0)
        yyerror("Tabela de Simbolos Vazia!");
    for(i = posFunc+1; i < n; i++){
        if(tabSimb[i].esc == 'L'){
            for(j = i; j < n - 1; j++){
                tabSimb[j] = tabSimb[j+nLoc];
                //printf("\nRemovendo..\n");
            }
            n--;
            i--;
        }
    }
    posTab -= nLoc;
}

/**
 * Escreve o tipo do símbolo da tabela
 * 
 * @param i Posição do símbolo
*/
char *escreveTip(int i){
    return tabSimb[i].tip == INT? "INT" : "LOG";
}

/**
 * Escreve o rótulo do símbolo da tabela
 * 
 * @param i Posição do símbolo
*/
char *escreveRot(int i){
    static char str[3];
    int rot = tabSimb[i].rot;
    if(rot != -1){
        sprintf(str, "L%d", rot);
        return str;
    }else{
        return "-";
    } 
}

/**
 * Escreve o número de parâmetros do símbolo da tabela
 * 
 * @param i Posição do símbolo
*/
char *escreveNrPar(int i){
    static char str[3];
    int npa = tabSimb[i].npa;
    if(npa != -1){
        sprintf(str, "%d", npa);
        return str;
    }else{
        return "-";
    } 
}

/**
 * Tabela de símbolos
 * 
 * Mostra todos os detalhes da tabela de símbolos
*/
void mostraTabelaCompleta() {
    int i;
    printf("\n\t\t\t\t\t\t Tabela de símbolos\n");
    for (i = 0; i < 100; i++)
        printf("-");
    printf("\n%3c | %30s | %s | %s | %s | %s | %s | %s | %s\n",'#', "ID", "ESC", "DSL", "ROT", "CAT", "TIP", "NPA", "PAR");
    for (i = 0; i < 100; i++)
        printf("-");
    
    for (i = 0; i < posTab; i++){
        printf("\n%3d | %30s | %3c | %3d | %3s | %3c | %3s | %3s |", i, tabSimb[i].id, tabSimb[i].esc, tabSimb[i].end, escreveRot(i), tabSimb[i].cat,  escreveTip(i), escreveNrPar(i));
        if(tabSimb[i].cat == 'F'){
            printf(" [");
            for(int j = 0; j < tabSimb[i].npa; j++){
                if(tabSimb[i].par[j] == INT){
                    printf(" INT ");
                }else{
                    printf(" LOG ");
                }
            }
            printf("] ");
        }else{
            printf(" - ");
        }
    }
    printf("\n");
}


// void testaAritmetico() {
//     int t1 = desempilha();
//     int t2 = desempilha();
//     if (t1 != INT || t2 != INT)
//         yyerror("Incompatibilidade de tipo!");
//     empilhar(INT);
// }

// void testaRelacional() {
//     int t1 = desempilha();
//     int t2 = desempilha();
//     if (t1 != INT || t2 != INT)
//         yyerror("Incompatibilidade de tipo!");
//     empilhar(LOG);
// }

// void testaLogico() {
//     int t1 = desempilha();
//     int t2 = desempilha();
//     if (t1 != LOG || t2 != LOG)
//         yyerror("Incompatibilidade de tipo!");
//     empilhar(LOG);
// }

#define TAM_PIL 100

/**
 * Estrutura a ser usada para a pilha
*/
struct
{
    int valor;
    char tipo; // r=rotulo, n=nvars, t=tipo, p=posicao
} pilha[TAM_PIL];
int topo = -1;

/**
 * Empilha na pilha semântica
 * 
 * @param valor Valor a ser empilhado
 * @param tipo Tipo do valor a ser empilhado
*/
void empilhar (int valor, char tipo) {
    if (topo == TAM_PIL)
        yyerror ("Pilha semântica cheia!");
    pilha[++topo].valor = valor;
    pilha[topo].tipo = tipo;
}

/**
 * Desempilha na pilha semântica
 * 
 * @param tipo Tipo do valor a ser desempilhado
*/
int desempilha(char tipo) {
    if (topo == -1) 
        yyerror("Pilha semântica vazia!");
    if ( pilha[topo].tipo != tipo){
        char msg[100];
        sprintf(msg, "Desempilha espera [%c] e encontrou[%c]", tipo, pilha[topo].tipo);
        yyerror(msg);    
    }
    return pilha[topo--].valor;
}

/**
 * Mostra a pilha semântica
*/
void mostraPilha(){
    int i = topo;
    printf("Pilha = [");
    while (i >=0)
    {
        printf("(%d,%c) ",pilha[i].valor, pilha[i].tipo);
        i--;
    }
    printf("]\n");   
}

/**
 * Testa o tipo das expressões
 * 
 * @param tipo1 Tipo do primeiro valor
 * @param tipo2 Tipo do segundo valor 
 * @param ret Tipo de retorno da função
*/
void testaTipo(int tipo1, int tipo2, int ret) {
    int t1 = desempilha('t');
    int t2 = desempilha('t');
    if (t1 != tipo1 || t2 != tipo2)
        yyerror("Incompatibilidade de tipo!");
    empilhar(ret, 't');
}

/**
 * Ajusta o endereço dos parâmetros na tabela de símbolos 
 * 
 * @param pos Posição do último parâmetro
 * @param nPar Número de parâmetros da função
 * 
 * @note Foi criada antes da posição da função ser capturada para uma variável global no sintatico.y, precisa ser melhorada.
*/
void ajustaParam(int pos, int nPar){  
    int endP = -3;
    int posFunc = pos - nPar;
    for (int i = pos; i >= posFunc; i--)
    {
        tabSimb[i].end = endP; 
        endP--;       
    } 
    tabSimb[posFunc].npa = nPar;
}







