/**
 * READ THIS DESCRIPTION!
 *
 * The processor takes in several inputs from a skeleton file.
 *
 * Inputs
 * clock: this is the clock for your processor at 50 MHz
 * reset: we should be able to assert a reset to start your pc from 0 (sync or
 * async is fine)
 *
 * Imem: input data from imem
 * Dmem: input data from dmem
 * Regfile: input data from regfile
 *
 * Outputs
 * Imem: output control signals to interface with imem
 * Dmem: output control signals and data to interface with dmem
 * Regfile: output control signals and data to interface with regfile
 *
 * Notes
 *
 * Ultimately, your processor will be tested by subsituting a master skeleton, imem, dmem, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file acts as a small wrapper around your processor for this purpose.
 *
 * You will need to figure out how to instantiate two memory elements, called
 * "syncram," in Quartus: one for imem and one for dmem. Each should take in a
 * 12-bit address and allow for storing a 32-bit value at each address. Each
 * should have a single clock.
 *
 * Each memory element should have a corresponding .mif file that initializes
 * the memory element to certain value on start up. These should be named
 * imem.mif and dmem.mif respectively.
 *
 * Importantly, these .mif files should be placed at the top level, i.e. there
 * should be an imem.mif and a dmem.mif at the same level as process.v. You
 * should figure out how to point your generated imem.v and dmem.v files at
 * these MIF files.
 *
 * imem
 * Inputs:  12-bit address, 1-bit clock enable, and a clock
 * Outputs: 32-bit instruction
 *
 * dmem
 * Inputs:  12-bit address, 1-bit clock, 32-bit data, 1-bit write enable
 * Outputs: 32-bit data at the given address
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem
	 
    // Regfile
    ctrl_writeEnable,               // O: Write enable for regfile
    ctrl_writeReg,                  // O: Register to write to in regfile
    ctrl_readRegA,                  // O: Register to read from port A of regfile
    ctrl_readRegB,                  // O: Register to read from port B of regfile
    data_writeReg,                  // O: Data to write to for regfile
    data_readRegA,                  // I: Data from port A of regfile
    data_readRegB	                  // I: Data from port B of regfile
	 );
    // Control signals
    input clock, reset;

    // Imem
    output [11:0] address_imem;
    input [31:0] q_imem;

    // Dmem
    output [11:0] address_dmem;
    output [31:0] data;
    output wren;
    input [31:0] q_dmem;

    // Regfile
    output ctrl_writeEnable;
    output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
    output [31:0] data_writeReg;
    input [31:0] data_readRegA, data_readRegB;
	 
	 // Decoding q_imem into instructions
	 wire [4:0] opcode, rd, rs, rt, shamt, ALUop;
	 wire [16:0] N;
	 wire [31:0] opdec;
	 wire [26:0] T;

	 decoder opdecode(opcode, opdec);
	 wire reg_ins, imm_ins; // reg_ins for register instructions, imm_ins for immediate
	 assign reg_ins = opdec[0];
	 or(imm_ins, opdec[6], opdec[2], opdec[5], opdec[7], opdec[8]);

	 assign opcode = q_imem[31:27];
	 assign rd = q_imem[26:22];
	 assign rs = q_imem[21:17];
	 assign rt = reg_ins ? q_imem[16:12] : 5'bz;
	 assign shamt = reg_ins ? q_imem[11:7] : 5'bz;
	 assign ALUop = reg_ins ? q_imem[6:2] : opdec[5] ? 5'b0 : 5'bz;
	 assign N = imm_ins ? q_imem[16:0] : 17'bz;
	 assign T = q_imem[26:0];
	 
	 // Implementation of PC
	 wire [31:0] PCPlusOne;
	 wire [31:0] newPC;
	 wire [31:0] nextPC;
	 
	 // BNE
	 wire [31:0] bnePC;
	 and (bnerst, opdec[2], bne);
	 alu bnechk(data_readRegA, data_readRegB, 5'b1, 5'b0, x2, bne, y3, z3); //alu for rd != rs
	 alu bnealu(PCPlusOne, {{15{N[16]}}, N}, 5'b0, 5'b0, bnePC, x1, y1, z1); //alu for PC + 1 + N
	 
	 // BLT
	 and (bltrst, opdec[6], blt);
	 alu bltchk(data_readRegA, data_readRegB, 5'b1, 5'b0, x3, y3, blt, z3); //alu for rd < rs
	 
	 // BEX
	 alu bexalu(data_readRegA, 32'b0, 5'b1, 5'b0, x4, bex, y4, z4);
	 and (bexrst, opdec[22], bex);
	 
	 // PC Plus One
	 alu incrementer({20'b0, address_imem}, 32'b1, 5'b0, 5'b0, PCPlusOne, x, y, z);
	 
	 // Assign next PC based on jump conditions
	 assign newPC = opdec[1] ? {5'b0, T} :
						 bnerst ? bnePC : 
						 opdec[3] ? {5'b0, T} :
						 opdec[4] ? data_readRegA :
						 bltrst ? bnePC :
						 bexrst ? {5'b0, T} : PCPlusOne;
	 dffe_ref counter(nextPC, newPC, clock, 1'b1, reset);
	 assign address_imem = nextPC[11:0];
	 
	 // Main ALU
	 wire [31:0] alures;
	 wire [31:0] argumentB;
	 assign argumentB = opdec[0] ? data_readRegB : opdec[5] ? {{15{N[16]}}, N} : 32'bz;
	 alu mainALU(data_readRegA, argumentB, ALUop, shamt, alures, isNotEqual, isLessThan, overflow);
	 
	 and (overflowWrite, opdec[0], overflow);

	 // Registers
	 or(ctrl_writeEnable, opdec[21], opdec[0], opdec[3], opdec[5], opdec[8]); // Write if add, addi, lw, jal
	 assign data_writeReg = opdec[21] ? {5'b0, T} :
									opdec[3] ? PCPlusOne :
									opdec[0] ? (overflow ? 32'b1 : alures) :
									opdec[5] ? alures :
									opdec[8] ? q_dmem : 32'bz; // Data to write
	 assign ctrl_writeReg = overflowWrite ? 5'd30 :
									opdec[21] ? 5'd30 :
									opdec[3] ? 5'd31 : rd;
    assign ctrl_readRegA = opdec[6] ? rd :
									opdec[4] ? rd :
									opdec[2] ? rd :
									opdec[7] ? rd :
									opdec[22] ? 5'd30 : rs;
    or(lwsw, opdec[7], opdec[8]);
	 assign ctrl_readRegB = opdec[6] ? rs :
									opdec[2] ? rs :
									lwsw ? rs : rt;

	 // ALU for the sw and lw functions to add N to register result
	 alu wordALU(data_readRegB, {15'b0, N}, 5'b0, 5'b0, address_dmem, a, b, c);
	
	 assign data = data_readRegA; // Data to write to dmem is the value in register A ($rd)
	 assign wren = opdec[7]; // Write enable if sw
endmodule