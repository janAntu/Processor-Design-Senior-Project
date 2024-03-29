// Module Name:    CPU 
// Project Name:   CSE141L
//
// Revision Fall 2020
// Based on SystemVerilog source code provided by John Eldon
// Comment:
// This is the TopLevel of your project
// Testbench will create an instance of your CPU and test it
// You may add a LUT if needed
// Set Ack to 1 to alert testbench that your CPU finishes doing a program or all 3 programs



	 
module CPU(Reset, Start, Clk,Ack);

	input Reset;		// init/reset, active high
	input Start;		// start next program
	input Clk;			// clock -- posedge used inside design
	output reg Ack;   // done flag from DUT

	
	
	wire [ 7:0] PgmCtr,        // program counter
			      PCTarg;
	wire [ 8:0] Instruction;   // our 9-bit instruction
	wire [ 1:0] Instr_opcode;  // out 2-bit opcode
	wire [ 7:0] ReadA, ReadB;  // reg_file outputs
	wire [ 7:0] InA, InB, 	   // ALU operand inputs
					ALU_out;       // ALU result
	wire [ 7:0] RegWriteValue, // data in to reg file
					MemAddr,
					MemWriteValue, // data in to data_memory
					MemReadValue;  // data out from data_memory

	// Control Wires
	wire    MemWrite,	   // data_memory write enable
				  RegWrEn,	   // reg_file write enable
					CZWrEn,
					Jump,	       // to program counter: jump 
					BranchEn,	   // to program counter: branch enable
					Destination,
					ZeroIn,
					ZeroOut,
					CarryIn,
					CarryOut;

	// Just for debugging
	reg  [15:0] CycleCt;	      // standalone; NOT PC!

	// Fetch = Program Counter + Instruction ROM
	// Program Counter
  InstFetch IF1 (
	.Reset       (Reset   ) , 
	.Start       (Start   ) ,  
	.Clk         (Clk     ) ,  
	.BranchAbs   (Jump    ) ,  // jump enable
	.BranchRelEn (BranchEn) ,  // branch enable
  .Target      (ReadA   ) ,
  .TargetRel 	 (Instruction[4:0]),
	.ProgCtr     (PgmCtr  )	   // program count = index to instruction memory
	);	

	// Control decoder
  Ctrl Ctrl1 (
	.Instruction  (Instruction),    // from instr_ROM
	.CFlag				(CarryOut),
	.ZFlag				(ZeroOut),
	.Jump         (Jump),		     // to PC
	.BranchEn     (BranchEn)		  // to PC
  );
  
  
	// instruction ROM
  InstROM IR1(
	.InstAddress   (PgmCtr), 
	.InstOut       (Instruction)
	);
	
	assign LoadInst = Instruction[8:6]==3'b010;  // calls out load specially
	
	always@*
	begin
		Ack = Instruction == 9'b000000000;  // Update this to the condition you want to set done to true
	end
	
	
	//Reg file
	// Modify D = *Number of bits you use for each register*
   // Width of register is 8 bits, do not modify
	RegFile #(.W(8),.D(2)) RF1 (
		.Clk    		(Clk),
		.WriteEn   (RegWrEn), 
		.Destination   (Destination), 
		.RaddrA    (Instruction[1:0]),
		.DataIn    (RegWriteValue), 
		.DataOutA  (ReadA), 
		.DataOutB  (ReadB)
	);


	CZReg #(.W(1)) CZ (
		.Clk    		(Clk),
		.WriteEn   (CZWrEn), 
		.ZIn    (ZeroIn),
		.CIn    (CarryIn), 
		.ZOut  (ZeroOut),
		.COut  (CarryOut)
	);
	
	
	
	assign InA = ReadA;						                       // connect RF out to ALU in
	assign InB = ReadB;
	assign Instr_opcode = Instruction[8:7];
	assign MemWrite = (Instruction[8:6] == 3'b011);                 // mem_store command
	assign MemWriteValue = ReadA;
	assign MemAddr = ReadB + Instruction[5:2];
	assign RegWriteValue = 
		Instruction[8:7] == 2'b11 ? Instruction[6:0] : // If SETQ, get literal from instruction
		(LoadInst ? MemReadValue : ALU_out);  // Otherwise, 2:1 switch into reg_file
	assign Destination = 
	  (Instruction[8:7] == 2'b00 && Instruction[6:4] != 3'b000) ?
		Instruction[2] : 0;  // Destination is always Q except for ALU ops
	assign RegWrEn = !(   // Set reg write for all insts EXCEPT:
		(Instruction[8:7] == 2'b10) ||        // Branch
		(Instruction[8:6] == 3'b011) ||     // SW
		(Instruction[8:3] == 6'b000001) ||  // CMPZ and CMPC
		(Instruction[8:1] == 8'b00000011) || // CPLC and CLRC
		(Instruction == 9'b000000001)        // JUMP
	);
	assign CZWrEn = (Instruction[8:7] == 2'b00) &&
		(Instruction != 9'b000000001);
	

	// Arithmetic Logic Unit
	ALU ALU1(
	  .InputA(InA),      	  
	  .InputB(InB),
	  .OP(Instruction[6:3]),
		.MOP(Instruction[2:0]),
		.ZeroIn(ZeroOut),
		.CarryIn(CarryOut),
	  .Out(ALU_out),
		.ZeroOut(ZeroIn),
		.CarryOut(CarryIn)
		 );
	 
	 
	 // Data Memory
	 	DataMem DM1(
		.DataAddress  (MemAddr), 
		.WriteEn      (MemWrite), 
		.DataIn       (MemWriteValue), 
		.DataOut      (MemReadValue), 
		.Clk 		  	  (Clk),
		.Reset		  (Reset)
	);

	
	
// count number of instructions executed
// Help you with debugging
	always @(posedge Clk) begin
	  if (Start == 1)	   // if(start)
		 CycleCt <= 0;
	  else if(Ack == 0)   // if(!halt)
		 CycleCt <= CycleCt+16'b1;
	
		// $display("\tRegWrEn: %h, RegWriteValue: %h, Destination: %h",
		// 				RegWrEn,
		// 				RegWriteValue,
		// 				Destination);
	end

endmodule