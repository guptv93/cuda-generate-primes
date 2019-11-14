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
 __global__ void remove_for_divisor(bool*, unsigned int, int);
 __global__ void remove_all(bool*, unsigned int, unsigned int);
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
   //File Stream Initialization
   FILE * fPtr;
   char fileName[15];
   sprintf(fileName, "%d", N);
   strcat(fileName, ".txt");
   fPtr = fopen(fileName, "w");
   
   double time_taken;
   clock_t start, end;
   start = clock();
   //CUDA Memory Allocation
   int size = (N+1) * sizeof(bool);
   bool * d_primes;
   cudaMalloc(&d_primes, size);

   //Configuring CUDA Kernels
   unsigned int last_divisor = sqrt(N);
   int num_threads = 1024;
   int num_blocks = last_divisor/(num_threads) + 1;
   int num_threads_for_two = 1024;
   int num_blocks_for_two = N/(num_threads_for_two*2) + 1;

   //Call kernels in Streams
   cudaStream_t stream[4]; 
   int ds[4] = {2,3,5,7};
   for (int i = 0; i < 4; i++) {
    cudaStreamCreate(&stream[i]); 
    remove_for_divisor<<<N/(num_threads_for_two*ds[i]) + 1, num_threads_for_two,0,stream[i]>>>(d_primes, N, ds[i]);
   }
   remove_all<<<num_blocks, num_threads, 0, stream[0]>>>(d_primes, N, last_divisor);
   cudaDeviceSynchronize();
   cudaError_t error = cudaGetLastError();
   if(error != cudaSuccess) {
     printf("CUDA error %s \n", cudaGetErrorString(error));
   }
   end = clock();
   time_taken = ((double)(end - start))/ CLOCKS_PER_SEC;
   printf("Time taken without print statements for %s is %lf\n","GPU", time_taken);

   //Copy CUDA Memory and Print in File
   bool * primes;
   primes = (bool *)calloc(N, sizeof(bool));
   cudaMemcpy(primes, d_primes, size, cudaMemcpyDeviceToHost);
   cudaFree(d_primes);
   int i;
   for(i = 2; i < N+1; i++)
   {
     if(!primes[i]) {
       fprintf(fPtr, "%d ", i);
     }
   }

}

 __global__
void remove_for_divisor(bool* n_series, unsigned int N, int divisor) {
  int i = blockIdx.x*blockDim.x + threadIdx.x;
  int e = divisor*(i+2);
  if(e <= N) {
    n_series[e] = true;
  }
}

__global__
void remove_all(bool* n_series, unsigned int N, unsigned int max_divisor) {

  int divisor = blockIdx.x * blockDim.x + threadIdx.x + 3;

  // this might initialize for some divisors (like 9) that are not prime but this 
  // still gives better performance, than waiting for 3 to finish and then executing 5,7 and 11.
  if (divisor <= max_divisor && n_series[divisor] == false) {

    // start marking off from (divisor)^2
    for (int j = divisor * divisor; j <= N; j += divisor) {
      n_series[j] = true;
    }

  }
}