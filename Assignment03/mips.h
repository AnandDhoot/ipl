#include <iostream>
#include <list>
#include <sstream>
using namespace std;
extern ofstream fout;
class Registers{
public:
	list<string> freeReg;
	list<string> usedReg;
	string data=".data \n"; //data segment

string genLabel(){

    static int x =0;
    string a;
    stringstream convert; // stringstream used for the conversion
    convert<<"L";
    convert << x;//add the value of Number to the characters in the stream
    x++;
    return convert.str();
}
	Registers(){

		for(int i=8;i<18;i++){
			string a="$";
			stringstream convert; // stringstream used for the conversion
			convert << i;//add the value of Number to the characters in the stream
			a =convert.str();
			a="$"+a;
			freeReg.push_back(a);
		}

	}
void structCp(string from,string to,int size){

for(int i=0;i<size;i+=4){
    fout<<"lw $a0, "<<i<<"("<<from<<")"<<endl;
    fout<<"sw $a0, "<<i<<"("<<to<<")"<<endl;
}

}
bool structChk(string type){
	if(type.size()<6) return false;
    return type.substr(0,6)=="struct"&&type[type.size()-1]!='*';
}
	string getNewReg(){
		if(freeReg.size()>0){
		string a= freeReg.back();
		usedReg.push_back(a);
		freeReg.pop_back();
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
	string storeReg(){
		//responsibility of caller to save and restore
		if(usedReg.size()>0){
		string a= usedReg.front();
		usedReg.pop_front();
		return a;
	}
		return "";
	}

	void freeUpReg(string reg){
		usedReg.remove(reg);
		freeReg.push_back(reg);
	}



};
