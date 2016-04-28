struct temp1 {
	int a[2];
};
struct temp {
	int x;
	int y[4];
	struct temp1 z[2];
};
int main() {
	int a[5];
	int b[5][12];
	struct temp f1;
	struct temp1 f2[4];
	struct temp1 f3;
	a[1] = 110;
	b[3][2] = a[1];
	printf(b[3][2], "\n");
}