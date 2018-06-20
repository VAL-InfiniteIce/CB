%define parse.error verbose
%define parse.traceinclude <std

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

%%


programm            : /* EMPTY */
                    | progamm declassignment ";" 
                    | progamm functiondefinition
                    ;

functiondefinition  : type id "(" parameterlist ")" "{" statementlist "}"
                    | type id "(" ")" "{" statementlist "}"
                    ;

parameterlist       : type id fparameters
                    ;
fparameters         : /*EMPTY*/
                    | "," type id fparameters
                    ;

functioncall        : id "(" A ")"
                    ;
fass                : /*EMPTY */
                    | assignment ffass
                    ;
ffass               : /* EMPTY */
                    | fass "," assignment
                    ;

statementlist       : /* EMPTY */
                    | statementlist block
                    ;
/* TODO! */
block               ::= "{" statementlist "}
                    ::= statement
/* TODO */
statement           ::= #unchanged
/* TODO */
statblock           ::= #unchanged

ifstatement         : <KW_IF> "(" assignment ")" statblock else
                    ;
else                : /* EMPTY */
                    | <KW_ELSE> statblock 
                    ;

forstatement        : <KW_FOR> "(" statdecl ";" expr ";" statassignment ")" statblock
                    ;
statdecl            : statassignment
                    | declassignmnet
                    ;
/* TODO */
dowhilestatement    ::= #unchanged
/* TODO */
whilestatement      ::= #unchanged

returnstatement     : <KW_RETURN> assignment
                    | <KW_RETURN>
                    ;
/* TODO */
printf              ::= #unchanged

declassignment      : type id 
                    | type id "=" assignment
                    ;
/* TODO */
type                ::= #unchanged
/* TODO */
statassignment      ::= #unchanged
/* TODO */
assignment          ::= #unchanged

expr                : simpexpr fexpr
                    ;
fexpr               : /* EMPTY */
                    | Op simpexpr fexpr
                    ;
Op                  : "=="
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
                    | Op term fterm
                    ;
Op                  : "+"
                    | "-"
                    | "||"
                    ;

term                : factor ffactor
                    ;
ffactor             : /* EMPTY */
                    | Op factor ffactor
                    ;
Op                  : "*"
                    | "/"
                    | "&&"
                    ;

/* TODO */
factor              ::= #unchanged

id                  : <ID>
                    ;

%%

int main()
{
	yydebug=1;
	return yyparse();
}

void yyerror(const char* msg)
{
}
