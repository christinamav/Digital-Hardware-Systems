module datapath

#(parameter[31:0] INITIAL_PC = 32'h00000000)

(output reg[31:0] dAddress, PC, dWriteData, WriteBackData, output wire Zero,
input wire[31:0] instr, dReadData, input wire[3:0] ALUCtrl, input wire clk, rst, PCSrc, ALUSrc,
RegWrite, MemToReg, loadPC);


/* Immediate Generation Unit */

//internal variables
reg [31:0] imm;

//check the opcode of the instruction to generate the immediate value accordingly
always @(instr)
begin
casez(instr[6:0])	//the immediate is sign extended at all cases

	//I-type instruction
	7'b00?0011 : begin //check the funct3 field for shift instructions
		     casez(instr[14:12]) 		     
		     3'b?01 : imm = {{27 {instr[24]}}, instr[24:20]}; 
		     default: imm = {{20 {instr[31]}}, instr[31:20]};
		     endcase
		     end
	//S-type instruction
	7'b0100011 : imm = { {20 {instr[31]}}, instr[31:25], instr[11:7]}; 
	//B-type instruction
	7'b1100011 : imm = { {20 {instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
	default	   : imm = 32'bx;
endcase
end 

/*-------------------------------------------------------------------------*/

/* Register File Unit */

//internal nets
wire [31:0] readData1, readData2;
reg [31:0] writeData;
//instantiate register file module
regfile REGF (.readData1(readData1), .readData2(readData2), .writeData(writeData),
.readReg1(instr[19:15]), .readReg2(instr[24:20]), .writeReg(instr[11:7]),  
.clk(clk), .write(RegWrite));

/*-------------------------------------------------------------------------*/

/* ALU Unit */

//internal nets and variables
reg [31:0] op2;
wire[31:0] result;

//multiplexer to select the signal that drives op2
always @*
op2 = ALUSrc ? imm : readData2;

//instantiate alu module
alu ALU (.zero(Zero), .result(result), .op1(readData1), .op2(op2), .alu_op(ALUCtrl));

/*-------------------------------------------------------------------------*/

/* Write Back Unit */

//multiplexer to select the signal that drives the writeData input of the register file
always @*
begin
writeData = MemToReg ? dReadData : result;
WriteBackData = writeData;
end

/*-------------------------------------------------------------------------*/

/* Data Memory Input */

//in case of a STORE instruction, the data written into memory (dWriteData) are the contents of 
//rs2 (readData2)
//in cases of STORE and LOAD instructions, the address of the data memory (dAddress) is the 
//result of the ALU operation
always@*
casez(instr[6:0])
//STORE
7'b0100011: begin
	    dAddress = result;
	    dWriteData = readData2;
	    end
//LOAD
7'b0000011: dAddress = result;
default: begin
	 dAddress = 32'bx;
	 dWriteData = 32'bx;
	 end
endcase

/*-------------------------------------------------------------------------*/

/* Program Counter Unit */

//initialize program counter if reset signal is high
//reset signal is synchronous
always @(posedge clk)
begin
if(rst)
PC <= INITIAL_PC;
else if(loadPC)
//update program counter if loadPC signal is high
//loadPC signal is synchronous
begin
if(PCSrc)
PC <= PC + imm; //the program branches
else
PC <= PC + 4;   //the program executes the next instruction in memory
end
end

/*-------------------------------------------------------------------------*/

endmodule