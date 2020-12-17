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
module RegFile (Clk,WriteEn,Destination,RaddrA,DataIn,DataOutA,DataOutB);
	parameter W=8, D=2;  // W = data path width (Do not change); D = pointer width (You may change)
	input                Clk,
								WriteEn,
								Destination;  // 0 for accumulator, 1 for other register
	input        [D-1:0] RaddrA;				  // address pointers
	input        [W-1:0] DataIn;
	output reg   [W-1:0] DataOutA;
	output reg   [W-1:0] DataOutB;

// W bits wide [W-1:0] and 2**4 registers deep 	 
reg [W-1:0] Registers[(2**D)-1:0];	  // or just registers[16-1:0] if we know D=4 always
reg [W-1:0] Accumulator;	            // special accumulator register



// NOTE:
// READ is combinational
// WRITE is sequential

always@*
begin
 DataOutA = Accumulator;
 DataOutB = Registers[RaddrA];
end

// sequential (clocked) writes 
always @ (posedge Clk) begin
  if (WriteEn)	                             // works just like data_memory writes
		if (Destination)
			Registers[RaddrA] <= DataIn;
		else
			Accumulator <= DataIn;

//$display("\tWriteEn: %h, DataIn: %h, Destination: %h", WriteEn, DataIn, Destination);
end

endmodule
