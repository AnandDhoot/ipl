int** main1(float *a[3][4], int **b, float c)
{
	int x1[10];
	float y2;
	float **z1;
	void *a11;
	void **b1;

	x1[2] = x1[1] + **z1;

	a11 = *b1;
	b1 = &a11;
}
struct main
{
	float x1;
	int* x2;
	float **dd3;
};
int main2(int **a1, struct main b[3][4], float c)
{
	float x11[3];
	float y2,y3;
	float **z1;

	x11[0] =  (y2 + c);
	return **a1;
}

struct hello {
        int a;
        float b;
};

int main7() {
        int b;
        int a;
        struct hello k;  

        a = k;

        return 0;
}