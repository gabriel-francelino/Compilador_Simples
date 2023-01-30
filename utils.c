// Estrutura da Tabela de Simbolos
#include <ctype.h>

#define TAM_TAB 100

enum {INT, LOG};

struct elemTabSimbolos {
    char id[100];   //identificador
    int end;    // endereço
    int tip;    // tipo variável
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

void mostraTabela() {
    puts("Tabela de Simbolos");
    puts("------------------");
    printf("%30s | %s | %s\n", "ID", "END", "TIP");
    for (int i = 0; i < 50; i++)
        printf("-");
    for (int i = 0; i < posTab; i++)
        printf("\n%30s | %3d | %s", tabSimb[i].id, tabSimb[i].end, tabSimb[i].tip == INT? "INT" : "LOG");
    printf("\n");
    
}

// Estrutura da Pilha Semântica
// usada para endereços, viaráveis, rótulos

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


/* OUTRAS OPÇOES DE TESTE DE TIPOS
void testaAritmetico(){
    int t1 = desempilha();
    int t2 = desempilha();
    if(t1 != INT || t2 != INT)
        yyerror("Incompatibilidade de tipo!");
    empilhar(INT);
}

void testaRelacional(){
    int t1 = desempilha();
    int t2 = desempilha();
    if(t1 != INT || t2 != INT)
        yyerror("Incompatibilidade de tipo!");
    empilhar(LOG);
}

void testaLogico(){
    int t1 = desempilha();
    int t2 = desempilha();
    if(t1 != LOG || t2 != LOG)
        yyerror("Incompatibilidade de tipo!");
    empilhar(LOG);
}
*/
//---------------------------------------------
void testaTipo(int tipo1, int tipo2, int ret){
    int t1 = desempilha();
    int t2 = desempilha();
    if(t1 != tipo1 || t2 != tipo2)
        yyerror("Incompatibilidade de tipo!");
    empilhar(ret);
}
