module decoder(output wire[3:0] alu_op, input wire btnc, btnl, btnr);

//combinational logic to produce alu_op[0]
not (p1, btnr);
xor (p2, btnl, btnc);
and (p3, p2, btnr);
and (p4, p1, btnl);
or (alu_op[0], p3, p4);

//combinational logic to produce alu_op[1]
not (p5, btnl);
not (p6, btnc);
and (p7, btnl, btnr);
and (p8, p5, p6);
or  (alu_op[1], p7, p8);

//combinational logic to produce alu_op[2]
and (p9, btnr, btnl);
xor (p10, btnr, btnl);
or  (p11, p9, p10);
not (p12, btnc);
and (alu_op[2], p11, p12);

//combinational logic to produce alu_op[3]
xnor(p13, btnr, btnc);
not (p14, btnr);
and (p15, btnc, p14);
or  (p16, p13, p15);
and (alu_op[3], btnl, p16);


endmodule
