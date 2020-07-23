module simple_adder(
	output reg [15:0]sum, 
	output reg c_out, 
	input [15:0]a, b);

always @* begin
 	{c_out, sum} = a + b;
end

endmodule