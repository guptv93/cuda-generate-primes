/* 
 *  Last name: Gupta  
 *  First name: Vaibhav
 *  Net ID: vvg239
 * 
 */

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <time.h> 

void seq_gen_primes(int);

int main(int argc, char * argv[])
{
  int N;
  // to measure time taken by a specific part of the code 
  double time_taken;
  clock_t start, end;
  if(argc == 2) 
  {
    N = atoi(argv[1]);
  }
  else
  {
    printf("Please give a value for N\n");
  }

  start = clock();
  seq_gen_primes(N);
  end = clock();
   
   time_taken = ((double)(end - start))/ CLOCKS_PER_SEC;
   printf("Time taken for %s is %lf\n","CPU", time_taken);
}


/*****************  The CPU sequential version **************/
void seq_gen_primes(int N)
{
  bool * all;
  int i,j;
  FILE * fPtr;
  char *fileName = malloc(15);
  sprintf(fileName, "%d", N);
  strcat(fileName, ".txt");
  fPtr = fopen(fileName, "w");
  all = (bool *)calloc(N+1, sizeof(bool));
  for(i = 2; i < (N+1)/2 + 1; i++) 
  {
    for(j = 2*i; j < N+1; j = j+i)
    {
      all[j] = true;
    }
  }
  for(i = 2; i < N+1; i++)
  {
    if(!all[i]) {
      fprintf(fPtr, "%d ", i);
    }
  }
  fprintf(fPtr, "\n");
}