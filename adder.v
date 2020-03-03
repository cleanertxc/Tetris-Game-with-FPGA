module adder(
	input [31:0] data_operandB,
	input [31:0] data_operandA, 
	output overflow,
	output [31:0] add_result);
	wire temp;
	
	csa32bit csa(data_operandA[31:0],data_operandB[31:0],1'b0,add_result[31:0],overflow,temp);
	
endmodule 

module csa32bit( //csa32bit
	input [31:0] a,
	input [31:0] b,
	input cin,
	output [31:0] sum,
	output overflow,
	//output cin_final
	output c_out
	//output temp_cin_final3);
	);
	
	wire temp_cin_final, temp_cin_final1, temp_cin_final2, temp_cin_final3;
	//wire temp
	
	wire co1, co2, co3, c04;
	eightbitcsa csa1 (a[7:0], b[7:0], cin, sum[7:0], co1,temp_cin_final);
	eightbitcsa csa2 (a[15:8], b[15:8], co1, sum[15:8], co2,temp_cin_final1);
	eightbitcsa csa3 (a[23:16], b[23:16], co2, sum[23:16], co3,temp_cin_final2);
	eightbitcsa csa4 (a[31:24], b[31:24], co3, sum[31:24], c_out,temp_cin_final3);
	
//	wire firstand;
//	and first_and (firstand,a[31],b[31]);
	wire firstxor;
	xor first_xor (firstxor,temp_cin_final3,c_out);
	assign overflow = firstxor ? 1'b1 : 1'b0;
	


endmodule

module eightbitcsa(//eightbitcsa(
	input [7:0] a,
	input [7:0] b,
	input cin,
	output [7:0] sum,
	output c_out,
	output c_in_final);
	//output cin_final,
	//output temp_cin1_final);
	
	wire c0_out, c1_out;
	wire [7:0] sum1bit;
	wire [7:0] sum0bit;
	wire [7:0] suminbit;
	wire  cin0;
	wire  cin1;
	wire  cin2;
//wire cin0, cin1;
wire temp_cin_final;
wire temp_cin0_final;
wire temp_cin1_final;
	
	//fourbit_adder bit0 (a[3:0], b[3:0], 1'b0, sum[3:0], cin0);  // c_out should be connected to select of summux
	fourbit_adder bit0 (a[3:0], b[3:0], cin, sum[3:0], cin0,temp_cin_final);  // c_out should be connected to select of summux

	// for when cin 0
	fourbit_adder bit1 (a[7:4], b[7:4], 1'b0, sum0bit[7:4], cin1,temp_cin0_final);		
//	// cin 1
	fourbit_adder bit2 (a[7:4], b[7:4], 1'b1, sum1bit[7:4], cin2,temp_cin1_final);

	
	// sum mux
	mymux mux8bit4(sum0bit[4], sum1bit[4], cin0, sum[4]);
	mymux mux8bit5(sum0bit[5], sum1bit[5], cin0, sum[5]);
	mymux mux8bit6(sum0bit[6], sum1bit[6], cin0, sum[6]);
	mymux mux8bit7(sum0bit[7], sum1bit[7], cin0, sum[7]);

	// mux for carry
	mymux muxcarry(cin1,cin2,cin0,c_out);
	mymux muxcarry2(temp_cin0_final,temp_cin1_final,temp_cin_final,c_in_final);
	//assign c_in_final = c_out;
	
	
	
endmodule 

module fourbit_adder( //fourbit_adder
	input [3:0] a,
	input [3:0] b,
	input cin0,
	output [3:0] sum,
	output c_out,
	output final_cin);
	
	wire [3:1] cin;
	
	onebit_adder bit1 (a[0], b[0], cin0, sum[0], cin[1]);
	onebit_adder bit2 (a[1], b[1], cin[1], sum[1], cin[2]);
	onebit_adder bit3 (a[2], b[2], cin[2], sum[2], cin[3]);
	onebit_adder bit4 (a[3], b[3], cin[3], sum[3], c_out);
	
	assign final_cin = cin[3];
	
endmodule 

module onebit_adder(    //onebit_adder(
	input a,
	input b,
	input c_in,
	output sum,
	output c_out);
	
	wire xorOut, xorab, abandout, cinxorOut;
	
	xor x_or(xorab, a, b);
	
	and ab_and(abandout, a, b);
	and cin_and(cinxorOut, xorab, c_in);
	or my_or(c_out, cinxorOut, abandout);
	xor sum_xor(sum, xorab, c_in);
endmodule
module my_not(
	input b,
	output bnot);
	
	not b_not(bnot,b);
endmodule

module muxadder(  // not of B for adder can't figure out other way
	input b,
	input s,
	output out);
	
	wire andone, andtwo, nots;
	wire notb;
	not b_not(notb,b);
	not s_not(nots,s);
	
	and my_andone(andone, notb,nots);
	and my_andtwo(andtwo, s, b);
	or my_or(out, andone, andtwo);
	
endmodule

module mymux(
	input a,
	input b,
	input s,
	output out);
	
	wire andone, andtwo, nots;
	not s_not(nots,s);
	
	and my_andone(andone, a,nots);
	and my_andtwo(andtwo, s, b);
	or my_or(out, andone, andtwo);
endmodule