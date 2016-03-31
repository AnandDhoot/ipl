// There may be some flexer directives here

%%
[ \t]                                   			    //skip
"\n"                                                                             {Parser::lineNum = Parser::lineNum + 1;}
int 													return Parser::INT;
void 													return Parser::VOID;
float 													return Parser::FLOAT;
return													return Parser::RETURN;
if 														return Parser::IF;
else 													return Parser::ELSE;
while 													return Parser::WHILE;
for 													return Parser::FOR;
struct													return Parser::STRUCT;
[1-9][0-9]*												{Parser::d_val__ = std::stoi(matched());   return ParserBase::INT_CONSTANT;}
0[xX][0-9a-fA-F]*										{Parser::d_val__ = std::stoi(matched());   return ParserBase::INT_CONSTANT;}
0[bB][01]*												{Parser::d_val__ = std::stoi(matched());   return ParserBase::INT_CONSTANT;}
0[0-7]* 												{Parser::d_val__ = std::stoi(matched());   return ParserBase::INT_CONSTANT;}
[0-9]+\.[0-9]*([eE]?[+-]?[0-9]+)? 						{Parser::d_val__ = std::stof(matched());   return ParserBase::FLOAT_CONSTANT;}
\"([^\\\"]*(\\[tn\"\\][^\\\"]*)?)*\"					{Parser::d_val__ = std::string(matched());   return ParserBase::STRING_LITERAL;}

"("                                         			return '(';
")"                                         			return ')';
"["                                         			return '[';
"]"                                         			return ']';
"{"                                         			return '{';
"}"                                         			return '}';
","                                         			return ',';
";"                                         			return ';';
"="                                         			return '=';
"<"                                         			return '<';
">"                                         			return '>';
"-"                                         			return '-';
"+"                                         			return '+';
"*"                                         			return '*';
"/"                                         			return '/';
"!"                                         			return '!';
"&"                                         			return '&';

"||"													return Parser::OR_OP;
"&&"													return Parser::AND_OP;
"=="													return Parser::EQ_OP;
"!="													return Parser::NE_OP;
"<="													return Parser::LE_OP;
">="													return Parser::GE_OP;
"++"													return Parser::INC_OP;
"->"                                                    return Parser::PTR_OP;
[a-zA-Z_][a-zA-Z0-9_]*									{Parser::d_val__ = std::string (matched());   return ParserBase::IDENTIFIER;};
"."                                         			return '.';
