module regfile(output reg [31:0] readData1, readData2, input wire [31:0] writeData, 
input wire [4:0] readReg1, readReg2, writeReg, input wire clk, write);

//register file, contains 32 words of 32-bit length each
reg [31:0] Mem [0:31];

//initialize registers to 0
integer i;
initial 
begin
for(i=0; i<32; i=i+1)
Mem[i] = 32'b0;
end

always @(posedge clk)
begin	//read data from memory 
readData1 = Mem[readReg1];
readData2 = Mem[readReg2];
if(write)	//if the write signal is high write data into memory 
Mem[writeReg] = writeData;
end

endmodule
