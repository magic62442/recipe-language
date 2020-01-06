%locations

%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <stdbool.h>
	#include <stdarg.h>
	#include "lex.yy.c"
	int tableSize = 0;
	bool tableEmpty = true;
	typedef struct TableElem
	{
	    char * type;
	    char * id;
	    bool prepared;
	}TableElem;

	TableElem SymbolTable[100];
	int yylex();
	int yyerror(const char *s);
	void AddElement(char * type, char * ids);
	bool CheckDeclared(char * id);
	void SetPrepared(char * id);
	bool CheckPrepared(char * type, char * id);
	char* StrCat(int n, ...);
	/*char * sentence*/
%}

%token SEMICOLON COLON COMMA
%token SACTION PACTION ADJECTIVE UNIT LEVEL TIME
%token NAMEBEGIN DECLBEGIN INGRBEGIN PREPBEGIN STEPBEGIN FOR TO INTO WHEN UNTIL AFTER BECOME FLAME
%token VEGETABLE 
%token MEAT 
%token SEASONING 
%token LC RC
%token ID UACTION NUM

%define parse.error verbose
%define api.value.type {char*}


%%

Program : Declarations DishName Ingredients Preparations Steps
	;

Declarations : DECLBEGIN COLON DecList 
	;

DecList : 
	| Declaration DecList
	;

Declaration : Type IdList SEMICOLON { $$ = StrCat(2, $1, $2); AddElement($1, $2);}
	| error SEMICOLON
	| error
	;

Type : VEGETABLE { $$ = StrCat(1, $1); }
	| MEAT		 { $$ = StrCat(1, $1); }
	| SEASONING  { $$ = StrCat(1, $1); }
	;

IdList : ID      { $$ = StrCat(1, $1); }
	| ID COMMA IdList  { $$ = StrCat(2, $1, $2); }
	;

DishName : NAMEBEGIN COLON Name SEMICOLON 
	;


Name : ID { $$ = StrCat(1, $1); }
	| ID Name { $$ = StrCat(2, $1, $2); }
	;

Ingredients : INGRBEGIN COLON IngreList
	;

IngreList :
	| IngredientSentence IngreList
	;

IngredientSentence : Ingredient
	| error SEMICOLON
	| error

Ingredient : ID NUM UNIT SEMICOLON {/*check id exist*/}
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

bool CheckDeclared(char * id) {
    for(int i = 0; i < tableSize; i++)
        if(strcmp(SymbolTable[i].id, id) == 0) {
            char * msg = (char *)malloc(100);
            strcpy(msg, "redefinition of ");
            msg = strcat(msg, id);
            yyerror(msg);
            return true;
        }

    return false;
}

bool CheckPrepared(char * type, char * id) {
    for(int i = 0; i < tableSize; i++)
        if(strcmp(SymbolTable[i].type, "seasoning") != 0 &&
           strcmp(SymbolTable[i].id, id) == 0 &&
           !SymbolTable[i].prepared) {
            char * msg = (char *)malloc(100);
            msg = strcat(msg, id);
            msg = strcat(msg, " before using it.");
            yyerror(msg);
            free(msg);
            return false;
        }
    return true;
}

void AddElement(char * type, char *ids) {
    TableElem e;
    char *id = NULL;
    char *s = (char *)malloc(1000);
    strcpy(s, ids);
    id = strtok(s, " ");
    while( id != NULL) {
        if(tableEmpty) {
            tableEmpty = false;
            e.type = type;
            e.id = id;
            e.prepared = false;
            SymbolTable[tableSize] = e;
            tableSize++;
        }
        else if(!CheckDeclared(id)) {
            e.type = type;
            e.id = id;
            e.prepared = false;
            SymbolTable[tableSize] = e;
            tableSize++;
        }

        id = strtok(NULL, " ");
    }
}

void SetPrepared(char * id) {
    for(int i = 0; i < tableSize; i++)
        if(strcmp(SymbolTable[i].id, id) == 0) {
            SymbolTable[i].prepared = true;
        }
}

char* StrCat(int n, ...) {
    va_list ap;
    va_start(ap, n);
    char * rst = (char *)malloc(1000);
    for (int i = 0; i < n; ++i)
    {
        char * s = va_arg(ap, char *);
        strcat(rst, s);
        if(i != n - 1)
            strcat(rst, " ");
    }

    return rst;
}

int main(int argc, char** argv)
{
	// #ifdef YYDEBUG
	// 	yydebug = 1;
	// #endif
	FILE *f;
	if(argc <= 1)
		f = fopen("../test/1.rec", "r");
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