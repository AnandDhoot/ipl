

float F(float x, float y){
  return (1+ (y/x));
}

void main()
{
  float y0,x0,y1,n,h,f,f1,k1,k2;
  int j;
  
  x0 = 1;
  y0 = 2;
  h = 0.25;
  n = 2;

  for(x0 = 1; n>x0; x0=x0+h)
  {
    f=F(x0,y0);
    k1 = h * f;
    f1 = F(x0+h,y0+k1);
    k2 = h * f1;
    y1 = y0 + ( k1 + k2)/2;
    printf("k1:",k1, "\n");
    printf("k2:",k2, "\n");
    printf("xn:",x0+h," yn:",y1,"\n");
    y0=y1;
  }
}
