#include "SymbolTable.h"
#include <string.h>

typedef struct TableElem
{
	char * type;
	char * id;
	bool prepared;
}TableElem;

TableElem SymbolTable[100];
void AddElement(char * type, char * ids) {
	TableElem e;
	char *id = NULL;
	id = strtok(ids, ",");
	while( id != NULL) {
		if(!CheckDeclared(id)) {
			e.type = type;
			e.id = id;
			e.prepared = false;
			SymbolTable[tableSize - 1] = TableElem;
			tableSize++;
		}

		id = strtok(ids, ",");
	}
}

bool CheckDeclared(char * id) {
	for(int i = 0; i < tableSize; i++)
		if(strcmp(SymbolTable[i].id, id) == 0) {
			char * msg = strcat("redefinition of ", id)
			yyerror(msg);
			return true;
		}

	return false;
}

void SetPrepared(char * id) {
	for(int i = 0; i < tableSize; i++)
		if(strcmp(SymbolTable[i].id, id) == 0) {
			SymbolTable[i].prepared = true;
			return true;
		}
}

bool CheckPrepared(char * type, char * id) {
	for(int i = 0; i < tableSize; i++)
		if(strcmp(SymbolTable[i].type, "seasoning") != 0 &&
		   strcmp(SymbolTable[i].id, id) == 0 &&
		   SymbolTable[i].prepared = false) {
			char * msg = strcat("please prepare ", id);
			msg = strcat(msg, " before using it.");
			yyerror(msg);
			return false;
		}
}

int main(int argc, char const *argv[])
{
	
	return 0;
}