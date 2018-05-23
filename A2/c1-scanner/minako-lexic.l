%{
#include <minako.h>
bool id = false;
%}
%x COMMENTLINE
%x COMMENTBLOCK
%x STRING
WHITESPACE  [ \t\n\r]
EXTRACHAR   [+-*/(){},;:]
%%
<INITIAL>{WHITESPACE}+              {}
<INITIAL>{EXTRACHAR}                {return (int) yytext[0];}
<INITIAL>"/*"                       {BEGIN(COMMENTBLOCK);}
<INITIAL>"//"                       {BEGIN(COMMENTLINE);}
<COMMENTBLOCK>.|\n                  {}
<COMMENTBLOCK>"*/"                  {BEGIN(INITIAL);}
<COMMENTLINE>.                      {}
<COMMENTLINE>\n                     {BEGIN(INITIAL);}
<INITIAL>&&                         {return AND;}
<INITIAL>||                         {return OR;}
<INITIAL>==                         {return EQ;}
<INITIAL>!=                         {return NEQ;}
<INITIAL><=                         {return LEQ;}
<INITIAL>>=                         {return GEQ;}
<INITIAL><                          {return LSS;}
<INITIAL>>                          {return GRT;}
<INITIAL>bool                       {id = true; return KW_BOOLEAN;}
<INITIAL>do                         {return KW_DO;}
<INITIAL>else                       {return KW_ELSE;}
<INITIAL>float                      {id = true; return KW_FLOAT;}
<INITIAL>for                        {return KW_FOR;}
<INITIAL>if                         {return KW_IF;}
<INITIAL>int                        {id = true; return KW_INT;}
<INITIAL>printf                     {return KW_PRINTF;}
<INITIAL>return                     {return KW_RETURN;}
<INITIAL>void                       {return KW_VOID;}
<INITIAL>while                      {return KW_WHILE;}
<INITIAL>[INTEGER]                  {return CONST_INT;}
<INITIAL>[FLOAT]                    {return CONST_FLOAT;}
<INITIAL>true                       {return CONST_BOOLEAN;}
<INITIAL>false                      {return CONST_BOOLEAN;}
<INITIAL>\"                         {BEGIN(STRING);}
<STRING>\"                          {return CONST_STRING;}
<INITIAL>[[:alpha:]][[:alnum:]]*    {if(id) { return ID;} else { /* ERROR */ } }
%%

