// Jeremie Clark + Joe Chamish
// DSD II
// Lab 5 - FIFO / Stack


module fifo #(
	parameter data_width = 4, // 4
	parameter num_elements = 4, // 4 
	parameter index_width = 2 // 2
)
(
	input [1:0]opcode,
	input clk,
	input [data_width-1:0]data_in,
	output reg [data_width-1:0]data_out,
	output reg overflow,
	output reg underflow
);

	reg [data_width-1:0]queue[num_elements-1:0];
	reg [index_width-1:0]ptrHead, ptrTail;
	reg full, empty;

	// Initial for simulation
	initial begin
		ptrHead = 0;
		ptrTail = 0;
		full = 0;
		empty = 1;
	end

	// Control case statement
	always @(posedge clk) begin
		underflow = 0;
		overflow = 0;
		case (opcode)
			2'b00 : ; // NO-OP
			2'b01 : read(); // READ
			2'b10 : write(); // WRITE
			2'b11 : reset(); // RESET
		default: ;
		endcase
	end

	// Task for FIFO read
	task read();
		if (!empty) begin
			data_out = queue[ptrTail];
			ptrTail = ptrTail + 1;
			if (ptrTail == ptrHead) begin
				empty = 1;
			end
			full = 0;
		end else begin
			underflow = 1;
		end
	endtask

	
	// Task for FIFO write
	task write();
		if (!full) begin
			queue[ptrHead] = data_in;
			ptrHead = ptrHead + 1;
			if (ptrTail == ptrHead) begin
				full = 1;
			end
			empty = 0;
		end else begin
			overflow = 1;
		end
	endtask
	
	// Task for FIFO reset
	task reset();
	begin
		ptrHead = 0;
		ptrTail = 0;
		full = 0;
		empty = 1;
	end
	endtask
endmodule 