// Module Name:    RegFile 
// Project Name:   CSE141L
//
// Revision Fall 2020
// Based on SystemVerilog source code provided by John Eldon
// Comment:
// This module is your register file.
// If you have more or less bits for your registers, update the value of D.
// Ex. If you only supports 8 registers. Set D = 3

/* parameters are compile time directives 
       this can be an any-size reg_file: just override the params!
*/
module CZReg (Clk,WriteEn,RaddrA,RaddrB,Waddr,DataIn,DataOutA,DataOutB);
	parameter W=1, D=1;  // W = data path width (Do not change); D = pointer width (You may change)
	input                Clk,
								WriteEn;
	input        [D-1:0] ZIn,				  // address pointers
	input        [W-1:0] CIn;
	output reg   [W-1:0] ZOut;			  
	output reg   [W-1:0] COut;				

// W bits wide [W-1:0] and 2**4 registers deep 	 
reg ZeroFlag;	  // 
reg CarryFlag;	            // 



// NOTE:
// READ is combinational
// WRITE is sequential

always@*
begin
 ZOut = ZeroFlag;
 COut = CarryFlag;
end

// sequential (clocked) writes 
always @ (posedge Clk)
  if (WriteEn)	                             // works just like data_memory writes
		ZeroFlag <= Zin;
		CarryFlag <= CIn;

endmodule
