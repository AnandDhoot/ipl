%scanner Scanner.h
%scanner-token-function d_scanner.lex()

%token VOID INT FLOAT RETURN IF ELSE
%token WHILE FOR INT_CONSTANT FLOAT_CONSTANT
%token STRING_LITERAL OR_OP AND_OP EQ_OP DEC_OP
%token NE_OP LE_OP GE_OP INC_OP IDENTIFIER OTHERS
 
%%
translation_unit: 
	function_definition
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"translation_unit\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
		} 
	| translation_unit function_definition
		{ 
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"translation_unit\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
			std::cout << $$ << " -> " << $2 << "\n";
		}
	;
 
function_definition: 
	type_specifier fun_declarator compound_statement
		{ 
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"function_definition\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
			std::cout << $$ << " -> " << $2 << "\n";
			std::cout << $$ << " -> " << $3 << "\n";
		} 
		;
	
 
type_specifier: 
	VOID
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"type_specifier\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"VOID\"]\n";
		}
	| INT 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"type_specifier\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"INT\"]\n";
		}  
	| FLOAT
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"type_specifier\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"FLOAT\"]\n";
		} 
	;
				

fun_declarator: 
	IDENTIFIER '(' parameter_list ')' 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"fun_declarator\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"IDENTIFIER\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"(\"]\n";
			std::cout << $$ << " -> " << $3 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\")\"]\n";
		}
	| IDENTIFIER '(' ')' 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"fun_declarator\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"IDENTIFIER\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"(\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\")\"]\n";
		}
	;

parameter_list: 
	parameter_declaration 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"parameter_list\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
		} 
	| parameter_list ',' parameter_declaration
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"parameter_list\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\",\"]\n";
			std::cout << $$ << " -> " << $3 << "\n";
		}  
	;

parameter_declaration: 
	type_specifier declarator 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"parameter_declaration\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
			std::cout << $$ << " -> " << $2 << "\n";
		}  
	;
				
declarator: 
	IDENTIFIER 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"declarator\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"IDENTIFIER\"]\n";
		}
	| declarator '[' constant_expression ']' 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"declarator\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"[\"]\n";
			std::cout << $$ << " -> " << $3 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"]\"]\n";
		}
	;
				

constant_expression: 
	INT_CONSTANT 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"constant_expression\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"INT_CONSTANT\"]\n";
		}
	| FLOAT_CONSTANT 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"constant_expression\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"FLOAT_CONSTANT\"]\n";
		}
	;

compound_statement: 
	'{' '}' 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"compound_statement\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"{\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"}\"]\n";
		}
	| '{' statement_list '}' 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"compound_statement\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"{\"]\n";
			std::cout << $$ << " -> " << $2 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"}\"]\n";
		}
	| '{' declaration_list statement_list '}' 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"compound_statement\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"{\"]\n";
			std::cout << $$ << " -> " << $2 << "\n";
			std::cout << $$ << " -> " << $3 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"}\"]\n";
		}
	;
	

statement_list: 
	statement
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"statement_list\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
		}
	| statement_list statement  
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"statement_list\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
			std::cout << $$ << " -> " << $2 << "\n";
		}
	;
	

statement: 
	'{' statement_list '}'  //a solution to the local decl problem
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"statement\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"{\"]\n";
			std::cout << $$ << " -> " << $2 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"}\"]\n";
		}
	| selection_statement  
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"statement\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
		} 
	| iteration_statement   
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"statement\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
		}
	| assignment_statement  
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"statement\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
		}
	| RETURN expression ';' 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"statement\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"RETURN\"]\n";
			std::cout << $$ << " -> " << $2 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\";\"]\n";
		}
	;
				

assignment_statement: 
	';'    
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"assignment_statement\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\";\"]\n";
		}           
	|  l_expression '=' expression ';'  
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"assignment_statement\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"=\"]\n";
			std::cout << $$ << " -> " << $3 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\";\"]\n";
		}       
	;


expression: 
	logical_and_expression 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"expression\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
		}
	| expression OR_OP logical_and_expression
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"expression\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"OR_OP\"]\n";
			std::cout << $$ << " -> " << $3 << "\n";
		}
	;


logical_and_expression: 
	equality_expression
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"logical_and_expression\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
		}
	| logical_and_expression AND_OP equality_expression 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"logical_and_expression\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"AND_OP\"]\n";
			std::cout << $$ << " -> " << $3 << "\n";
		}
	;


equality_expression: 
	relational_expression
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"equality_expression\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
		} 
	| equality_expression EQ_OP relational_expression 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"equality_expression\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"EQ_OP\"]\n";
			std::cout << $$ << " -> " << $3 << "\n";
		}  
	| equality_expression NE_OP relational_expression
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"equality_expression\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"NE_OP\"]\n";
			std::cout << $$ << " -> " << $3 << "\n";
		}
	;

relational_expression: 
	additive_expression
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"relational_expression\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
		}
	| relational_expression '<' additive_expression 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"relational_expression\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"<\"]\n";
			std::cout << $$ << " -> " << $3 << "\n";
		}
	| relational_expression '>' additive_expression 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"relational_expression\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\">\"]\n";
			std::cout << $$ << " -> " << $3 << "\n";
		}
	| relational_expression LE_OP additive_expression 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"relational_expression\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"LE_OP\"]\n";
			std::cout << $$ << " -> " << $3 << "\n";
		}
	| relational_expression GE_OP additive_expression 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"relational_expression\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"GE_OP\"]\n";
			std::cout << $$ << " -> " << $3 << "\n";
		}
	;
	

additive_expression: 
	multiplicative_expression
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"additive_expression\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
		}
	| additive_expression '+' multiplicative_expression 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"additive_expression\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"+\"]\n";
			std::cout << $$ << " -> " << $3 << "\n";
		}
	| additive_expression '-' multiplicative_expression 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"additive_expression\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"-\"]\n";
			std::cout << $$ << " -> " << $3 << "\n";
		}
	;
	

multiplicative_expression: 
	unary_expression
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"multiplicative_expression\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
		}
	| multiplicative_expression '*' unary_expression 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"multiplicative_expression\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"*\"]\n";
			std::cout << $$ << " -> " << $3 << "\n";
		}
	| multiplicative_expression '/' unary_expression 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"multiplicative_expression\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"/\"]\n";
			std::cout << $$ << " -> " << $3 << "\n";
		}
	;

unary_expression: 
	postfix_expression 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"unary_expression\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
		}         
	| unary_operator postfix_expression 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"unary_expression\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
			std::cout << $$ << " -> " << $2 << "\n";
		}
	;
	

postfix_expression: 
	primary_expression
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"postfix_expression\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
		}
	| IDENTIFIER '(' ')'
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"postfix_expression\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"IDENTIFIER\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"(\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\")\"]\n";
		}
	| IDENTIFIER '(' expression_list ')' 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"postfix_expression\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"IDENTIFIER\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"(\"]\n";
			std::cout << $$ << " -> " << $3 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\")\"]\n";
		}
	| l_expression INC_OP
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"postfix_expression\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"INC_OP\"]\n";
		}
	;

primary_expression: 
	l_expression
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"primary_expression\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
		}
	| l_expression '=' expression 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"primary_expression\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"=\"]\n";
			std::cout << $$ << " -> " << $3 << "\n";
		} 
	| INT_CONSTANT
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"primary_expression\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"INT_CONSTANT\"]\n";
		} 
	| FLOAT_CONSTANT
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"primary_expression\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"FLOAT_CONSTANT\"]\n";
		} 
	| STRING_LITERAL
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"primary_expression\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"STRING_LITERAL\"]\n";
		} 
	| '(' expression ')'  
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"primary_expression\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"(\"]\n";
			std::cout << $$ << " -> " << $2 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\")\"]\n";
		} 
	;

l_expression: 
	IDENTIFIER
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"l_expression\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"IDENTIFIER\"]\n";
		} 
	| l_expression '[' expression ']'  
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"l_expression\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"[\"]\n";
			std::cout << $$ << " -> " << $3 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"]\"]\n";
		} 
	;

expression_list: 
	expression
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"expression_list\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
		}
	| expression_list ',' expression
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"expression_list\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\",\"]\n";
			std::cout << $$ << " -> " << $3 << "\n";
		}
	;

unary_operator: 
	'-' 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"unary_operator\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"-\"]\n";
		}
	| '!'   
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"unary_operator\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"!\"]\n";
		}
	; 

selection_statement: 
	IF '(' expression ')' statement ELSE statement  
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"selection_statement\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"IF\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"(\"]\n";
			std::cout << $$ << " -> " << $3 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\")\"]\n";
			std::cout << $$ << " -> " << $5 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"ELSE\"]\n";
			std::cout << $$ << " -> " << $7 << "\n";
		}
	;

iteration_statement: 
	WHILE '(' expression ')' statement  
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"iteration_statement\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"WHILE\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"(\"]\n";
			std::cout << $$ << " -> " << $3 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\")\"]\n";
			std::cout << $$ << " -> " << $5 << "\n";
		}
	| FOR '(' expression ';' expression ';' expression ')' statement
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"iteration_statement\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"FOR\"]\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\"(\"]\n";
			std::cout << $$ << " -> " << $3 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\";\"]\n";
			std::cout << $$ << " -> " << $5 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\";\"]\n";
			std::cout << $$ << " -> " << $7 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\")\"]\n";
			std::cout << $$ << " -> " << $9 << "\n";
		}
	;

declaration_list: 
	declaration           
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"declaration_list\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
		}
	| declaration_list declaration
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"declaration_list\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
			std::cout << $$ << " -> " << $2 << "\n";
		}
	;

declaration: 
	type_specifier declarator_list';'
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"declaration\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
			std::cout << $$ << " -> " << $2 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\";\"]\n";
		}
	;

declarator_list: 
	declarator
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"declarator_list\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
		}
	| declarator_list ',' declarator 
		{
			$$ = ++nodeCount;
			std::cout << $$ << "[label=\"declarator_list\"]\n";
			std::cout << $$ << " -> " << $1 << "\n";
			std::cout << $$ << " -> " << ++nodeCount << "\n";
			std::cout << nodeCount << "[label=\",\"]\n";
			std::cout << $$ << " -> " << $3 << "\n";
		}
	;
 