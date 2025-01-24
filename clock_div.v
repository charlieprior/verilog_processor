module clock_div(clk,reset,clkdiv);
	input clk, reset;
	output clkdiv;
	
	wire din;
	wire q;
	assign din = ~q;
	dffe_ref DFF(q, din, clk, 1'b1, reset);
	
	assign clkdiv1 = q;
	
	wire din2, q2;
	assign din2 = ~q2;
	
	dffe_ref DFF2(q2, din2, clkdiv1, 1'b1, reset);
	
	assign clkdiv = q2;
	
endmodule 