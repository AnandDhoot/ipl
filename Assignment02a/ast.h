#include <iostream>
#include <stdio.h>
#include <string>
#include <list>
using namespace std;

class abstract_astnode
{
public:
virtual void print () = 0;
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

class RefAst : public ExpAst {
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
        Op1(string w, ExpAst *x){
            operat = w;
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
        Op2(string w, ExpAst *x,ExpAst *y){
            operat = w;
            leftExp = x;
            rightExp = y;
        }

        void print(){
            cout<<"("<<operat<<" " ; leftExp->print(); rightExp->print(); cout<<")";
        }
};

class Funcall : public ExpAst{

    public:
        Identifier* funName;
        list<ExpAst *> expList;
        Funcall(Identifier *w, list<ExpAst *> x){
            funName = w;
            expList = x;
        }
        Funcall(Identifier *w, list<ExpAst *>* x){
            funName = w;
            expList = *x;
        }

        void print(){
            cout<<"(Funcall " ; 
            for(list<ExpAst *>::iterator it=expList.begin(); it != expList.end(); it++)
                (*it)->print();
            cout<<")";
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

class Seq : public StmtAst{

    public:
        list<StmtAst *> stmtList;
        Seq(list<StmtAst *> x){
            stmtList = x;
        }
        Seq(list<StmtAst *>* x){
            stmtList = *x;
        }

        void print(){
            cout<<"(Seq " ; 
		cout<<stmtList.size();
            for(list<StmtAst *>::iterator it = stmtList.begin(); it != stmtList.end(); it++)
                (*it)->print();
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
        }

        void print(){
            cout<<"(If " ; 
            IfExp->print(); 
            thenStmt->print(); 
            elseStmt->print(); 
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
        }

        void print(){
            cout<<"(For " ; 
            initExp->print(); 
            condExp->print(); 
            incExp->print(); 
            bodyStmt->print(); 
            cout<<")";
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

class ArrayRef : public RefAst{

    public:
        RefAst *varIdent;
        ExpAst *exp;
        ArrayRef(RefAst *x,ExpAst *y){
            varIdent = x;
            exp = y;
        }

        void print(){
            cout<<"(ArrayRef " ; 
            varIdent->print();
	    exp->print();
            cout<<")";
        }
};
