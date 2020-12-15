// CSE141L  Fall 2020
// test bench to be used to verify student projects
// pulses start while loading program 1 operand into DUT
//  waits for done pulse from DUT
//  reads and verifies result from DUT against its own computation
// Based on SystemVerilog source code provided by John Eldon
 
module test_bench_1();


  reg      clk   = 1'b0   ;      // advances simulation step-by-step
  reg           init  = 1'b1   ;      // init (reset) command to DUT
  reg           start = 1'b1   ;      // req (start program) command to DUT
  wire       done           ;      // done flag returned by DUT
  
// ***** instantiate your top level design here *****
  CPU dut(
    .Clk     (clk  ),   // input: use your own port names, if different
    .Reset    (init ),   // input: some prefer to call this ".reset"
    .Start     (start),   // input: launch program
    .Ack     (done )    // output: "program run complete"
  );


// program 1 variables
reg[63:0] dividend;      // fixed for pgm 1 at 64'h8000_0000_0000_0000;
reg[15:0] divisor1;	   // divisor 1 (sole operand for 1/x) to DUT
reg[63:0] quotient1;	   // internal wide-precision result
reg[15:0] result1,	   // desired final result, rounded to 16 bits
            result1_DUT;   // actual result from DUT
real quotientR;			   // quotient in $real format

	 
// clock -- controls all timing, data flow in hardware and test bench
always begin
       clk = 0;
  #5; clk = 1;
  #5;
  $display("Cycle: %d, PC: %d, Inst: %b, Q: %h, R0: %h, R1: %h, R2: %h, R3: %h, Z: %h, done: %h",
           dut.CycleCt,
           dut.PgmCtr,
           dut.Instruction,
           dut.RF1.Accumulator,
           dut.RF1.Registers[0],
           dut.RF1.Registers[1],
           dut.RF1.Registers[2],
           dut.RF1.Registers[3],
           dut.CZ.ZeroFlag,
           done);
end

initial begin

// launch program 1
  start = 1;
  dividend = 64'h8000_0000_0000_0000;	   // this is 1.000000000
  // *** try various values here ***
  divisor1 = 3;		// This is testing 1/4, which would produce hex value 2000        
// your memory gets loaded here
// *** change names of memory or its guts as needed ***
  dut.DM1.Core[8] = divisor1[15:8];
  dut.DM1.Core[9] = divisor1[ 7:0];
  if(divisor1) div1;										// regal value of nonzero vector = 1;
  else result1 = '1;    // 1/0 = all 1's (maximum value; "saturating reg")
  #20;  init = 0;
  #20; start = 0;
  #20;
  wait(done);
// your memory gets read here
// *** change names of memory or its guts as needed ***
  result1_DUT[15:8] = dut.DM1.Core[10];
  result1_DUT[ 7:0] = dut.DM1.Core[11];
  $display ("divisor = %h , quotient = %h , result1 = %h, equiv to %10.5f", 
    divisor1, quotient1, result1, quotientR); 
  if(result1==result1_DUT) $display("success -- match1");
  else $display("OOPS1! expected %h, got %h",result1,result1_DUT);
  
  #10;
  $stop;
end

task automatic div1;
begin
  quotient1 = dividend/divisor1;			// Actually doing 1/ divisor to get a result to compare with your processor's division
  //result1 = quotient1[63:48]+quotient1[47]; // half-LSB upward rounding (Uncomment this line to use rounding)
  result1 = quotient1[63:48];                 // No Rounding
  quotientR = 1.00000/$itor(divisor1);
end
endtask

endmodule