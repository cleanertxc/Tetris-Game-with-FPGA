module dff7bit( //one 7 bit dff
	input enable,
	input clock,
	input ctrl_reset,
	input [6:0] data_writeReg,
	output [6:0] dff_out
	);
	
	genvar i;
	generate
	for(i=0;i<7;i=i+1)
		begin: flipflop32bit
			dffe_ref dff (dff_out[i],data_writeReg[i],clock,enable,ctrl_reset);
		end
	endgenerate
endmodule