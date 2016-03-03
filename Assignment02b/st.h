#include <map>
#include <iostream>
#include <vector>
using namespace std;
class Tb;
class symbol{
public:
	string name;
	bool vartype; //var/fun
	string scope; // param/local/global
	string type;
	int size;
	int offset;
	vector<int> dimensions;
	Tb* symtab; // if of type struct

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
	void print(){
		cout<<name<<"\t"<<vartype<<"\t"<<scope<<"\t"<<type<<"\t"<<size<<"\t"<<offset;
		if(dimensions.size() != 0){
			cout << "Array: ";
			for(int i = 0; i < dimensions.size(); i++)
				cout << " [" << dimensions[i] << "] ";
			cout<<"\n";
		}

	}
};
class Tb{
public:
	string name;
	map<string,symbol> sym;
	void print(){
		cout<<name<<"\n";
		for(map<string,symbol>::iterator iterator = sym.begin(); iterator != sym.end(); iterator++) {
			iterator->second.print();

		}
	}

	void recPrint(){
		cout<<name<<"\n";
		for(map<string,symbol>::iterator iterator = sym.begin(); iterator != sym.end(); iterator++) {
			iterator->second.print();
			if(iterator->second.symtab!=NULL)
				iterator->second.symtab->recPrint();

		}
	}
};