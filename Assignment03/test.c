struct asfj {
	int a;
	float b[3];
	int c1;
};

int main(int a[5], int b[3]) {
	int f2, f1, *g;
	struct asfj df;
	struct asfj *rg;
	f2 = 10;
	g = &f1;
	*g = 1;
	f1 = (*g)++;
	return f1;
}