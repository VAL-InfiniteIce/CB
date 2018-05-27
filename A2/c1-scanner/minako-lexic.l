%option noyywrap
%option yylineno
%option nounput
%option nodefault
%{
#define TRUE 1
#define FALSE 0

#include "minako.h"

%}

%x COMMENTLINE
%x COMMENTBLOCK
%x STRING
WHITESPACE  [ \t\n\r]
EXTRACHAR   [\+\-\*\/\(\)\{\},;:]
%%
<INITIAL>"/*"                       {BEGIN(COMMENTBLOCK);}
<COMMENTBLOCK>.|\n                  {}
<COMMENTBLOCK>"*/"                  {BEGIN(INITIAL);}
<INITIAL>"//"                       {BEGIN(COMMENTLINE);}
<COMMENTLINE>.                      {}
<COMMENTLINE>\n                     {BEGIN(INITIAL);}
<INITIAL>&&                         {return AND;}
<INITIAL>"||"                       {return OR;}
<INITIAL>==                         {return EQ;}
<INITIAL>!=                         {return NEQ;}
<INITIAL><=                         {return LEQ;}
<INITIAL>>=                         {return GEQ;}
<INITIAL><                          {return LSS;}
<INITIAL>>                          {return GRT;}
<INITIAL>bool                       {return KW_BOOLEAN;}
<INITIAL>do                         {return KW_DO;}
<INITIAL>else                       {return KW_ELSE;}
<INITIAL>float                      {return KW_FLOAT;}
<INITIAL>for                        {return KW_FOR;}
<INITIAL>if                         {return KW_IF;}
<INITIAL>int                        {return KW_INT;}
<INITIAL>printf                     {return KW_PRINTF;}
<INITIAL>return                     {return KW_RETURN;}
<INITIAL>void                       {return KW_VOID;}
<INITIAL>while                      {return KW_WHILE;}
<INITIAL>[INTEGER]                  {return CONST_INT;}
<INITIAL>[FLOAT]                    {return CONST_FLOAT;}
<INITIAL>"true"                     {return CONST_BOOLEAN;}
<INITIAL>"false"                    {return CONST_BOOLEAN;}
<INITIAL>\"                         {BEGIN(STRING);}
<STRING>\"                          {BEGIN(INITIAL);return CONST_STRING;}
<STRING>[[:alnum:]]*                {}
<INITIAL>[[:alpha:]][[:alnum:]]*    {return ID;}
<INITIAL>{WHITESPACE}+              {}
<INITIAL>{EXTRACHAR}                {return (int) yytext[0];}
<INITIAL><<EOF>>                    {return -1;}
%%
/*
int main()
{
    int val;
    while ( (val = yylex()) )
    {
        printf("Value is %d", val);
    }
    return 0;
    printf("TEST!!!!!!!!!!!!!!!!!");
    return 0;
}
*/
