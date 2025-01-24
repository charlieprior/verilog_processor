module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);

   input [31:0] data_operandA, data_operandB;
   input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

   output [31:0] data_result;
   output isNotEqual, isLessThan, overflow;
	
	genvar i;
	
	// Decode the opcode
	wire addcode, subcode, andcode, orcode;
	and(addcode, ~ctrl_ALUopcode[4], ~ctrl_ALUopcode[3], ~ctrl_ALUopcode[2], ~ctrl_ALUopcode[1], ~ctrl_ALUopcode[0]);
	and(subcode, ~ctrl_ALUopcode[4], ~ctrl_ALUopcode[3], ~ctrl_ALUopcode[2], ~ctrl_ALUopcode[1],  ctrl_ALUopcode[0]);
	and(andcode, ~ctrl_ALUopcode[4], ~ctrl_ALUopcode[3], ~ctrl_ALUopcode[2],  ctrl_ALUopcode[1], ~ctrl_ALUopcode[0]);
	and(orcode,  ~ctrl_ALUopcode[4], ~ctrl_ALUopcode[3], ~ctrl_ALUopcode[2],  ctrl_ALUopcode[1],  ctrl_ALUopcode[0]);
	and(sllcode, ~ctrl_ALUopcode[4], ~ctrl_ALUopcode[3],  ctrl_ALUopcode[2], ~ctrl_ALUopcode[1], ~ctrl_ALUopcode[0]);
	and(sracode, ~ctrl_ALUopcode[4], ~ctrl_ALUopcode[3],  ctrl_ALUopcode[2], ~ctrl_ALUopcode[1],  ctrl_ALUopcode[0]);
	
	// Addition and subtraction
	wire [31:0] B_input;
	assign B_input = subcode ? ~data_operandB : data_operandB;
	
	wire [31:0] addsub_result;
	addsub addsub0(data_operandA, B_input, subcode, addsub_result, overflow);
	
	// Not equal to
	or(isNotEqual, addsub_result[0], addsub_result[1], addsub_result[2], addsub_result[3],
	               addsub_result[4], addsub_result[5], addsub_result[6], addsub_result[7],
						addsub_result[8], addsub_result[9], addsub_result[10], addsub_result[11],
						addsub_result[12], addsub_result[13], addsub_result[14], addsub_result[15],
						addsub_result[16], addsub_result[17], addsub_result[18], addsub_result[19],
						addsub_result[20], addsub_result[21], addsub_result[22], addsub_result[23],
						addsub_result[24], addsub_result[25], addsub_result[26], addsub_result[27],
						addsub_result[28], addsub_result[29], addsub_result[30], addsub_result[31]);
	
	// Less than
	xor(isLessThan, addsub_result[31], overflow);
	
	// AND
	wire [31:0] and_result;
	generate
		for (i = 0; i < 32; i = i + 1) begin : gen_and
			and(and_result[i], data_operandA[i], data_operandB[i]);
		end
	endgenerate
	
	// OR
	wire [31:0] or_result;
	generate
		for (i = 0; i < 32; i = i + 1) begin : gen_or
			or(or_result[i], data_operandA[i], data_operandB[i]);
		end
	endgenerate
	
	// SLL
	wire [31:0] sl0, sl1, sl2, sl3, sll_result;
	assign sl0 = ctrl_shiftamt[0] ? {data_operandA[30:0], 1'b0} : data_operandA;
	assign sl1 = ctrl_shiftamt[1] ? {sl0[29:0], 2'b0} : sl0;
	assign sl2 = ctrl_shiftamt[2] ? {sl1[27:0], 4'b0} : sl1;
	assign sl3 = ctrl_shiftamt[3] ? {sl2[23:0], 8'b0} : sl2;
	assign sll_result = ctrl_shiftamt[4] ? {sl3[15:0], 16'b0} : sl3;
	
	// SRA
	wire [31:0] sr0, sr1, sr2, sr3, sra_result;
	assign sign_bit = data_operandA[31];
	assign sr0 = ctrl_shiftamt[0] ? {{1{sign_bit}}, data_operandA[31:1]} : data_operandA;
	assign sr1 = ctrl_shiftamt[1] ? {{2{sign_bit}}, sr0[31:2]} : sr0;
	assign sr2 = ctrl_shiftamt[2] ? {{4{sign_bit}}, sr1[31:4]} : sr1;
	assign sr3 = ctrl_shiftamt[3] ? {{8{sign_bit}}, sr2[31:8]} : sr2;
	assign sra_result = ctrl_shiftamt[4] ? {{16{sign_bit}}, sr3[31:16]} : sr3;
	
	// Assign final result bassed on opcode
	assign data_result = addcode ? addsub_result :
								subcode ? addsub_result : 
								andcode ? and_result    :
								orcode  ? or_result     :
								sllcode ? sll_result    :
								sracode ? sra_result    : 32'bX;

endmodule
