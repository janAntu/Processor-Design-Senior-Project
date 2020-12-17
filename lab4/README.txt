
*******************************************************************************
                                 LAB 4 README
*******************************************************************************

> Overview:
Our team managed to complete all three programs, and so each of these programs
work on our processor.

> Video Link

> Rounding vs. Flooring
Our programs use flooring instead of rounding.

> Testbenches
We modified all three of the testbenches and included them in our submission
as test_bench_1.v, test_bench_2.v, and test_bench_3.v. We made very few
modifications: first, we eliminated some of the redundant code that had been
copy-pasted between the three files. Second, we added $display statements
to log our output and debug our programs. Finally, we set the reset signal
to zero before writing the input to memory for each program, because otherwise
the memory would be reset after it was written.