%define parse.error verbose
%define parse.trace

%{

%}
%code requires {
	#include <stdlib.h>
	#include <stdarg.h>
	#include "symtab.h"
	#include "syntree.h"
	
	extern void yyerror(const char*, ...);
	extern int yylex();
	extern int yylineno;
	extern FILE* yyin;
}

%code provides {
	extern symtab_t* tab;
	extern syntree_t* ast;
}

%code {
	/* globale Zeiger auf Symboltabelle und abstrakten Syntaxbaum */
	symtab_t* tab;
	syntree_t* ast;
	
	/* interner (globaler) Zeiger auf die aktuell geparste Funktion */
	static symtab_symbol_t* func;
	
	/**@brief Kombiniert zwei Ausdrücke einer binären Operation und stellt
	 * sicher, dass sie auf deren Typen definiert ist.
	 * @param lhs  linke Seite
	 * @param rhs  rechte Seite
	 * @param op   Operator
	 * @return ID des Operatorknoten
	 */
	static syntree_nid
	combine(syntree_nid id1, syntree_nid id2, syntree_node_tag op);
	
	/* Hilfsfunktionen */
	
	/**@brief Gibt den Zeiger auf einen Knoten der entsprechenden ID zurück.
	 */
	static inline syntree_node_t*
	nodePtr(syntree_nid id) { return syntreeNodePtr(ast, id); }
	
	/**@brief Gibt den Knotentyp zurück.
	 */
	static inline syntree_node_type
	nodeType(syntree_nid id) { return nodePtr(id)->type; }
	
	/**@brief Gibt den Wert eines Knotens zurück.
	 */
	static inline union syntree_node_value_u*
	nodeValue(syntree_nid id) { return &nodePtr(id)->value; }
	
	/**@brief Gibt den ersten Kindknoten eines Containers zurück.
	 */
	static inline syntree_nid
	nodeFirst(syntree_nid id) { return nodePtr(id)->value.container.first; }
	
	/**@brief Gibt den Folgeknoten eines Knotens zurück.
	 */
	static inline syntree_nid
	nodeNext(syntree_nid id) { return nodePtr(id)->next; }
}

%union {
	char* string;
	double floatValue;
	int intValue;
	
	symtab_symbol_t* symbol;
	syntree_nid node;
	syntree_node_type type;
}

%{
    extern int checkType(symtab_symbol_t * self, unsigned int toCompare);
    extern int insertElement();
    extern symtab_symbol_t * checkExistence();

    symtab_symbol_t * currentFunctionHandle = NULL;
    symtab_symbol_t * currentParameter = NULL;
%}

%printer { fprintf(yyoutput, "\"%s\"", $$); } <string>
%printer { fprintf(yyoutput, "%g", $$); } <floatValue>
%printer { fprintf(yyoutput, "%i", $$); } <intValue>
%printer {
	if ($$ != 0)
	{
		putc('\n', yyoutput);
		syntreePrint(ast, $$, yyoutput, 1);
	}
} <node>
%printer {
	putc('\n', yyoutput);
	symtabPrint(tab, yyoutput);
} declassignment functiondefinition

%destructor { free($$); } <string>

/* used tokens (KW is abbreviation for keyword) */
%token AND
%token OR
%token EQ
%token NEQ
%token LEQ
%token GEQ
%token LSS
%token GRT
%token KW_BOOLEAN
%token KW_DO
%token KW_ELSE
%token KW_FLOAT
%token KW_FOR
%token KW_IF
%token KW_INT
%token KW_PRINTF
%token KW_RETURN
%token KW_VOID
%token KW_WHILE
%token <intValue>   CONST_INT
%token <floatValue> CONST_FLOAT
%token <intValue>   CONST_BOOLEAN
%token <string>     CONST_STRING
%token <string>     ID

/* definition of association and precedence of operators */
%left '+' '-' OR
%left '*' '/' AND
%nonassoc UMINUS

/* workaround for handling dangling else */
/* LOWER_THAN_ELSE stands for a not existing else */
%nonassoc LOWER_THAN_ELSE
%nonassoc KW_ELSE

%type <node> program declassignment
%type <node> opt_argumentlist argumentlist
%type <node> statementlist statement block
%type <node> ifstatement forstatement dowhilestatement whilestatement opt_else
%type <node> returnstatement printf statassignment
%type <node> expr simpexpr functioncall assignment

%type <type> type
%type <symbol> parameter

%%

start:
	program {
		symtab_symbol_t* entry = symtabLookup(tab, "main");
        if (! entry) { yyerror("a 'void main()' must bedeclared\n"); }
        if (entry->type != SYNTREE_TYPE_Void) { yyerror("the 'main()' must be of type void!\n"); }
        if (entry->par_next != NULL) { yyerror("there are no parameters for 'void main()' allowed!\n"); }

		nodeValue(0)->program.body = syntreeNodeAppend(ast, $program, entry->body);
		nodeValue(0)->program.globals = symtabMaxGlobals(tab);
	}
	;

/* see EBNF grammar for further information */
program:
	/* empty */
		{ $$ = syntreeNodeEmpty(ast, SYNTREE_TAG_Sequence); }
	| program[prog] declassignment[decl] ';'
		{ syntreeNodeAppend(ast, $prog, $decl); }
	| program functiondefinition
	;

functiondefinition:
	type ID[name]
    {
		/* globale Zeiger auf das aktuelle Funktionssymbol */
		func = symtabSymbol($name, $type);
		func->is_function = 1;
		func->body = syntreeNodeEmpty(ast, SYNTREE_TAG_Function);
		
		if (symtabInsert(tab, func) != 0)
        {
		    yyerror("double declaration of function %s\n.", $name);
        }
        symtabPrint(tab, stdout);
        /* Just to be save: */
        if (currentFunctionHandle != NULL) { fprintf(stderr, "cFH != NULL\n"); exit(-2); }
        currentFunctionHandle = func;
        currentParameter = func;

	}
	'(' opt_parameterlist ')'
    {
        currentParameter = NULL;
        currentFunctionHandle = NULL;
    }
    '{' statementlist[body] '}'
    {
		syntreeNodeAppend(ast, func->body, $body);
		nodeValue(func->body)->function.locals = symtabMaxLocals(tab);
	}
	;

opt_parameterlist:
	/* empty */
	| parameterlist
	;

parameterlist:
	parameter
	| parameter ',' parameterlist
	;

parameter:
	type[type] ID[name]
    {
        symtab_symbol_t* sym = symtabSymbol($name, $type);

        // TODO check double delcaration in parameters
        currentParameter->par_next = sym;
        currentParameter = sym;

        symtabInsert(tab, sym);
        symtabPrint(tab, stdout);
    }
	;

functioncall:
	ID[name] '(' opt_argumentlist[args] ')' {
		symtab_symbol_t* fn = symtabLookup(tab, $name);
		
		if (fn == NULL)
			yyerror("unknown symbol '%s'", $name);
		
		$$ = syntreeNodePair(ast, SYNTREE_TAG_Call, $args, fn->body);
		nodePtr($$)->type = fn->type;
        symtabPrint(tab, stdout);
	}
	;

opt_argumentlist:
	/* empty */
		{ $$ = syntreeNodeEmpty(ast, SYNTREE_TAG_Sequence); }
	| argumentlist
	;

argumentlist:
	assignment[expr]
		{ $$ = syntreeNodeTag(ast, SYNTREE_TAG_Sequence, $expr); }
	| argumentlist[list] ',' assignment[elem]
		{ $$ = syntreeNodeAppend(ast, $list, $elem); }
	;

statementlist:
	/* empty */
		{ $$ = syntreeNodeEmpty(ast, SYNTREE_TAG_Sequence); }
	| statementlist[list] statement[elem]
		{ $$ = syntreeNodeAppend(ast, $list, $elem); }
	;

block:
	'{'
		statementlist[body]
	'}' { $$ = $body; }
	;

statement:
	  ifstatement
	| forstatement
	| whilestatement
	| returnstatement ';'
	| dowhilestatement ';'
	| printf ';'
	| declassignment ';'
	| statassignment ';'
	| functioncall ';'
	| block
	;

ifstatement:
	KW_IF '(' assignment[cond] ')' statement[then] opt_else[else] {
		$$ = syntreeNodePair(ast, SYNTREE_TAG_If, $cond, $then);
		$$ = syntreeNodeAppend(ast, $$, $else);
	}
	;

/* KW_ELSE has higher precedence, so an occuring 'else' will cause the */
/* execution of the second rule */
opt_else:
	/* empty */ %prec LOWER_THAN_ELSE
		{ $$ = 0; }
	| KW_ELSE statement[else]
		{ $$ = $else; }
	;

forstatement:
	KW_FOR '(' declassignment[init] ';' expr[cond] ';' statassignment[step] ')' statement[body] {
		$$ = syntreeNodePair(ast, SYNTREE_TAG_For, $init, $cond);
		$$ = syntreeNodeAppend(ast, $$, $step);
		$$ = syntreeNodeAppend(ast, $$, $body);
	}
	| KW_FOR '(' statassignment[init] ';' expr[cond] ';' statassignment[step] ')' statement[body] {
		$$ = syntreeNodePair(ast, SYNTREE_TAG_For, $init, $cond);
		$$ = syntreeNodeAppend(ast, $$, $step);
		$$ = syntreeNodeAppend(ast, $$, $body);
	}
	;

dowhilestatement:
	KW_DO statement[body] KW_WHILE '(' assignment[cond] ')' {
		$$ = syntreeNodePair(ast, SYNTREE_TAG_DoWhile, $cond, $body);
	}
	;

whilestatement:
	KW_WHILE '(' assignment[cond] ')' statement[body] {
		$$ = syntreeNodePair(ast, SYNTREE_TAG_While, $cond, $body);
	}
	;

returnstatement:
	KW_RETURN {
		$$ = syntreeNodeEmpty(ast, SYNTREE_TAG_Return);
	}
	| KW_RETURN assignment[expr] {
		if (func->type != nodeType($expr))
			$expr = syntreeNodeCast(ast, func->type, $expr);
		
		$$ = syntreeNodeTag(ast, SYNTREE_TAG_Return, $expr);
	}
	;

printf:
	KW_PRINTF '(' assignment[arg] ')'
		{ $$ = syntreeNodeTag(ast, SYNTREE_TAG_Print, $arg); }
	| KW_PRINTF '(' CONST_STRING[arg] ')'
		{ $$ = syntreeNodeTag(ast, SYNTREE_TAG_Print, syntreeNodeString(ast, $arg)); }
	;

declassignment:
	type ID[name] {
		$$ = 0;
        symtab_symbol_t* sym = symtabSymbol($name, $type);

        if ( checkExistence($name) ) { yyerror("%s already declared!\n", $name); }

        symtabInsert(tab, sym);
        symtabPrint(tab, stdout);
	}
	| type ID[name] '=' assignment[expr] {
	    symtab_symbol_t* sym = symtabSymbol($name, $type);
		
        $expr = checkType(sym, $expr);

        if ( checkExistence($name) ) { yyerror("%s already declared!\n", $name); }

		$$ = syntreeNodePair(ast, SYNTREE_TAG_Assign, syntreeNodeVariable(ast, sym), $expr);

        symtabInsert(tab, sym);
        symtabPrint(tab, stdout);
	}
	;

type:
	KW_BOOLEAN { $$ = SYNTREE_TYPE_Boolean; }
	| KW_FLOAT { $$ = SYNTREE_TYPE_Float; }
	| KW_INT   { $$ = SYNTREE_TYPE_Integer; }
	| KW_VOID  { $$ = SYNTREE_TYPE_Void; }
	;

statassignment:
	ID[name] '=' assignment[expr] {
		symtab_symbol_t* sym = checkExistence($name);
		
        if (!sym) { yyerror("%s is used before declaration!\n", $name); }

		if (sym->type != nodeType($expr))
			$expr = syntreeNodeCast(ast, sym->type, $expr);
		
		$$ = syntreeNodePair(ast, SYNTREE_TAG_Assign,
		                     syntreeNodeVariable(ast, sym), $expr);
	}
	;

assignment:
	ID[name] '=' assignment[expr] {
		symtab_symbol_t* sym = checkExistence($name);
		
        if (!sym) { yyerror("%s is used before declaration\n", $name); }

		if (sym->type != nodeType($expr))
			$expr = syntreeNodeCast(ast, sym->type, $expr);
		
		$$ = syntreeNodePair(ast, SYNTREE_TAG_Assign,
		                     syntreeNodeVariable(ast, sym), $expr);
		nodePtr($$)->type = sym->type;
	}
	| expr
	;

expr:
	simpexpr
	| simpexpr[lhs] EQ  simpexpr[rhs]
		{ $$ = combine($lhs, $rhs, SYNTREE_TAG_Eqt); }
	| simpexpr[lhs] NEQ simpexpr[rhs]
		{ $$ = combine($lhs, $rhs, SYNTREE_TAG_Neq); }
	| simpexpr[lhs] LEQ simpexpr[rhs]
		{ $$ = combine($lhs, $rhs, SYNTREE_TAG_Leq); }
	| simpexpr[lhs] GEQ simpexpr[rhs]
		{ $$ = combine($lhs, $rhs, SYNTREE_TAG_Geq); }
	| simpexpr[lhs] LSS simpexpr[rhs]
		{ $$ = combine($lhs, $rhs, SYNTREE_TAG_Lst); }
	| simpexpr[lhs] GRT simpexpr[rhs]
		{ $$ = combine($lhs, $rhs, SYNTREE_TAG_Grt); }
	;

simpexpr:
	simpexpr[lhs] '+' simpexpr[rhs]
		{ $$ = combine($lhs, $rhs, SYNTREE_TAG_Plus); }
	| simpexpr[lhs] '-' simpexpr[rhs]
		{ $$ = combine($lhs, $rhs, SYNTREE_TAG_Minus); }
	| simpexpr[lhs] OR simpexpr[rhs]
		{ $$ = combine($lhs, $rhs, SYNTREE_TAG_LogOr); }
	| simpexpr[lhs] '*' simpexpr[rhs]
		{ $$ = combine($lhs, $rhs, SYNTREE_TAG_Times); }
	| simpexpr[lhs] '/' simpexpr[rhs]
		{ $$ = combine($lhs, $rhs, SYNTREE_TAG_Divide); }
	| simpexpr[lhs] AND simpexpr[rhs]
		{ $$ = combine($lhs, $rhs, SYNTREE_TAG_LogAnd); }
	| '-' simpexpr[operand] %prec UMINUS {
		$$ = syntreeNodeTag(ast, SYNTREE_TAG_Uminus, $operand);
		nodePtr($$)->type = nodeType($operand);
	}
	| CONST_INT[val]
		{ $$ = syntreeNodeInteger(ast, $val); }
	| CONST_FLOAT[val]
		{ $$ = syntreeNodeFloat(ast, $val); }
	| CONST_BOOLEAN[val]
		{ $$ = syntreeNodeBoolean(ast, $val); }
	| functioncall
	| ID[name] {
		symtab_symbol_t* sym = symtabLookup(tab, $name);

		$$ = syntreeNodeVariable(ast, sym);
	}
	| '(' assignment ')'
		{ $$ = $assignment; }
	;

%%

int main(int argc, const char* argv[])
{
	symtab_t symtab;
	syntree_t syntree;
	int rc;
	
	/* belege die globalen Zeiger mit den lokalen Werten */
	tab = &symtab;
	ast = &syntree;
	
	/* versuche die Datei aus der Kommandozeile zu öffnen
	 * oder lies aus der Standardeingabe */
	yyin = (argc != 2) ? stdin : fopen(argv[1], "r");
	
	if (yyin == NULL)
		yyerror("couldn't open file %s\n", argv[1]);
	
	/* initialisiere die Hilfsstrukturen */
	if (symtabInit(tab))
	{
		fputs("out-of-memory error\n", stderr);
		exit(-1);
	}
	
	if (syntreeInit(ast))
	{
		fputs("out-of-memory error\n", stderr);
		exit(-1);
	}
	
	/* parse das Programm */
	yydebug = 0;
	rc = yyparse();
	printf("Result of test: %i\n", rc);
	/* gib' Symboltabelle und Syntaxbaum wieder frei */
	symtabRelease(&symtab);
	syntreeRelease(&syntree);
	
	return rc;
}

int insertElement()
{
    return 0;
}

symtab_symbol_t *checkExistence(const char *name)
{
    symtab_symbol_t* other = symtabLookup(tab, name);
    if (! other)
    {
        printf("%s is a new one!\n", name);
        return 0;
    } else {
        printf("%s is already defined!\n", name);
        return other;
    }
}

int checkType(symtab_symbol_t *self, unsigned int toCompare)
{
	if (self->type != nodeType(toCompare))
    {
		toCompare = syntreeNodeCast(ast, self->type, toCompare);
        // TODO : int to float cast is legit
        printf("Expr has %i as value\n", toCompare);
        yyerror("can't cast %i to %i!", toCompare, self->type);
    }
    return toCompare;
}
/**@brief Gibt eine Fehlermeldung aus und beendet das Programm mit Exitcode -1.
 * Die Funktion akzeptiert eine variable Argumentliste und nutzt die Syntax von
 * printf.
 * @param msg  die Fehlermeldung
 * @param ...  variable Argumentliste für die Formatierung von \p msg
 */
void yyerror(const char* msg, ...)
{
	va_list args;
	
	va_start(args, msg);
	fprintf(stderr, "Error in line %d: ", yylineno);
	vfprintf(stderr, msg, args);
	fprintf(stderr, "\n");
	va_end(args);
    exit(-1);
}

/**@brief Testet, ob eine binäre Operation zwischen zwei getypten Ausdrücken
 * definiert ist und bricht mit einem Fehler ab, falls nicht.
 * @param lhs  Typ des Operanden auf der linken Seite
 * @param rhs  Typ des Operanden auf der rechten Seite
 * @param op   Operator
 * @return resultierender Typ aus der Operation
 */	
static syntree_node_type
combineTypes(syntree_node_type lhs, syntree_node_type rhs, syntree_node_tag op)
{
	/* lhs und rhs können sein:
	 * SYNTREE_TYPE_Void,
	 * SYNTREE_TYPE_Boolean,
	 * SYNTREE_TYPE_Integer,
	 * SYNTREE_TYPE_Float
	 */

	switch (op)
	{
	case SYNTREE_TAG_Eqt:
	case SYNTREE_TAG_Neq:
	case SYNTREE_TAG_Leq:
	case SYNTREE_TAG_Geq:
	case SYNTREE_TAG_Lst:
	case SYNTREE_TAG_Grt:
	case SYNTREE_TAG_LogOr:
	case SYNTREE_TAG_LogAnd:
	case SYNTREE_TAG_Plus:
	case SYNTREE_TAG_Minus:
	case SYNTREE_TAG_Times:
	case SYNTREE_TAG_Divide:
		break;
		
	default:
	 	yyerror("unknown operation (internal error)");
	}
	
	/* just to avoid a warning */
	return SYNTREE_TYPE_Integer;
}

syntree_nid
combine(syntree_nid lhs, syntree_nid rhs, syntree_node_tag op)
{
	syntree_nid res;
	syntree_node_type lhs_type = nodeType(lhs);
	syntree_node_type rhs_type = nodeType(rhs);
	syntree_node_type type = combineTypes(lhs_type, rhs_type, op);
	
	if (lhs_type != rhs_type)
	{
		/* Situation: ein Integer und ein Float (impliziter Cast) */
		if (lhs_type != SYNTREE_TYPE_Float)
			lhs = syntreeNodeCast(ast, SYNTREE_TYPE_Float, lhs);
		else if (rhs_type != SYNTREE_TYPE_Float)
			rhs = syntreeNodeCast(ast, SYNTREE_TYPE_Float, rhs);
	}
	
	res = syntreeNodePair(ast, op, lhs, rhs);
	nodePtr(res)->type = type;
	return res;
}
