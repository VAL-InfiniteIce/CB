/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_MINAKO_SYNTAX_TAB_H_INCLUDED
# define YY_YY_MINAKO_SYNTAX_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif
/* "%code requires" blocks.  */
#line 7 "minako-syntax.y" /* yacc.c:1909  */

	#include <stdlib.h>
	#include <stdarg.h>
	#include "symtab.h"
	#include "syntree.h"
	
	extern void yyerror(const char*, ...);
	extern int yylex();
	extern int yylineno;
	extern FILE* yyin;

#line 56 "minako-syntax.tab.h" /* yacc.c:1909  */

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    AND = 258,
    OR = 259,
    EQ = 260,
    NEQ = 261,
    LEQ = 262,
    GEQ = 263,
    LSS = 264,
    GRT = 265,
    KW_BOOLEAN = 266,
    KW_DO = 267,
    KW_ELSE = 268,
    KW_FLOAT = 269,
    KW_FOR = 270,
    KW_IF = 271,
    KW_INT = 272,
    KW_PRINTF = 273,
    KW_RETURN = 274,
    KW_VOID = 275,
    KW_WHILE = 276,
    CONST_INT = 277,
    CONST_FLOAT = 278,
    CONST_BOOLEAN = 279,
    CONST_STRING = 280,
    ID = 281,
    UMINUS = 282,
    LOWER_THAN_ELSE = 283
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 70 "minako-syntax.y" /* yacc.c:1909  */

	char* string;
	double floatValue;
	int intValue;
	
	symtab_symbol_t* symbol;
	syntree_nid node;
	syntree_node_type type;

#line 107 "minako-syntax.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);
/* "%code provides" blocks.  */
#line 19 "minako-syntax.y" /* yacc.c:1909  */

	extern symtab_t* tab;
	extern syntree_t* ast;

#line 125 "minako-syntax.tab.h" /* yacc.c:1909  */

#endif /* !YY_YY_MINAKO_SYNTAX_TAB_H_INCLUDED  */
