int main() {
   int num, rem, rev, temp;
 
   rev = 0;
   num = 234154;
 
   while (num >= 1) {
	  temp = num/10;
      rem = num - temp*10;
      rev = rev * 10 + rem;
      num = num / 10;
   }
 
   printf("Reversed Number : ", rev, "\n");
   return (0);
}
