%locations

%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "lex.yy.c"
	int yylex();
	int yyerror(const char *s);
%}

%token SEMICOLON COLON COMMA
%token SACTION PACTION ADJECTIVE UNIT LEVEL TIME
%token NAMEBEGIN DECLBEGIN INGRBEGIN PREPBEGIN STEPBEGIN FOR TO INTO WHEN UNTIL AFTER BECOME FLAME
%token VEGETABLE MEAT SEASONING
%token LC RC
%define parse.error verbose

%union{
	char * id;
	char * uaction;
    int number;
}

%token <id> ID
%token <uaction> UACTION
%token <number> NUM

%%

Program : Declarations DishName Ingredients Preparations Steps
	;

Declarations : DECLBEGIN COLON DecList 
	;

DecList : 
	| Declaration DecList
	;

Declaration : Type IdList SEMICOLON
	| error SEMICOLON
	| error
	;

Type : VEGETABLE
	| MEAT
	| SEASONING
	;

IdList : ID
	| ID COMMA IdList
	;

DishName : NAMEBEGIN COLON Name SEMICOLON
	;

Name : ID
	| ID Name
	;

Ingredients : INGRBEGIN COLON IngreList
	;

IngreList :
	| IngredientSentence IngreList
	;

IngredientSentence : Ingredient
	| error SEMICOLON
	| error

Ingredient : ID NUM UNIT SEMICOLON
	| ID SEMICOLON
	;

Preparations : PREPBEGIN COLON PrepStmts
	;

PrepStmts :  
	| PrepSentence PrepStmts
	;

PrepSentence : PrepStmt
	| error SEMICOLON
	| error
	;

PrepStmt : PACTION NUM UNIT ID SEMICOLON
	| PACTION ID SEMICOLON
	| PACTION ID Preposition State SEMICOLON
	| PACTION ID FOR NUM TIME SEMICOLON
	;

Steps : STEPBEGIN COLON StepStmts
	;

StepStmts : 
	| StepSentence StepStmts
	;

StepSentence : StepStmt
	| error SEMICOLON
	| error
	;

StepStmt : Saction NUM UNIT ID SEMICOLON
	| Saction ID SEMICOLON 
	| Saction ID Preposition State SEMICOLON
	| Saction ID FOR NUM TIME SEMICOLON
	| LEVEL FLAME BLOCK
	;

BLOCK : LC StepStmts RC
	;

Saction : SACTION 
	| UACTION
	;

Preposition : TO
	| INTO
	| WHEN
	| UNTIL
	| AFTER
	;

State : BECOME ADJECTIVE
	| BECOME UNIT
	| UNIT
	;
%%

int yyerror(const char *s)
{
	printf("Syntax Error at line %d : %s\n", yylineno, s);
	return 0;
}

int main(int argc, char** argv)
{
	FILE *f;
	if(argc <= 1)
		f = fopen("../test/1.cb", "r");
	else {
		f = fopen(argv[1], "r");
	}
	if(!f) 
	{
		perror(argv[1]);
		return 1;
	}
	yyrestart(f);
    yyparse();
    return 0;
}