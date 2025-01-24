module cla(a, b, cin, sum, cout, overflow);
	input [7:0] a, b;
	input cin;
	output [7:0] sum;
	output cout, overflow;
	
	wire [7:0] p, g, c, x0, x1, x2, x3, x4, x5, x6, x7;
	assign c[0] = cin;
	
	genvar i;
	generate
		for (i= 0; i < 8; i = i + 1) begin : gen_pg
			xor (p[i], a[i], b[i]);
			and (g[i], a[i], b[i]);
		end
	endgenerate
	
	and (x0[0], cin, p[0]);
	generate
		for(i = 1; i < 8; i = i + 1) begin : gen_x0
			and (x0[i], x0[i-1], p[i]);
		end
	endgenerate
	
	and (x1[1], g[0], p[1]);
	generate
		for(i = 2; i < 8; i = i + 1) begin : gen_x1
			and (x1[i], x1[i-1], p[i]);
		end
	endgenerate
	
	and (x2[2], g[1], p[2]);
	generate
		for(i = 3; i < 8; i = i + 1) begin : gen_x2
			and (x2[i], x2[i-1], p[i]);
		end
	endgenerate
	
	and (x3[3], g[2], p[3]);
	generate
		for(i = 4; i < 8; i = i + 1) begin : gen_x3
			and (x3[i], x3[i-1], p[i]);
		end
	endgenerate
	
	and (x4[4], g[3], p[4]);
	generate
		for(i = 5; i < 8; i = i + 1) begin : gen_x4
			and (x4[i], x4[i-1], p[i]);
		end
	endgenerate
	
	and (x5[5], g[4], p[5]);
	generate
		for(i = 6; i < 8; i = i + 1) begin : gen_x5
			and (x5[i], x5[i-1], p[i]);
		end
	endgenerate
	
	and (x6[6], g[5], p[6]);
	generate
		for(i = 7; i < 8; i = i + 1) begin : gen_x6
			and (x6[i], x6[i-1], p[i]);
		end
	endgenerate
	
	and (x7[7], g[6], p[7]);
	
	or (c[1], x0[0], g[0]);
	or (c[2], x0[1], x1[1], g[1]);
	or (c[3], x0[2], x1[2], x2[2], g[2]);
	or (c[4], x0[3], x1[3], x2[3], x3[3], g[3]);
	
	or (c[5], x0[4], x1[4], x2[4], x3[4], x4[4], g[4]);
	or (c[6], x0[5], x1[5], x2[5], x3[5], x4[5], x5[5], g[5]);
	or (c[7], x0[6], x1[6], x2[6], x3[6], x4[6], x5[6], x6[6], g[6]);
	or (cout, x0[7], x1[7], x2[7], x3[7], x4[7], x5[7], x6[7], x7[7], g[7]);
	
	
	generate
		for (i = 0; i < 8; i = i + 1) begin : gen_sum
			xor sum_xor(sum[i], a[i], b[i], c[i]);
		end
	endgenerate
	
	xor (overflow, cout, c[7]);
	
	
endmodule
