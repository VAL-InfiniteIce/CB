/***************************************************************************//**
 * @file minako.c
 * @author Dorian Weber und die Studenten
 * @brief Enthält den Interpreter sowie den Einstiegspunkt in das Programm.
 ******************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include "minako-syntax.tab.h"
#include "symtab.h"
#include "syntree.h"

/**@brief Maximale Anzahl gleichzeitig verwendeter Variablen im Interpreter.
 */
#define MINAKO_STACK_SIZE 1024

/* ******************************************************* private structures */

/**@brief Ein Variablenwert im Interpreter.
 */
typedef struct minako_value_s
{
	/**@brief Typ des Variablenwertes.
	 */
	syntree_node_type type;
	
	/**@brief Variablenwert.
	 */
	union
	{
		int boolean;  /**<@brief Boolescher Wert. */
		int integer;  /**<@brief Ganzzahliger Wert. */
		float real;   /**<@brief Fließkommawert. */
		char* string; /**<@brief Zeiger auf Zeichenkette. */
	} value;
} minako_value_t;

/**@brief Struktur des Laufzeitzustands des Interpreters.
 */
typedef struct minako_vm_s
{
	minako_value_t stack[MINAKO_STACK_SIZE]; /**<@brief Variablenstack. */
	minako_value_t eax;  /**<@brief Ausgaberegister. */
	minako_value_t* ebp; /**<@brief Base pointer. */
	minako_value_t* esp; /**<@brief Stack pointer. */
	int returnFlag; /**<@brief Signalisiert das Verlassen einer Funktion. */
} minako_vm_t;

/**@brief Prototyp von Funktionen, die einen Knoten interpretieren.
 * @note Der Zustand der virtuellen Maschine und der ausgeführte Syntaxbaum
 * werden der Einfachheit halber implizit als globale Variablen bereitgestellt.
 * @param node  der zu interpretierende Knoten
 */
typedef void minako_exec_p(const syntree_node_t* node);

/**@brief Funktionszeigertyp der Interpreter-Funktionen.
 */
typedef minako_exec_p* minako_exec_f;

/* ****************************************************************** globals */

/* Deklaration aller Interpreterfunktionen */
#define DECL(NODE) \
	static minako_exec_p exec ## NODE;
	SYNTREE_NODE_LIST(DECL)
#undef DECL

/**@brief Globaler Zeiger auf den aktuellen Zustand der virtuellen Maschine.
 */
static minako_vm_t* vm;

#define CALLBACK(NODE) \
	&exec ## NODE,

/**@brief Statische Dispatchtabelle zur Lokalisierung der richtigen
 * Interpreterfunktion für einen gegebenen Knotentyp im Syntaxbaum.
 */
static const minako_exec_f
dispatchTable[] = {
	SYNTREE_NODE_LIST(CALLBACK)
};

#undef CALLBACK

/* ******************************************************** private functions */

/* Trace-Unterstützung zum Debuggen des Interpreters */

#ifndef NDEBUG
	static unsigned int indent;
	
	/**@brief Schreibt den Namen eines Knotentags eingerückt in die
	 * Standardausgabe und erhöht die Einrückung.
	 */
	#define TRACE_ENTER(TAG) \
		if (yydebug) { \
			printf("%*s<%s>\n", indent*4, "", nodeTagName[TAG]); \
			++indent; \
		}
	
     	/**@brief Verringert die Einrückung und schreibt den Namen eines
	 * Knotentags eingerückt in die Standardausgabe.
     	 */
	#define TRACE_LEAVE(TAG) \
		if (yydebug) { \
			--indent; \
			printf("%*s</%s>\n", indent*4, "", nodeTagName[TAG]); \
		}
	
     	/**@brief Schreibt den Wert einer Stackvariablen eingerückt in die Ausgabe.
     	 */
	#define TRACE_VALUE(VAL) \
		if (yydebug) { \
			printf("%*s", indent*4, ""); \
			switch (VAL.type) { \
			case SYNTREE_TYPE_Boolean: \
				printf("%s", VAL.value.boolean ? "true" : "false"); \
				break; \
			case SYNTREE_TYPE_Integer: \
				printf("%i", VAL.value.integer); \
				break; \
			case SYNTREE_TYPE_Float: \
				printf("%g", VAL.value.real); \
				break; \
			case SYNTREE_TYPE_String: \
				printf("\"%s\"", VAL.value.string); \
				break; \
			case SYNTREE_TYPE_Void: \
				printf("(void)"); \
				break; \
			} \
			putc('\n', stdout); \
		}
#else
	#define TRACE_ENTER(TAG)
	#define TRACE_LEAVE(TAG)
	#define TRACE_VALUE(VAL)
#endif

/* Hilfsfunktionen */

/**@brief Gibt den ersten Kindknoten eines Containers zurück.
 */
static inline const syntree_node_t*
nodeFirst(const syntree_node_t* node)
{
	return syntreeNodePtr(ast, node->value.container.first);
}

/**@brief Gibt den letzten Kindknoten eines Containers zurück.
 */
static inline const syntree_node_t*
nodeLast(const syntree_node_t* node)
{
	return syntreeNodePtr(ast, node->value.container.last);
}

/**@brief Gibt den Folgeknoten eines Knotens zurück.
 */
static inline const syntree_node_t*
nodeNext(const syntree_node_t* node)
{
	return syntreeNodePtr(ast, node->next);
}

/**@brief Prüft ob der gegebene Knoten der Terminatorknoten ist.
 * Terminatorknoten terminieren Container, analog zum terminierenden 0-Byte für
 * C-Strings.
 */
static inline int
nodeSentinel(const syntree_node_t* node)
{
	return syntreeNodeId(ast, node) == 0;
}

/* Dispatcher */

/**@brief Ruft für einen gegebenen Knoten die entsprechende Ausführungsfunktion.
 */
static inline minako_value_t
dispatch(const syntree_node_t* node)
{
	/* rufe die dem Knotentyp entsprechende Funktion */
	TRACE_ENTER(node->tag);
	dispatchTable[node->tag](node);
	TRACE_LEAVE(node->tag);
	
	return vm->eax;
}

/* ********************************* */
/* Literale */
/* ********************************* */

static void
execInteger(const syntree_node_t* node)
{
	vm->eax.type = node->type;
	vm->eax.value.integer = node->value.integer;
	TRACE_VALUE(vm->eax);
}

static void
execFloat(const syntree_node_t* node)
{
	/* TODO: Implementation */
}

static void
execBoolean(const syntree_node_t* node)
{
	/* TODO: Implementation */
}

static void
execString(const syntree_node_t* node)
{
	/* TODO: Implementation */
}

static void
execLocVar(const syntree_node_t* node)
{
	vm->eax = vm->ebp[node->value.variable];
}

static void
execGlobVar(const syntree_node_t* node)
{
	/* TODO: Implementation */
}

/* ********************************* */
/* Anweisungen */
/* ********************************* */

static void
execProgram(const syntree_node_t* node)
{
	/* prepare the VM for execution */
	vm->returnFlag = 0;
	vm->ebp = vm->esp = vm->stack;
	
	/* allocate space for global variables */
	vm->esp += node->value.program.globals;
	
	/* protect from stack overflow */
	if (vm->esp >= vm->stack + MINAKO_STACK_SIZE)
	{
		fprintf(stderr, "stack overflow\n");
		exit(-1);
	}
	
	execSequence(node);
}

static void
execFunction(const syntree_node_t* node)
{
	/* TODO: Implementation des Funktionsrufs vervollständigen */
	vm->ebp = vm->esp;
	execSequence(nodeFirst(node));
}

static void
execCall(const syntree_node_t* node)
{
	/* TODO: Parameterübergabe implementieren */
	/* Vorsicht: f(x, g(y)) muss auch funktionieren! */
	
	/* execute the function body */
	dispatch(nodeLast(node));
}

static void
execSequence(const syntree_node_t* node)
{
	/* TODO: Abarbeitung der gesamten Sequenz implementieren */
	if (!nodeSentinel(nodeFirst(node)))
		dispatch(nodeFirst(node));
}

static void
execIf(const syntree_node_t* node)
{
	const syntree_node_t* test = nodeFirst(node);
	const syntree_node_t* cons = nodeNext(test);
	
	/* test if we need to select the else block */
	if (dispatch(test).value.boolean)
		dispatch(cons);
	else 
		; /* TODO: else-Fall implementieren */
}

static void
execDoWhile(const syntree_node_t* node)
{
	const syntree_node_t* cond = nodeFirst(node);
	const syntree_node_t* exec = nodeLast(node);
	
	do
	{
		dispatch(exec);
		
		if (vm->returnFlag)
			break;
	}
	while (dispatch(cond).value.boolean);
}

static void
execWhile(const syntree_node_t* node)
{
	/* TODO: Implementation */
}

static void
execFor(const syntree_node_t* node)
{
	/* TODO: Implementation */
}

static void
execPrint(const syntree_node_t* node)
{
	switch (dispatch(nodeFirst(node)).type)
	{
	case SYNTREE_TYPE_Void:
		break;
	
	case SYNTREE_TYPE_Boolean:
		fputs(vm->eax.value.boolean ? "true" : "false", stdout);
		break;
	
	case SYNTREE_TYPE_Integer:
		printf("%i", vm->eax.value.integer);
		break;
	
	case SYNTREE_TYPE_Float:
		printf("%g", vm->eax.value.real);
		break;
	
	case SYNTREE_TYPE_String:
		fputs(vm->eax.value.string, stdout);
		break;
	}
	
	putc('\n', stdout);
}

static void
execAssign(const syntree_node_t* node)
{
	/* TODO: Implementation */
}

static void
execReturn(const syntree_node_t* node)
{
	node = nodeFirst(node);
	
	if (!nodeSentinel(node))
		dispatch(node);
	
	vm->returnFlag = 1;
}

/* ********************************* */
/* Ausdrücke */
/* ********************************* */

static void
execCast(const syntree_node_t* node)
{
	dispatch(nodeFirst(node));
	
	switch (node->type)
	{
	case SYNTREE_TYPE_Float:
		switch (vm->eax.type)
		{
		case SYNTREE_TYPE_Integer:
			vm->eax.type = node->type;
			vm->eax.value.real = vm->eax.value.integer;
			break;
			
		default:
			assert(!"unexpected source type");
		}
		
		break;
		
	default:
		assert(!"unexpected target type");
	}
}

static void
execPlus(const syntree_node_t* node)
{
	minako_value_t lhs = dispatch(nodeFirst(node));
	minako_value_t rhs = dispatch(nodeLast(node));
	
	switch (node->type)
	{
	case SYNTREE_TYPE_Integer:
		vm->eax.value.integer = lhs.value.integer + rhs.value.integer;
		break;
		
	case SYNTREE_TYPE_Float:
		vm->eax.value.real = lhs.value.real + rhs.value.real;
		break;
		
	default:
		assert(!"unexpected type in operation");
	}
}

static void
execMinus(const syntree_node_t* node)
{
	/* TODO: Implementation */
}

static void
execTimes(const syntree_node_t* node)
{
	/* TODO: Implementation */
}

static void
execDivide(const syntree_node_t* node)
{
	/* TODO: Implementation */
}

static void
execLogOr(const syntree_node_t* node)
{
	(void) (dispatch(nodeFirst(node)).value.boolean
	|| dispatch(nodeLast(node)).value.boolean);
}

static void
execLogAnd(const syntree_node_t* node)
{
	/* TODO: Implementation */
}

static void
execUminus(const syntree_node_t* node)
{
	/* TODO: Implementation */
}

static void
execEqt(const syntree_node_t* node)
{
	vm->eax.type = SYNTREE_TYPE_Boolean;
	switch (nodeFirst(node)->type)
	{
	case SYNTREE_TYPE_Boolean:
		/* TODO: Implementation */
		break;
		
	case SYNTREE_TYPE_Integer:
		/* TODO: Implementation */
		break;
		
	case SYNTREE_TYPE_Float:
		/* TODO: Implementation */
		break;
		
	default:
		assert(!"unexpected type in operation");
	}
}

static void
execNeq(const syntree_node_t* node)
{
	/* TODO: Implementation */
}

static void
execLeq(const syntree_node_t* node)
{
	/* TODO: Implementation */
}

static void
execGeq(const syntree_node_t* node)
{
	/* TODO: Implementation */
}

static void
execLst(const syntree_node_t* node)
{
	/* TODO: Implementation */
}

static void
execGrt(const syntree_node_t* node)
{
	/* TODO: Implementation */
}

/* *************************************************************** driver *** */

int main(int argc, const char* argv[])
{
	symtab_t symtab;
	syntree_t syntree;
	minako_vm_t engine;
	int rc;
	
	/* belege die globalen Zeiger mit den lokalen Werten */
	tab = &symtab;
	ast = &syntree;
	vm = &engine;
	
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
	
	/* gib die Symboltabelle wieder frei */
	symtabRelease(&symtab);
	
	/* führe den Syntaxbaum aus */
	if (rc == 0)
	{
		yydebug = 1;
		dispatch(syntreeNodePtr(ast, 0));
	}
	
	/* gib den Syntaxbaum wieder frei */
	syntreeRelease(&syntree);
	
	return rc;
}
