struct TableElem
{
	char * type;
	char * id;
	bool prepared;
};

void AddElement(char * type, char * ids);

bool CheckDeclared(char * type, char * id);

void SetPrepared(char * id);

bool CheckPrepared(char * type, char * id);