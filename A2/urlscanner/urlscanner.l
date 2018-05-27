%option noyywrap
%option yylineno
%option nounput
%option nodefault
%{
#include "urlscanner.h"
%}
%x COMMENTLINE
%x COMMENTBLOCK
%x A_TAG_BEFORE
%x HREF
%x A_TAG_AFTER
%x TEXT

SPACE                           [ \t\n\r]
URLCHARS                        [a-zA-Z0-9\/.:]
%%
<INITIAL><!                     {BEGIN(COMMENTLINE);}
<COMMENTLINE>>|\n               {BEGIN(INITIAL);}
<COMMENTLINE>.                  {}
<INITIAL><!--                   {BEGIN(COMMENTBLOCK);}
<COMMENTBLOCK>-->               {BEGIN(INITIAL);}
<COMMENTBLOCK>.|\n              {}
<INITIAL><a                     {BEGIN(A_TAG_BEFORE);}
<A_TAG_BEFORE>href=\"           {BEGIN(HREF);}
<A_TAG_BEFORE>.|\n              {}
<HREF>\"                        {BEGIN(A_TAG_AFTER);}
<HREF>[^\"]*                    {yylval = yytext; return TOKEN_URL;}
<A_TAG_AFTER>>                  {BEGIN(TEXT);}
<A_TAG_AFTER>.|\n               {}
<TEXT><\/a({SPACE}*)>           {BEGIN(INITIAL);}
<TEXT>[^<]*                     {yylval = yytext; return TOKEN_TEXT;}
<INITIAL>.|\n                   {}
<<EOF>>                         {return MYEOF;}
%%
/*
<TEXT>"</a[SPACE]*>"            {BEGIN(INITIAL);}
<TEXT>[.|\n]*                   {return TOKEN_TEXT;}
*/
