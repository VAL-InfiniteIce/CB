%define parse.error verbose
%define parse.trace

%{
#include <stdlib.h>
#define YYDEBUG 1
%}

%code requires {
	#include <stdio.h>
	
	extern void yyerror(const char*);
	extern FILE* yyin;
}

%code {
	extern int yylex();
	extern int yylineno;
}

%union {
	char* string;
	double floatValue;
	int intValue;
}

%token AND           "&&"
%token OR            "||"
%token EQ            "=="
%token NEQ           "!="
%token LEQ           "<="
%token GEQ           ">="
%token LSS           "<"
%token GRT           ">"
%token KW_BOOLEAN    "bool"
%token KW_DO         "do"
%token KW_ELSE       "else"
%token KW_FLOAT      "float"
%token KW_FOR        "for"
%token KW_IF         "if"
%token KW_INT        "int"
%token KW_PRINTF     "printf"
%token KW_RETURN     "return"
%token KW_VOID       "void"
%token KW_WHILE      "while"
%token CONST_INT     "integer literal"
%token CONST_FLOAT   "float literal"
%token CONST_BOOLEAN "boolean literal"
%token CONST_STRING  "string literal"
%token ID            "identifier"

%left "-" "+"
%left "*" "/"
%precedence UMINUS
%left "("
%right ")"
%left "if"
%right "else"

%start startpro

%token END 0 "end of file"
%%


startpro            : programm
                    ;

programm            : /* EMPTY */
                    | declassignment ";" programm
                    | functiondefinition programm
                    ;

functiondefinition  : type id "(" parameterlist ")" "{" statementlist "}"
                    | type id "(" ")" "{" statementlist "}"
                    ;

parameterlist       : type id fparameters
                    ;
fparameters         : /*EMPTY*/
                    | "," type id fparameters
                    ;

functioncall        : id "(" fass ")" %prec UMINUS
                    ;
fass                : /*EMPTY */
                    | assignment ffass
                    ;
ffass               : /* EMPTY */
                    | "," assignment ffass
                    ;

statementlist       : /* EMPTY */
                    | block statementlist
                    ;

block               : "{" statementlist "}"
                    | statement
                    ;

statement           : ifstatement
                    | forstatement
                    | whilestatement
                    | returnstatement ";"
                    | dowhilestatement ";"
                    | printf ";"
                    | declassignment ";"
                    | statassignment ";"
                    | functioncall ";"
                    ;

ifstatement         : KW_IF "(" assignment ")" block
                    | KW_IF "(" assignment ")" block KW_ELSE block
                    ;

forstatement        : KW_FOR "(" statdecl ";" expr ";" statassignment ")" block { printf("\n"); }
                    ;
statdecl            : statassignment
                    | declassignment
                    ;

dowhilestatement    : KW_DO block KW_WHILE "(" assignment ")"
                    ;

whilestatement      : KW_WHILE "(" assignment ")" block
                    ;

returnstatement     : KW_RETURN assignment
                    | KW_RETURN
                    ;

printf              : KW_PRINTF "(" printdeci ")"
                    ;

printdeci           : assignment
                    | CONST_STRING
                    ;

declassignment      : type id
                    | type id "=" assignment
                    ;

type                : KW_BOOLEAN
                    | KW_FLOAT
                    | KW_INT
                    | KW_VOID
                    ;

statassignment      : id "=" assignment
                    ;

assignment          : statassignment
                    | expr
                    ;

expr                : simpexpr fexpr
                    ;
fexpr               : /* EMPTY */
                    | eop simpexpr
                    ;
eop                 : "=="
                    | "!="
                    | "<"
                    | ">"
                    | "<="
                    | ">="
                    ;

simpexpr            : "-" term fterm
                    | term fterm
                    ;
fterm               : /* EMPTY */
                    /* | fterm "+" term */
                    /* | fterm "-" term */
                    /* | fterm "||" term */
                    | top term fterm
                    ;

top                 : "+"
                    | "-"
                    | "||"
                    ;

term                : factor ffactor
                    ;
ffactor             : /* EMPTY */
                    | fop factor ffactor
                    ;
fop                 : "*"
                    | "/"
                    | "&&"
                    ;

factor              : CONST_INT
                    | CONST_FLOAT
                    | CONST_BOOLEAN
                    | functioncall
                    | id
                    | "(" assignment ")"
                    ;

id                  : ID
                    ;

%%

int main(int argc, char* argv[])
{
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
	return yyparse();
}

void yyerror(const char* msg)
{
    printf("Error in %i: %s\n", yylineno, msg);
    exit(-1);
}
