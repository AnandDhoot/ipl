// There may be some flexer directives here

%%
[ \t\n]                                   			    //skip
int 													return Parser::INT;
void 													return Parser::VOID;
float 													return Parser::FLOAT;
return													return Parser::RETURN;
if 														return Parser::IF;
else 													return Parser::ELSE;
while 													return Parser::WHILE;
for 													return Parser::FOR;
[1-9][0-9]*												return Parser::INT_CONSTANT;
0[xX][0-9a-fA-F]*										return Parser::INT_CONSTANT;
0[bB][01]*												return Parser::INT_CONSTANT;
0[0-7]* 												return Parser::INT_CONSTANT;
[0-9]+\.[0-9]*([eE]?[+-]?[0-9]+)? 						return Parser::FLOAT_CONSTANT;
\"([^\\\"]*(\\[tn\"\\][^\\\"]*)?)*\"					return Parser::STRING_LITERAL;

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

"||"													return Parser::OR_OP;
"&&"													return Parser::AND_OP;
"=="													return Parser::EQ_OP;
"!="													return Parser::NE_OP;
"<="													return Parser::LE_OP;
">="													return Parser::GE_OP;
"++"													return Parser::INC_OP;
"--"													return Parser::DEC_OP;

[a-zA-Z_][a-zA-Z0-9_]*									return Parser::IDENTIFIER;

.                                        				return Parser::OTHERS;
 