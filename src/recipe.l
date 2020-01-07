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

{non_zero}{digits}|{digit}      { yylval = strdup(yytext); return NUM; }

	/*characters*/

";"      	   { return SEMICOLON; }
":"			   { return COLON; }
","			   { return COMMA; }
"{"			   { return LC; }
"}"			   { return RC; }
\n 			   { yycolumn = 1; }
[ \t]          { /* ignore white space */ }
"/*"(.)*"*/"   { /* ignore notes */ }

	/*actions, units, adjectives, levels*/ 

(take|peel|soak|cut|chop|beat|stir) { yylval = strdup(yytext); return PACTION; }
(pour|scramble|mix|fry|steam|roast|braise|simmer) { yylval = strdup(yytext); return SACTION; }
(low|medium|high) { yylval = strdup(yytext); return LEVEL; }
(red|boiled|watery|solid) { yylval = strdup(yytext); return ADJECTIVE; }
(minutes|seconds|hours) { yylval = strdup(yytext); return TIME; }
(g|tablespoons|bags|packs|bars|pieces|segments|drops|bowlsslices|dices|chunks|shreds) { yylval = strdup(yytext); return UNIT; }

	/*key words*/ 
	/*yylval = strdup(yytext);*/

name		   { yylval = strdup(yytext); return NAMEBEGIN; }
declarations   { yylval = strdup(yytext); return DECLBEGIN; }
ingredients	   { yylval = strdup(yytext); return INGRBEGIN; }
preparations   { yylval = strdup(yytext); return PREPBEGIN; }
steps		   { yylval = strdup(yytext); return STEPBEGIN; }
to             { yylval = strdup(yytext); return TO; }
with		   { yylval = strdup(yytext); return WITH; }
into		   { yylval = strdup(yytext); return INTO; }
when		   { yylval = strdup(yytext); return WHEN; }
until		   { yylval = strdup(yytext); return UNTIL; }
after		   { yylval = strdup(yytext); return AFTER; }
become		   { yylval = strdup(yytext); return BECOME; }
flame		   { yylval = strdup(yytext); return FLAME; }

	/*types*/ 

vegetable	   { yylval = strdup(yytext); return VEGETABLE; }
meat		   { yylval = strdup(yytext); return MEAT; }
seasoning	   { yylval = strdup(yytext); return SEASONING; }

	/*identifiers*/ 

{word}		   { yylval = strdup(yytext); return ID; }

	/*user defined actions*/ 

[\"]{word}[\"] { yylval = strdup(yytext); return UACTION; }

	/*notes*/ 

"//"		   { char c = input(); while(c != '\n') c = input(); }

	/*others*/

.      		   { printf("Lexical Error at line %d: unexpected \'%s\' \n", yylineno, yytext); }



%%

