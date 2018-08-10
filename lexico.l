%{
#include "gramatica.tab.h"
#include <stdio.h>
#include <string.h>
char *yytext;
YYSTYPE yylval;

%}

//basico
DIGIT           [0-9]
ALFA		[A-Za-z_]
NUMBER          ({DIGIT}+)
IDENT		{ALFA}({ALFA}|{DIGIT})*
WS              [ \t]*
RET             [\n]

//palavras reservadas
IF			"if"
WHILE			"while"
PRINT			"print"
THEN			"then"
ELSE			"else"
INT			"int"
DO			"do"

//operadores
SOMA            [\+]
SUB             [\-]
MULT            [\*]
ATRIB		"="

//parenteses
AP              "("
FP              ")"

//chaves
AC		"{"
FC		"}"

//virgula
VIRG 		","

//ponto e virgula
PTV             ";"

%%

{WS}           		 {
               		   /* COME OS ESPAÇOS */
                	 }

{NUMBER}       		{ int aux;
			  strcpy(yylval.t.symbol, yytext);
                	  return _N;
                	}

{IDENT}         	{int aux;
			  strcpy(yylval.t.symbol, yytext);
			  return _ID;
			}

{RET}           	{
                	  return yytext[0];
                	}	
                
{IF}			{return _IF;}

{WHILE}			{return _WHILE;}

{PRINT}			{return _PRINT;}

{THEN}			{return _THEN;}

{ELSE}			{return _ELSE;}

{INT}			{return _INT;}

{DO}			{return _DO;}

{SOMA}			{return _SOMA;}

{SUB}			{return _SUB;}

{MULT}			{return _MULT;}

{AP}             	{return _ABREPAR;}

{FP}             	{return _FECHAPAR;}

{AC}			{return _ABRECHA;}

{FC}			{return _FECHACHA;}

{VIRG}            	{return _VIRG;}

{PTV}            	{return _PTVIRG;}

