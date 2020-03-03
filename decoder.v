module mydecoder(
	input [4:0] ctrl_writeReg,
	output JP, DMwe, BR, Rwd,Rdst,Rwe,ALUb,ALUop
);
wire [4:0] ctrl_writeReg_NOT;
	genvar i;
	generate 
		for (i=0;i<5;i=i+1)
		begin: write_ctrl_nots
		not wirtectrlnots (ctrl_writeReg_NOT[i],ctrl_writeReg[i]);		
		end
	endgenerate
	 
	 wire [10:0] decoderOut;
	
	and o22 (decoderOut[10],ctrl_writeReg[4],ctrl_writeReg_NOT[3],ctrl_writeReg[2],ctrl_writeReg[1],ctrl_writeReg_NOT[0]); //bext
	and o21 (decoderOut[9],ctrl_writeReg[4],ctrl_writeReg_NOT[3],ctrl_writeReg[2],ctrl_writeReg_NOT[1],ctrl_writeReg[0]); //setx

	and o8 (decoderOut[8],ctrl_writeReg_NOT[4],ctrl_writeReg[3],ctrl_writeReg_NOT[2],ctrl_writeReg_NOT[1],ctrl_writeReg_NOT[0]); //lw 
	and o7 (decoderOut[7],ctrl_writeReg_NOT[4],ctrl_writeReg_NOT[3],ctrl_writeReg[2],ctrl_writeReg[1],ctrl_writeReg[0]); //sw
	and o6 (decoderOut[6],ctrl_writeReg_NOT[4],ctrl_writeReg_NOT[3],ctrl_writeReg[2],ctrl_writeReg[1],ctrl_writeReg_NOT[0]); //blt
	and o5 (decoderOut[5],ctrl_writeReg_NOT[4],ctrl_writeReg_NOT[3],ctrl_writeReg[2],ctrl_writeReg_NOT[1],ctrl_writeReg[0]); //addi
	and o4 (decoderOut[4],ctrl_writeReg_NOT[4],ctrl_writeReg_NOT[3],ctrl_writeReg[2],ctrl_writeReg_NOT[1],ctrl_writeReg_NOT[0]); //jr
	and o3 (decoderOut[3],ctrl_writeReg_NOT[4],ctrl_writeReg_NOT[3],ctrl_writeReg_NOT[2],ctrl_writeReg[1],ctrl_writeReg[0]); //jal
	and o2 (decoderOut[2],ctrl_writeReg_NOT[4],ctrl_writeReg_NOT[3],ctrl_writeReg_NOT[2],ctrl_writeReg[1],ctrl_writeReg_NOT[0]); //bne
	and o1 (decoderOut[1],ctrl_writeReg_NOT[4],ctrl_writeReg_NOT[3],ctrl_writeReg_NOT[2],ctrl_writeReg_NOT[1],ctrl_writeReg[0]); //j
	and o0 (decoderOut[0],ctrl_writeReg_NOT[4],ctrl_writeReg_NOT[3],ctrl_writeReg_NOT[2],ctrl_writeReg_NOT[1],ctrl_writeReg_NOT[0]); //rtype
	
	wire jpout,brout,rdstout,rweout, alubout,aluopout;
	
	OR jpOR (jpout,decoderOut[1],decoderOut[3],decoderOut[4],decoderOut[10],decoderOut[9]);
	OR brOR (brout,decoderOut[2],decoderOut[6]);
	NOT rdstNOT (rdstout,decoderOut[0]);
	OR rweOR (rweout,decoderOut[0],decoderOut[8],decoderOut[5]);
	OR alubOR (alubout,decoderOut[8],decoderOut[7],decoderOut[5]);
	OR aluopoutOR (aluopout,decoderOut[2],decoderOut[6]);
	
	assign JP = jpout ? 1'b1 : 1'b0;
	assign DMwe = decoderOut[7] ? 1'b1 : 1'b0;
	assign BR = brout ? 1'b1 : 1'b0;
	assign Rwd = decoderOut[8] ? 1'b1 : 1'b0;
	assign Rdst = rdstout ? 1'b1 : 1'b0;
	assign Rwe = rweout ? 1'b1 : 1'b0;
	assign ALUb = alubout ? 1'b1 : 1'b0;
	assign ALUop = aluopout ? 1'b1 : 1'b0;
	
	
	
endmodule