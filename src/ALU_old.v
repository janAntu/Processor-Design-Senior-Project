// Module Name:    ALU 
// Project Name:   CSE141L
//
// Revision Fall 2020
// Based on SystemVerilog source code provided by John Eldon
// Comment:
// 


	 
module ALU(InputA,InputB,OP,Out,Zero);

	input [ 7:0] InputA;
	input [ 7:0] InputB;
	input [ 2:0] OP;
	output reg [7:0] Out; // logic in SystemVerilog
	output reg Zero;

	always@* // always_comb in systemverilog
	begin 
		Out = 0;
		case (OP)
		3'b000: Out = InputA + InputB; // ADD
		3'b001: Out = InputA & InputB; // AND
		3'b010: Out = InputA | InputB; // OR
		3'b011: Out = InputA ^ InputB; // XOR
		3'b100: Out = InputA << 1;				// Shift left
		3'b101: Out = {1'b0,InputA[7:1]};   // Shift right
		default: Out = 0;
	  endcase
	
	end 

	always@*							  // assign Zero = !Out;
	begin
		case(Out)
			'b0     : Zero = 1'b1;
			default : Zero = 1'b0;
      endcase
	end


endmodule