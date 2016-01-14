#include <iostream>
#include <iomanip>
#include "Scanner.h"
using namespace std;
int main() {
	Scanner scanner;   // define a Scanner object
	while (int token = scanner.lex()) // get all tokens
	{
		string const &text = scanner.matched();
		switch (token) {
                case Scanner::VOID:
                 cout << "VOID: \t\t" << text << '\n'; 
                 break;
                case Scanner::INT:
                 cout << "INT: \t\t" << text << '\n'; 
                 break;
                case Scanner::FLOAT:
                 cout << "FLOAT: \t\t" << text << '\n'; 
                 break;
                case Scanner::RETURN:
                 cout << "RETURN: \t\t" << text << '\n'; 
                 break;
                case Scanner::IF:
                 cout << "IF: \t\t" << text << '\n'; 
                 break;
                case Scanner::ELSE:
                 cout << "ELSE: \t\t" << text << '\n'; 
                 break;
                case Scanner::WHILE:
                 cout << "WHILE: \t\t" << text << '\n'; 
                 break;
                case Scanner::FOR:
                 cout << "FOR: \t\t" << text << '\n'; 
                 break;
                case Scanner::INT_CONSTANT:
                 cout << "INT_CONSTANT: \t\t" << text << '\n'; 
                 break;
                case Scanner::FLOAT_CONSTANT:
                 cout << "FLOAT_CONSTANT: \t\t" << text << '\n'; 
                 break;
                case Scanner::STRING_LITERAL:
                 cout << "STRING_LITERAL: \t\t" << text << '\n'; 
                 break;
                case Scanner::OR_OP:
                 cout << "OR_OP: \t\t" << text << '\n'; 
                 break;
                case Scanner::AND_OP:
                 cout << "AND_OP: \t\t" << text << '\n'; 
                 break;
                case Scanner::EQ_OP:
                 cout << "EQ_OP: \t\t" << text << '\n'; 
                 break;
                case Scanner::NE_OP:
                 cout << "NE_OP: \t\t" << text << '\n'; 
                 break;
                case Scanner::LE_OP:
                 cout << "LE_OP: \t\t" << text << '\n'; 
                 break;
                case Scanner::GE_OP:
                 cout << "GE_OP: \t\t" << text << '\n'; 
                 break;
                case Scanner::INC_OP:
                 cout << "INC_OP: \t\t" << text << '\n'; 
                 break;
                case Scanner::DEC_OP:
                 cout << "DEC_OP: \t\t" << text << '\n'; 
                 break;
                case Scanner::IDENTIFIER:
                 cout << "IDENTIFIER: \t\t" << text << '\n'; 
                 break;
                case Scanner::OTHERS:
                 cout << "OTHERS: \t\t" << text << '\n'; 
                 break;
                case '(':
                 cout << "lparen\t\t" << text << '\n'; 
                 break;
                case ')':
                 cout << "rparen\t\t" << text << '\n'; 
                 break;
                case '[':
                 cout << "lsquare \t\t" << text << '\n'; 
                 break;
                case ']':
                 cout << "rsquare \t\t" << text << '\n'; 
                 break;
                case '{':
                 cout << "lcurly \t\t" << text << '\n'; 
                 break;
                case '}':
                 cout << "rcurly \t\t" << text << '\n'; 
                 break;
                case ',':
                 cout << "comma \t\t" << text << '\n'; 
                 break;
                case ';':
                 cout << "semicolon \t\t" << text << '\n'; 
                 break;
                case '=':
                 cout << "equals \t\t" << text << '\n'; 
                 break;
                case '<':
                 cout << "le \t\t" << text << '\n'; 
                 break;
                case '>':
                 cout << "ge \t\t" << text << '\n'; 
                 break;
                case '-':
                 cout << "minus \t\t" << text << '\n'; 
                 break;
                case '+':
                 cout << "plus \t\t" << text << '\n'; 
                 break;
                case '*':
                 cout << "mult \t\t" << text << '\n'; 
                 break;
                case '/':
                 cout << "slash \t\t" << text << '\n'; 
                 break;
                case '!':
                 cout << "exclam \t\t" << text << '\n'; 
                 break;
		}
	}
}
