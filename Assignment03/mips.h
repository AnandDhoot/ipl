#include <iostream>
#include <list>
#include <sstream>
using namespace std;


class Registers{
public:
	list<string> freeReg;
	list<string> usedReg;

	Registers(){

		for(int i=8;i<12;i++){
			string a="$";
			stringstream convert; // stringstream used for the conversion
			convert << i;//add the value of Number to the characters in the stream
			a =convert.str();
			a="$"+a;
			freeReg.push_back(a);
		}

	}

	string getNewReg(){
		if(freeReg.size()>0){
		string a= freeReg.front();
		usedReg.push_back(a);
		freeReg.pop_front();
		return a;
	}
		return "";
	}
	string getUsedReg(){
		//responsibility of caller to save and restore
		if(usedReg.size()>0){
		string a= usedReg.front();
		usedReg.pop_front();
		usedReg.push_back(a);
		return a;
	}
		return "";
	}

	void freeUpReg(string reg){
		usedReg.remove(reg);
		freeReg.push_back(reg);
	}



};

