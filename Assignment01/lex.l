// There may be some flexer directives here

%%
[ \t]                                   			    //skip
int 													return INT;
void 													return VOID;
float 													return FLOAT;
return 													return RETURN;
if 														return IF;
else 													return ELSE;
while 													return WHILE;
for 													return FOR;
[+-]?[1-9][0-9]*										return INT_CONSTANT;
0[xX][0-9a-fA-F]*										return INT_CONSTANT;
0[bB][01]*												return INT_CONSTANT;
0[0-7]* 												return INT_CONSTANT;
[0-9]+\.[0-9]*([eE]?[+-]?[0-9]+)? 						return FLOAT_CONSTANT;
\"([^\\\"]*(\\[tn\"\\][^\\\"]*)?)*\"					return STRING_LITERAL;

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

"||"													return OR_OP;
"&&"													return AND_OP;
"=="													return EQ_OP;
"!="													return NE_OP;
"<="													return LE_OP;
">="													return GE_OP;
"++"													return INC_OP;
"--"													return DEC_OP;

[a-zA-Z_][a-zA-Z0-9_]*									return IDENTIFIER;

.                                        				return OTHERS;
