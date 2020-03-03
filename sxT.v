module sxT( // works
	input [31:0] imemout,
	output [31:0] extendedOut	
	);
	
	wire signBit;
	//wire [16:0] immediate;
	assign extendedOut [26:0] = imemout [26:0];
	assign signBit = imemout[26] ? 1'b1:1'b0;
	
	// extend
	assign extendedOut[27] = signBit;
	assign extendedOut[28] = signBit;
	assign extendedOut[29] = signBit;
	assign extendedOut[30] = signBit;
	assign extendedOut[31] = signBit;
	
endmodule