module decoder(
	address,
	enable
);
	input [4:0] address;
	output [31:0] enable;
	
	and(enable[0],  ~address[4], ~address[3], ~address[2], ~address[1], ~address[0]);
	and(enable[1],  ~address[4], ~address[3], ~address[2], ~address[1], address[0]);
	and(enable[2],  ~address[4], ~address[3], ~address[2], address[1], ~address[0]);
	and(enable[3],  ~address[4], ~address[3], ~address[2], address[1], address[0]);

	and(enable[4],  ~address[4], ~address[3], address[2], ~address[1], ~address[0]);
	and(enable[5],  ~address[4], ~address[3], address[2], ~address[1], address[0]);
	and(enable[6],  ~address[4], ~address[3], address[2], address[1], ~address[0]);
	and(enable[7],  ~address[4], ~address[3], address[2], address[1], address[0]);
	
	and(enable[8],  ~address[4], address[3], ~address[2], ~address[1], ~address[0]);
	and(enable[9],  ~address[4], address[3], ~address[2], ~address[1], address[0]);
	and(enable[10], ~address[4], address[3], ~address[2], address[1], ~address[0]);
	and(enable[11], ~address[4], address[3], ~address[2], address[1], address[0]);
	
	and(enable[12], ~address[4], address[3], address[2], ~address[1], ~address[0]);
	and(enable[13], ~address[4], address[3], address[2], ~address[1], address[0]);
	and(enable[14], ~address[4], address[3], address[2], address[1], ~address[0]);
	and(enable[15], ~address[4], address[3], address[2], address[1], address[0]);
	
	and(enable[16], address[4], ~address[3], ~address[2], ~address[1], ~address[0]);
	and(enable[17], address[4], ~address[3], ~address[2], ~address[1], address[0]);
	and(enable[18], address[4], ~address[3], ~address[2], address[1], ~address[0]);
	and(enable[19], address[4], ~address[3], ~address[2], address[1], address[0]);
	
	and(enable[20], address[4], ~address[3], address[2], ~address[1], ~address[0]);
	and(enable[21], address[4], ~address[3], address[2], ~address[1], address[0]);
	and(enable[22], address[4], ~address[3], address[2], address[1], ~address[0]);
	and(enable[23], address[4], ~address[3], address[2], address[1], address[0]);
	
	and(enable[24], address[4], address[3], ~address[2], ~address[1], ~address[0]);
	and(enable[25], address[4], address[3], ~address[2], ~address[1], address[0]);
	and(enable[26], address[4], address[3], ~address[2], address[1], ~address[0]);
	and(enable[27], address[4], address[3], ~address[2], address[1], address[0]);
	
	and(enable[28], address[4], address[3], address[2], ~address[1], ~address[0]);
	and(enable[29], address[4], address[3], address[2], ~address[1], address[0]);
	and(enable[30], address[4], address[3], address[2], address[1], ~address[0]);
	and(enable[31], address[4], address[3], address[2], address[1], address[0]);

	

	
endmodule