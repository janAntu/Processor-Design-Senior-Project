// Module Name:    Ctrl 
// Project Name:   CSE141L
//
// Revision Fall 2020
// Based on SystemVerilog source code provided by John Eldon
// Comment:
// This module is the control decoder (combinational, not clocked)
// Out of all the files, you'll probably write the most lines of code here
// inputs from instrROM, ALU flags
// outputs to program_counter (fetch unit)
// There may be more outputs going to other modules

module Ctrl (Instruction, Jump, BranchEn);


  input[ 8:0] Instruction;	   // machine code
	input       CFlag,
	            ZFlag;
  output reg Jump,
              BranchEn;

	// jump on right shift that generates a zero
	always@*
	begin
	  if(Instruction ==  9'b000000001)
		 Jump = 1;
	  else
		 Jump = 0;
		 
		if((Instruction[8:5] ==  4'b1000 && ZFlag) || 
		   (Instruction[8:5] ==  4'b1001 && !ZFlag) ||
		   (Instruction[8:5] ==  4'b1010 && CFlag) ||
		   (Instruction[8:5] ==  4'b1011 && !CFlag)) 
		 BranchEn = 1;
	  else
		 BranchEn = 0;
		 
		 
	end


endmodule

