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

struct elemTabSimbolos {
    char id[100];       // identificador
    int end;            // endereço global ou deslocamento local
    int tip;            // tipo variável
    char esc;           // escopo: 'g'=GLOBAL, 'l'=LOCAL
    int rot;            // rotulo (especifico para funcao)
    char cat;           // categoria: 'f'=FUN, 'p'=PAR, 'v'=VAR
    int par[MAX_PAR];   // tipos dos parametros (funcao)
    // int *par;        // tipos dos parametros (funcao) outra alternativa
    int npa;            // numero de parametros (funcao)
} tabSimb[TAM_TAB], elemTab;

int posTab = 0;

void maiuscula (char *s) {
    for (int i = 0; s[i]; i++)
        s[i] = toupper(s[i]);
    
}

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

void insereSimbolo (struct elemTabSimbolos elem) {
    int i;
    // maiuscula(elem.id);       // para fazer diferenciação entre variáveis maiúsculas e minúsculas
    if (posTab == TAM_TAB)
        yyerror("Tabela de Simbolos Cheia!");
    for (i = posTab - 1; (strcmp(tabSimb[i].id, elem.id) || tabSimb[i].esc != 'L' )&& i >= 0; i--)
        ;
    if (i != -1) {
        char msg[200];
        sprintf(msg, "Identificador [%s] duplicado!", elem.id);
        yyerror(msg);
    }
    tabSimb[posTab++] = elem;

}

//sugestão :
//desenvolver uma rotina para ajustar o endereço dos parametros
//na tabela de simbolos e o vetor de parametros da funcao
//depois que for cadastrado o ultimo parametro

//modificar a rptina mostraTabela para apresentar os outros 
//campos (esc, rot, cat, ...) da tabela
char *escreveTip(int i){
    return tabSimb[i].tip == INT? "INT" : "LOG";
}

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

//char *printa

// void mostraTabela() {
//     puts("Tabela de Simbolos");
//     puts("------------------");
//     printf("%30s | %s | %s \n", "ID", "END", "TIP");
//     for (int i = 0; i < 50; i++)
//         printf("-");
//     for (int i = 0; i < posTab; i++)
//         printf("\n%30s | %3d | %s", tabSimb[i].id, tabSimb[i].end, tabSimb[i].tip == INT? "INT" : "LOG");
//     printf("\n");
// }

/*  TABELA DE SIMBOLOS COMPLETA */
void mostraTabelaCompleta() {
    int i;
    printf("Tabela de símbolos");
    printf("\n%3c | %30s | %s | %s | %s | %s | %s | %s | %s\n",'#', "ID", "ESC", "DSL", "ROT", "CAT", "TIP", "NPA", "PAR");
    for (i = 0; i < 100; i++)
        printf("-");
    for (i = 0; i < posTab; i++)
        printf("\n%3d | %30s | %3c | %3d | %3s | %3c | %3s | %3s | %6d\n", i, tabSimb[i].id, tabSimb[i].esc, tabSimb[i].end, escreveRot(i), tabSimb[i].cat,  escreveTip(i), escreveNrPar(i), 0/*tabSimb[i].par[i]/*precisa mudar a apresentação do parametro*/);
    puts("\n");
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

// Estrutura da Pilha Semântica
// usada para endereços, variáveis, rótulos




#define TAM_PIL 100
//int pilha[TAM_PIL];
//sugestao para depurar pilha - tem que mudar em todas as ocorrencias
struct
{
    int valor;
    char tipo; // r=rotulo, n=nvars, t=tipo, p=posicao
} pilha[TAM_PIL];
int topo = -1;

// void empilhar (int valor) {
//     if (topo == TAM_PIL)
//         yyerror ("Pilha semântica cheia!");
//     pilha[++topo] = valor;
// }

// int desempilha() {
//     if (topo == -1) 
//         yyerror("Pilha semântica vazia!");
//     return pilha[topo--];
// }

void empilhar (int valor, char tipo) {
    if (topo == TAM_PIL)
        yyerror ("Pilha semântica cheia!");
    pilha[++topo].valor = valor;
    pilha[topo].tipo = tipo;
}

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

void testaTipo(int tipo1, int tipo2, int ret) {
    int t1 = desempilha('t');
    int t2 = desempilha('t');
    if (t1 != tipo1 || t2 != tipo2)
        yyerror("Incompatibilidade de tipo!");
    empilhar(ret, 't');
}

void ajustaParam(int pos, int nPar){    //parametros: # da função, e n parametros
    int endP = -3;
    int posFunc = pos - nPar;
    for (int i = pos; i >= posFunc; i--)
    {
        tabSimb[i].end = endP; 
        endP--;       
    } 
    tabSimb[posFunc].npa = nPar;
}







