
%token VOID INT FLOAT RETURN IF ELSE
%token WHILE FOR INT_CONSTANT FLOAT_CONSTANT
%token STRING_LITERAL OR_OP AND_OP EQ_OP DEC_OP PTR_OP
%token NE_OP LE_OP GE_OP INC_OP IDENTIFIER OTHERS STRUCT

%polymorphic STRING : std::string;  EXPAST : ExpAst*; STMTAST : StmtAst*; STMTLIST : list<StmtAst*>*; EXPLIST : list<ExpAst*>*; INTCONST : IntConst*; FLOATCONST : FloatConst*; STRINGCONST : StringConst*; IDENTIFIER : Identifier*; ArrayRef : ArrayRef*; Op2 : Op2*; Op1 : Op1*; FUNCALL : Funcall*; Seq: Seq*; Return : Return*; Ass : Ass*; If : If*; Empty : Empty*; While : While*; For : For*; INT : int; FLOAT : float;

%type<STRING> unary_operator IDENTIFIER STRING_LITERAL
%type<INT> INT_CONSTANT
%type<FLOAT> FLOAT_CONSTANT

%type<EXPAST> expression logical_and_expression equality_expression relational_expression additive_expression multiplicative_expression unary_expression postfix_expression primary_expression l_expression

%type<STMTAST> compound_statement statement assignment_statement selection_statement iteration_statement      

%type<EXPLIST> expression_list

%type<STMTLIST> statement_list

%%

translation_unit 
        :  struct_specifier
 	| function_definition 
 	| translation_unit function_definition 
        | translation_unit struct_specifier
        ;

struct_specifier 
        : STRUCT IDENTIFIER '{' declaration_list '}' ';'
        ;

function_definition
	: type_specifier fun_declarator compound_statement 
	;

type_specifier
        : base_type
        | type_specifier '*'
        ;

base_type 
        : VOID 	
        | INT   
	| FLOAT 
        | STRUCT IDENTIFIER 
        ;

fun_declarator
	: IDENTIFIER '(' parameter_list ')' 
	| IDENTIFIER '(' ')' 
	;

parameter_list
	: parameter_declaration 
	| parameter_list ',' parameter_declaration 
	;

parameter_declaration
	: type_specifier declarator 
        ;

declarator
	: IDENTIFIER 
	| declarator '[' constant_expression ']' 
        ;

constant_expression 
        : INT_CONSTANT 
        | FLOAT_CONSTANT 
        ;

compound_statement
	: '{' '}' 
	| '{' statement_list '}' 
        | '{' declaration_list statement_list '}' 
	;

statement_list
	: statement		
        | statement_list statement	
	;

statement
        : '{' statement_list '}'  //a solution to the local decl problem
        | selection_statement 	
        | iteration_statement 	
	| assignment_statement	
        | RETURN expression ';'	
        ;

assignment_statement
	: ';' 								
	|  l_expression '=' expression ';'	
	;

expression
	: logical_and_expression
        | expression OR_OP logical_and_expression
	;
logical_and_expression
        : equality_expression
        | logical_and_expression AND_OP equality_expression 
	;

equality_expression
	: relational_expression 
        | equality_expression EQ_OP relational_expression 	
	| equality_expression NE_OP relational_expression
	;
relational_expression
	: additive_expression
        | relational_expression '<' additive_expression 
	| relational_expression '>' additive_expression 
	| relational_expression LE_OP additive_expression 
        | relational_expression GE_OP additive_expression 
	;

additive_expression 
	: multiplicative_expression
	| additive_expression '+' multiplicative_expression 
	| additive_expression '-' multiplicative_expression 
	;

multiplicative_expression
	: unary_expression
	| multiplicative_expression '*' unary_expression 
	| multiplicative_expression '/' unary_expression 
	;
unary_expression
	: postfix_expression  				
	| unary_operator postfix_expression 
	;

postfix_expression
	: primary_expression  				
        | IDENTIFIER '(' ')' 				
	| IDENTIFIER '(' expression_list ')' 
	| l_expression INC_OP 				
	;

primary_expression
	: l_expression
        | l_expression '=' expression   
        | INT_CONSTANT 
	| FLOAT_CONSTANT
        | STRING_LITERAL
	| '(' expression ')' 	
	;

l_expression
        : IDENTIFIER
        | l_expression '[' expression ']' 	
        | '*' l_expression
        | '&' l_expression // & and * are similar
        | l_expression '.' IDENTIFIER
        | l_expression PTR_OP IDENTIFIER	
        ;

expression_list
        : expression
        | expression_list ',' expression
	;

unary_operator
        : '-'	
	| '!' 	
	;

selection_statement
        : IF '(' expression ')' statement ELSE statement 
	;

iteration_statement
	: WHILE '(' expression ')' statement 	
	| FOR '(' expression ';' expression ';' expression ')' statement  //modified this production
        ;

declaration_list
        : declaration  					
        | declaration_list declaration
	;

declaration
	: type_specifier declarator_list';' 
	;

declarator_list
	: declarator
	| declarator_list ',' declarator 
 	;


