#include <map>
using namespace std;
class symbol{
	string name;
	bool vartype; //var/fun
	string scope; // param/local/global
	string type;
	int size;
	int offset;
	localTb* symtab; // if of type struct

	symbol(	string name1,
	bool vartype1, //var/fun
	string scope1, // param/local/global
	string type1,
	int size1,
	int offset1,
	Tb* symtab1 ){
		name=name1;
		vartype=vartype1;
		scope=scope1;
		type=type1;
		size=size1;
		offset=offset1;

	}
};
class Tb{
	string name;
	map<string,symbol> sym;
	void print(){
		for(it_type iterator = sym.begin(); iterator != sym.end(); iterator++) {
			

	}
	void recPrint(){

	}
};