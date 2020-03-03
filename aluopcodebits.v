module aluopcodebits(
input [4:0] ctrl_writeReg,
	output [5:0] decorderOut);
	
	wire [4:0] ctrl_writeReg_NOT;
	
	genvar i;
	generate 
		for (i=0;i<5;i=i+1)
		begin: write_ctrl_nots
		not wirtectrlnots (ctrl_writeReg_NOT[i],ctrl_writeReg[i]);		
		end
	endgenerate

	and o5 (decorderOut[5],ctrl_writeReg_NOT[4],ctrl_writeReg_NOT[3],ctrl_writeReg[2],ctrl_writeReg_NOT[1],ctrl_writeReg[0]); //sra
	and o4 (decorderOut[4],ctrl_writeReg_NOT[4],ctrl_writeReg_NOT[3],ctrl_writeReg[2],ctrl_writeReg_NOT[1],ctrl_writeReg_NOT[0]); //sll
	and o3 (decorderOut[3],ctrl_writeReg_NOT[4],ctrl_writeReg_NOT[3],ctrl_writeReg_NOT[2],ctrl_writeReg[1],ctrl_writeReg[0]); //or
	and o2 (decorderOut[2],ctrl_writeReg_NOT[4],ctrl_writeReg_NOT[3],ctrl_writeReg_NOT[2],ctrl_writeReg[1],ctrl_writeReg_NOT[0]); //and
	and o1 (decorderOut[1],ctrl_writeReg_NOT[4],ctrl_writeReg_NOT[3],ctrl_writeReg_NOT[2],ctrl_writeReg_NOT[1],ctrl_writeReg[0]);//sub
	and o0 (decorderOut[0],ctrl_writeReg_NOT[4],ctrl_writeReg_NOT[3],ctrl_writeReg_NOT[2],ctrl_writeReg_NOT[1],ctrl_writeReg_NOT[0]);//add
endmodule