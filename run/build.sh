# flex ../src/recipe.l
# bison -d -v  ../src/recipe.y
# gcc -ll lex.yy.c recipe.tab.c -std=c99 -o parser

flex ../src/recipe.l
bison -o syntax.tab.c -d -v -t ../src/recipe.y
gcc -c syntax.tab.c -o syntax.tab.o
gcc -o parser syntax.tab.o -ll -ly