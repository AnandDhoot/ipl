#include <iostream>
#include <iomanip>
#include "Parser.h"
using namespace std;

Tb globTab;
Tb* currTab = new Tb();
string currIdentifier;
string type0;
int value = 0;
bool parsingFun = true;
int currSize = 0;
bool isIntConst = false;
int offset = 4;
int maxParamOffset = 0;

int main (int argc, char** arg)
{

	Parser parser;
	parser.parse();
}
