// Module Name:    ALU 
// Project Name:   CSE141L
//
// Revision Fall 2020
// Based on SystemVerilog source code provided by John Eldon
// Comment:
// 


	 
module ALU(InputA,InputB,OP,MOP,ZeroIn,CarryIn,Out,ZeroOut,CarryOut);

	input [ 7:0] InputA;
	input [ 7:0] InputB;
	input [ 3:0] OP;
	input [ 2:0] MOP;
	input ZeroIn;
	input CarryIn;
	output reg [7:0] Out; // logic in SystemVerilog
	output reg ZeroOut;
	output reg CarryOut;

	always@* // always_comb in systemverilog
	begin 
		Out = 0;
		ZeroOut = ZeroIn;
		CarryOut = CarryIn;
		
		case (OP)
		// Handles RRC, RLC, CPLC, CLRC
		4'b0000: begin 
			case (MOP)
			3'b100: begin
				Out = {1'b0,InputB[7:1]};
				CarryOut = InputB[0];
			end
			3'b101: begin
				Out = InputB << 1;
				CarryOut = InputB[7];
			end
			3'b110: CarryOut = ~CarryIn;
			3'b111: CarryOut = 1'b0;
			endcase
		end		

		// Handles both compare instructions, CMPZ and CMPC
		4'b0001: begin 
			if(MOP[2] == 1'b0)
					ZeroOut = (InputA == InputB) ? 1 : 0;
			if(MOP[2] == 1'b1)
				CarryOut = (InputA < InputB) ? 1 : 0;
		end		
		4'b0010: begin				// SUB
			Out = InputB - InputA;
			CarryOut = (InputA < InputB) ? 1 : 0;
		end
		4'b0011: Out = InputB - 1; 		// DEC
		4'b0100: Out = InputA | InputB; // OR
		4'b0101: Out = InputA & InputB; // AND
		4'b0110: Out = InputA ^ InputB; // XOR
		4'b0111: Out = InputA + InputB; // ADD
		4'b1000: Out = InputB; 			// MOV f Q
		4'b1001: Out = ~InputB; 				// COM
		4'b1010: Out = InputB + 1; 			// INC
		4'b1011: Out = InputA; 					// MOV f F
		4'b1100: Out = InputB << 1; 		// Shift left
		4'b1101: Out = 8'b0; 						// CLEAR
		4'b1110: Out = {1'b0,InputB[7:1]};  // Shift right
		//4'b1111: // N/A
		default: Out = 0;
	  endcase

		// Set the Z bit for specified ALU functions
		if ((OP[3] == 1'b0 && OP[3:1] != 3'b000) ||
		    (OP == 4'b1001) || (OP == 4'b1010) ||(OP == 4'b1101))
			ZeroOut = (Out == 0) ? 1 : 0;
	
	end 


endmodule