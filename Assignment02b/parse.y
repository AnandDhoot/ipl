%token VOID INT FLOAT RETURN IF ELSE
%token WHILE FOR INT_CONSTANT FLOAT_CONSTANT
%token STRING_LITERAL OR_OP AND_OP EQ_OP PTR_OP
%token NE_OP LE_OP GE_OP INC_OP IDENTIFIER STRUCT

%polymorphic STRING : std::string; REFAST : RefAst*; EXPAST : ExpAst*; STMTAST : StmtAst*; STMTLIST : list<StmtAst*>*; EXPLIST : list<ExpAst*>*; INTCONST : IntConst*; FLOATCONST : FloatConst*; STRINGCONST : StringConst*; IDENTIFIER : Identifier*; ArrayRef : ArrayRef*; Op2 : Op2*; Op1 : Op1*; FUNCALL : Funcall*; Seq: Seq*; Return : Return*; Ass : Ass*; If : If*; Empty : Empty*; While : While*; For : For*; INT : int; FLOAT : float;

%type<STRING> unary_operator IDENTIFIER STRING_LITERAL
%type<INT> INT_CONSTANT
%type<FLOAT> FLOAT_CONSTANT
%type<STMTLIST> statement_list
%type<EXPLIST> expression_list
%type<STMTAST> compound_statement statement assignment_statement selection_statement iteration_statement 
%type<EXPAST> expression logical_and_expression logical_or_expression equality_expression relational_expression additive_expression multiplicative_expression unary_expression postfix_expression primary_expression 
%type<REFAST> l_expression

%%

complete_code
	: translation_unit
		{
			// TODO - Add offsets. 
			globTab.recPrint();
		}
	;

translation_unit 
    : struct_specifier
 	| function_definition 
 	| translation_unit function_definition 
    | translation_unit struct_specifier
    ;

struct_specifier 
    : STRUCT IDENTIFIER '{' declaration_list '}' ';'
    ;

function_definition
	: type_specifier fun_declarator compound_statement 
		{
			globTab.name = "Global Symbol Table";
			
			symbol* s = new symbol(currTab->name, "fun", "", currTab->returnType, 0, 0, currTab);
			globTab.sym[currTab->name] = s;
			currTab->parent = &globTab;
			parsingFun = true;

			Tb *newSymTab = new Tb();
			currTab = newSymTab;
		}
	;

type_specifier                   // This is the information 
    : VOID 	                 // that gets associated with each identifier
    	{
    		type0 = "void";
    		currSize = 0;
    		if(parsingFun)
    		{
    			currTab->returnType = type0;
    			parsingFun = false;
    		}
		}
    | INT   
    	{
    		type0 = "int";
    		currSize = 4;
    		if(parsingFun)
    		{
    			currTab->returnType = type0;
    			parsingFun = false;
    		}
    	}
	| FLOAT 
		{	
			type0 = "float";
			currSize = 8;
    		if(parsingFun)
    		{
    			currTab->returnType = type0;
    			parsingFun = false;
    		}
		}
    | STRUCT IDENTIFIER 
    ;

fun_declarator
	: IDENTIFIER '(' parameter_list ')' 
		{
			currTab->name = $1;
		}
	| IDENTIFIER '(' ')' 
		{
			currTab->name = $1;
		}
    | '*' fun_declarator 
    	{
   			currTab->returnType += "*";
    	}
	;


parameter_list
	: parameter_declaration 
	| parameter_list ',' parameter_declaration 
	;

parameter_declaration
	: type_specifier declarator 
		{
			for(int i = 0; i<currTab->sym[currIdentifier]->dimensions.size(); i++)
				currTab->sym[currIdentifier]->size *= currTab->sym[currIdentifier]->dimensions[i];
			currTab->sym[currIdentifier]->scope = "param";
		}
    ;

declarator
	: IDENTIFIER 
		{

			currIdentifier = $1;
			symbol* s = new symbol($1, "var", "local", type0, currSize, 0, NULL);
			currTab->sym[$1] = s;
		}
	| declarator '[' primary_expression']'
		{
			if(isIntConst)
			{
				currTab->sym[currIdentifier]->dimensions.push_back(value);
				isIntConst = false;
			}
			else
			{
				// Check if primary expression is INT
				cout << "ERORR AND ABORT" << endl;
			}
				
		}
    | '*' declarator 
    	{
    		currSize = 4;

			currTab->sym[currIdentifier]->type += "*";
			currTab->sym[currIdentifier]->size = 4;
    	}
    ;

primary_expression 
    : l_expression
		{
			$$ = $1;
		}	
    | INT_CONSTANT 
	    {
	    	$$ = new IntConst($1);
	    	value = $1;
	    	isIntConst = true;
	    }
    | FLOAT_CONSTANT
	    {
	    	$$ = new FloatConst($1);
	    }
    | STRING_LITERAL
	    {
	    	$$ = new StringConst($1);
	    }
    | '(' expression ')' 
		{
			$$ = $2;
		}
    ;

compound_statement
	: '{' '}'
		{
			$$ = new Seq(new list<StmtAst*>());
			($$)->print(0);std::cout<<std::endl;
		}
	| '{' statement_list '}'
		{
			$$ = new Seq($2);
			($$)->print(0);std::cout<<std::endl;
		}
 	| '{' declaration_list statement_list '}'
		{
			$$ = new Seq($3);
			($$)->print(0);std::cout<<std::endl;
		}
	;

statement_list
	: statement		
    	{
    		$$ = new list<StmtAst *>();
    		$$->push_back($1);
    	}
    | statement_list statement	
    	{
    		((list<StmtAst *>*)$1)->push_back($2);
    		$$ = $1;
    	}
	;

statement
    : '{' statement_list '}' 
    	{
    		$$ = new Seq($2);
    	}
    | selection_statement
		{
			$$ = $1;
		}	
    | iteration_statement 
		{
			$$ = $1;
		}		
	| assignment_statement	
		{
			$$ = $1;
		}	
    | RETURN expression ';'	
    	{
    		$$ = new Return($2);
    		$$ -> print(0);
    	}
    ;

assignment_statement
	: ';' 	
		{
			$$ = new Empty();
		}			
	|  expression ';'  
		{
			$$ = new Ass($1);
		}	
	;

expression 
    :  logical_or_expression
		{
			$$ = $1;
		}	
    |  l_expression '=' expression 	
		{
			$$ = new Assign($1, $3);
		}	
    ;

logical_or_expression            // The usual hierarchy that starts here...
	: logical_and_expression
		{
			$$ = $1;
		}	
    | logical_or_expression OR_OP logical_and_expression
		{
			$$ = new Op2("OR", $1, $3);
		}	
	;

logical_and_expression
    : equality_expression
		{
			$$ = $1;
		}	
    | logical_and_expression AND_OP equality_expression 
		{
			$$ = new Op2("AND", $1, $3);
		}	
	;

equality_expression
	: relational_expression
		{
			$$ = $1;
		}	 
    | equality_expression EQ_OP relational_expression 
		{
			$$ = new Op2("EQ", $1, $3);
		}	
	| equality_expression NE_OP relational_expression
		{
			$$ = new Op2("NE", $1, $3);
		}
	;

relational_expression
	: additive_expression
		{
			$$ = $1;
		}	
    | relational_expression '<' additive_expression 
		{
			$$ = new Op2("LT", $1, $3);
		}
	| relational_expression '>' additive_expression 
		{
			$$ = new Op2("GT", $1, $3);
		}
	| relational_expression LE_OP additive_expression 
		{
			$$ = new Op2("LE", $1, $3);
		}
    | relational_expression GE_OP additive_expression 
		{
			$$ = new Op2("GE", $1, $3);
		}
	;

additive_expression 
	: multiplicative_expression
		{
			$$ = $1;
		}	
	| additive_expression '+' multiplicative_expression
		{
			$$ = new Op2("Plus", $1, $3);
		} 
	| additive_expression '-' multiplicative_expression 
		{
			$$ = new Op2("Minus", $1, $3);
		}
	;

multiplicative_expression
	: unary_expression
		{
			$$ = $1;
		}	
	| multiplicative_expression '*' unary_expression
		{
			$$ = new Op2("Multiply", $1, $3);
		} 
	| multiplicative_expression '/' unary_expression 
		{
			$$ = new Op2("Divide", $1, $3);
		}
	;

unary_expression
	: postfix_expression  
		{
			$$ = $1;
		}					
	| unary_operator postfix_expression 
		{
			$$ = new Op1($1, $2);
		}			
	;

postfix_expression
	: primary_expression 
		{
			$$ = $1;
		}	 				
    | IDENTIFIER '(' ')' 
    	{
    		$$ = new Funcall(new Identifier($1), new list<ExpAst *>());
    	}		
	| IDENTIFIER '(' expression_list ')' 
    	{
    		$$ = new Funcall(new Identifier($1), $3);
    	}
	| l_expression INC_OP
		{
			$$ = new Op1("PlusPlus", $1);
		}		
	;

l_expression
    : IDENTIFIER
	    {
	    	$$ = new Identifier($1);
	    }
    | l_expression '[' expression ']'
    	{
    		$$ = new ArrayRef($1,$3);
    	}
    | '*' l_expression
		{
			$$ = new Deref($2);
		}
    | l_expression '.' IDENTIFIER
		{
			$$ = new Member($1, new Identifier($3));
		}
    | l_expression PTR_OP IDENTIFIER
		{
			$$ = new Arrow($1, new Identifier($3));
		}
    | '(' l_expression ')'	
    	{
    		$$ = $2;
    	}
    ;

expression_list
    : expression
    	{
    		$$ = new list<ExpAst *>();
    		$$->push_back($1);
    	}
    | expression_list ',' expression
    	{
    		((list<ExpAst *>*)$1)->push_back($3);
    		$$ = $1;
    	}
	;

unary_operator
    : '-'	
    	{
    		$$ = "uminus";
    	}
	| '!'
    	{
    		$$ = "NOT";
    	} 	
    | '&'
    	{
    		$$ = "AddressOf";
    	} 	
    | '*'
    	{
    		$$ = "Deref";
    	} 	
	;

selection_statement
    : IF '(' expression ')' statement ELSE statement 
    	{
    		$$ = new If($3, $5, $7);
    	}
	;

iteration_statement
	: WHILE '(' expression ')' statement 
		{
			$$ = new While($3, $5);
		}	
	| FOR '(' expression ';' expression ';' expression ')' statement  //modified this production
		{
			$$ = new For($3, $5, $7, $9);
		}
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


