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

%%

complete_code
	:{
		fout<<".text\n .globl main\n";
	} 
	translation_unit
		{
			globTab.name = "Global Symbol Table";
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
		{
			if(globTab.inScope($2) != NULL)
			{
				cerr << "Redeclaration of symbol " + $2 + " at line " << lineNum << endl; 
				exit(124);
			}
			currTab->name = $2;
			currTab->returnType = "struct " + currTab->name; // Basically, the type
			symbol* s = new symbol(currTab->name, "struct", "global", currTab->returnType, 0, 0, currTab);
			
			globTab.sym[currTab->name] = s;
			parsingFun = true;

			int totSize = 0;
			for(map<string,symbol*>::iterator iterator = currTab->sym.begin(); iterator != currTab->sym.end(); iterator++) 
			{
				totSize += iterator->second->size;
				iterator->second->offset += 4;
				iterator->second->offset *= -1;
			}
			globTab.sym[currTab->name]->size = totSize;

			Tb *newSymTab = new Tb();
			currTab = newSymTab;
			currTab->parent = &globTab;
			offset = -4;
		}
    ;

function_definition
	: type_specifier fun_declarator 
		{
			offset = -4;
		}
	compound_statement
		{
			// symbol* s = new symbol(currTab->name, "fun", "", currTab->returnType, 0, 0, currTab);
			// globTab.sym[currTab->name] = s;
			parsingFun = true;
			int localsWidth=0;

			for(map<string,symbol*>::iterator iterator = currTab->sym.begin(); iterator != currTab->sym.end(); iterator++) 
			{
				if(iterator->second->scope == "local"){
					iterator->second->offset = iterator->second->offset - iterator->second->size+4;
					localsWidth+=iterator->second->size;
				}
				else
					iterator->second->offset = iterator->second->offset - iterator->second->size + 8;
			}

			fout<<currTab->name<<":\n";
			fout<<"addi $sp,$sp,-4\n";
			fout<<"sw $ra,0($sp)\n";
			fout<<"addi $sp,$sp,-4\n";
			fout<<"sw $fp,0($sp)\n";
			fout<<"add $fp,$sp,$0\n";
			//make space for locals
			fout<<"addi $sp,$sp,"<<-localsWidth<<endl;
			//store shit
			Tb *newSymTab = new Tb();
			currTab = newSymTab;
			currTab->parent = &globTab;
			offset = -4;

			($4)->print(0);std::cout<<std::endl;
			($4)->genCode();
			//restore shit
			fout<<"addi $sp,$fp,4\n";
			fout<<"lw $fp,0($fp)\n";
			fout<<"lw $ra,0($sp)\n";
			fout<<"addi $sp,$sp,-4\n";
			fout<<"jr $ra";
		}
	;

type_specifier                   // This is the information 
    : VOID 	                 // that gets associated with each identifier
    	{
    		type0 = "void";
    		type1 = "void";
    		currSize = 0;
    		if(parsingFun)
    		{
    			currTab->returnType = type0;

    			// cout << endl << "Here " << currTab->name << endl << endl;

    			parsingFun = false;
    		}
    		isStruct = false;
		}
    | INT   
    	{
    		type0 = "int";
    		type1 = "int";
    		currSize = 4;
    		if(parsingFun)
    		{
    			currTab->returnType = type0;
    			parsingFun = false;
    		}
    		isStruct = false;
    	}
	| FLOAT 
		{	
			type0 = "float";
			type1 = "float";
			currSize = 4;
    		if(parsingFun)
    		{
    			currTab->returnType = type0;
    			parsingFun = false;
    		}
    		isStruct = false;
		}
    | STRUCT IDENTIFIER 
    	{
    		type0 = $2;
    		type1 = $2;
    		// if(globTab.inScope($2)==NULL){
    		// 	cerr<<"Struct used without declaration at "<<lineNum<<endl;
    		// 	exit(0);
    		// }

    		if(globTab.inScope($2)==NULL)
    			currSize = 0;
    		else
    			currSize = globTab.inScope($2)->size;
    		if(parsingFun)
    		{
    			currTab->returnType = type0;
    			parsingFun = false;
    		}

    		isStruct = true;
    		structName = $2;
    	}
    ;

fun_declarator
	: IDENTIFIER '(' parameter_list ')' 
		{

			if($1 != currTab->name && globTab.inScope($1) != NULL)
			{
				cerr << "Redeclaration of symbol " + $1 + " at line " << lineNum << endl; 
				exit(125);
			}

			currTab->name = $1;
				symbol* s = new symbol(currTab->name, "fun", "", currTab->returnType, 0, 0, currTab);
				globTab.sym[currTab->name] = s;
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
				symbol* s = new symbol(currTab->name, "fun", "", currTab->returnType, 0, 0, currTab);
				globTab.sym[currTab->name] = s;
			offset = 0;
		}
    | '*' fun_declarator 
    	{
   			currTab->returnType += "*";
   			globTab.sym[currTab->name]->type = currTab->returnType;
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
			type0+="*";
			currTab->sym[currIdentifier]->size = 4;
    	}
    ;

primary_expression 
    :INT_CONSTANT 
	    {
	    	$$ = new IntConst($1);
	    	value = $1;
	    	isIntConst = true;
	    	$$->isLval=0;
	    	$$->isConst=1;
	    }
	| IDENTIFIER
	    {
	    	$$ = new Identifier($1);
	    	if(currTab->inScope($1)==NULL){
	    		cerr<<"Scope Error at "<<lineNum << endl;
	    		exit(3);
	    	}
	    	$$->type=currTab->inScope($1)->starType();
	    	$$->dim=currTab->inScope($1)->dimensions;
	    	$$->base_type=currTab->inScope($1)->type;
	    	$$->isConst=0;
	    	$$->isLval=1;
	    }
    | FLOAT_CONSTANT
	    {
	    	$$ = new FloatConst($1);
	    	isIntConst = false;
	    	$$->isLval=0;
	    	$$->isConst=1;
	    }
    | STRING_LITERAL
	    {
	    	$$ = new StringConst($1);
	    	isIntConst = false;
	    	$$->isLval=0;
	    	$$->isConst=1;
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
		}
	| '{' statement_list '}'
		{
			$$ = new Seq($2);
			//($$)->print(0);std::cout<<std::endl;
		}
 	| '{' declaration_list statement_list '}'
		{
			$$ = new Seq($3);
			//($$)->print(0);std::cout<<std::endl;
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
    		string retType = currTab->returnType;

			// Code from expression assignment
			// (With some modifications)
			/********************************/
			if(retType == "void*" && $2->type[$2->type.size()-1] == '*')
			{
				$$ = new Return($2);
			}
			else if($2->type == "void*" && retType[retType.size()-1] == '*')
 			{
 				$$ = new Return($2);
 			}
			else if(retType[retType.size()-1] == '*' && $2->type[$2->type.size()-1] == '*')
			{
				if(retType == $2->type)
				{
					$$ = new Return($2);
				}
				else
				{
					cerr << "Incorrect return-type at " << lineNum << endl;
					exit(12);
				}
			}
			else if(retType[retType.size()-1] == '*' || $2->type[$2->type.size()-1] == '*')
			{
				cerr << "Incorrect return-type at " << lineNum << endl;
				exit(12);
			}
			else
			{
				if(retType == "void" || $2->type == "void")
				{
					cerr << "Void types at line " << lineNum << endl;
					exit(112);
				}
				if(retType!=$2->type)
				{
					// Case to handle assingments of structs. 
					// currTab->inScope() returns NULL for non-structs
					if(currTab->inScope(retType)==NULL && currTab->inScope($2->type)==NULL)
						$$ = new Return(new Op1("TO-"+retType,$2));
					else
					{
						cerr << "Incorrect return-type at " << lineNum << endl;
						exit(12);
					}
				}
				else
					$$ = new Return($2);
			}
			/********************************/

    		//$$ -> print(0);
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
    |  unary_expression '=' expression 	
		{
			// TODO - Handle array assignments
			// TODO - Copy code for ^ in return, function parameters

			ExpAst* temp = $1;
			if(!temp->isLval) 
			{
				cerr << "Exp has no Lvalue at  " << lineNum << endl;
				exit(112);
			}
			if(temp->type!=temp->base_type) //to Combat assignmnets to whole arrays
			{
				cerr << "Incorrect types at line " << lineNum << endl;
				exit(112);
			}
			if(temp->type == "void*" && $3->type[$3->type.size()-1] == '*')
			{
				$$ = new Assign(temp, $3);
			}
			else if($3->type == "void*" && temp->type[temp->type.size()-1] == '*')
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
				if(temp->type == "void" || $3->type == "void")
				{
					cerr << "Void types at line " << lineNum << endl;
					exit(112);
				}
				if(temp->type!=$3->type)
				{
					// Case to handle assingments of structs. 
					if(currTab->inScope(temp->type)==NULL && currTab->inScope($3->type)==NULL)
						$$ = new Assign(temp, new Op1("TO-"+temp->type,$3));
					else
					{
						cerr << "Incorrect types at line " << lineNum << endl;
						exit(112);
					}
				}
				else
					$$ = new Assign(temp, $3);
			}
			$$->type = "int";
			$$->isConst=1;
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
			$$->isConst=1;
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
			$$->isConst=1;
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
			$$->isConst=1;
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
			$$->isConst=1;
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
			$$->type="int";
			$$->isConst=1;
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
			$$->type="int";
			$$->isConst=1;
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
			$$->type="int";
			$$->isConst=1;
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

			$$->type="int";
			$$->isConst=1;
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
				$$->type="float";
			}
			else if($1->type == "float")
			{
				$$ = new Op2("Plus-FLOAT", $1, $3);
				$$->type="float";
			}
			else
			{
				$$ = new Op2("Plus-INT", $1, $3);
				$$->type="int";

			}
			$$->isConst=1;

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
				$$->type="float";
			}
			else if($1->type == "float")
			{
				$$ = new Op2("Minus-FLOAT", $1, $3);
				$$->type="float";
			}
			else
			{
				$$ = new Op2("Minus-INT", $1, $3);
				$$->type="int";
			}
			$$->isConst=1;

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
				$$->type="float";
			}
			else if($1->type == "float")
			{
				$$ = new Op2("Multiply-FLOAT", $1, $3);
				$$->type="float";
			}
			else
			{
				$$ = new Op2("Multiply-INT", $1, $3);
				$$->type="int";
			}
			$$->isConst=1;
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
				$$->type="float";
			}
			else if($1->type == "float")
			{
				$$ = new Op2("Divide-FLOAT", $1, $3);
				$$->type="float";
			}
			else
			{
				$$ = new Op2("Divide-INT", $1, $3);
				$$->type="int";
			}
			$$->isConst=1;
		}
	;

unary_expression
	: postfix_expression  
		{
			$$ = $1;
		}					
	| unary_operator unary_expression 
		{
			$$ = new Op1($1, $2);
			ExpAst* temp=$2;
			if($1=="AddressOf"){
				if($2->isLval==0){
					cerr<<"AddressOf applied to non l_value exp at "<<lineNum<<endl;
					exit(0);
				}

				$$->type=temp->type+"*";
				$$->base_type=temp->base_type+"*";
				$$->dim=temp->dim;
				$$->isLval=0;
			}
			else if($1=="Deref"){
			ExpAst* temp=  $2;
			$$ = new Deref($2);
    		if(temp->base_type[temp->base_type.size()-1]=='*'){
    		$$->type=temp->type.substr(0,temp->type.size()-1);
    		$$->base_type=temp->base_type.substr(0,temp->base_type.size()-1);
    		$$->dim=temp->dim;
    		if($$->type=="void"){
    			cerr<<"Void Pointer Deref error " << lineNum << endl;
    			exit(3);

    		}

    	}
    		else{
    			cerr<<"Arbit Pointer Deref error " << lineNum << endl;
    			exit(3);
    		}
    		$$->isLval=1;
    		$$->isConst=0;
			}
			else if($1=="NOT"){
				if($2->type!="int"&&$2->type!="float"){
					cerr<<"Not operat not comaptible with type at "<<lineNum<<endl;
					exit(3);
				}
				$$->type="int";
				$$->isConst=1;
				$$->isLval=0;

			}
			else if($1=="uminus"){
				if($2->type!="int"&&$2->type!="float"){
					cerr<<"Minus operat not comaptible with type at "<<lineNum<<endl;
					exit(3);
				}
				$$->type=$2->type;
				$$->isLval=0;
				$$->isConst=1;
			}
		}			
	;

postfix_expression
	: primary_expression 
		{
			$$ = $1;
		}	 				
    | IDENTIFIER '(' ')' 	
    	{
    		if(globTab.inScope($1) == NULL)
    		{
    			cerr << "Function definition not found. Error at line " << lineNum << endl;
    			exit(1243);
    		}

    		vector<symbol*> symArr;
    		symArr = ((globTab.inScope($1))->symtab)->sort_byoffset();
    		if(symArr.size() > 0 && symArr[0]->scope == "param")
    		{
    			cerr << "No arguments supplied. Error at line " << lineNum << endl;
    			exit(1242);
    		}

    		$$ = new Funcall(new Identifier($1), new list<ExpAst *>());
    		$$->type=globTab.sym[$1]->starType();
    		$$->base_type=globTab.sym[$1]->type;
    		$$->isConst=0;
    		$$->isLval=0;
    	}		
	| IDENTIFIER '(' expression_list ')' 
    	{
    		if(globTab.inScope($1) == NULL)
    		{
    			cerr << "Function definition not found. Error at line " << lineNum << endl;
    			exit(1243);
    		}
    		
    		vector<symbol*> symArr;
    		symArr = ((globTab.inScope($1))->symtab)->sort_byoffset();
    		int countParams = 0;
    		for(int i=0; i<symArr.size(); i++)
    		{
    			if(symArr[i]->scope == "param")
    				countParams ++;
    			else
    				break;
    		}

    		list<ExpAst*> expList;

    		if(countParams > 0 && ((list<ExpAst *>*)$3)->size() == countParams)
    		{
    			int i = -1;
    			while(true)
	    		{
	    			i++;
	    			if(i >= countParams)
	    				break;

	    			ExpAst* argum = ((list<ExpAst *>*)$3)->front();
    				((list<ExpAst *>*)$3)->pop_front();
    				
    				string leftType = symArr[i]->type;
    				for(int i1=0; i1<symArr[i]->dimensions.size(); i1++)
    				{
    					if(i1 == 0)
	    					leftType += "*";
	    				else
	    				{
	    					stringstream ss;
	    					ss << leftType << "[" << symArr[i]->dimensions[i1] << "]";
	    					leftType = ss.str();
	    				}
    				}
    				string rightType = argum->base_type;
    				for(int i1=0; i1<argum->dim.size(); i1++)
    				{
    					if(i1 == 0)
	    					rightType += "*";
	    				else
	    				{
	    					stringstream ss;
	    					ss << rightType << "[" << argum->dim[i1] << "]";
	    					rightType = ss.str();
	    				}
    				}

    				// cerr << leftType << " -- " << rightType << endl;

	    			// Code from expression assignment
					// (With some modifications)
	    			/********************************/

					if(symArr[i]->type == "void*" && argum->type[argum->type.size()-1] == '*')
					{
    					expList.push_back(argum);
						continue;
					}
					else if(argum->type == "void*" && symArr[i]->type[symArr[i]->type.size()-1] == '*')
		 			{
    					expList.push_back(argum);
						continue;
		 			}
		 			else if(symArr[i]->dimensions.size()>0 || argum->dim.size() > 0)
		 			{
						if(leftType == rightType)
						{
    						expList.push_back(argum);
							continue;
						}
						else
						{
							cerr << "Arguments mismatch at " << lineNum << endl;
							exit(112);
						}

		 			}
					else if(symArr[i]->type[symArr[i]->type.size()-1] == '*' && argum->type[argum->type.size()-1] == '*')
					{
						if(symArr[i]->type == argum->type)
						{
    						expList.push_back(argum);
							continue;
						}
						else
						{
							cerr << "Arguments mismatch at " << lineNum << endl;
							exit(112);
						}
					}
					else if(symArr[i]->type[symArr[i]->type.size()-1] == '*' || argum->type[argum->type.size()-1] == '*')
					{
						cerr << "Arguments mismatch at " << lineNum << endl;
						exit(112);
					}
					else
					{
						if(symArr[i]->type == "void" || argum->type == "void")
						{
	 						cerr << "Void types at line " << lineNum << endl;
	 						exit(112);
 						}
						if(symArr[i]->type!=argum->type)
						{
							// Case to handle assingments of structs. 
							if(currTab->inScope(symArr[i]->type)==NULL && currTab->inScope(argum->type)==NULL)
							{
								// TODO - Add typecasting to AST
								// argum = new Op1("TO-"+symArr[i]->type, argum);
	    						expList.push_back(new Op1("TO-"+symArr[i]->type, argum));
								continue;
							}
							else
							{
								cerr << "Arguments mismatch at " << lineNum << endl;
								exit(112);
							}
						}
						else
						{
							// $$ = new Assign(symArr[i], argum);
    						expList.push_back(argum);
							continue;
						}
					}

	    			/********************************/
	    		}
	    	}
	    	else
	    	{
    			cerr << "Incorrect number of arguments supplied. Error at line " << lineNum << endl;
    			exit(1241);
	    	}

    		$$ = new Funcall(new Identifier($1), expList);
    		$$->type=globTab.sym[$1]->starType();
    		$$->base_type=globTab.sym[$1]->type;
  			$$->isConst=0;
    		$$->isLval=0;
    	}
	| postfix_expression INC_OP
		{
			ExpAst* temp = $1;
			if(temp->isLval==0){
				cerr << "Increment Op not allowed for type Error at line " << lineNum << endl;
    			exit(1241);
			}
			$$ = new Op1("PlusPlus", temp);
			$$->type=temp->type;
			$$->isConst=1;
    		$$->isLval=0;
		}		

    | postfix_expression '[' expression ']'
    	{
    		ExpAst* temp=  $1;
    		$$ = new ArrayRef($1,$3);

    		if(temp->type[temp->type.size()-1]=='*' && $3->type=="int"){
    		$$->type=temp->type.substr(0,temp->type.size()-1);
    		$$->base_type=temp->base_type;
    		if(temp->dim.size()>0){
    		temp->dim.erase(temp->dim.begin());
    		$$->dim= temp->dim;
    		}
    	}
    		else{
    			cerr<<"Arbit Array acess error at " << lineNum << endl;
    			exit(3);
    		}
    		$$->isConst=0;
    		$$->isLval=temp->isLval;

    	}
    | postfix_expression '.' IDENTIFIER
		{	ExpAst* temp=$1;
			string id=$3;
			$$ = new Member($1, new Identifier(id));
			symbol* t = globTab.inScope(temp->type);
			if(t==NULL){
				cerr<<"Member not defined for "<<temp->type<< " at " <<lineNum << endl;
				exit(2);
			}
			symbol* mem=t->symtab->inScope(id);
			if(mem==NULL){
				cerr<<"No such Member "<<id<< " at " <<lineNum << endl;
				exit(2);
			}
			$$->type= mem->starType() ; 
			$$->dim= mem->dimensions ; 
			$$->base_type=mem->type;
			$$->isConst=0;
			$$->isLval=1;	

		}
    | postfix_expression PTR_OP IDENTIFIER
		{
			ExpAst* temp=$1;
			$$ = new Arrow($1, new Identifier($3));
			if(temp->base_type[temp->base_type.size()-1]=='*'&&temp->base_type==temp->type){
			symbol* t = globTab.inScope(temp->type.substr(0,temp->type.size()-1));
			if(t==NULL){
				cerr<<"PTR not defined for "<<temp->type << " at " <<lineNum << endl;
				exit(2);
			}
			symbol* mem=t->symtab->inScope($3);
			if(mem==NULL){
				cerr<<" No such Member "<<$3<< " at " <<lineNum << endl;
				exit(2);
			}
			$$->type= mem->starType() ;
			$$->dim= mem->dimensions ; 
			$$->base_type=mem->type;}
			 else{
    			cerr<<"Arbit Pointer OP error "<< " at " <<lineNum << endl;
    			exit(3);
    		}
    		$$->isConst=0;
    		$$->isLval=1;

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
			if(type0=="void"){
				cerr<<"illegal void type declared at "<<lineNum<<endl;
				exit(3);
			}

    		if(isStruct && globTab.inScope(structName)==NULL && type0[type0.size() - 1] != '*'){
				cerr<<"Struct used without declaration at "<<lineNum<<endl;
				exit(0);
    		}

			type0=type1;
			for(int i = 0; i<currTab->sym[currIdentifier]->dimensions.size(); i++)
				currTab->sym[currIdentifier]->size *= currTab->sym[currIdentifier]->dimensions[i];
			offset -= currTab->sym[currIdentifier]->size;
		}
	| declarator_list ',' declarator 
		{
			if(type0=="void"){
				cerr<<"illegal void type declared at "<<lineNum<<endl;
				exit(3);
			}

    		if(isStruct && globTab.inScope(structName)==NULL && type0[type0.size() - 1] != '*'){
				cerr<<"Struct used without declaration at "<<lineNum<<endl;
				exit(0);
    		}

			type0=type1;
			for(int i = 0; i<currTab->sym[currIdentifier]->dimensions.size(); i++)
				currTab->sym[currIdentifier]->size *= currTab->sym[currIdentifier]->dimensions[i];
			offset -= currTab->sym[currIdentifier]->size;
		}
 	;


