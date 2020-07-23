module top(clk, in1, in2, alu1_out, alu2_out, zero_flag1, zero_flag2, overflow1, overflow2);
input clk;
input [11:0] in1, in2;
output [7:0] alu1_out, alu2_out;
output zero_flag1, zero_flag2, overflow1, overflow2;

wire L2_start, L2_done;
wire [1:0] bus_select;
tri [11:0] bus;
wire [7:0] data_out1, data_out2, alu1data1, alu1data2, alu2data1, alu2data2;
wire c1_done, c2_done;
wire c1_start, c2_start;
wire read1, read2;
wire [3:0]ID1, ID2;
wire c1_go, c2_go;
wire [11:0] bus_L2, bus_c1, bus_c2;
wire [11:0] input1, input2;
wire [3:0] opcode1, opcode2;
wire empty1,empty2;
wire alu1_done, alu2_done;
wire pop1, pop2;
wire full1, full2, init1, init2;
reg [11:0]input_reg1, input_reg2;
reg [1:0]load_input_FIFO1, load_input_FIFO2;

L2_cache  L2(bus_L2, L2_done, L2_start, bus, c1_done, c2_done, clk);
L1_cache L1_1(data_out1, c1_done, bus_c1, c1_start, read1, ID1, bus, c1_go, clk);
L1_cache L1_2(data_out2, c2_done, bus_c2, c2_start, read2, ID2, bus, c2_go, clk);
arbiter arbiter(c1_go, c2_go, L2_start, bus_select, c2_done, c1_done, c1_start, c2_start, L2_done, clk);
Decoder decoder1(input1, clk, empty1, c1_done, alu1_done, c1_start, data_out1, alu1data1, alu1data2, opcode1, ID1, pop1, read1, init1);
Decoder decoder2(input2, clk, empty2, c2_done, alu2_done, c2_start, data_out2, alu2data1, alu2data2, opcode2, ID2, pop2, read2, init2);
FIFO1 Input_FIFO1 (clk, load_input_FIFO1, in1, full1, empty1, input1);
FIFO1 Input_FIFO2 (clk, load_input_FIFO2, in2, full2, empty2, input2);
ALU alu1( opcode1, alu1data1, alu1data2, clk, alu1_out, zero_flag1, overflow1, alu1_done);
ALU alu2( opcode2, alu2data1, alu2data2, clk, alu2_out, zero_flag2, overflow2, alu2_done);

assign bus = (bus_select == 0) ? bus_c1 : 12'bz;
assign bus = (bus_select == 1) ? bus_c2 : 12'bz;
assign bus = (bus_select == 2) ? bus_L2 : 12'bz;

always@(posedge clk)
begin
	input_reg1 = in1;
end

always@(posedge clk)
begin
	input_reg2 = in2;
end

always@*
begin
	if (init1 == 1)
		load_input_FIFO1 = 2'b00;
	else if (input_reg1 != in1)
		load_input_FIFO1 = 2'b01;
	else if (pop1 == 1)
		load_input_FIFO1 = 2'b10;
	else
		load_input_FIFO1 = 2'b11;
	if (init2 == 1)
		load_input_FIFO2 = 2'b00;
	else if (input_reg2 != in2)
		load_input_FIFO2 = 2'b01;
	else if (pop2 == 1)
		load_input_FIFO2 = 2'b10;
	else
		load_input_FIFO2 = 2'b11;

end

endmodule