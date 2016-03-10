#include <map>
#include <iostream>
#include <vector>
using namespace std;

class Tb;
class symbol{
public:
	string name;
	string vartype; //var/fun
	string scope; // param/local/global
	string type;
	int size;
	int offset;
	vector<int> dimensions;
	Tb* symtab; // if of type struct

	symbol(	string name1,
	string vartype1, //var/fun
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
		symtab = symtab1;
	}
	void print(){
		cout<<name<<"\t"<<vartype<<"\t"<<scope<<"\t"<<type;
		if(dimensions.size() != 0){
			for(int i = 0; i < dimensions.size(); i++)
				cout << "[" << dimensions[i] << "]";
		}
		cout<<"\t"<<size<<"\t"<<offset<<"\t"<<symtab<<endl;

	}
};
class Tb{
public:
	string name;
	Tb* parent;
	int offset;
	string returnType;
	map<string,symbol*> sym;

	Tb()
	{
		name = "";
		parent = NULL;
		offset = 0;
	}

	void print(){
		cout<<name<<"\n";
		for(map<string,symbol*>::iterator iterator = sym.begin(); iterator != sym.end(); iterator++) {
			iterator->second->print();

		}
	}
symbol* inScope(string var){
	if(sym.find(var)!=sym.end())
		return sym[var];
	else if(parent!=NULL)
		return parent->inScope(var);
	return NULL;
}
	void recPrint(){
		cout << endl << "-----------------------" << endl;
		cout<<name<<"\t"<<this<<"\n";
		for(map<string,symbol*>::iterator iterator = sym.begin(); iterator != sym.end(); iterator++) {
			iterator->second->print();
		}
		cout << endl << "-----------------------" << endl;
		for(map<string,symbol*>::iterator iterator = sym.begin(); iterator != sym.end(); iterator++) {
			if(iterator->second->symtab!=NULL)
			{
				cout << endl << endl;
				iterator->second->symtab->recPrint();
			}

		}
	}
};
