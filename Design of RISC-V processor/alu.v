module alu

//parameters to represent ALU operations
#(parameter[3:0] ALUOP_AND = 4'b0000, 
	    	 ALUOP_OR = 4'b0001,
	    	 ALUOP_ADD = 4'b0010,
	    	 ALUOP_SUB = 4'b0110,
	    	 ALUOP_LESS = 4'b0111,
	    	 ALUOP_SHIFT_RIGHT = 4'b1000,
	    	 ALUOP_SHIFT_LEFT = 4'b1001,
		 ALUOP_SHIFT_RIGHT_ARITHM = 4'b1010,
		 ALUOP_XOR = 4'b1101)
	
(output reg zero, output reg [31:0] result,
input wire [31:0] op1, input wire [31:0] op2, input wire [3:0] alu_op);
 
always @*
begin
//select which ALU operation to perform
case(alu_op)
	ALUOP_AND 	  	 : result = op1 & op2;			//logic AND
	ALUOP_OR 	  	 : result = op1 | op2;			//logic OR
	ALUOP_ADD 	  	 : result = op1 + op2;			//addition
	ALUOP_SUB 	  	 : result = op1 - op2;			//subtraction
	ALUOP_LESS 	  	 : result = $signed(op1) < $signed(op2);//less than
	ALUOP_SHIFT_RIGHT 	 : result = op1 >> op2[4:0];		//logical shift right
	ALUOP_SHIFT_LEFT  	 : result = op1 << op2[4:0];		//logical shift left
	ALUOP_SHIFT_RIGHT_ARITHM : result = $signed(op1) >>> op2[4:0];	//arithmetic shift right
	ALUOP_XOR 	  	 : result = op1 ^ op2;			//logic XOR
	default 	  	 : result = 32'sb0;
endcase

//indicate when the result of the ALU operation is equal to zero
if(result == 0)
zero = 1;
else
zero = 0;

end

endmodule
