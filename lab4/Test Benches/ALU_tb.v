`timescale 1ns/ 1ps



//Test bench
//Arithmetic Logic Unit
/*
* INPUT: A, B
* op: 00, A PLUS B
* op: 01, A AND B
* op: 10, A OR B
* op: 11, A XOR B
* OUTPUT A op B
* equal: is A == B?
* even: is the output even?
*/


module ALU_tb;
reg [ 7:0] INPUTA;     	  // data inputs
reg [ 7:0] INPUTB;
reg [ 3:0] op;		// ALU opcode, part of microcode
reg [ 2:0] mop;		// ALU opcode, part of microcode
reg ZeroIn;
reg CarryIn;

wire[ 7:0] OUT;		// ALU output
wire ZeroOut;
wire CarryOut;    
 
reg [ 7:0] expected;
reg expectedZ;
reg expectedC;
 
// CONNECTION
ALU uut(
  .InputA(INPUTA),      	  
  .InputB(INPUTB),
  .OP(op),				  
  .MOP(mop),			
  .ZeroIn(ZeroIn),
  .CarryIn(CarryIn),  
  .Out(OUT),		  			
  .ZeroOut(ZeroOut),		
  .CarryOut(CarryOut)		
    );
	 
initial begin

	CarryIn = 0;
	ZeroIn = 0;

	// RRC
	INPUTA = 4;
	INPUTB = 7;
	op = 4'b0000;
	mop = 3'b100;
	expected = 3;
	expectedZ = 0;
	expectedC = 1;
	test_alu_func;
	#5

	// RLC
	INPUTA = 4;
	INPUTB = 7;
	op = 4'b0000;
	mop = 3'b101;
	expected = 14;
	expectedZ = 0;
	expectedC = 0;
	test_alu_func;
	#5

	// CPLC
	CarryIn = 0;
	op = 4'b0000;
	mop = 3'b110;
	expected = 0;
	expectedZ = 0;
	expectedC = 1;
	test_alu_func;
	#5

	// CPLC
	CarryIn = 1;
	op = 4'b0000;
	mop = 3'b110;
	expected = 0;
	expectedZ = 0;
	expectedC = 0;
	test_alu_func;
	#5

	// CLRC
	CarryIn = 0;
	op = 4'b0000;
	mop = 3'b111;
	expected = 0;
	expectedZ = 0;
	expectedC = 0;
	test_alu_func;
	#5

	// CLRC
	CarryIn = 1;
	op = 4'b0000;
	mop = 3'b111;
	expected = 0;
	expectedZ = 0;
	expectedC = 0;
	test_alu_func;
	#5

	CarryIn = 0;
	ZeroIn = 0;

	// CMPZ
	INPUTA = 4;
	INPUTB = 7;
	op = 4'b0001;
	mop = 3'b000;
	expected = 0;
	expectedZ = 0;
	expectedC = 0;
	test_alu_func;
	#5

	// CMPZ
	INPUTA = 7;
	INPUTB = 7;
	op = 4'b0001;
	mop = 3'b000;
	expected = 0;
	expectedZ = 1;
	expectedC = 0;
	test_alu_func;
	#5

	// CMPC
	INPUTA = 4;
	INPUTB = 7;
	op = 4'b0001;
	mop = 3'b100;
	expected = 0;
	expectedZ = 0;
	expectedC = 1;
	test_alu_func;
	#5

	// CMPC
	INPUTA = 7;
	INPUTB = 7;
	op = 4'b0001;
	mop = 3'b100;
	expected = 0;
	expectedZ = 0;
	expectedC = 0;
	test_alu_func;
	#5

	INPUTA = 10;
	INPUTB = 17; 
	op= 4'b0010; // SUB
	test_alu_func; // void function call
	#5;

	INPUTA = 1;
	INPUTB = 1; 
	op= 4'b0101; // AND
	test_alu_func; // void function call
	#5;
	
	INPUTA = 4;
	INPUTB = 1;
	op= 4'b0111; // ADD
	test_alu_func; // void function call
	#5;

	INPUTA = 3;
	op= 4'b0011; // DEC
	test_alu_func; // void function call
	#5;

	INPUTA = 4;
	INPUTB = 2; 
	op= 4'b0100; // OR
	test_alu_func; // void function call
	#5;

	// Expected: 7
	INPUTA = 3;
	INPUTB = 4; 
	op= 4'b0110; // XOR
	test_alu_func; // void function call
	#5;

	INPUTA = 7;
	INPUTB = 5;
	op= 4'b1000; // MOV f Q
	test_alu_func; // void function call
	#5;

	// Expected: -6
	INPUTA = 6;
	op= 4'b1001; // COM
	test_alu_func; // void function call
	#5;

	// Expected: 9
	INPUTA = 8;
	op= 4'b1010; // INC
	test_alu_func; // void function call
	#5;
	
	INPUTA = 7;
	INPUTB = 5;
	op= 4'b1011; // MOV f F
	test_alu_func; // void function call
	#5;

	INPUTA = 2;
	INPUTB = 1;
	op= 4'b1100; // Shift left
	test_alu_func; // void function call
	#5;

	INPUTA = 2;
	INPUTB = 1;
	op= 4'b1101; // Clear
	test_alu_func; // void function call
	#5;

	// Expected: 4
	INPUTA = 4;
	INPUTB = 1;
	op= 4'b1110; // Shift right
	test_alu_func; // void function call
	#5;

	
	end
	
	task test_alu_func;
	begin
	  case (op)
		4'b0010: expected = -7;
		4'b0011: expected = 2; 		// DEC
		4'b0100: expected = 6; // OR
		4'b0101: expected = 1; // AND
		4'b0110: expected = 7; // XOR
		4'b0111: expected = 5; // ADD
		4'b1000: expected = 5; 			// MOV f Q
		4'b1001: expected = -7; 				// COM
		4'b1010: expected = 9; 			// INC
		4'b1011: expected = 7; 					// MOV f F
		4'b1100: expected = 4; 		// Shift left
		4'b1101: expected = 8'b0; 						// CLEAR
		4'b1110: expected = 2;  // Shift right
	  endcase
	  #1; if(expected == OUT && (op > 1 || (expectedC == CarryOut && expectedZ == ZeroOut)))
		begin
			$display("%t YAY!! inputs = %h %h, opcode = %b, ZeroOut %b, CarryOut %b",$time, INPUTA,INPUTB,op, ZeroOut, CarryOut);
		end
	    else begin $display("%t FAIL! inputs = %h %h, opcode = %b, expected output = %h, actual output = %h, ZeroOut %b, CarryOut %b",$time, INPUTA,INPUTB,op,expected,OUT,ZeroOut,CarryOut);end
		
	end
	endtask



endmodule