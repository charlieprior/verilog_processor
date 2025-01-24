module addsub(a, b, cin, sum, overflow);
	input [31:0] a, b;
	input cin;
	output [31:0] sum;
	output overflow;
	
	wire [3:0] c, of;
	
	cla cla0_7(a[7:0], b[7:0], cin, sum[7:0], c[0], of[0]);
	cla cla8_15(a[15:8], b[15:8], c[0], sum[15:8], c[1], of[1]);
	cla cla16_23(a[23:16], b[23:16], c[1], sum[23:16], c[2], of[2]);
	cla cla24_31(a[31:24], b[31:24], c[2], sum[31:24], c[3], overflow);
	
endmodule
