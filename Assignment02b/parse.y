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
			globTab.name = "Global Symbol Table";
			// TODO - Check for scope of variables. 
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
    : STRUCT IDENTIFIER 
    	{
			if(globTab.inScope($2) != NULL)
			{
				cerr << "Redeclaration of symbol " + $2 + " at line " << lineNum << endl; 
				exit(124);
			}
    	}
    '{' declaration_list '}' ';'
		{
			currTab->name = $2;
			currTab->returnType = "struct " + currTab->name; // Basically, the type
			symbol* s = new symbol(currTab->name, "struct", "global", currTab->returnType, 0, 0, currTab);
			globTab.sym[currTab->name] = s;
			parsingFun = true;

			int totSize = 0;
			for(map<string,symbol*>::iterator iterator = currTab->sym.begin(); iterator != currTab->sym.end(); iterator++) 
			{
				totSize += iterator->second->size;
			}
			globTab.sym[currTab->name]->size = totSize;

			Tb *newSymTab = new Tb();
			currTab = newSymTab;
			currTab->parent = &globTab;
			offset = 0;
		}
    ;

function_definition
	: type_specifier fun_declarator 
		{
			offset = -4;
		}
	compound_statement
		{
			symbol* s = new symbol(currTab->name, "fun", "", currTab->returnType, 0, 0, currTab);
			globTab.sym[currTab->name] = s;
			parsingFun = true;

			Tb *newSymTab = new Tb();
			currTab = newSymTab;
			currTab->parent = &globTab;
			offset = 0;
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
    	{
    		type0 = $2;
    		currSize = globTab.inScope($2)->size;
    		if(parsingFun)
    		{
    			currTab->returnType = type0;
    			parsingFun = false;
    		}
    	}
    ;

fun_declarator
	: IDENTIFIER '(' parameter_list ')' 
		{
			if(globTab.inScope($1) != NULL)
			{
				cerr << "Redeclaration of symbol " + $1 + " at line " << lineNum << endl; 
				exit(125);
			}
			currTab->name = $1;
			offset = 0;

			for(map<string,symbol*>::iterator iterator = currTab->sym.begin(); iterator != currTab->sym.end(); iterator++) 
			{
				iterator->second->offset = maxParamOffset - iterator->second->offset;
			}
		}
	| IDENTIFIER '(' ')' 
		{
			if(globTab.inScope($1) != NULL)
			{
				cerr << "Redeclaration of symbol " + $1 + " at line " << lineNum << endl; 
				exit(125);
			}
			currTab->name = $1;
			offset = 0;
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
			offset += currTab->sym[currIdentifier]->size;
			maxParamOffset = offset;
		}
    ;

declarator
	: IDENTIFIER 
		{
			if(currTab->inScope($1) != NULL)
			{
				cerr << "Redeclaration of symbol " + $1 + " at line " << lineNum << endl; 
				exit(124);
			}
			currIdentifier = $1;
			symbol* s = new symbol($1, "var", "local", type0, currSize, offset, NULL);
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
				cerr << "Expected constant integer at line " << lineNum << endl;
				exit(120);
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
			RefAst* temp = $1;
			if(temp->type == "void*" && $3->type[$3->type.size()-1] == '*')
			{
				$$ = new Assign(temp, $3);
			}
			else if(temp->type[temp->type.size()-1] == '*' && $3->type[$3->type.size()-1] == '*')
			{
				if(temp->type == $3->type)
				{
					$$ = new Assign(temp, $3);
				}
				else
				{
					cerr << "Incorrect types at line " << lineNum << endl;
					exit(112);
				}
			}
			else if(temp->type[temp->type.size()-1] == '*' || $3->type[$3->type.size()-1] == '*')
			{
				cerr << "Incorrect types at line " << lineNum << endl;
				exit(112);
			}
			else
			{
				if(temp->type!=$3->type)
					$$ = new Assign(temp, new Op1("TO-"+temp->type,$3));
				else
					$$ = new Assign(temp, $3);
			}
			$$->type = "int";
		}	
    ;

logical_or_expression            // The usual hierarchy that starts here...
	: logical_and_expression
		{
			$$ = $1;
		}	
    | logical_or_expression OR_OP logical_and_expression
		{
			if($1->type.back() == '*' || $3->type.back() == '*')
			{
				cerr << "Incorrect types at line " << lineNum << endl;
				exit(112);
			}

			$$ = new Op2("OR", $1, $3);
			$$->type="int";
		}	
	;

logical_and_expression
    : equality_expression
		{
			$$ = $1;
		}	
    | logical_and_expression AND_OP equality_expression 
		{
			if($1->type.back() == '*' || $3->type.back() == '*')
			{
				cerr << "Incorrect types at line " << lineNum << endl;
				exit(112);
			}
			$$ = new Op2("AND", $1, $3);
			$$->type="int";
		}	
	;

equality_expression
	: relational_expression
		{
			$$ = $1;
		}	 
    | equality_expression EQ_OP relational_expression 
		{
			if($1->type.back() == '*' || $3->type.back() == '*')
			{
				cerr << "Incorrect types at line " << lineNum << endl;
				exit(112);
			}
			if($1->type!=$3->type)
			{
				if($1->type == "int")
					$$ = new Op2("EQ", new Op1("TO-"+$3->type,$1), $3);
				else
					$$ = new Op2("EQ", $1, new Op1("TO-"+$1->type,$3));
			}
			else
				$$ = new Op2("EQ", $1, $3);

			$$->type="int";
		}	
	| equality_expression NE_OP relational_expression
		{
			if($1->type.back() == '*' || $3->type.back() == '*')
			{
				cerr << "Incorrect types at line " << lineNum << endl;
				exit(112);
			}
			if($1->type!=$3->type)
			{
				if($1->type == "int")
					$$ = new Op2("NE", new Op1("TO-"+$3->type,$1), $3);
				else
					$$ = new Op2("NE", $1, new Op1("TO-"+$1->type,$3));
			}
			else
				$$ = new Op2("NE", $1, $3);

			$$->type="int";
		}
	;

relational_expression
	: additive_expression
		{
			$$ = $1;
		}	
    | relational_expression '<' additive_expression 
		{
			if($1->type.back() == '*' || $3->type.back() == '*')
			{
				cerr << "Incorrect types at line " << lineNum << endl;
				exit(112);
			}

			
			if($1->type!=$3->type)
			{
				if($1->type == "int")
					$$ = new Op2("LT-FLOAT", new Op1("TO-"+$3->type,$1), $3);
				else
					$$ = new Op2("LT-FLOAT", $1, new Op1("TO-"+$1->type,$3));
			}
			else if($1->type == "float")
				$$ = new Op2("LT-FLOAT", $1, $3);
			else
				$$ = new Op2("LT-INT", $1, $3);
			$$->type=="int";
		}
	| relational_expression '>' additive_expression 
		{
			if($1->type.back() == '*' || $3->type.back() == '*')
			{
				cerr << "Incorrect types at line " << lineNum << endl;
				exit(112);
			}
			
			if($1->type!=$3->type)
			{
				if($1->type == "int")
					$$ = new Op2("GT-FLOAT", new Op1("TO-"+$3->type,$1), $3);
				else
					$$ = new Op2("GT-FLOAT", $1, new Op1("TO-"+$1->type,$3));
			}
			else if($1->type == "float")
				$$ = new Op2("GT-FLOAT", $1, $3);
			else
				$$ = new Op2("GT-INT", $1, $3);
			$$->type=="int";
		}
	| relational_expression LE_OP additive_expression 
		{
			if($1->type.back() == '*' || $3->type.back() == '*')
			{
				cerr << "Incorrect types at line " << lineNum << endl;
				exit(112);
			}
			
			if($1->type!=$3->type)
			{
				if($1->type == "int")
					$$ = new Op2("LE-FLOAT", new Op1("TO-"+$3->type,$1), $3);
				else
					$$ = new Op2("LE-FLOAT", $1, new Op1("TO-"+$1->type,$3));
			}
			else if($1->type == "float")
				$$ = new Op2("LE-FLOAT", $1, $3);
			else
				$$ = new Op2("LE-INT", $1, $3);
			$$->type=="int";
		}
    | relational_expression GE_OP additive_expression 
		{
			if($1->type.back() == '*' || $3->type.back() == '*')
			{
				cerr << "Incorrect types at line " << lineNum << endl;
				exit(112);
			}
			
			if($1->type!=$3->type)
			{
				if($1->type == "int")
					$$ = new Op2("GE-FLOAT", new Op1("TO-"+$3->type,$1), $3);
				else
					$$ = new Op2("GE-FLOAT", $1, new Op1("TO-"+$1->type,$3));
			}
			else if($1->type == "float")
				$$ = new Op2("GE-FLOAT", $1, $3);
			else
				$$ = new Op2("GE-INT", $1, $3);

			$$->type=="int";
		}
	;

additive_expression 
	: multiplicative_expression
		{
			$$ = $1;
		}	
	| additive_expression '+' multiplicative_expression
		{
			if($1->type.back() == '*' || $3->type.back() == '*')
			{
				cerr << "Incorrect types at line " << lineNum << endl;
				exit(112);
			}
			
			if($1->type!=$3->type)
			{
				if($1->type == "int")
					$$ = new Op2("Plus-FLOAT", new Op1("TO-"+$3->type,$1), $3);
				else
					$$ = new Op2("Plus-FLOAT", $1, new Op1("TO-"+$1->type,$3));
				$$->type=="float";
			}
			else if($1->type == "float")
			{
				$$ = new Op2("Plus-FLOAT", $1, $3);
				$$->type=="float";
			}
			else
			{
				$$ = new Op2("Plus-INT", $1, $3);
				$$->type=="int";
			}

		} 
	| additive_expression '-' multiplicative_expression 
		{
			if($1->type.back() == '*' || $3->type.back() == '*')
			{
				cerr << "Incorrect types at line " << lineNum << endl;
				exit(112);
			}
			
			if($1->type!=$3->type)
			{
				if($1->type == "int")
					$$ = new Op2("Minus-FLOAT", new Op1("TO-"+$3->type,$1), $3);
				else
					$$ = new Op2("Minus-FLOAT", $1, new Op1("TO-"+$1->type,$3));
				$$->type=="float";
			}
			else if($1->type == "float")
			{
				$$ = new Op2("Minus-FLOAT", $1, $3);
				$$->type=="float";
			}
			else
			{
				$$ = new Op2("Minus-INT", $1, $3);
				$$->type=="int";
			}

		}
	;

multiplicative_expression
	: unary_expression
		{
			$$ = $1;
		}	
	| multiplicative_expression '*' unary_expression
		{
			if($1->type.back() == '*' || $3->type.back() == '*')
			{
				cerr << "Incorrect types at line " << lineNum << endl;
				exit(112);
			}

			if($1->type!=$3->type)
			{
				if($1->type == "int")
					$$ = new Op2("Multiply-FLOAT", new Op1("TO-"+$3->type,$1), $3);
				else
					$$ = new Op2("Multiply-FLOAT", $1, new Op1("TO-"+$1->type,$3));
				$$->type=="float";
			}
			else if($1->type == "float")
			{
				$$ = new Op2("Multiply-FLOAT", $1, $3);
				$$->type=="float";
			}
			else
			{
				$$ = new Op2("Multiply-INT", $1, $3);
				$$->type=="int";
			}
		} 
	| multiplicative_expression '/' unary_expression 
		{
			if($1->type.back() == '*' || $3->type.back() == '*')
			{
				cerr << "Incorrect types at line " << lineNum << endl;
				exit(112);
			}

			
			if($1->type!=$3->type)
			{
				if($1->type == "int")
					$$ = new Op2("Divide-FLOAT", new Op1("TO-"+$3->type,$1), $3);
				else
					$$ = new Op2("Divide-FLOAT", $1, new Op1("TO-"+$1->type,$3));
				$$->type=="float";
			}
			else if($1->type == "float")
			{
				$$ = new Op2("Divide-FLOAT", $1, $3);
				$$->type=="float";
			}
			else
			{
				$$ = new Op2("Divide-INT", $1, $3);
				$$->type=="int";
			}
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
			$$->type=$2->type;
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
    		$$->type=globTab.sym[$1]->type;
    	}		
	| IDENTIFIER '(' expression_list ')' 
    	{
    		$$ = new Funcall(new Identifier($1), $3);
    		$$->type=globTab.sym[$1]->type;
    	}
	| l_expression INC_OP
		{
			$$ = new Op1("PlusPlus", $1);
			$$->type=$1->type;
		}		
	;

l_expression
    : IDENTIFIER
	    {
	    	$$ = new Identifier($1);
	    	if(currTab->inScope($1)==NULL){
	    		cerr<<"Scope Error"<<lineNum;
	    		exit(3);
	    	}
	    	$$->type=currTab->inScope($1)->starType();
	    	$$->base_type=currTab->inScope($1)->type;
	    }
    | l_expression '[' expression ']'
    	{
    		RefAst* temp=  $1;
    		$$ = new ArrayRef($1,$3);

    		if(temp->type[temp->type.size()-1]=='*'){
    		$$->type=temp->type.substr(0,temp->type.size()-1);
    		$$->base_type=temp->base_type;
    	}
    		else{
    			cerr<<"Arbit Array acess error\n";
    			exit(3);
    		}

    	}
    | '*' l_expression
		{
			RefAst* temp=  $2;
			$$ = new Deref($2);
    		if(temp->base_type[temp->base_type.size()-1]=='*'){
    		$$->type=temp->base_type.substr(0,temp->base_type.size()-1);
    		$$->base_type=temp->base_type.substr(0,temp->base_type.size()-1);
    	}
    		else{
    			cerr<<"Arbit Pointer Deref error\n";
    			exit(3);
    		}
		}
    | l_expression '.' IDENTIFIER
		{	RefAst* temp=$1;
			string id=$3;
			$$ = new Member($1, new Identifier(id));
			symbol* t = globTab.inScope(temp->type);
			cerr<<temp->type;
			if(t==NULL){
				cerr<<"Member not defined for "<<temp->type<<lineNum;
				exit(2);
			}
			symbol* mem=t->symtab->inScope(id);
			if(mem==NULL){
				cerr<<" No such Member"<<id<<lineNum;
				exit(2);
			}
			$$->type= mem->starType() ; 
			$$->base_type=mem->type;

		}
    | l_expression PTR_OP IDENTIFIER
		{
			RefAst* temp=$1;
			$$ = new Arrow($1, new Identifier($3));
			if(temp->base_type[temp->base_type.size()-1]=='*'){
			symbol* t = globTab.inScope(temp->type.substr(0,temp->type.size()-1));
			if(t==NULL){
				cerr<<"PTR not defined for "<<temp->type<<lineNum;
				exit(2);
			}
			symbol* mem=t->symtab->inScope($3);
			if(mem==NULL){
				cerr<<" No such Member"<<$3<<lineNum;
				exit(2);
			}
			$$->type= mem->starType() ; 
			$$->base_type=mem->type;}
			 else{
    			cerr<<"Arbit Pointer OP error\n";
    			exit(3);
    		}

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
		{
			for(int i = 0; i<currTab->sym[currIdentifier]->dimensions.size(); i++)
				currTab->sym[currIdentifier]->size *= currTab->sym[currIdentifier]->dimensions[i];
			offset -= currTab->sym[currIdentifier]->size;
		}
	| declarator_list ',' declarator 
		{
			for(int i = 0; i<currTab->sym[currIdentifier]->dimensions.size(); i++)
				currTab->sym[currIdentifier]->size *= currTab->sym[currIdentifier]->dimensions[i];
			offset -= currTab->sym[currIdentifier]->size;
		}
 	;


