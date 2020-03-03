module sx( // works
	input [31:0] imemout,
	output [31:0] extendedOut	
	);
	
	wire signBit;
	//wire [16:0] immediate;
	assign extendedOut [16:0] = imemout [16:0];
	assign signBit = imemout[16] ? 1'b1:1'b0;
	
	// extend
	assign extendedOut[17] = signBit;
	assign extendedOut[18] = signBit;
	assign extendedOut[19] = signBit;
	assign extendedOut[20] = signBit;
	assign extendedOut[21] = signBit;
	assign extendedOut[22] = signBit;
	assign extendedOut[23] = signBit;
	assign extendedOut[24] = signBit;
	assign extendedOut[25] = signBit;
	assign extendedOut[26] = signBit;
	assign extendedOut[27] = signBit;
	assign extendedOut[28] = signBit;
	assign extendedOut[29] = signBit;
	assign extendedOut[30] = signBit;
	assign extendedOut[31] = signBit;
	
endmodule