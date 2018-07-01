%define parse.error verbose
%define parse.trace

%{
#include <stdlib.h>
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
%%


programm            : /* EMPTY */
                    | programm declassignment ";" 
                    | programm functiondefinition
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
                    | ffass "," assignment
                    ;

statementlist       : /* EMPTY */
                    | statementlist block
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

forstatement        : KW_FOR "(" statdecl ";" expr ";" statassignment ")" block
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
                    | eop simpexpr fexpr
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
                    | fterm top term
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

int main()
{
    printf("HALLLLLO\n");
    printf("Ergebnis: %d\n", yyparse());
	return 0; 
}

void yyerror(const char* msg)
{
    printf("FUCK!");
    return;
}
