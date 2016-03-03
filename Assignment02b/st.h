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

};
class localTb{

	map<name,symbol> sym;

};
class st {

	map<string,localTb> table;
	localTb globalStuff;

};