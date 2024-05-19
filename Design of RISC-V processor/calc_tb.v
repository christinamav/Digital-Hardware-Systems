`timescale 1ns/1ns

module calc_tb();

//inputs
reg clk, btnc, btnu, btnd, btnr, btnl;
reg [15:0] sw;
//output
wire [15:0] led;

//instantiate calculator module
calc CALC (.led(led), .sw(sw), .btnc(btnc), .btnl(btnl), .btnr(btnr), 
.btnu(btnu), .btnd(btnd), .clk(clk));

//reset
initial
begin
btnu = 1'b1;
#15 btnu = 1'b0;
end

//accumulator update button
initial
begin
btnd = 1'b0;
end

always
begin
#16 btnd = 1'b1;
#1  btnd = 1'b0;
end

//clock
initial 
begin
clk = 1'b0;
end

always
begin
#10 clk = ~clk;
end

//control input values
initial
begin
#15	btnl = 1'b0; btnc = 1'b1; btnr = 1'b1;
#15	btnl = 1'b0; btnc = 1'b1; btnr = 1'b0;
#15	btnl = 1'b0; btnc = 1'b0; btnr = 1'b0;
#15	btnl = 1'b0; btnc = 1'b0; btnr = 1'b1;
#15	btnl = 1'b1; btnc = 1'b0; btnr = 1'b0;
#15	btnl = 1'b1; btnc = 1'b0; btnr = 1'b1;
#15	btnl = 1'b1; btnc = 1'b1; btnr = 1'b0;
#15	btnl = 1'b1; btnc = 1'b1; btnr = 1'b1;
#15	btnl = 1'b1; btnc = 1'b0; btnr = 1'b1;
end


//switches input
initial
begin
#15	sw = 16'sh1234;
#15	sw = 16'sh0ff0;
#15	sw = 16'sh324f;
#15	sw = 16'sh2d31;
#15	sw = 16'shffff;
#15	sw = 16'sh7346;
#15	sw = 16'sh0004;
#15	sw = 16'sh0004;
#15	sw = 16'shffff;
end

endmodule
