// CSE141L  Fall 2020
// test bench to be used to verify student projects
// pulses start while loading program 3 operand into DUT
//  waits for done pulse from DUT
//  reads and verifies result from DUT against its own computation
// Based on SystemVerilog source code provided by John Eldon
module test_bench_3();


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
			
// program 3 variables
reg[15:0] dat_in3;	   // operand to DUT
reg[ 7:0] result3;	   // expected SQRT(operand) result from DUT
reg[47:0] square3;	   // internal expansion of operand
reg[ 7:0] result3_DUT;   // actual SQRT(operand) result from DUT
real argument, result, 	   // reals used in test bench square root algorithm
     error, result_new;
	 
// clock -- controls all timing, data flow in hardware and test bench
always begin
       clk = 0;
  #5; clk = 1;
  #5;
  $display("Cycle: %d, PC: %d, Inst: %b, Q: %h, R0: %h, R1: %h, R2: %h, R3: %h, Z: %h, C: %h",
           dut.CycleCt,
           dut.PgmCtr,
           dut.Instruction,
           dut.RF1.Accumulator,
           dut.RF1.Registers[0],
           dut.RF1.Registers[1],
           dut.RF1.Registers[2],
           dut.RF1.Registers[3],
           dut.CZ.ZeroFlag,
           dut.CZ.CarryFlag);
end

initial begin

// preload operands and launch program 3
  #10; start = 1;
  #20;  init = 0;
// insert operand
  dat_in3 = 190;// Max : 65535;		   // *** try various values here ***
// *** change names of memory or its guts as needed ***
  dut.DM1.Core[16] = dat_in3[15: 8];
  dut.DM1.Core[17] = dat_in3[ 7: 0]; 
  if(dat_in3==0) result3 = 0;   // trap 0 case up front
  else div3;
  #20; start = 0;
  #20; wait(done);
// *** change names of memory or its guts as needed ***
  result3_DUT = dut.DM1.Core[18];     
  $display("operand(hex) = %h, sqrt(hex) = %h",dat_in3,result3);
  if(result3==result3_DUT) $display("success -- match3");
  else $display("OOPS3! expected %h (hex), got %h",result3,result3_DUT);
  #10;
  $stop;
end

task automatic div3;
begin
  argument = $itor(dat_in3);
//  real error, result_new;
  result = 1.0;
  error = 1.0;
  while (error > 0.001) begin
    result_new = argument/2.0/result + result/2.0;
    error = (result_new - result)/result;
    if (error < 0.0) error = -error;
      result = result_new;
  end
  result3 = $rtoi(result);
  
  // The following two lines are for rounding. if you want to 'floor' instead, comment the two lines below
  //if(!(&(result3))) 
  //  result3 = $rtoi(result+0.5);
	
end
endtask

endmodule