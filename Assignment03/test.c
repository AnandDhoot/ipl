
int main(int a[5], int b[3]) {
	int f1, *g;
	g=&f1;
	f1=23;
	f1 = 1 + f1;
	printf(*g,"\n");

}