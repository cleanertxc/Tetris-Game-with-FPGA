module clockdivider(
	input clock,
	input reset,
	output q_50,
	output clock_25,
	output clock_12
);

wire enable = 1'b1;
//wire q_50;
dffe_ref MHz_50 (q_50,~q_50,clock,enable,reset);
dffe_ref MHz_25 (clock_25,~clock_25,q_50,enable,reset);
dffe_ref MHz_12 (clock_12,~clock_12,clock_25,enable,reset);
endmodule
