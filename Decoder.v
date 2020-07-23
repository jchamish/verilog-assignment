module Decoder(
	input [11:0]input_string,
	input clock,
	output reg [3:0]addr1, addr2, ALU_op);
	
always @(posedge clock)
begin
	addr1 = input_string[3:0];
	addr2 = input_string[7:4];
	ALU_op = input_string[11:8];
end
endmodule
