struct s {
    int a;
};
struct t {
    int a;
    int b;
};
int * f(void * a, int * b) {
    float * c;
    c = a;
    b = a;
    return a;
    return b;
}

int g() {
    struct s a, *p;
    struct t * b, **q;
    void * v;
    p = &a;
    q = &b;
    v = f(*q, &(p->a));
    q = *v;
    return (*(*q)).b;
}