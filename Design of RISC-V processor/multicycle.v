module multicycle
#(parameter[31:0] INITIAL_PC = 32'h00400000)

(output wire[31:0] dAddress, dWriteData, PC, WriteBackData, output reg MemRead, MemWrite,
input wire[31:0] instr, dReadData, input wire rst, clk);


/* ALU Control Logic */

//define parameters to match the instruction encoding of RISC-V processor
//based on the fields funct7 and funct3

parameter[3:0]  AND = 4'b0111,
	        OR = 4'b0110,
		ADD = 4'b0000,
		SUB = 4'b1000,
		SLT = 4'b0010,
		SRL = 4'b0101,
		SLL = 4'b0001,
		SRA = 4'b1101,
		XOR = 4'b0100;
		 
//overwrite these parameters in the alu instance in the datapath unit
defparam DATAPATH.ALU.ALUOP_AND = AND,
	 DATAPATH.ALU.ALUOP_OR = OR,	 
	 DATAPATH.ALU.ALUOP_ADD = ADD,
	 DATAPATH.ALU.ALUOP_SUB = SUB,
	 DATAPATH.ALU.ALUOP_LESS = SLT,
	 DATAPATH.ALU.ALUOP_SHIFT_RIGHT = SRL,
	 DATAPATH.ALU.ALUOP_SHIFT_LEFT = SLL,
	 DATAPATH.ALU.ALUOP_SHIFT_RIGHT_ARITHM = SRA,
	 DATAPATH.ALU.ALUOP_XOR = XOR;

//define an ALUCtrl signal to select the alu operation needed based on 
//the instruction encoding
reg[3:0] ALUCtrl;

//depending on the opcode determine the instruction type
always @*
casez(instr[6:0])
//R-type
7'b0110011 : ALUCtrl = {instr[30], instr[14:12]};
//ALU-Immediate type
7'b0010011 : begin //check the funct3 field for shift instructions
	     casez(instr[14:12]) 		     
	     3'b?01 : ALUCtrl = {instr[30], instr[14:12]}; 
	     default: ALUCtrl = {1'b0, instr[14:12]};
	     endcase
	     end
//Load-type or S-type
7'b0?00011 : ALUCtrl = ADD;  
//B-type
7'b1100011 : ALUCtrl = SUB;
default    : ALUCtrl = 4'bx;
endcase

//define an ALUSrc signal to select which source drives the second input
//operand of the alu unit 
reg ALUSrc;

always @(instr)
casez(instr[6:0])
//ALU-Immediate type or Load-type or S-type
//these types of commands require immediate data
7'b0010011, 7'b0?00011 : ALUSrc = 1;
//all the rest types of commands source the second input operand
//from the register file 
default : ALUSrc = 0;
endcase

/*-------------------------------------------------------------------------*/

/* Write-Back-Data Multiplexer Control Signal */

reg MemToReg;

//MemToReg signal is activated only for the load instruction. Its value is important
//only when the current-state is WB and not otherwise.
always@(instr)
if(instr[6:0] == 7'b0000011)
MemToReg = 1;
else
MemToReg = 0;

/*-------------------------------------------------------------------------*/

/* Program Counter Source Multiplexer Control Signal */

wire Zero;
reg PCSrc;

//PCSrc signal is activated only for the branch instruction if the Zero signal of the ALU
//is also activated. Its value is important only when the current-state is WB and not otherwise.
always@(instr or Zero)
if(instr[6:0] == 7'b1100011 && Zero == 1)
PCSrc = 1;
else 
PCSrc = 0;

/*-------------------------------------------------------------------------*/

/* Datapath Unit */


reg RegWrite, loadPC; 

//instantiate datapath module
datapath #(INITIAL_PC) DATAPATH (.dAddress(dAddress), .PC(PC), .dWriteData(dWriteData), .WriteBackData(WriteBackData), 
.Zero(Zero), .instr(instr), .dReadData(dReadData), .ALUCtrl(ALUCtrl), .clk(clk), .rst(rst), .PCSrc(PCSrc),
.ALUSrc(ALUSrc), .RegWrite(RegWrite), .MemToReg(MemToReg), .loadPC(loadPC));

/*-------------------------------------------------------------------------*/

/* Finite State Machine */

//define parameters for the 5 states of the machine
parameter[2:0]  IF = 3'b000,	//instruction fetch
		ID = 3'b001,	//instruction decode
		EX = 3'b010,	//execute
		MEM = 3'b011,	//memory operations
		WB = 3'b100;	//write back to register file

reg[2:0] current_state, next_state;

//state memory unit
always @(posedge clk)
begin	//go to instruction fetch state if reset signal is high
if(rst)	//reset signal is synchronous
current_state <= IF;
else
current_state <= next_state;
end

//next-state forming logic
always @(current_state)	//the next-state only depends on the current-state and not on the input
begin : NEXT_STATE_LOGIC
case(current_state)
IF : next_state = ID;
ID : next_state = EX;
EX : next_state = MEM;
MEM : next_state = WB;
WB : next_state = IF;
default : next_state = IF;
endcase
end

//output forming logic
always @(current_state or instr) //the outputs depend on the current-state as well as on the input 
begin : OUTPUT_LOGIC
case(current_state)
MEM : 	begin
	//MemRead signal is activated for load instructions to enable reading data
	//from RAM. This signal is only activated if the current state is MEM.
	if(instr[6:0] == 7'b0000011) 
	MemRead = 1;
	else
	MemRead = 0;
	
	//MemWrite signal is activated for store instructions to enable writing data
	//into RAM. This signal is only activated if the current state is MEM.
	if(instr[6:0] == 7'b0100011)
	MemWrite = 1;
	else
	MemWrite = 0;
	
	//these signals are only activated if the current state is WB.
	RegWrite = 0;
	loadPC = 0;
	end
WB : 	begin
	casez(instr[6:0])
	//R-type instructions or I-type instructions require writing back into the register file
	7'b0110011, 7'b00?0011 : RegWrite = 1;
	default : RegWrite = 0;
	endcase
	
	//loadPC signal is activated to enable updating the program counter for the instruction 
	//fetch state which follows next
	loadPC = 1;

	MemRead = 0;
	MemWrite = 0;
	end
default:begin 
	RegWrite = 0;
	loadPC = 0;
	MemRead = 0;
	MemWrite = 0;
	end
endcase
end

/*-------------------------------------------------------------------------*/

endmodule 
