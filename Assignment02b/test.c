struct s {
    int a;
    float b;
};

int * f(void * a, int * b) {
    float * c;
    int t[4];
    t["cool"]=1;
    c = a;
    b=(b);
    b = a;
    return a;
    return b;
}
struct t {
    int a;
    int b;
    float d;
};
struct jil {
    int a;
    int b;
    float d;
};
int g() {
    struct s a, *p;
    struct t * b, **q;
    void * v;
    int ti[1];
    p = &a;
    q = &b;
    v = f(*q, &(p->a));
    (*&ti)[0]=1;
    return (*(*q)).b;
}