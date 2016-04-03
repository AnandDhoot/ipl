#include <iostream>
#include <fstream>
#include <iomanip>
#include "Parser.h"
using namespace std;

Tb globTab;
Tb* currTab = new Tb();
string currIdentifier;
string type0,type1;
int value = 0;
bool parsingFun = true;
int currSize = 0;
bool isIntConst = false;
int offset = -4;
int maxParamOffset = 0;
bool isStruct = false;
string structName;
ofstream fout;
Registers r;
int main (int argc, char** arg)
{
	currTab->parent = &globTab;
	fout.open("code.txt", fstream::out);
	Parser parser;
	parser.parse();
	fout.close();
}
