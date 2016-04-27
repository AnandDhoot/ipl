struct f {
	int d;
	int x;
};
struct f an(struct f x,int z){
	struct f y;
	y.d=x.d+z;
	return y;
}
int main(struct f c[5]) {
	int x,*y;
	struct f a,b;
	b= an(a,25);
	printf(b.d);

}