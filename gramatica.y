%{
#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
extern int yylex ();
 
#define NADA		9999
#define FRACASSO	9998
#define ACHOUDIFVAR	9997

char *msg4 = "unknow entity in source program";

typedef enum { /*enumera os tipos de entidade*/
	Variable,
	Constant,
	Temporary,
	Function,
	Procedure
} Entity;

/*
Tabela de simbolos: define uma tabela cm 100 linhas ,
 50 para simbolos do programa fonte e 50 para as variaveis temporárias.
 E 3 colunas: valor(atributo), tipo de entidade( enumeradas acima), e
  o nome no programa fonte.
    
SymbTab: 1as 50 entradas p/ simbolos do fonte
e últimas p/ as temporarias
*/
typedef struct {
  char     asciiOfSource [20];
  Entity   entt;
  int      value;
} SymbTab;

SymbTab symbTab [100];

/* indices que indicam a posição na tabela de simbolos, de simbolos do fonte e 
de elementos temporarios criados .*/
int	indSymb,  
	indTemp;


/* inteiros que marcam o comeco da tabela para simbolos 
do programa fonte e para elementos temporarios .*/
int	topTab=0;   // first 50 entries are programmer symbols
int	topTemp=50; // last  50 entries are temporary


//procura determinado simbolo da tabela na parte dos simbolos do fonte(1-50). 
int searchSymbTab (char *symb){ 
  int k;
  for (k = 0; k < topTab; k++)
    if (strcmp(symb,symbTab[k].asciiOfSource) == 0)
      return k;
  return topTab;
};

/* insere simbolos na tabela.
int insertSymbTab (char *symb, Entity whichEntt) {

  int existingSym, current, aux;
  
  // verifica se o simbolo ja existe e retorna o indice se jah existir
  existingSym = searchSymbTab (symb);
  if (existingSym < topTab) return existingSym;
  current = topTab;
  if ((whichEntt == Variable) || (whichEntt == Constant)) { //verifica se a entidade é uma constante ou variavel.
     strcpy(symbTab[current].asciiOfSource,symb);// coloca o nome da variavel ou da constante na tabela
     symbTab[current].entt = whichEntt; // preenche o campo entidade da tabela na linha atual
     }
  else { //se nao for uma variavel ou uma constante.
    char * ptMsg = (char *) malloc (80);
    strcpy(ptMsg,"Unknown entity type: "); 
    strcat(ptMsg,symb); 
    yyerror (ptMsg);
    };//se for uma constante a posição na tabela de simbolos recebe o valor constante.
  if (whichEntt == Constant)
     symbTab[current].value = atoi(symb);
  if (whichEntt == Variable) 
     symbTab[current].value = 0;  
  topTab++;
  return current;
};
//gera uma variavel temporária e retorna o indice desta na tabela de simbolos.
int temp () { 
	char nomeTemporaria[4];
	int retorno;
        sprintf(nomeTemporaria,"t%d",topTemp-50);
	strcpy(symbTab[topTemp].asciiOfSource,nomeTemporaria);
	symbTab[topTemp].entt = Temporary;
        retorno=topTemp;
	topTemp++;
	return (retorno);
};

//imprime a tabela de simbolos

void printSymbTable () {
int i, j, inicio, fimTrecho;
inicio=0;
j=0;
fimTrecho = topTab-1;// trecho dos símbolos do programa  
while (j <= 1) {
  for (i=inicio; i <= fimTrecho; i++) { 
    switch (symbTab[i].entt) {
      case Variable: printf("> Variable: ");break;
      case Constant: printf("> Numerical Constant: ");break;
      case Temporary: printf("> Temporary: ");break;
      case Function: printf("> Function: ");break;
      case Procedure: printf("> Procedure: ");break;
      default: yyerror(msg4);break;
    };
    printf("%s ", symbTab[i].asciiOfSource);
    printf("%d \n", symbTab[i].value);
    };// do for
  j++;
  inicio = 50;
  fimTrecho=topTemp-1;  // trecho das temporárias
}; // do while
}; // da function printSymbTable

//enumera os operadores da quadrupla.
typedef enum {
ADD,
SUB,
MUL,
DIV,
STO,
J,
JF,
PRINT
} Operador;

//formato da quadrupla. declara um Vetor de 100 posicoes
struct Quadrupla {
	Operador        op;
	int             operando1;
	int             operando2;
	int             operando3;
	} quadrupla [ 100 ];
	
//proxima quadrupla
int prox; 

//gera e coloca a quadrupla dentro do vetor;
void gera (Operador codop,int end1,int end2,int end3){
	quadrupla [prox].op = codop;
	quadrupla [prox].operando1 = end1;
	quadrupla [prox].operando2 = end2;
	quadrupla [prox].operando3 = end3;
	prox++;
	};
void remenda(int posM,Operador codop,int end1,int end2,int end3 )
{
	quadrupla [posM].op = codop;
	quadrupla [posM].operando1 = end1;
	quadrupla [posM].operando2 = end2;
	quadrupla [posM].operando3 = end3;
}
//imprime
void imprimeQuadrupla(){
  int r; 
  for(r=0;r<prox;r++) 
    printf("%d %d %d %d\n",
            quadrupla[r].op,                
               quadrupla[r].operando1,
                  quadrupla[r].operando2,
                     quadrupla[r].operando3);
  
}; //da funcao imprimeQuadrupla

//imprime a tabela de simbolos e as quadruplas
void finaliza () {
  printSymbTable ();
  imprimeQuadrupla ();
  printf("End normal compilation! \n");
  exit(0);
  };

//função do bison para imprimir o erro.
void yyerror(const char *str)
{
  printf("error: %s\n",str);
  exit (1);
};

//n sei
int yywrap()
{
  return 1;
};


int main()
{
  printf("\n \n> Compiladores 2018.1 \n>"); 
  yyparse();
  return 0;
};

%}

//define a estrutura d um simbolo n terminal(simbolos da direita da regra)
//simbolos terminais que possuem atributos
//

%union{
  struct T{
    char symbol[21]; // simbolo
    int intval;}t; // posicao na tabela de simbolos
 }
 %union{
 struct Ma{
	char caracter[21];
	int intQuadr;}m;
 }

 //declara os tokens

%token BLOCO SELCOMND COMANDOS VARIAVEL DECLARACAO
%token _ABRECHA _FECHACHA 
%token _ATRIB _EOF _ABREPAR _FECHAPAR _PTVIRG _VIRG
%token _SOMA _SUB _MULT _WHILE _PRINT _THEN _ELSE _INT _DO 
%token _ERRO
%token _N _V


//simbolos nao terminais e simbolos terminais que possuem atributos.
%type<t> EXPRESSAO T F _N _ID 
%type<m> M N
%%



/* 
regras da gramatica e acoes semanticas
*/


PROGRAMA    : DECLARACAO _ABRECHA COMANDOS _FECHACHA{
				finaliza();
			};

DECLARACAO  : DECLARACAO VARIAVEL _PTVIRG{
			
			} 
			| VARIAVEL _PTVIRG{
			
			}
			;


VARIAVEL    : VARIAVEL _VIRG _ID{
			} 
			
			| _INT _ID{
				
			}
			;

COMANDOS 	: COMANDOS _PTVIRG SELCOMNDO{
			} 
			
			| SELCOMNDO{
			}
			;

                 
SELCOMNDO : _IF _ABRECHA EXPRESSAO _FECHACHA _THEN M BLOCO _ELSE M BLOCO{
				remenda($3.indQuadr,JF,$2.intval,$6.indQuadr+1,NADA);
				remenda($6.indQuadr, J, prox, NADA,NADA);
			}
			
			|  _IF _ABRECHA EXPRESSAO _FECHACHA _THEN M BLOCO{
				remenda($4.indQuadr,JF,S2.intval,NADA)
			}
			
			|  _WHILE N _ABRECHA EXPRESSAO _FECHACHA M _DO BLOCO{
				gera(J,$2.intQuadr,NADA,NADA);
				remenda($4.indQuadr,JF,$3.intval,prox,NADA)
			}
			
			|  _ID _ATRIB EXPRESSAO{
					gera(STO,$3.intval,$1.intval,NADA);
			}
			
			|  _PRINT _ABRECHA E _FECHACHA {
                   gera(PRINT,$3.intval, NADA, NADA);
				   printf("\n");}
            ;     
            
BLOCO	  : _ABRECHA COMANDOS _FECHACHA{
			} 
			| SELCOMANDO{
		    }
		   ;             
                 
EXPRESSAO : EXPRESSAO _SOMA T{
				$$.intval=temp();
				gera(ADD,$1.intval,$3.intval,$$.intval);	
			}
			|  EXPRESSAO _SUB T{
				$$.intval=temp();
				gera(SUB,$1.intval,$3.intval,$$.intval);			
			}
			;
			
M 		  : {   $$.indQuadr = prox;
				prox++;
			};
				
N			: {$$.indQuadr = prox;};
		
T    	  : T _MULT F {	
			$$.intval = temp(); 
			gera (MUL,$1.intval,$3.intval,$$.intval);}	
			;
		 
F    	  : _ID {$$.intval=$1.insertSymbTab($1.symbol, Variable);
		   }
		  | _N {$$.intval=$1.insertSymbTab($1.symbol, Constant);
           } 
     ;
%%

void atendeReclamacao () {
  int aux;
  aux = 0; // trying avoid compilation error in bison
  }

