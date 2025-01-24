module regfile (
    clock,
    ctrl_writeEnable,
    ctrl_reset, ctrl_writeReg,
    ctrl_readRegA, ctrl_readRegB, data_writeReg,
    data_readRegA, data_readRegB
);

   input clock, ctrl_writeEnable, ctrl_reset;
   input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
   input [31:0] data_writeReg;

   output [31:0] data_readRegA, data_readRegB;
	
	// Decode the addresses
	wire [31:0] write_decoded, readA_decoded, readB_decoded;
	decoder decodeW(ctrl_writeReg, write_decoded);
	decoder decodeA(ctrl_readRegA, readA_decoded);
	decoder decodeB(ctrl_readRegB, readB_decoded);
	
	// Register 0 is always 0
	assign data_readRegA = readA_decoded[0] ? 32'b0 : 32'bz;
	assign data_readRegB = readB_decoded[0] ? 32'b0 : 32'bz;
	
	genvar i;
	generate
	  for (i = 1; i < 32; i = i + 1) begin : gen_dffe
		 wire [31:0] q;
		 wire enable;
		 
		 and(enable, write_decoded[i], ctrl_writeEnable);
		 
		 dffe_ref dffe0(q, data_writeReg, clock, enable, ctrl_reset);
		 assign data_readRegA = readA_decoded[i] ? q : 32'bz;
		 assign data_readRegB = readB_decoded[i] ? q : 32'bz;
	  end
	endgenerate
	
endmodule
