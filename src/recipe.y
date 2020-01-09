%locations

%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <stdbool.h>
	#include <stdarg.h>
	#include "lex.yy.c"
	int tableSize = 0;
	bool tableEmpty = true;
	char * dishName;
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
	bool CheckDeclared(char * id, int type);
	void SetPrepared(char * id);
	bool CheckPrepared(char * id);
	char* StrCat(int n, ...);
	void WriteRecord(const char *id, const char * line);
%}

%token SEMICOLON COLON COMMA
%token SACTION PACTION ADJECTIVE UNIT LEVEL TIME
%token NAMEBEGIN DECLBEGIN INGRBEGIN PREPBEGIN STEPBEGIN 
%token FOR TO INTO WHEN UNTIL AFTER 
%token BECOME FLAME
%token VEGETABLE MEAT SEASONING 
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

Declaration : Type IdList SEMICOLON { $$ = StrCat(2, $1, $2); AddElement($1, $2); }
	| error SEMICOLON
	| error
	;

Type : VEGETABLE { $$ = StrCat(1, $1); }
	| MEAT		 { $$ = StrCat(1, $1); }
	| SEASONING  { $$ = StrCat(1, $1); }
	;

IdList : ID      { $$ = StrCat(1, $1); }
	| ID COMMA IdList  { $$ = StrCat(2, $1, $3); }
	;

DishName : NAMEBEGIN COLON Name SEMICOLON { $$ = strdup($3); dishName = $$; }
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

Ingredient : ID NUM UNIT SEMICOLON { $$ = StrCat(3, $1, $2, $3, $3); CheckDeclared($1, 2); }
	| ID SEMICOLON { $$ = StrCat(1, $1); CheckDeclared($1, 2); }
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

PrepStmt : 
	PACTION NUM UNIT ID SEMICOLON
	{ 
		$$ = StrCat(4, $1, $2, $3, $4); 
	    if(CheckDeclared($4, 2)) 
	    { 
	   	    SetPrepared($4); 
	   	    WriteRecord($4, $$);
	    } 
	}

	| PACTION ID SEMICOLON 
	{ 
		$$ = StrCat(2, $1, $2); 
	    if(CheckDeclared($2, 2)) 
	    { 
	   	    SetPrepared($2); 
	   	    WriteRecord($2, $$);
	    } 
	}

	| PACTION ID Preposition State SEMICOLON 
	{ 
		$$ = StrCat(4, $1, $2, $3, $4); 
	    if(CheckDeclared($2, 2)) 
	    { 
	   	    SetPrepared($2); 
	   	    WriteRecord($2, $$);
	    } 
	}

	| PACTION ID FOR NUM TIME SEMICOLON 
	{ 
		$$ = StrCat(5, $1, $2, $3, $4, $5); 
	    if(CheckDeclared($2, 2)) 
	    { 
	   	    SetPrepared($2); 
	   	    WriteRecord($2, $$);
	    } 
	}
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

StepStmt : 
	Saction NUM UNIT ID SEMICOLON
	{ 
		$$ = StrCat(4, $1, $2, $3, $4); 
	    if(CheckDeclared($4, 2) && CheckPrepared($4)) 
	    { 
	   	    WriteRecord($4, $$);
	    } 
	}

	| Saction ID SEMICOLON 
	{ 
		$$ = StrCat(2, $1, $2); 
	    if(CheckDeclared($2, 2) && CheckPrepared($2)) 
	    { 
	   	    WriteRecord($2, $$);
	    } 
	}

	| Saction ID Preposition State SEMICOLON 
	{ 
		$$ = StrCat(4, $1, $2, $3, $4); 
	    if(CheckDeclared($2, 2) && CheckPrepared($2)) 
	    { 
	   	    WriteRecord($2, $$);
	    } 
	}

	| Saction ID FOR NUM TIME SEMICOLON 
	{ 
		$$ = StrCat(5, $1, $2, $3, $4, $5); 
	    if(CheckDeclared($2, 2) && CheckPrepared($2)) 
	    { 
	   	    WriteRecord($2, $$);
	    } 
	}

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

State : BECOME ADJECTIVE { $$ = StrCat(2, $1, $2); }
	| BECOME UNIT { $$ = StrCat(2, $1, $2); }
	| UNIT 
	;
%%

int yyerror(const char *s)
{
	printf("Syntax Error at line %d : %s\n", yylineno, s);
	return 0;
}

bool CheckDeclared(char * id, int type) {
    if(type == 1) {
        for(int i = 0; i < tableSize; i++)
            if(strcmp(SymbolTable[i].id, id) == 0) {
                char * msg = (char *)malloc(100);
                strcpy(msg, "redefinition of ");
                msg = strcat(msg, id);
                yyerror(msg);
                free(msg);
                return true;
            }

        return false;
    }
    else {
        for(int i = 0; i < tableSize; i++)
            if(strcmp(SymbolTable[i].id, id) == 0) {
                return true;
            }
        char * msg = (char *)malloc(100);
        strcpy(msg, "undeclared identifier ");
        msg = strcat(msg, id);
        yyerror(msg);
        free(msg);
        return false;
    }
}

bool CheckPrepared(char * id) {
    for(int i = 0; i < tableSize; i++)
        if(strcmp(SymbolTable[i].type, "seasoning") != 0 &&
           strcmp(SymbolTable[i].id, id) == 0 &&
           !SymbolTable[i].prepared) {
            char * msg = (char *)malloc(100);
            strcpy(msg, "using ");
            msg = strcat(msg, id);
            msg = strcat(msg, " without preparing them.");
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
        else if(!CheckDeclared(id, 1)) {
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

void WriteRecord(const char *id, const char * line) {
    char * filename = (char*)malloc(100);
    filename[0] = '\0';
    strcat(filename, "../output/");
    strcat(filename, id);
    strcat(filename, ".txt");
    FILE * f = fopen(filename, "a");
    fprintf(f, "in recipe \"%s\": \n", dishName);
    fprintf(f, "\t%s\n\n", line);
    fclose(f);
}

int main(int argc, char** argv)
{
	#ifdef YYDEBUG
		yydebug = 1;
	#endif
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