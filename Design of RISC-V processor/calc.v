module calc(output reg [15:0] led, input wire [15:0] sw, input wire btnc, 
input wire btnl, input wire btnr, input wire btnu, input wire btnd, 
input wire clk);

//register to store the current value of the result of the ALU operation
reg [15:0] accumulator;

//internal nets
wire [31:0] result;
wire [3:0] alu_op_control;

//alu control system instantiation
decoder DECODER (.alu_op(alu_op_control), .btnc(btnc), .btnr(btnr), .btnl(btnl));

//alu module instantiation
alu ALU (.zero(), .result(result), .op1({{16 {accumulator[15]}},accumulator}), .op2({{16 {sw[15]}},sw}), 
.alu_op(alu_op_control));  

//register (accumulator) design

always@(posedge clk or posedge btnd)
//reset register when synchronous btnu signal is high
begin
if(btnu)
accumulator <= 16'h00;
//update register on positive edge of unsynchronous signal btnd
else if(btnd)
accumulator <= result[15:0];
end


//connect accumulator output to led
always @*
led = accumulator;

endmodule