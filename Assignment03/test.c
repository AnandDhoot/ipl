struct f {
	int d;
};
int f(int x){
	return x+1;
}
int main(struct f c[5], int b[3]) {
	int x,*y;
	struct f a;
	a.d=1;
	printf(a.d);
}