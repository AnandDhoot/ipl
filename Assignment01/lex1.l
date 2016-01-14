

// There may be some flexer directives here

%%
[ \t]                                    //skip
(push|mov|and|sub)l|call|leave|ret          return MNEMONIC;
(-?)[[:digit:]]+                            return NUMBER;
"$"(-?)[[:digit:]]+                         return IMMNUMBER;  
"%"(ebp|esp|edx|eax|esp)                    return REGISTER;     
[[:alpha:]][[:alnum:]]*                     return SYMBOL;
"$"("."?)[[:alpha:]][[:alnum:]]*            return IMMSYMBOL;
"+"                                         return '+';
","                                         return ',';
"("                                         return '(';
")"                                         return ')';
":"                                         return ':';
"\n"                                        return '\n';
.                                           return OTHERS;                                          

