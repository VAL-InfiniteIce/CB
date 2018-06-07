%option noyywrap
%option yylineno
%option nounput
%option noinput
%option always-interactive

WHITESPACE     [ \t\n\r]
INTEGER        [[:digit:]]+
FLOAT          {INTEGER}"."{INTEGER}|"."{INTEGER}

%x COMMENT

%{
#include "minako.h"
yystype yylval;
%}

%%

{WHITESPACE}+ {                 /* ignore whitespaces */ }
"//".*\n      {                 /* C++ Comment */ }
"/*"          { BEGIN(COMMENT); /* C   Comment */ }
<COMMENT>"*/" { BEGIN(INITIAL); }
<COMMENT>.|\n {}

&&          { return AND; }
"||"        { return OR;  }
==          { return EQ;  }
!=          { return NEQ; }
\<=         { return LEQ; }
>=          { return GEQ; }
\<          { return LSS; }
>           { return GRT; }

bool        { return KW_BOOLEAN; }
do          { return KW_DO; }
else        { return KW_ELSE; }
float       { return KW_FLOAT; }
for         { return KW_FOR; }
if          { return KW_IF; }
int         { return KW_INT; }
printf      { return KW_PRINTF; }
return      { return KW_RETURN; }
void        { return KW_VOID; }
while       { return KW_WHILE; }

{FLOAT}([eE]([\-+])?{INTEGER})? { yylval.floatValue = atof(yytext); return CONST_FLOAT; }
{INTEGER}[eE]([\-+])?{INTEGER}  { yylval.floatValue = atof(yytext); return CONST_FLOAT; }
{INTEGER}   { yylval.intValue = atoi(yytext); return CONST_INT; }
"true"      { yylval.intValue = 1; return CONST_BOOLEAN; }
"false"     { yylval.intValue = 0; return CONST_BOOLEAN; }
[[:alpha:]]([[:alnum:]]|_)* { yylval.string = yytext; return ID; }

<<EOF>>     { return EOF; }
.           { return yytext[0]; }

%%

