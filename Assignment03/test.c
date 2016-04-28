struct temp1 {
	int a[2];
};
struct temp {
	int x;
	int y[4];
	struct temp1 z[2];
};
struct temp** f(struct temp x[5][12]){

	return x;
}
int main() {
	int a[5];
	struct temp b[5][12];
	float fed;
	a[1] = 110;
	b[1][2].x = a[1];
	fed=1.2;
	printf(fed);

}