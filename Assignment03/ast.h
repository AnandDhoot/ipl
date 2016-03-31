#include <iostream>
#include <stdio.h>
#include <string>
#include <list>
#include <sstream>
#include "st.h"
using namespace std;

extern Tb globTab;
extern Tb* currTab;
extern string currIdentifier;
extern string type0,type1;
extern int value;
extern int currSize;
extern bool parsingFun;
extern bool isIntConst;
extern int offset;
extern int maxParamOffset;
extern bool isStruct;
extern string structName;
class abstract_astnode
{
public:
    string name;
    bool vartype; //var/fun
    string scope; // param/local/global
    string type;
    int size;
    int offset;
    Tb* myTab;
virtual void print (int level) = 0;
// virtual std::string generate_code(const symbolTable&) = 0;
// virtual basic_types getType() = 0;
// virtual bool checkTypeofAST() = 0;
protected:
// virtual void setType(basic_types) = 0;
private:
// typeExp astnode_type;
} ;


class ExpAst : public abstract_astnode {
    public:
    string type;
    string name;
    string base_type;
    std::vector<int> dim;
    bool isConst=0,isLval;;
    virtual void print (int level){}
    void genCode(){}
};

class StmtAst : public abstract_astnode {
    public:
    virtual void print (int level){}
    void genCode(){}
};

class RefAst : public ExpAst {
    public:

    virtual void print (int level){}
};

class IntConst : public ExpAst {

  public:
    int x;
    IntConst(int n){
        x = n;
        type="int";
        isConst=1;
        myTab=currTab;
    }

    void print(int level){
            cout << string(level, '\t');
        cout<<"(IntConst "<<x<<")";
    }
};

class FloatConst : public ExpAst {

  public:
    float x;
    FloatConst(float n){
        x = n;
        type="float";
        isConst=1;
        myTab=currTab;
    }

    void print(int level){
        cout << string(level, '\t');
        cout<<"(FloatConst "<<x<<")";
    }
};

class StringConst : public ExpAst {

  public:
    string x;
    StringConst(string n){
        x = n;
        isConst=1;
        myTab=currTab;
    }

    void print(int level){
        cout << string(level, '\t');
        cout<<"(StringConst "<<x<<")";
    }
};

class Identifier : public ExpAst {

  public:
    string x;
    Identifier(string n){
        x = n;
        myTab=currTab;
    }

    void print(int level){
        cout << string(level, '\t');
        cout<<"(Id \""<<x<<"\")";
    }
};

class Empty : public StmtAst{
    public:
        void print (int level){
            cout << string(level, '\t');
            cout<<"(Empty)";
        }
};

class Return : public StmtAst{

    public:
        ExpAst *retExp;
        Return(ExpAst *x){
            retExp = x;
            myTab=currTab;
        }

        void print(int level){
            cout << string(level, '\t');
            cout<<"(Return "; retExp->print(0); cout<<")";
        }
};

class Op1 : public ExpAst{

    public:
        string operat;
        ExpAst *restExp;
        Op1(string w, ExpAst *x){
            operat = w;
            restExp = x;
            myTab=currTab;
        }

        void print(int level){
            cout << string(level, '\t');
            cout<<"("<<operat<<" " ; restExp->print(0); cout<<")";
        }
};

class Op2 : public ExpAst{

    public:
        string operat;
        ExpAst *leftExp;
        ExpAst *rightExp;
        Op2(string w, ExpAst *x,ExpAst *y){
            operat = w;
            leftExp = x;
            rightExp = y;
            myTab=currTab;
        }

        void print(int level){
            cout << string(level, '\t');
            cout<<"("<<operat<<" " ; leftExp->print(0); rightExp->print(0); cout<<")";
        }
};

class Assign : public ExpAst{

    public:
        ExpAst *lExp;
        ExpAst *rightExp;
        Assign(ExpAst *x,ExpAst *y){
            lExp = x;
            rightExp = y;
            myTab=currTab;
        }

        void print(int level){
            cout << string(level, '\t');
                cout<<"(Assign "; lExp->print(0);rightExp->print(0); cout<<")";
        }

        void genCode(){
            lExp->genCode();
            rightExp->genCode();
            fout << "lw $t0, 0($sp)" << endl;
            fout << "lw $t1, 4($sp)" << endl;
            fout << "addi $sp, $sp, -8" << endl;

            fout << "sw $t1, 0($t0)" << endl;
            fout << "addi $sp, $sp, 4" << endl;
            fout << "sw $1, 0($sp)" << endl;
        }
};

class Funcall : public ExpAst{

    public:
        Identifier* funName;
        list<ExpAst *> expList;
        Funcall(Identifier *w, list<ExpAst *> x){
            funName = w;
            expList = x;
            myTab=currTab;
        }
        Funcall(Identifier *w, list<ExpAst *>* x){
            funName = w;
            expList = *x;
            myTab=currTab;
        }

        void print(int level){
            cout << string(level, '\t');
            cout<<"(Funcall " << endl; 
            for(list<ExpAst *>::iterator it=expList.begin(); it != expList.end(); it++)
            {
                cout << string(level+1, '\t');
                (*it)->print(0);
            }
            cout << string(level, '\t');
            cout<<")";
        }
};

class Ass : public StmtAst{

    public:
        ExpAst *Exp;
        Ass(ExpAst *x){
            Exp = x;
        }

        void print(int level){
            cout << std::string(level, '\t');
            cout<<"(Assign_exp " ; Exp->print(0); cout<<")";
        }
};

class Seq : public StmtAst{

    public:
        list<StmtAst *> stmtList;
        Seq(list<StmtAst *> x){
            stmtList = x;
            myTab=currTab;
        }
        Seq(list<StmtAst *>* x){
            stmtList = *x;
            myTab=currTab;
        }

        void print(int level){
            cout << string(level, '\t');
            cout<<"(Seq " <<myTab->name<< endl; 
            for(list<StmtAst *>::iterator it = stmtList.begin(); it != stmtList.end(); it++)
            {
                (*it)->print(level+1);
                cout << endl;
            }
            cout << string(level, '\t');
            cout<<")";
        }
};

class If : public StmtAst{

    public:
        ExpAst *IfExp;
        StmtAst *thenStmt;
        StmtAst *elseStmt;
        If(ExpAst *x, StmtAst *y, StmtAst *z){
            IfExp = x;
            thenStmt = y;
            elseStmt = z;
            myTab=currTab;
        }

        void print(int level){
            cout << string(level, '\t');
            cout<<"(If " << endl; 
            IfExp->print(level+1); 
            cout << endl;
            thenStmt->print(level+1); 
            cout << endl;
            elseStmt->print(level+1); 
            cout << endl;
            cout << string(level, '\t');
            cout<<")";
        }
};

class For : public StmtAst{

    public:
        ExpAst *initExp;
        ExpAst *condExp;
        ExpAst *incExp;
        StmtAst *bodyStmt;
        For(ExpAst *w, ExpAst *x, ExpAst *y, StmtAst *z){
            initExp = w;
            condExp = x;
            incExp = y;
            bodyStmt = z;
            myTab=currTab;
        }

        void print(int level){
            cout << string(level, '\t');
            cout << "(For " << endl; 
            initExp->print(level+1); 
            cout << endl;
            condExp->print(level+1); 
            cout << endl;
            incExp->print(level+1); 
            cout << endl;
            bodyStmt->print(level+1); 
            cout << endl;
            cout << string(level, '\t');
            cout<<")" << endl;
        }
};

class While : public StmtAst{

    public:
        ExpAst *whileExp;
        StmtAst *thenStmt;
        While(ExpAst *x,StmtAst *y){
            whileExp = x;
            thenStmt = y;
            myTab=currTab;
        }

        void print(int level){
            cout << string(level, '\t');
            cout<<"(While " << endl; whileExp->print(level+1); cout << endl; thenStmt->print(level+1); cout << endl;
            cout << string(level, '\t'); cout<<")" << endl;
        }
};

class Pointer : public ExpAst{

    public:
        ExpAst *exp;
        Pointer(ExpAst *x){
            exp = x;
            myTab=currTab;
        }

        void print(int level){
            cout << string(level, '\t');
            cout<<"(Pointer "; exp->print(0); cout<<")";
        }
};

class Deref : public ExpAst{

    public:
        ExpAst *exp;
        Deref(ExpAst *x){
            exp = x;
            myTab=currTab;
        }

        void print(int level){
            cout << string(level, '\t');
            cout<<"(Deref "; exp->print(0); cout<<")";
        }
};

class ArrayRef : public ExpAst{

    public:
        ExpAst *varIdent;
        ExpAst *exp;
        ArrayRef(ExpAst *x,ExpAst *y){
            varIdent = x;
            exp = y;
            myTab=currTab;
        }

        void print(int level){
            cout << string(level, '\t');
            cout<<"(ArrayRef " ; 
            varIdent->print(0);
            exp->print(0);
            cout<<")";
        }
};

class Member : public ExpAst{

    public:
        ExpAst *varIdent;
        Identifier *id;
        Member(ExpAst *x,Identifier *y){
            varIdent = x;
            id = y;
            myTab=currTab;
        }

        void print(int level){
            cout << string(level, '\t');
            cout<<"(Member " ; 
            varIdent->print(0);
            id->print(0);
            cout<<")";
        }
};

class Arrow : public ExpAst{

    public:
        ExpAst *varIdent;
        Identifier *id;
        Arrow(ExpAst *x,Identifier *y){
            varIdent = x;
            id = y;
            myTab=currTab;
        }

        void print(int level){
            cout << string(level, '\t');
            cout<<"(Arrow " ; 
            varIdent->print(0);
            id->print(0);
            cout<<")";
        }
};
