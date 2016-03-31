#include<stdio.h>
int arr[10];      //To see the data layout
int* p = &arr[0]; //To see the data layout
int main ()
{
  int i=5, fact = 1;
  while (i>0)
    {
      fact = i * fact;
      i = i - 1;
    }
  printf("%d \n", fact);
  return 0;
}    
