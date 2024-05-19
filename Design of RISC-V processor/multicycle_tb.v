`timescale 1ns/1ns

module multicycle_tb();

/* PORTS */

//inputs
reg rst, clk;
wire[31:0] instr, dReadData;
//outputs
wire MemRead, MemWrite;
wire[31:0] dAddress, dWriteData, PC, WriteBackData;

integer FILE;

/*-------------------------------------------------------------------------*/

/* MODULES */ 

//instantiate multicyle module
multicycle DUT (dAddress, dWriteData, PC, WriteBackData, MemRead, MemWrite, instr, dReadData, rst, clk);

//instantiate rom module
rom ROM_DUT (.clk(clk), .addr(PC[8:0]), .dout(instr));

//instantiate ram module
ram RAM_DUT (.clk(clk), .write_enable(MemWrite), .read_enable(MemRead), .addr(dAddress[8:0]), .din(dWriteData),
		.dout(dReadData));  

/*-------------------------------------------------------------------------*/

/* INPUT SIGNALS AND DATA */

//reset signal is active-high and synchronous
initial
begin
rst = 1'b1;
#15 rst = 1'b0;
end

//clock signal
initial 
clk = 1'b0;

always
#10 clk = ~clk;


/*-------------------------------------------------------------------------*/

/* REGISTER FILE CONTENT */
integer i;

initial
begin
FILE = $fopen("registers.txt");
for(i=0; i<24; i=i+1)
#100 $fdisplay(FILE, "PC: %h	| Write Back Data: %h" ,PC, WriteBackData);
end

/*-------------------------------------------------------------------------*/

endmodule
