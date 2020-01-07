# Recipe Language

To delicious foods!

To mouthwatering foods!

To scrumptious foods!

## Requirements

Minimum requirement:

- C compiler supporting c99, such as GCC version 4.6.3;
- GNU Flex version 2.5.35;
- GNU Bison version 2.5

## Organization

./src/: flex and bison source code

./test/: test files 

./run/: executable and other outputs of flex and bison. 

​		syntax.output: a detailed description of the LALR(1) table of the grammar

​		lex.yy.c: the lexical analyzer

​		syntax.tab.c: the grammar and semantic analyzer

​		parser: the executable

./output/: storing actions of each food in recipes. For example:

​		tomatoes.txt: storing actions on tomatoes in all input recipes.

## Build and Run

To build the source code, go to directory ./run/, Run build.sh, or type the following in your terminal:

```shell
flex ../src/recipe.l
bison -o syntax.tab.c -d -v ../src/recipe.y
gcc -c syntax.tab.c -o syntax.tab.o
gcc -o parser syntax.tab.o -ll -lfl
# Mac os: gcc -o parser syntax.tab.o -ll -ly
```

Then you should run the executable in your terminal:

```shell
./parser
# the default input file is ../test/1.rec
# you can type something like 
# ./parser inputfile
# to assign an input file for the parser
```

Then you would see something like this in your terminal:

```shell
Syntax Error at line 4 : redefinition of tomatoes
Syntax Error at line 12 : undeclared identifier potatoes
Syntax Error at line 19 : using eggs without preparing them.
Lexical Error at line 21: unexpected '-'
Lexical Error at line 21: unexpected '-'
```

And you would see something like this in corresponding files in ../output:

```
in recipe "tomatoes and eggs": 
	cut tomatoes into pieces
```

## Semantic analysis

There are four main tasks of semantic analysis:

- Check whether an identifier is declared before using it
- Check whether an identifier is redefined
- Check whether vegetables and meat are prepared before using them
- Storing actions on foods

