// CSE141L  Fall 2020
// test bench to be used to verify student projects
// pulses start while loading program 1 operand into DUT
//  waits for done pulse from DUT
//  reads and verifies result from DUT against its own computation
// Based on SystemVerilog source code provided by John Eldon
 
module test_bench_small();


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
	 
// clock -- controls all timing, data flow in hardware and test bench
always begin
       clk = 0;
  #5; clk = 1;
  #5;
  $display("Cycle: %d, PC: %d, Inst: %b, Q: %h, R0: %h, R1: %h, R2: %h, R3: %h, Z: %h, MemAddr: %h, RWV: %h, WriteEn: %h",
           dut.CycleCt,
           dut.PgmCtr,
           dut.Instruction,
           dut.RF1.Accumulator,
           dut.RF1.Registers[0],
           dut.RF1.Registers[1],
           dut.RF1.Registers[2],
           dut.RF1.Registers[3],
           dut.CZ.ZeroFlag,
           dut.MemAddr,
           dut.RegWriteValue,
           dut.MemWrite);
end

initial begin

// launch program 1
  start = 1;
  #20;  init = 0;
  dut.DM1.Core[1] = 11;
  dut.DM1.Core[2] = 4;
  #20; start = 0;
  #20;
  wait(done);
  $display("Accum: %h, R0: %h, R1: %h, R2: %h, R3: $h, Z: %h",
           dut.RF1.Accumulator,
           dut.RF1.Registers[0],
           dut.RF1.Registers[1],
           dut.RF1.Registers[2],
           dut.RF1.Registers[3],
           dut.CZ.ZeroFlag);
// your memory gets read here
// *** change names of memory or its guts as needed ***
  $display("Result should equal 7; actual is %h", dut.DM1.Core[3]);
  $display("Memory[1:3]: %h%h%h", dut.DM1.Core[1], dut.DM1.Core[2], dut.DM1.Core[3]);
  #10;
  $stop;
end

endmodule