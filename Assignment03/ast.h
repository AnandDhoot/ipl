#include <iostream>
#include <iomanip>
#include <stdio.h>
#include <string>
#include <list>
#include <sstream>
#include <fstream>
#include "st.h"
#include "mips.h"
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
extern ofstream fout;
extern Registers r;
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
    bool isConst=0,isLval;int offset;// iF exp is lval , offset wrt ebp;
    string allotedReg;
    bool regToRestore=0;
    virtual void print (int level){}
    virtual void genCode(){}
};

class StmtAst : public abstract_astnode {
    public:
    virtual void print (int level){}
    virtual void genCode(){}
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

    void genCode(){
         fout <<"#"<< x << " ---Int Constant---" << endl;
        string reg= r.getNewReg();
        string t= " , ";
        if(reg==""){
            reg=r.getUsedReg();
            regToRestore=1;
            //store
            fout<<"addi $sp, $sp, -4"<<endl;
            fout<<"sw "<<reg<<", 0($sp)"<<endl;
            //load const
            fout<<"li "<<reg<<t<<x<<endl;
            allotedReg=reg;
        }
        else{
            fout<<"li "<<reg<<t<<x<<endl;
            allotedReg=reg;
        }
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

    void genCode(){
        fout <<"#"<< x << " ---Float Constant---" << endl;
        string reg= r.getNewReg();
        string t= " , $0, ";
        if(reg==""){
            reg=r.getUsedReg();
            regToRestore=1;
            //store
            fout<<"addi $sp, $sp, -4"<<endl;
            fout<<"sw "<<reg<<", 0($sp)"<<endl;
            //load const
            fout<<"li.s $f1, "<<x<<endl;
            fout<<"mfc1 "<<reg<<", $f1"<<endl;
            allotedReg=reg;
        }
        else{
            fout<<"li.s $f1, "<<x<<endl;
            fout<<"mfc1 "<<reg<<", $f1"<<endl;
            allotedReg=reg;
        }
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

    void genCode(){
        fout << x << " ---String Constant---" << endl;
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

    void genCode(){
        symbol *s = myTab->sym[x];
        // TODO - Handle function calls
        if(s == NULL) {
            cerr << "Not present in symTab" << endl; }
        cerr << myTab->name << " " << s->name << " " << s->offset << endl;

        string reg = r.getNewReg();
        if(reg==""){
            reg = r.getUsedReg();
            regToRestore = 1;
            //store
            fout << "addi $sp, $sp, -4" << endl;
            fout << "sw "<<reg<<", 0($sp)"<<endl;
            //load const
            fout << "lw " << reg << ", " << s->offset << "($fp)" << endl;
            allotedReg = reg;
        }
        else{
            fout << "lw " << reg << ", " << s->offset << "($fp)" << endl;
            allotedReg = reg;
        }

    }
};

class Empty : public StmtAst{
    public:
        void print (int level){
            cout << string(level, '\t');
            cout<<"(Empty)";
        }

        void genCode(){
            
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

        void genCode(){
            retExp->genCode();
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

        void genCode(){
            regToRestore=restExp->regToRestore;
            fout <<"#"<< operat << " ---Unary---" << endl;
            restExp->genCode();
            if(operat=="TO-float"){
                fout<<"mtc1 "<<restExp->allotedReg<<",$f1"<<endl;
                fout<<"cvt.s.w $f1, $f1"<<endl;
                fout<<"mfc1 "<<restExp->allotedReg<<",$f1"<<endl;
            }
            else if(operat=="TO-int"){
                fout<<"mtc1 "<<restExp->allotedReg<<",$f1"<<endl;
                fout<<"cvt.w.s $f1, $f1"<<endl;
                fout<<"mfc1 "<<restExp->allotedReg<<",$f1"<<endl;
            }
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
        void genCode(){
            leftExp->genCode();
            //restore reg if there             
            rightExp->genCode();
            //restore reg if there 

            //for add
            if(operat=="Plus-INT")
            fout<<"add "<<leftExp->allotedReg<<","<<rightExp->allotedReg<<", "<<leftExp->allotedReg<<endl;
            else if(operat=="Minus-INT"){
            fout<<"sub "<<leftExp->allotedReg<<","<<rightExp->allotedReg<<", "<<leftExp->allotedReg<<endl;
            }
            else if(operat=="Multiply-INT"){
            fout<<"mult "<<leftExp->allotedReg<<","<<rightExp->allotedReg<<endl;
            fout<<"mflo "<<leftExp->allotedReg<<endl;
            }
            else if(operat=="Divide-INT"){
            fout<<"div "<<leftExp->allotedReg<<","<<rightExp->allotedReg<<endl;
            fout<<"mflo "<<leftExp->allotedReg<<endl;
            }
            else if(operat=="Plus-FLOAT"){

                fout<<"mtc1 "<<leftExp->allotedReg<<",$f1"<<endl;
                fout<<"mtc1 "<<rightExp->allotedReg<<",$f2"<<endl;
                fout<<"add.s $f2,$f1,$f2"<<endl;
                fout<<"mfc1 "<<leftExp->allotedReg<<",$f2"<<endl;
            }
            else if(operat=="Minus-FLOAT"){

                fout<<"mtc1 "<<leftExp->allotedReg<<",$f1"<<endl;
                fout<<"mtc1 "<<rightExp->allotedReg<<",$f2"<<endl;
                fout<<"sub.s $f2,$f1,$f2"<<endl;
                fout<<"mfc1 "<<leftExp->allotedReg<<",$f2"<<endl;
            }
            else if(operat=="Multiply-FLOAT"){

                fout<<"mtc1 "<<leftExp->allotedReg<<",$f1"<<endl;
                fout<<"mtc1 "<<rightExp->allotedReg<<",$f2"<<endl;
                fout<<"mul.s $f2,$f1,$f2"<<endl;
                fout<<"mfc1 "<<leftExp->allotedReg<<",$f2"<<endl;
            }
            else if(operat=="Divide-FLOAT"){

                fout<<"mtc1 "<<leftExp->allotedReg<<",$f1"<<endl;
                fout<<"mtc1 "<<rightExp->allotedReg<<",$f2"<<endl;
                fout<<"dive.s $f2,$f1,$f2"<<endl;
                fout<<"mfc1 "<<leftExp->allotedReg<<",$f2"<<endl;
            }
            //TODO support <=,>= etc etc.
            if(rightExp->regToRestore){
                //restore right 
                fout<<"lw"<<rightExp->allotedReg<<",$sp"<<endl;
                fout<<"addi $sp,$sp,4"<<endl;
                //now leftExp stored reg on TOS
            }
            else
                r.freeUpReg(rightExp->allotedReg);
            if(leftExp->regToRestore){
                regToRestore=1;
            }
            allotedReg=leftExp->allotedReg;
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
            // fout << setw(7) << left << "lw" << setw(7) << left << "$t0, 0($sp)" << endl;
            // fout << setw(7) << left << "lw" << setw(7) << left << "$t1, 4($sp)" << endl;
            // fout << setw(7) << left << "addi" << setw(7) << left << "$sp, $sp, -8" << endl;

            // fout << setw(7) << left << "sw" << setw(7) << left << "$t1, 0($t0)" << endl;
            // fout << setw(7) << left << "addi" << setw(7) << left << "$sp, $sp, 4" << endl;
            // fout << setw(7) << left << "sw" << setw(7) << left << "$t1, 0($sp)" << endl;
            // fout << endl;
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

        void genCode(){
            fout << "NewFun" << ":" << endl;
            funName->genCode();
            for(list<ExpAst *>::iterator it=expList.begin(); it != expList.end(); it++)
            {
                (*it)->genCode();
            }
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

        void genCode(){
            Exp->genCode();
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

        void genCode(){
            for(list<StmtAst *>::iterator it = stmtList.begin(); it != stmtList.end(); it++)
            {
                (*it)->genCode();
            }
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

        void genCode(){
            IfExp->genCode();
            thenStmt->genCode();
            elseStmt->genCode();
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

        void genCode(){
            initExp->genCode();
            condExp->genCode();
            incExp->genCode();
            bodyStmt->genCode();
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

        void genCode(){
            whileExp->genCode();
            thenStmt->genCode();
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

        void genCode(){
            exp->genCode();
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
        void genCode(){
            exp->genCode();
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

        void genCode(){
            varIdent->genCode();
            exp->genCode();
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

        void genCode(){
            varIdent->genCode();
            id->genCode();
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

        void genCode(){
            varIdent->genCode();
            id->genCode();
        }
};
