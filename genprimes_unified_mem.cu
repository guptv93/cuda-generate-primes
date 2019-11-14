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
 __global__ void gen_primes(bool*, unsigned int, int);
 void gpu_gen_primes(unsigned int);
 
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
   gpu_gen_primes(N);
   end = clock();

   time_taken = ((double)(end - start))/ CLOCKS_PER_SEC;
   printf("Time taken for %s is %lf\n","GPU", time_taken);
 }

 /******************** The GPU parallel version **************/
 void  gpu_gen_primes(unsigned int N)
{
   FILE * fPtr;
   char fileName[15];
   sprintf(fileName, "%d", N);
   strcat(fileName, ".txt");
   fPtr = fopen(fileName, "w");

   int size = (N+1) * sizeof(bool);
   bool * n_series;
   cudaMallocManaged((void**) &n_series, size);
   int last_divisor = (N+1)/2;
   for(int divisor = 2; divisor < last_divisor; divisor++) {
     if(n_series[divisor]) continue;
     int num_threads = 512;
     int num_blocks = N/(divisor*num_threads) + 1;
     gen_primes<<<num_blocks, num_threads>>>(n_series, N, divisor);
     cudaDeviceSynchronize();
     cudaError_t error = cudaGetLastError();
     if(error != cudaSuccess) {
       printf("CUDA error %s \n", cudaGetErrorString(error));
       break;
     }
   }

   int i;
   for(i = 2; i < N+1; i++)
   {
     if(!n_series[i]) {
       fprintf(fPtr, "%d ", i);
     }
   }
   fprintf(fPtr, "\n");
   cudaFree(n_series);
}

 __global__
void gen_primes(bool* n_series, unsigned int N, int divisor) {
  int i = blockIdx.x*blockDim.x + threadIdx.x;
  int e = divisor*(i+2);
  if(e <= N) {
    n_series[e] = true;
  }
}