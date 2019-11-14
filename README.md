# Prime Number Generator

## Code Walkthrough

I have used `streams` to accelerate code performance. The algorithm is called Sieve of Eratosthenes, where in each iteration we choose a *divisor* (starting from 2), and cancel out all elements between 1 and N, that are divisible by the divisor. Then we look for the next element that has not already been cancelled out and use that as the *divisor*.

For the first part, I explicitly use `2, 3, 5 and 7` as the divisors. I lauch a kernel for each one of them, where all the threads check if the corresponding element is divisible by the given divisor for the kernel. All the kernels are launched in different streams, so they run parallely.

Once the above kernels are done executing, I spawn a single kernel that would cancel out the multiple of the remaining numbers (which are still not cancelled out). This computation might execute a few unnecessary Sieves (for divisors which are not prime), but the massive parallelism still improves the performance.
