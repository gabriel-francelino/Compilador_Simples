// Estrutura da Tabela de Simbolos
#include <ctype.h>
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
    char esc[1];        // escopo: 'g'=GLOBAL, 'l'=LOCAL
    int rot;            // rotulo (especifico para funcao)
    char cat;           // categoria: 'f'=FUN, 'p'=PAR, 'v'=VAR
    int par[MAX_PAR];   // tipos dos parametros (funcao)
    // int *par;   // tipos dos parametros (funcao) outra alternativa
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
    for (i = posTab - 1; strcmp(tabSimb[i].id, elem.id) && i >= 0; i--)
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
char *printaTip(int i){
    return tabSimb[i].tip == INT? "INT" : "LOG";
}

void mostraTabela() {
    puts("Tabela de Simbolos");
    puts("------------------");
    printf("%30s | %s | %s \n", "ID", "END", "TIP");
    for (int i = 0; i < 50; i++)
        printf("-");
    for (int i = 0; i < posTab; i++)
        printf("\n%30s | %3d | %s", tabSimb[i].id, tabSimb[i].end, tabSimb[i].tip == INT? "INT" : "LOG");
    printf("\n");
}

/*  TABELA DE SIMBOLOS COMPLETA */
void mostraTabelaCompleta() {
    int i;
    printf("Tabela de símbolos");
    printf("\n%3c | %30s | %s | %s | %s | %s | %s | %s | %s\n",'#', "ID", "ESC", "DSL", "ROT", "CAT", "TIP", "NPA", "PAR");
    for (i = 0; i < 100; i++)
        printf("-");
    for (i = 0; i < posTab; i++)
        printf("\n%3d | %30s | %3s | %3d | %3d | %3c | %3s | %3d | %6d\n", i, tabSimb[i].id, tabSimb[i].esc, tabSimb[i].end, tabSimb[i].rot, tabSimb[i].cat,  printaTip(i), tabSimb[i].npa, 0/*tabSimb[i].par[i]/*precisa mudar a apresentação do parametro*/);
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
int pilha[TAM_PIL];
int topo = -1;

void empilhar (int valor) {
    if (topo == TAM_PIL)
        yyerror ("Pilha semântica cheia!");
    pilha[++topo] = valor;
}

int desempilha() {
    if (topo == -1) 
        yyerror("Pilha semântica vazia!");
    return pilha[topo--];
}

void testaTipo(int tipo1, int tipo2, int ret) {
    int t1 = desempilha();
    int t2 = desempilha();
    if (t1 != tipo1 || t2 != tipo2)
        yyerror("Incompatibilidade de tipo!");
    empilhar(ret);
}