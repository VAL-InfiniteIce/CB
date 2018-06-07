#include <stdio.h>
#include <stdlib.h>
#include "minako.h"

yystype yylval;

int eat(int *currentToken, int *nextToken);
int isToken();
int isTokenAndEat();

int main(int argc, char* argv[])
{
	int token;

	if (argc != 2)
		yyin = stdin;
	else
	{
		yyin = fopen(argv[1], "r");
		if (yyin == 0)
		{
			fprintf(stderr, "Fehler: Konnte Datei %s nicht zum lesen oeffnen.\n", argv[1]);
			exit(-1);
		}
	}
    
    int currentToken = yylex();
    int nextToken = yylex();

    if (currentToken == EOF) { return 0; }

	while (currentToken != EOF)
    {
        //
        // TODO
        // 
    }

    return 0;
}

int eat(int *currentToken, int *nextToken)
{
    *currentToken = *nextToken;
    if (*currentToken != EOF)
    {
        *nextToken = yylex();
    }
    return 0;
}

int isToken()
{
    // TODO
    return 0;
}

int isTokenAndEat()
{
    // TODO
    // on error:
    // printf(stderr, "ERROR: Syntaxfehler in Zele (<zeile>)");
    // exit(-1);
    return 0;
}
