#include <iostream>
#include <iomanip>
#include <stdio.h>
#include <string>
#include <list>
#include <sstream>
#include <fstream>
#include <algorithm>
#include "st.h"
#include "mips.h"
using namespace std;

extern Tb globTab;
extern Tb* currTab;
extern string currIdentifier;
extern string type0, type1;
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

protected:
// virtual void setType(basic_types) = 0;
private:
// typeExp astnode_type;
} ;
class ExpAst : public abstract_astnode {
public:
    int width;
    vector<int> dimensions;
    string type;
    string name;
    string base_type;
    std::vector<int> dim;
    bool isConst = 0, isLval; int offset; // iF exp is lval , offset wrt ebp;
    string allotedReg;
    bool regToRestore = 0;
    string storeAddr;
    virtual void print (int level) {}
    virtual void genCode() {}
    virtual void getAddr() {}
};

class StmtAst : public abstract_astnode {
public:
    virtual void print (int level) {}
    virtual void genCode() {}
};

class RefAst : public ExpAst {
public:

    virtual void print (int level) {}
};

class IntConst : public ExpAst {

public:
    int x;
    IntConst(int n) {
        x = n;
        type = "int";
        isConst = 1;
        myTab = currTab;
    }

    void print(int level) {
        cout << string(level, '\t');
        cout << "(IntConst " << x << ")";
    }

    void genCode() {
        fout << "#" << x << " ---Int Constant---" << endl;
        string reg = r.getNewReg();
        string t = " , ";
        if (reg == "") {
            reg = r.getUsedReg();
            regToRestore = 1;
            //store
            fout << "addi $sp, $sp, -4" << endl;
            fout << "sw " << reg << ", 0($sp)" << endl;
            //load const
            fout << "li " << reg << t << x << endl;
            allotedReg = reg;
        }
        else {
            fout << "li " << reg << t << x << endl;
            allotedReg = reg;
        }
    }
};

class FloatConst : public ExpAst {

public:
    float x;
    FloatConst(float n) {
        x = n;
        type = "float";
        isConst = 1;
        myTab = currTab;
    }

    void print(int level) {
        cout << string(level, '\t');
        cout << "(FloatConst " << x << ")";
    }

    void genCode() {
        fout << "#" << x << " ---Float Constant---" << endl;
        string reg = r.getNewReg();
        string t = " , $0, ";
        if (reg == "") {
            reg = r.getUsedReg();
            regToRestore = 1;
            //store
            fout << "addi $sp, $sp, -4" << endl;
            fout << "sw " << reg << ", 0($sp)" << endl;
            //load const
            fout << fixed << setprecision(6) << "li.s $f1, " << x << endl;
            fout << "mfc1 " << reg << ", $f1" << endl;
            allotedReg = reg;
        }
        else {
            fout << fixed << setprecision(6) << "li.s $f1, " << x << endl;
            fout << "mfc1 " << reg << ", $f1" << endl;
            allotedReg = reg;
        }
    }
};

class StringConst : public ExpAst {

public:
    string x;
    StringConst(string n) {
        x = n;
        isConst = 1;
        myTab = currTab;
        type = "string";
    }

    void print(int level) {
        cout << string(level, '\t');
        cout << "(StringConst " << x << ")";
    }

    void genCode() {
        string l = r.genLabel();
        r.data += l + ": .asciiz " + x + "\n";
        allotedReg = l;
        regToRestore = 0;
    }
};

class Identifier : public ExpAst {

public:
    string x;
    Identifier(string n) {
        x = n;
        myTab = currTab;
    }

    void print(int level) {
        cout << string(level, '\t');
        cout << "(Id \"" << x << "\")";
    }

    void genCode() {
        symbol *s = myTab->sym[x];
        // TODO - Handle function calls
        if (s == NULL) {
            cerr << "Not present in symTab" << endl;
        }
        // cerr << myTab->name << " " << s->name << " " << s->offset << endl;
        dimensions = s->dimensions;

        string reg = r.getNewReg();
        if (reg == "") {
            reg = r.getUsedReg();
            regToRestore = 1;
            //store
            fout << "addi $sp, $sp, -4" << endl;
            fout << "sw " << reg << ", 0($sp)" << endl;
            //load const
            if (dimensions.size() > 0)
                fout << "addi " << reg << ", $fp, " << s->offset << endl;
            else
                fout << "lw " << reg << ", " << s->offset << "($fp)" << endl;
            allotedReg = reg;
        }
        else {

            if (dimensions.size() > 0)
                fout << "addi " << reg << ", $fp, " << s->offset << endl;
            else
                fout << "lw " << reg << ", " << s->offset << "($fp)" << endl;
            allotedReg = reg;
        }
    }

    void getAddr() {

        symbol *s = myTab->sym[x];
        if (s == NULL) {
            cerr << "Not present in symTab" << endl;
        }
        // cerr << myTab->name << " " << s->name << " " << s->offset << endl;

        width = 4;
        if (s->type.substr(0, 6) == "struct" && s->type[s->type.size() - 1] != '*')
        {
            symbol *s1 = globTab.sym[base_type];
            width = s1->size;
        }
        dimensions = s->dimensions;

        string reg = r.getNewReg();
        if (reg == "") {
            reg = r.getUsedReg();
            regToRestore = 1;
            //store
            fout << "addi $sp, $sp, -4" << endl;
            fout << "sw " << reg << ", 0($sp)" << endl;
            //load const
            if (s->scope == "param" && s->dimensions.size() > 0)
                fout << "lw " << reg << ", " << s->offset << "($fp)" << endl;
            else
                fout << "addi " << reg << ", $fp, " << s->offset << endl;
            allotedReg = reg;
        }
        else {
            if (s->scope == "param" && s->dimensions.size() > 0)
                fout << "lw " << reg << ", " << s->offset << "($fp)" << endl;
            else
                fout << "addi " << reg << ", $fp, " << s->offset << endl;
            allotedReg = reg;
        }
        // cerr << "-------------" << allotedReg << endl;
    }
};

class Empty : public StmtAst {
public:
    void print (int level) {
        cout << string(level, '\t');
        cout << "(Empty)";
    }

    void genCode() {

    }
};

class Return : public StmtAst {

public:
    ExpAst *retExp;
    Return(ExpAst *x) {
        retExp = x;
        myTab = currTab;
    }

    void print(int level) {
        cout << string(level, '\t');
        cout << "(Return "; retExp->print(0); cout << ")";
    }

    void genCode() {
        if (r.structChk(retExp->type)) {
            retExp->getAddr();
            fout << "addi $a1,$fp," << myTab->retOffset << endl;
            r.structCp(retExp->allotedReg, "$a1", globTab.sym[retExp->type]->size);

        }
        else {
            retExp->genCode();
            fout << "sw " << retExp->allotedReg << "," << myTab->retOffset << "($fp)\n";

        }
        r.freeUpReg(retExp->allotedReg);
    }
};

class Op1 : public ExpAst {

public:
    string operat;
    ExpAst *restExp;
    Op1(string w, ExpAst *x) {
        operat = w;
        restExp = x;
        myTab = currTab;
    }

    void print(int level) {
        cout << string(level, '\t');
        cout << "(" << operat << " " ; restExp->print(0); cout << ")";
    }

    void genCode() {
        fout << "# " << operat << " ---Unary---" << endl;
        if (operat == "TO-float") {
            restExp->genCode();
            regToRestore = restExp->regToRestore;
            allotedReg = restExp->allotedReg;
            fout << "mtc1 " << restExp->allotedReg << ",$f1" << endl;
            fout << "cvt.s.w $f1, $f1" << endl;
            fout << "mfc1 " << restExp->allotedReg << ",$f1" << endl;
        }
        else if (operat == "TO-int") {
            restExp->genCode();
            regToRestore = restExp->regToRestore;
            allotedReg = restExp->allotedReg;
            fout << "mtc1 " << restExp->allotedReg << ",$f1" << endl;
            fout << "cvt.w.s $f1, $f1" << endl;
            fout << "mfc1 " << restExp->allotedReg << ",$f1" << endl;
        }
        else if (operat == "uminus") {
            restExp->genCode();
            regToRestore = restExp->regToRestore;
            allotedReg = restExp->allotedReg;
            if (type == "float") {
                fout << "mtc1 " << restExp->allotedReg << ",$f1" << endl;
                fout << "li.s $f2,-1.0 " << endl;
                fout << "mul.s $f1,$f1,$f2 " << endl;
                fout << "mfc1 " << restExp->allotedReg << ",$f1" << endl;
            }
            if (type == "int") {
                fout << "sub " << restExp->allotedReg << ",$0," << restExp->allotedReg << endl;
            }
        }
        else if (operat == "NOT") {
            restExp->genCode();
            regToRestore = restExp->regToRestore;
            allotedReg = restExp->allotedReg;
            //TODO
            if (type == "float") {
            }
            if (type == "int") {

            }
        }
        else if (operat == "AddressOf")
        {
            restExp->getAddr();
            allotedReg = restExp->allotedReg;
            regToRestore = restExp->regToRestore;
        }
        else if (operat == "PlusPlus")
        {
            restExp->getAddr();

            string reg = r.getNewReg();
            if (reg == "") {
                reg = r.getUsedReg();
                regToRestore = 1;
                //store
                fout << "addi $sp, $sp, -4" << endl;
                fout << "sw " << reg << ", 0($sp)" << endl;
                //load const
                fout << "lw " << reg << ", 0(" << restExp->allotedReg << ")" << endl;
                fout << "addi " << reg << ", " << reg << ", 1" << endl;
                fout << "sw " << reg << ", 0(" << restExp->allotedReg << ")" << endl;
                fout << "addi " << reg << ", " << reg << ", -1" << endl;
                fout << "move " << restExp->allotedReg << ", " << reg << endl;
                //restore
                fout << "lw " << reg << ", 0($sp)" << endl;
                fout << "addi $sp, $sp, 4" << endl;
                regToRestore = 0;
            }
            else {
                fout << "lw " << reg << ", 0(" << restExp->allotedReg << ")" << endl;
                fout << "addi " << reg << ", " << reg << ", 1" << endl;
                fout << "sw " << reg << ", 0(" << restExp->allotedReg << ")" << endl;
                fout << "addi " << reg << ", " << reg << ", -1" << endl;
                fout << "move " << restExp->allotedReg << ", " << reg << endl;
                r.freeUpReg(reg);
            }

            allotedReg = restExp->allotedReg;
            regToRestore = restExp->regToRestore;
        }
    }
};

class Op2 : public ExpAst {

public:
    string operat;
    ExpAst *leftExp;
    ExpAst *rightExp;
    Op2(string w, ExpAst *x, ExpAst *y) {
        operat = w;
        leftExp = x;
        rightExp = y;
        myTab = currTab;
    }
    void print(int level) {
        cout << string(level, '\t');
        cout << "(" << operat << " " ; leftExp->print(0); rightExp->print(0); cout << ")";
    }
    void genCode() {

             if (operat == "AND") {
                leftExp->genCode();
                string l1 = r.genLabel();
                string l2 = r.genLabel();
                if (leftExp->type == "float")
                    fout << "sll " << leftExp->allotedReg << "," << leftExp->allotedReg << ",1" << endl;
                fout << "beqz " << leftExp->allotedReg << "," << l1 << endl;
                rightExp->genCode();
                if (rightExp->type == "float")
                    fout << "sll " << rightExp->allotedReg << "," << rightExp->allotedReg << ",1" << endl;
                fout << "beqz " << rightExp->allotedReg << "," << l1 << endl;
                fout << "li " << leftExp->allotedReg << ", 1\n";
                fout << "j " << l2 << endl;
                fout << l1 << ":\n";
                fout << "li " << leftExp->allotedReg << ", 0\n";
                fout << l2 << ":\n";
                 if (rightExp->regToRestore) {
                    //restore right
                    fout << "lw " << rightExp->allotedReg << ", 0($sp)" << endl;
                    fout << "addi $sp, $sp, 4" << endl;
                    //now leftExp stored reg on TOS
                }
                else
                    r.freeUpReg(rightExp->allotedReg);
                if (leftExp->regToRestore) {
                    regToRestore = 1;
                }
                allotedReg = leftExp->allotedReg;
                return;

            }
            else if (operat == "OR") {
                leftExp->genCode();
                string l1 = r.genLabel();
                string l2 = r.genLabel();
                if (leftExp->type == "float")
                    fout << "sll " << leftExp->allotedReg << "," << leftExp->allotedReg << ",1" << endl;
                fout << "bnez " << leftExp->allotedReg << "," << l1 << endl;
                rightExp->genCode();
                if (rightExp->type == "float")
                    fout << "sll " << rightExp->allotedReg << "," << rightExp->allotedReg << ",1" << endl;
                fout << "bnez " << rightExp->allotedReg << "," << l1 << endl;
                fout << "li " << leftExp->allotedReg << ", 0\n";
                fout << "j " << l2 << endl;
                fout << l1 << ":\n";
                fout << "li " << leftExp->allotedReg << ", 1\n";
                fout << l2 << ":\n";
                 if (rightExp->regToRestore) {
                    //restore right
                    fout << "lw " << rightExp->allotedReg << ", 0($sp)" << endl;
                    fout << "addi $sp, $sp, 4" << endl;
                    //now leftExp stored reg on TOS
                }
                else
                    r.freeUpReg(rightExp->allotedReg);
                if (leftExp->regToRestore) {
                    regToRestore = 1;
                }
                allotedReg = leftExp->allotedReg;
                return;
            }



        leftExp->genCode();
        rightExp->genCode();

        //TODO - ADD EQ,NE
        if (operat == "Plus-INT")
            fout << "add " << leftExp->allotedReg << "," << rightExp->allotedReg << ", " << leftExp->allotedReg << endl;
        else if (operat == "Minus-INT") {
            fout << "sub " << leftExp->allotedReg << "," << leftExp->allotedReg << ", " << rightExp->allotedReg << endl;
        }
        else if (operat == "Multiply-INT") {
            fout << "mul " << leftExp->allotedReg << "," << leftExp->allotedReg << "," << rightExp->allotedReg << endl;
        }
        else if (operat == "Divide-INT") {
            fout << "div " << leftExp->allotedReg << "," << leftExp->allotedReg << "," << rightExp->allotedReg << endl;
        }
        else if (operat == "LT-INT") {
            fout << "slt " << leftExp->allotedReg << "," << leftExp->allotedReg << "," << rightExp->allotedReg << endl;
        }
        else if (operat == "LE-INT") {
            fout << "slt " << leftExp->allotedReg << "," << rightExp->allotedReg << "," << leftExp->allotedReg << endl;
            fout << "li $a0, 1" << endl;
            fout << "sub " << leftExp->allotedReg << ", $a0, " << leftExp->allotedReg << endl;
        }
        else if (operat == "GT-INT") {
            fout << "slt " << leftExp->allotedReg << "," << rightExp->allotedReg << "," << leftExp->allotedReg << endl;
        }
        else if (operat == "GE-INT") {
            fout << "slt " << leftExp->allotedReg << "," << leftExp->allotedReg << "," << rightExp->allotedReg << endl;
            fout << "li $a0, 1" << endl;
            fout << "sub " << leftExp->allotedReg << ", $a0, " << leftExp->allotedReg << endl;
        }

        else if (operat == "EQ") {
            string l1 = r.genLabel();
            string l2 = r.genLabel();
            fout << "beq " << leftExp->allotedReg << "," << rightExp->allotedReg << "," << l1 << endl;
            fout << "li " << leftExp->allotedReg << ", 0\n";
            fout << "j " << l2 << endl;
            fout << l1 << ":\n";
            fout << "li " << leftExp->allotedReg << ", 1\n";
            fout << l2 << ":\n";

        }
        else if (operat == "NE") {
            string l1 = r.genLabel();
            string l2 = r.genLabel();
            fout << "bne " << leftExp->allotedReg << "," << rightExp->allotedReg << "," << l1 << endl;
            fout << "li " << leftExp->allotedReg << ", 0\n";
            fout << "j " << l2 << endl;
            fout << l1 << ":\n";
            fout << "li " << leftExp->allotedReg << ", 1\n";
            fout << l2 << ":\n";

        }
        else if (operat == "Plus-FLOAT") {

            fout << "mtc1 " << leftExp->allotedReg << ",$f1" << endl;
            fout << "mtc1 " << rightExp->allotedReg << ",$f2" << endl;
            fout << "add.s $f2,$f1,$f2" << endl;
            fout << "mfc1 " << leftExp->allotedReg << ",$f2" << endl;
        }
        else if (operat == "Minus-FLOAT") {

            fout << "mtc1 " << leftExp->allotedReg << ",$f1" << endl;
            fout << "mtc1 " << rightExp->allotedReg << ",$f2" << endl;
            fout << "sub.s $f2,$f1,$f2" << endl;
            fout << "mfc1 " << leftExp->allotedReg << ",$f2" << endl;
        }
        else if (operat == "Multiply-FLOAT") {

            fout << "mtc1 " << leftExp->allotedReg << ",$f1" << endl;
            fout << "mtc1 " << rightExp->allotedReg << ",$f2" << endl;
            fout << "mul.s $f2,$f1,$f2" << endl;
            fout << "mfc1 " << leftExp->allotedReg << ",$f2" << endl;
        }
        else if (operat == "Divide-FLOAT") {

            fout << "mtc1 " << leftExp->allotedReg << ",$f1" << endl;
            fout << "mtc1 " << rightExp->allotedReg << ",$f2" << endl;
            fout << "div.s $f2,$f1,$f2" << endl;
            fout << "mfc1 " << leftExp->allotedReg << ",$f2" << endl;
        }
        else if (operat == "LT-FLOAT") {
            fout << "mtc1 " << leftExp->allotedReg << ",$f1" << endl;
            fout << "mtc1 " << rightExp->allotedReg << ",$f2" << endl;
            fout << "c.lt.s $f1,$f2" << endl;
            string l=r.genLabel();
            string l2=r.genLabel();
            fout << "bc1f " << l << endl;
            fout << "li " << leftExp->allotedReg << ",1" << endl;
            fout << "j "<<l2<<endl;
            fout<<l<<":\n";
            fout << "li " << leftExp->allotedReg << ",0" << endl;
            fout<<l2<<":\n";

        }
        else if (operat == "LE-FLOAT") {
            fout << "mtc1 " << leftExp->allotedReg << ",$f1" << endl;
            fout << "mtc1 " << rightExp->allotedReg << ",$f2" << endl;
            fout << "c.le.s $f1,$f2" << endl;
            string l=r.genLabel();
            string l2=r.genLabel();
            fout << "bc1f " << l << endl;
            fout << "li " << leftExp->allotedReg << ",1" << endl;
            fout << "j "<<l2<<endl;
            fout<<l<<":\n";
            fout << "li " << leftExp->allotedReg << ",0" << endl;
            fout<<l2<<":\n";
        }
        else if (operat == "GT-FLOAT") {
            fout << "mtc1 " << leftExp->allotedReg << ",$f1" << endl;
            fout << "mtc1 " << rightExp->allotedReg << ",$f2" << endl;
            fout << "c.lt.s $f2,$f1" << endl;
            string l=r.genLabel();
            string l2=r.genLabel();
            fout << "bc1f " << l << endl;
            fout << "li " << leftExp->allotedReg << ",1" << endl;
            fout << "j "<<l2<<endl;
            fout<<l<<":\n";
            fout << "li " << leftExp->allotedReg << ",0" << endl;
            fout<<l2<<":\n";
        }
        else if (operat == "GE-FLOAT") {
            fout << "mtc1 " << leftExp->allotedReg << ",$f1" << endl;
            fout << "mtc1 " << rightExp->allotedReg << ",$f2" << endl;
            fout << "c.le.s $f2,$f1" << endl;
            string l=r.genLabel();
            string l2=r.genLabel();
            fout << "bc1f " << l << endl;
            fout << "li " << leftExp->allotedReg << ",1" << endl;
            fout << "j "<<l2<<endl;
            fout<<l<<":\n";
            fout << "li " << leftExp->allotedReg << ",0" << endl;
            fout<<l2<<":\n";
        }
        if (rightExp->regToRestore) {
            //restore right
            fout << "lw " << rightExp->allotedReg << ", 0($sp)" << endl;
            fout << "addi $sp, $sp, 4" << endl;
            //now leftExp stored reg on TOS
        }
        else
            r.freeUpReg(rightExp->allotedReg);
        if (leftExp->regToRestore) {
            regToRestore = 1;
        }
        allotedReg = leftExp->allotedReg;
    }
};

class Assign : public ExpAst {

public:
    ExpAst *lExp;
    ExpAst *rightExp;
    Assign(ExpAst *x, ExpAst *y) {
        lExp = x;
        rightExp = y;
        myTab = currTab;
    }

    void print(int level) {
        cout << string(level, '\t');
        cout << "(Assign "; lExp->print(0); rightExp->print(0); cout << ")";
    }
    void getAddr() {
        genCode();
    }
    void genCode() {
        if (r.structChk(lExp->type)) {
            rightExp->getAddr();
            lExp->getAddr();
            r.structCp(rightExp->allotedReg, lExp->allotedReg, globTab.sym[lExp->type]->size);
            if (lExp->regToRestore) {
                //restore left
                fout << "lw " << lExp->allotedReg << ", 0($sp)" << endl;
                fout << "addi $sp, $sp, 4" << endl;
                //now rightExp stored reg on TOS
            }
            else
                r.freeUpReg(lExp->allotedReg);
            regToRestore = rightExp->regToRestore;
            allotedReg = rightExp->allotedReg;

        }
        else {
            rightExp->genCode();
            lExp->getAddr();
            fout << "sw " << rightExp->allotedReg << ", 0(" << lExp->allotedReg << ")" << endl;

            if (lExp->regToRestore) {
                //restore left
                fout << "lw " << lExp->allotedReg << ", 0($sp)" << endl;
                fout << "addi $sp, $sp, 4" << endl;
                //now rightExp stored reg on TOS
            }
            else
                r.freeUpReg(lExp->allotedReg);
            regToRestore = rightExp->regToRestore;
            allotedReg = rightExp->allotedReg;
        }
    }
};

class Funcall : public ExpAst {

public:
    Identifier* funName;
    list<ExpAst *> expList;
    Funcall(Identifier *w, list<ExpAst *> x) {
        funName = w;
        expList = x;
        myTab = currTab;
    }
    Funcall(Identifier *w, list<ExpAst *>* x) {
        funName = w;
        expList = *x;
        myTab = currTab;
    }

    void print(int level) {
        cout << string(level, '\t');
        cout << "(Funcall " << endl;
        for (list<ExpAst *>::iterator it = expList.begin(); it != expList.end(); it++)
        {
            (*it)->print(level + 1);
            cout << endl;
        }
        cout << string(level, '\t');
        cout << ")";
    }

    void genCode() {
        if (funName->x == "printf") {

            for (list<ExpAst *>::iterator it = expList.begin(); it != expList.end(); it++)
            {
                (*it)->genCode();
                if ((*it)->type == "string") {
                    fout << "li $v0, 4\n";
                    fout << "la $a0," << (*it)->allotedReg << endl;
                    fout << "syscall\n";
                }
                else if ((*it)->type == "float") {
                    fout << "li $v0, 2\n";
                    fout << "mtc1 " << (*it)->allotedReg << ",$f12" << endl;
                    fout << "syscall\n";
                }
                else {
                    fout << "li $v0, 1\n";
                    fout << "or $a0,$0," << (*it)->allotedReg << endl;
                    fout << "syscall\n";
                    if ((*it)->regToRestore) {
                        //restore right
                        fout << "lw " << (*it)->allotedReg << ", 0($sp)" << endl;
                        fout << "addi $sp, $sp, 4" << endl;
                    }
                    else if ((*it)->type != "string")
                        r.freeUpReg((*it)->allotedReg);
                }
            }

        }
        else {
            //push usedReg to stack
            int i = -4;
            list<string> restoreReg;
            fout << "addi $sp,$sp," << -4 * (int)r.usedReg.size() << endl;
            string reg = r.storeReg();

            while (reg != "") {
                i += 4;
                fout << "sw " << reg << "," << i << "($sp)" << endl;
                r.freeReg.push_back(reg);
                restoreReg.push_front(reg);
                reg = r.storeReg();
            }
            //make space for retval
            fout << "addi $sp,$sp," << -globTab.sym[funName->x]->size << endl;
            //push params
            int paramSize = 0;
            for (list<ExpAst *>::iterator it = expList.begin(); it != expList.end(); it++)
            {
                //handle structs /arrays
                if (r.structChk((*it)->type)) {
                    fout << "addi $sp,$sp," << -1 * globTab.sym[(*it)->type]->size << endl;
                    (*it)->getAddr();
                    r.structCp((*it)->allotedReg, "$sp", globTab.sym[(*it)->type]->size);
                    paramSize += globTab.sym[(*it)->type]->size;
                }
                else {
                    (*it)->genCode();
                    fout << "addi $sp,$sp,-4\n";
                    fout << "sw " << (*it)->allotedReg << " ,0($sp)\n";
                    if ((*it)->regToRestore) {
                        fout << "lw " << (*it)->allotedReg << ", 0($sp)" << endl;
                        fout << "addi $sp, $sp, 4" << endl;
                    }
                    else if ((*it)->type != "string")
                        r.freeUpReg((*it)->allotedReg);

                    paramSize += 4;
                }
            }
            //call fxn
            fout << "jal " << "Fxn" + funName->x << endl;
            //free up param space
            fout << "addi $sp,$sp," << paramSize << endl;
            //restore usedReg
            while (restoreReg.size() > 0) {
                reg = restoreReg.front();
                restoreReg.pop_front();
                fout << "lw " << reg << "," << i + globTab.sym[funName->x]->size << "($sp)" << endl;
                r.usedReg.push_back(reg);
                r.freeReg.remove(reg);
                i -= 4;
            }
            //load retVal TODO handle structs will be pain

            reg = r.getNewReg();
            if (reg == "") {
                regToRestore = 1;
                //store
                fout << "lw $a0" << ",0($sp)" << endl;
                fout << "addi $sp,$sp," << r.usedReg.size() * 4 + globTab.sym[funName->x]->size << endl;
                reg = r.getUsedReg();
                fout << "addi $sp, $sp, -4" << endl;
                fout << "sw " << reg << ", 0($sp)" << endl;
                fout << "add " << reg << ",$a0,$0" << endl;
                //load const
                allotedReg = reg;
            }
            else {
                fout << "lw " << reg << ",0($sp)" << endl;
                allotedReg = reg;
                fout << "addi $sp,$sp," << r.usedReg.size() * 4 + globTab.sym[funName->x]->size - 4 << endl;
            }

        }
    }
    void getAddr() {
        //push usedReg to stack
        int i = -4;
        list<string> restoreReg;
        fout << "addi $sp,$sp," << -4 * (int)r.usedReg.size() << endl;
        string reg = r.storeReg();

        while (reg != "") {
            i += 4;
            fout << "sw " << reg << "," << i << "($sp)" << endl;
            r.freeReg.push_back(reg);
            restoreReg.push_front(reg);
            reg = r.storeReg();
        }
        //make space for retval
        fout << "addi $sp,$sp," << -globTab.sym[funName->x]->size << endl;
        //push params
        int paramSize = 0;
        for (list<ExpAst *>::iterator it = expList.begin(); it != expList.end(); it++)
        {
            //handle structs /arrays
            if (r.structChk((*it)->type)) {
                fout << "addi $sp,$sp," << -1 * globTab.sym[(*it)->type]->size << endl;
                (*it)->getAddr();
                r.structCp((*it)->allotedReg, "$sp", globTab.sym[(*it)->type]->size);
                paramSize += globTab.sym[(*it)->type]->size;
            }
            else {
                (*it)->genCode();
                fout << "addi $sp,$sp,-4\n";
                fout << "sw " << (*it)->allotedReg << " ,0($sp)\n";
                if ((*it)->regToRestore) {
                    fout << "lw " << (*it)->allotedReg << ", 0($sp)" << endl;
                    fout << "addi $sp, $sp, 4" << endl;
                }
                else if ((*it)->type != "string")
                    r.freeUpReg((*it)->allotedReg);

                paramSize += 4;
            }
        }
        //call fxn
        fout << "jal " << "Fxn" + funName->x << endl;
        //free up param space
        fout << "addi $sp,$sp," << paramSize << endl;
        //restore usedReg
        while (restoreReg.size() > 0) {
            reg = restoreReg.front();
            restoreReg.pop_front();
            fout << "lw " << reg << "," << i + globTab.sym[funName->x]->size << "($sp)" << endl;
            r.usedReg.push_back(reg);
            r.freeReg.remove(reg);
            i -= 4;
        }
        //load retVal TODO handle structs will be pain

        reg = r.getNewReg();
        if (reg == "") {
            regToRestore = 1;
            //store
            fout << "addi $a0,$sp,0" << endl;
            fout << "addi $sp,$sp," << r.usedReg.size() * 4 + globTab.sym[funName->x]->size << endl;
            reg = r.getUsedReg();
            fout << "addi $sp, $sp, -4" << endl;
            fout << "sw " << reg << ", 0($sp)" << endl;
            fout << "add " << reg << ",$a0,$0" << endl;
            //load const
            allotedReg = reg;
        }
        else {
            fout << "addi " << reg << ",$sp,0" << endl;
            allotedReg = reg;
            fout << "addi $sp,$sp," << r.usedReg.size() * 4 + globTab.sym[funName->x]->size - 4 << endl;
        }

    }
};

class Ass : public StmtAst {

public:
    ExpAst *Exp;
    Ass(ExpAst *x) {
        Exp = x;
    }

    void print(int level) {
        cout << std::string(level, '\t');
        cout << "(Assign_exp \n" ; Exp->print(level + 1); cout << ")";
    }

    void genCode() {
        Exp->genCode();
    }
};

class Seq : public StmtAst {

public:
    list<StmtAst *> stmtList;
    Seq(list<StmtAst *> x) {
        stmtList = x;
        myTab = currTab;
    }
    Seq(list<StmtAst *>* x) {
        stmtList = *x;
        myTab = currTab;
    }

    void print(int level) {
        cout << string(level, '\t');
        cout << "(Seq " << myTab->name << endl;
        for (list<StmtAst *>::iterator it = stmtList.begin(); it != stmtList.end(); it++)
        {
            (*it)->print(level + 1);
            cout << endl;
        }
        cout << string(level, '\t');
        cout << ")";
    }

    void genCode() {
        for (list<StmtAst *>::iterator it = stmtList.begin(); it != stmtList.end(); it++)
        {
            (*it)->genCode();
            while (true)
            {
                string reg = r.getUsedReg();
                if (reg == "") break;
                r.freeUpReg(reg);
            }
        }
    }
};

class If : public StmtAst {

public:
    ExpAst *IfExp;
    StmtAst *thenStmt;
    StmtAst *elseStmt;
    If(ExpAst *x, StmtAst *y, StmtAst *z) {
        IfExp = x;
        thenStmt = y;
        elseStmt = z;
        myTab = currTab;
    }

    void print(int level) {
        cout << string(level, '\t');
        cout << "(If " << endl;
        IfExp->print(level + 1);
        cout << endl;
        thenStmt->print(level + 1);
        cout << endl;
        elseStmt->print(level + 1);
        cout << endl;
        cout << string(level, '\t');
        cout << ")";
    }

    void genCode() {
        string l1 = r.genLabel();
        string l2 = r.genLabel();
        IfExp->genCode();
        //TODO chk if works with ptrs
        if (IfExp->type != "float")
            fout << "beq $0," << IfExp->allotedReg << " " << l1 << endl;
        else {
            fout << "mtc1 " << IfExp->allotedReg << ",$f1\n";
            fout << "li.s $f2,0.0\n";
            fout << "c.eq.s $f1,$f2\n";
            fout << "bc1f " << l1 << endl;
        }
        thenStmt->genCode();
        fout << "j " << l2 << endl;
        fout << l1 << ":\n";
        elseStmt->genCode();
        fout << l2 << ":\n";
    }
};

class For : public StmtAst {

public:
    ExpAst *initExp;
    ExpAst *condExp;
    ExpAst *incExp;
    StmtAst *bodyStmt;
    For(ExpAst *w, ExpAst *x, ExpAst *y, StmtAst *z) {
        initExp = w;
        condExp = x;
        incExp = y;
        bodyStmt = z;
        myTab = currTab;
    }

    void print(int level) {
        cout << string(level, '\t');
        cout << "(For " << endl;
        initExp->print(level + 1);
        cout << endl;
        condExp->print(level + 1);
        cout << endl;
        incExp->print(level + 1);
        cout << endl;
        bodyStmt->print(level + 1);
        cout << endl;
        cout << string(level, '\t');
        cout << ")" << endl;
    }

    void genCode() {
        string l1 = r.genLabel();
        string l2 = r.genLabel();
        initExp->genCode();
        fout << l1 << ":\n";
        condExp->genCode();
        if (condExp->type != "float")
            fout << "beq $0," << condExp->allotedReg << " " << l2 << endl;
        else {
            fout << "mtc1 " << condExp->allotedReg << ",$f1\n";
            fout << "li.s $f2,0.0\n";
            fout << "c.eq.s $f1,$f2\n";
            fout << "bc1f " << l1 << endl;
        }
        bodyStmt->genCode();
        incExp->genCode();
        fout << "j " << l1 << endl;
        fout << l2 << ":\n";
    }
};

class While : public StmtAst {

public:
    ExpAst *whileExp;
    StmtAst *thenStmt;
    While(ExpAst *x, StmtAst *y) {
        whileExp = x;
        thenStmt = y;
        myTab = currTab;
    }

    void print(int level) {
        cout << string(level, '\t');
        cout << "(While " << endl; whileExp->print(level + 1); cout << endl; thenStmt->print(level + 1); cout << endl;
        cout << string(level, '\t'); cout << ")" << endl;
    }

    void genCode() {
        string l1 = r.genLabel();
        string l2 = r.genLabel();
        fout << l1 << ":\n";
        whileExp->genCode();
        if (whileExp->type != "float")
            fout << "beq $0," << whileExp->allotedReg << " " << l2 << endl;
        else {
            fout << "mtc1 " << whileExp->allotedReg << ",$f1\n";
            fout << "li.s $f2,0.0\n";
            fout << "c.eq.s $f1,$f2\n";
            fout << "bc1f " << l1 << endl;
        }
        thenStmt->genCode();
        fout << "j " << l1 << endl;
        fout << l2 << ":\n";

    }
};

class Deref : public ExpAst {

public:
    ExpAst *exp;
    Deref(ExpAst *x) {
        exp = x;
        myTab = currTab;
    }

    void print(int level) {
        cout << string(level, '\t');
        cout << "(Deref "; exp->print(0); cout << ")";
    }
    void genCode() {
        exp->genCode();
        fout << "lw " << exp->allotedReg << ", 0(" << exp->allotedReg << ")" << endl;
        allotedReg = exp->allotedReg;
        regToRestore = exp->regToRestore;
    }
    void getAddr() {
        exp->genCode();
        // fout << "lw " << exp->allotedReg << ", 0(" << exp->allotedReg << ")"<<endl;
        allotedReg = exp->allotedReg;
        regToRestore = exp->regToRestore;
    }
};
    
class ArrayRef : public ExpAst {

public:
    ExpAst *varIdent;
    ExpAst *exp;
    ArrayRef(ExpAst *x, ExpAst *y) {
        varIdent = x;
        exp = y;
        myTab = currTab;
    }

    void print(int level) {
        cout << string(level, '\t');
        cout << "(ArrayRef " ;
        varIdent->print(0);
        exp->print(0);
        cout << ")";
    }

    void genCode() {

        getAddr();
        if (dimensions.size() > 0)      // To handle arrays in functions
            return;

        fout << "lw " << allotedReg << ", 0(" << allotedReg << ")" << endl;

    }

    void getAddr() {
        varIdent->getAddr();
        exp->genCode();

        width = varIdent->width;
        dimensions = varIdent->dimensions;
        if(dimensions.size() > 0)
            dimensions.erase(dimensions.begin());
        else
            fout << "lw " << varIdent->allotedReg << ", 0(" << varIdent->allotedReg << ")" << endl;

        int offst = varIdent->width;
        for (int i = 1; i < varIdent->dimensions.size(); i++)
            offst *= varIdent->dimensions[i];

        fout << "li $a0, " << offst << endl;
        fout << "mul " << exp->allotedReg << ", " << exp->allotedReg << ", $a0" << endl;

        fout << "add " << varIdent->allotedReg << ", " << varIdent->allotedReg << ", " << exp->allotedReg << endl;
        allotedReg = varIdent->allotedReg;
        regToRestore = varIdent->regToRestore;

        if (exp->regToRestore) {
            //restore
            fout << "lw " << exp->allotedReg << ", 0($sp)" << endl;
            fout << "addi $sp, $sp, 4" << endl;
        }
        else
            r.freeUpReg(exp->allotedReg);
        
    }
};

class Member : public ExpAst {

public:
    ExpAst *varIdent;
    Identifier *id;
    Member(ExpAst *x, Identifier *y) {
        varIdent = x;
        id = y;
        myTab = currTab;
    }

    void print(int level) {
        cout << string(level, '\t');
        cout << "(Member " ;
        varIdent->print(0);
        id->print(0);
        cout << ")";
    }

    void genCode() {
        varIdent->getAddr();
        Tb* someTab = globTab.sym[varIdent->type]->symtab;
        symbol *s = someTab->sym[id->x];
        if (s->offset != 0)
            fout << "addi " << varIdent->allotedReg << ", " << varIdent->allotedReg
                 << ", " << s->offset << endl;
        
        width = 4;
        if (s->type.substr(0, 6) == "struct"  && s->type[s->type.size() - 1] != '*')
        {
            symbol *s1 = globTab.sym[base_type];
            width = s1->size;
        }
        dimensions = s->dimensions;

        if (dimensions.size() == 0)
            fout << "lw " << varIdent->allotedReg << ", 0(" << varIdent->allotedReg << ")" << endl;

        allotedReg = varIdent->allotedReg;
        regToRestore = varIdent->regToRestore;
    }

    void getAddr() {
        varIdent->getAddr();
        // cerr << varIdent->type << endl;
        Tb* someTab = globTab.sym[varIdent->type]->symtab;
        symbol *s = someTab->sym[id->x];
        if (s->offset != 0)
            fout << "addi " << varIdent->allotedReg << ", " << varIdent->allotedReg
                 << ", " << s->offset << endl;

        width = 4;
        if (s->type.substr(0, 6) == "struct"  && s->type[s->type.size() - 1] != '*')
        {
            symbol *s1 = globTab.sym[base_type];
            width = s1->size;
        }
        dimensions = s->dimensions;

        allotedReg = varIdent->allotedReg;
        regToRestore = varIdent->regToRestore;
    }
};

class Arrow : public ExpAst {

public:
    ExpAst *varIdent;
    Identifier *id;
    Arrow(ExpAst *x, Identifier *y) {
        varIdent = x;
        id = y;
        myTab = currTab;
    }

    void print(int level) {
        cout << string(level, '\t');
        cout << "(Arrow " ;
        varIdent->print(0);
        id->print(0);
        cout << ")";
    }

    void genCode() {
        varIdent->genCode();

        string typ = (varIdent->type).substr(0, (varIdent->type).size() - 1);
        Tb* someTab = globTab.sym[typ]->symtab;
        symbol *s = someTab->sym[id->x];
        if (s->offset != 0)
            fout << "addi " << varIdent->allotedReg << ", " << varIdent->allotedReg
                 << ", " << s->offset << endl;
        
        width = 4;
        if (s->type.substr(0, 6) == "struct" && s->type[s->type.size() - 1] != '*')
        {
            symbol *s1 = globTab.sym[base_type];
            width = s1->size;
        }
        dimensions = s->dimensions;

        if (dimensions.size() == 0)
            fout << "lw " << varIdent->allotedReg << ", 0(" << varIdent->allotedReg << ")" << endl;

        allotedReg = varIdent->allotedReg;
        regToRestore = varIdent->regToRestore;
    }

    void getAddr() {
        varIdent->genCode();

        string typ = (varIdent->type).substr(0, (varIdent->type).size() - 1);
        Tb* someTab = globTab.sym[typ]->symtab;
        symbol *s = someTab->sym[id->x];
        if (s->offset != 0)
            fout << "addi " << varIdent->allotedReg << ", " << varIdent->allotedReg
                 << ", " << s->offset << endl;

        width = 4;
        if (s->type.substr(0, 6) == "struct" && s->type[s->type.size() - 1] != '*')
        {
            symbol *s1 = globTab.sym[base_type];
            width = s1->size;
        }
        dimensions = s->dimensions;

        allotedReg = varIdent->allotedReg;
        regToRestore = varIdent->regToRestore;
    }
};
