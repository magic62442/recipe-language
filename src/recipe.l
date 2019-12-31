%{

	#include <stdio.h>
	#include <string.h>
	#include "syntax.tab.h"
	int yycolumn = 1;
    #define YY_USER_ACTION \
        yylloc.first_line = yylloc.last_line = yylineno; \
        yylloc.first_column = yycolumn; \
        yylloc.last_column = yycolumn + yyleng - 1; \
        yycolumn += yyleng;
%}

%option yylineno

non_zero	[1-9]
digit 		([0-9])
digits    	({digit})+
letter      ([a-zA-Z])
word		([a-zA-Z])+

%%

	/*numbers*/

{non_zero}{digits}|{digit}      { yylval.number = atoi(yytext); return NUM; }

	/*characters*/

";"      	   { return SEMICOLON; }
":"			   { return COLON; }
","			   { return COMMA; }
"{"			   { return LC; }
"}"			   { return RC; }
\n 			   { yycolumn = 1; }
[ \t]   { /* ignore white space */ }
"/*"(.)*"*/"   { /* ignore notes */ }
	/*actions, units, adjectives, levels*/ 




(take|peel|soak|cut|chop|beat|stir) { return PACTION; }
(pour|scramble|mix|fry|steam|roast|braise|simmer) { return SACTION; }
(low|medium|high) { return LEVEL; }
(red|boiled|watery) { return ADJECTIVE; }
(minutes|seconds|hours) { return TIME; }
(g|tablespoons|bags|packs|bars|pieces|segments|drops|bowlsslices|dices|chunks|shreds) { return UNIT; }

	/*key words*/ 
	/*yylval.str = strdup(yytext);*/

name		   { return NAMEBEGIN; }
declarations   { return DECLBEGIN; }
ingredients	   { return INGRBEGIN; }
preparations   { return PREPBEGIN; }
steps		   { return STEPBEGIN; }
to             { return TO; }
into		   { return INTO; }
when		   { return WHEN; }
until		   { return UNTIL; }
after		   { return AFTER; }
become		   { return BECOME; }
flame		   { return FLAME; }

	/*types*/ 

vegetable	   { return VEGETABLE; }
meat		   { return MEAT; }
seasoning	   { return SEASONING; }

	/*identifiers*/ 

{word}		   { yylval.id = strdup(yytext); return ID; }

	/*user defined actions*/ 

[\"]{word}[\"] { yylval.uaction = strdup(yytext); return UACTION; }

	/*notes*/ 

"//"		   { char c = input(); while(c != '\n') c = input(); }

	/*others*/

.      		   { printf("Error at line %d: unexpected \'%s\' \n", yylineno, yytext); }



%%

