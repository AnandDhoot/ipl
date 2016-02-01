#include <iostream>
#include <stdio.h>
#include <string>
#include <list>
using namespace std;

class abstract_astnode
{
public:
virtual void print () = 0;
virtual std::string generate_code(const symbolTable&) = 0;
virtual basic_types getType() = 0;
virtual bool checkTypeofAST() = 0;
protected:
virtual void setType(basic_types) = 0;
private:
typeExp astnode_type;
} ;



class ExpAst : public abstract_astnode {
	public:

    virtual void print (){
        cout<<"This is an abstract ExpAst class"<<endl;
    }
};

class StmtAst : public abstract_astnode {
    public:

    virtual void print (){
        cout<<"This is an abstract StmtAst class"<<endl;
    }
};

class RefAst : public abstract_astnode {
	public:

    virtual void print (){
        cout<<"This is an abstract RefAst class"<<endl;
    }
};


class IntConst : public ExpAst {

  public:
    int x;
    IntConst(int n){
    	x = n;
    }

    void print(){
    	cout<<"(IntConst "<<x<<")";
    }
};

class FloatConst : public ExpAst {

  public:
    float x;
    FloatConst(float n){
    	x = n;
    }

    void print(){
    	cout<<"(FloatConst "<<x<<")";
    }
};

class StringConst : public ExpAst {

  public:
    string x;
    StringConst(string n){
    	x = n;
    }

    void print(){
    	cout<<"(StringConst "<<x<<")";
    }
};

class Identifier : public RefAst {

  public:
    string x;
    Identifier(string n){
    	x = n;
    }

    void print(){
    	cout<<"(Id \""<<x<<"\")";
    }
};

class Empty : public StmtAst{
    public:
        void print (){
            cout<<"(Empty)";
        }
};


class Return : public StmtAst{

    public:
    	ExpAst *retExp;
        Return(ExpAst *x){
            retExp = x;
        }

        void print(){
            cout<<"(Return "; retExp->print(); cout<<")";
        }
};

class Op1 : public ExpAst{

    public:
    	string operat;
    	ExpAst *restExp;
        Op1(ExpAst *x){
            restExp = x;
        }

        void print(){
            cout<<"("<<operat<<" " ; restExp->print(); cout<<")";
        }
};

class Op2 : public ExpAst{

    public:
    	string operat;
    	ExpAst *leftExp;
    	ExpAst *rightExp;
        Op2(ExpAst *x,ExpAst *y){
            leftExp = x;
            rightExp = y;
        }

        void print(){
            cout<<"("<<operat<<" " ; leftExp->print(); rightExp->print(); cout<<")";
        }
};

class Ass : public StmtAst{

    public:
    	ExpAst *leftExp;
    	ExpAst *rightExp;
        Ass(ExpAst *x,ExpAst *y){
            leftExp = x;
            rightExp = y;
        }

        void print(){
            cout<<"(Assign_exp " ; leftExp->print(); rightExp->print(); cout<<")";
        }
};
class While : public StmtAst{

    public:
    	ExpAst *whileExp;
    	StmtAst *thenStmt;
        While(ExpAst *x,StmtAst *y){
            whileExp = x;
            thenStmt = y;
        }

        void print(){
            cout<<"(While " ; whileExp->print(); thenStmt->print(); cout<<")";
        }
};

class Pointer : public RefAst{

    public:
    	RefAst *exp;
        Pointer(RefAst *x){
            exp = x;
        }

        void print(){
            cout<<"(Pointer "; exp->print(); cout<<")";
        }
};

class Deref : public RefAst{

    public:
    	RefAst *exp;
        Deref(RefAst *x){
            exp = x;
        }

        void print(){
            cout<<"(Deref "; exp->print(); cout<<")";
        }
};
