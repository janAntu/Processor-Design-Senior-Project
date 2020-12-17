
*******************************************************************************
                                 LAB 4 README
*******************************************************************************

> Overview:
Our team managed to complete all three programs, and so each of these programs
work on our processor.

The greatest challenges we faced were translating our similated processor into
Verilog circuits. During Lab 1, we wrote a program in Python to run our three
programs and simulate the processor, and this helped us ensure that our
assembly programs were correct. However, translating this design into Verilog
code was challenging, especially when we realized we needed to modify our ISA.

> Video Link
https://ucsd.zoom.us/rec/share/3f3HPkl8ZASdd8dZ_IjNHIiQ5e9heTel_BJuXdFIacTPXuiinoUiwzvzRfVsrD2U.5OkXwLD2GaLzXIMP
Passcode: tP*M4zXX 

> Rounding vs. Flooring
Our programs use flooring instead of rounding.

> Using the Assembler
To assemble a file, use runasm.py like below:
$ python runasm.py [assembly file] [target file]

> Testbenches
We modified all three of the testbenches and included them in our submission
as test_bench_1.v, test_bench_2.v, and test_bench_3.v. We made very few
modifications: first, we eliminated some of the redundant code that had been
copy-pasted between the three files. Second, we added $display statements
to log our output and debug our programs. Finally, we set the reset signal
to zero before writing the input to memory for each program, because otherwise
the memory would be reset after it was written.
