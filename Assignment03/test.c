struct asfj {
	int a;
	float b[3];
	int c1;
};

int main(int a[5], int b[3]) {
	int f1, g;
	struct asfj df;
	struct asfj *rg;
	df.c1 = 1;
	rg = &df;
	rg->c1 = f1;
	return f1;
}