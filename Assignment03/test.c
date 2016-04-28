void f(int a[10]){
	a[5]=1;
}
void main(){
	int a[20][10];
	a[6][5]=4;
	printf(a[6][5], "\n");
	f(a[6]);
	printf(a[6][5], "\n");
}

