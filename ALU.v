module ALU(
	input [3:0]op_code,
	input [7:0]data1,
	input [7:0]data2,
	input clock,
	output reg [7:0]output_string,
	output reg zero_flag, overflow_flag, done);
	`define OP_NOOP 4'b0000
	`define OP_ADD 4'b0001
	`define OP_SUBTRACT 4'b0010
	`define OP_AND 4'b0110
	`define OP_OR 4'b0111
	`define OP_ZERO_TEST 4'b1001
	`define OP_GT 4'b1010
	`define OP_EQ 4'b1011
	`define OP_LT 4'b1100

always@ *
begin
	if(output_string == 0)
		zero_flag = 1;
	else
		zero_flag = 0;
end

always@ (posedge clock)
begin
done = 0;
	case(op_code)
		`OP_NOOP	:
			begin
				output_string = 0;
				overflow_flag = 0;
				done = 1;
			end
		`OP_ADD	:	
			begin
				simple_addr(data1, data2, overflow_flag, output_string);//add
				done = 1;
			end
		`OP_SUBTRACT	:
			begin
				simple_addr(data1, ((data2 ^ 8'hFF) + 1), overflow_flag, output_string);//subtract
				done = 1;
			end
		`OP_AND	:
			begin
				my_and(data1, data2, output_string);//AND
				overflow_flag = 0;
				done = 1;
			end
		`OP_OR	:
			begin	
				my_or(data1, data2, output_string);//OR
				overflow_flag = 0;
				done = 1;
			end
		`OP_ZERO_TEST	:
			begin	
				zeroes(data1, output_string);//Zero
				overflow_flag = 0;
				done = 1;
			end
		`OP_GT :	
			begin 
				greater_than(data1, data2, output_string);//Greater Than
				overflow_flag = 0;
				done = 1;
			end
		`OP_EQ : 
			begin
				equal_to(data1, data2, output_string);//Equal To
				overflow_flag = 0;
				done = 1;
			end
		`OP_LT :
			begin 
				less_than(data1, data2, output_string);//Less Than
				overflow_flag = 0;
				done = 1;
			end
	endcase
end

task greater_than(
	input [7:0]in1, in2,
	output reg greater);
	begin
		if (in1 > in2)
			greater = 1;
		else
			greater = 0;
	end
endtask

task equal_to;
	input [7:0]in1, in2;
	output reg equal;
	begin
		if (in1 == in2)
			equal = 1;
		else
			equal = 0;
	end
endtask

task less_than;
	input [7:0]in1, in2;
	output reg less;
	begin
	if (in1 < in2)
		less = 1;
	else
		less = 0;
	end
endtask

task zeroes;
	input [7:0]in;
	output reg out;
		begin
			if (in == 0)
				out = 1;
			else
				out = 0;
		end
endtask

task my_and;
	input [7:0]in1, in2;
	output [7:0]out;
		begin
			out = in1 & in2;
		end
endtask

task my_or;
	input [7:0]in1, in2;
	output [7:0]out;
		begin
			out = in1 | in2;
		end
endtask

task simple_addr;
input [7:0]in1, in2;
output reg c_out;
output reg [7:0]sum_delayed;
reg [8:0]sum;
begin
	sum = in1 + in2;
	sum_delayed = sum[7:0];
	c_out = sum[8];
end
endtask

endmodule
