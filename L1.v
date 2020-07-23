module L1_cache(data_out, done, bus_out, bus_start, read, ID, bus_in, bus_done, clk);
output reg [7:0] data_out;
output reg done;
output reg [11:0] bus_out;
output reg bus_start;
input read;
input [3:0] ID;
input [11:0] bus_in; //{done signal, id, data}
input bus_done;
input clk; 
reg [11:0] cache_memory [3:0];
reg hit;
reg [1:0] state;
integer i;

always @ (posedge clk) begin 
		case (state)	
		0: begin 
			done=0;
			bus_start=0;
			hit = 0;
			if(read == 1)
				state = 1;
			else 
				state = 0;
		end
		1: begin
			bus_start=0;
			bus_out=12'bzzzzzzzzzzzz;
			for(i=0; i< 4; i=i+1) begin
				if (ID == cache_memory[i][11:8]) begin
					hit=1; 
					data_out = cache_memory[i][7:0];
				end
			end
			if (hit ==1) begin
				done = 1;
				state = 0;
			end else begin
				done = 0;
				data_out=8'bzzzzzzzz;
				state = 2;
			end	
		end
		2:begin 
			done=0;
			hit = 0;
			bus_start=1;
			bus_out = {ID,8'bzzzzzzzz};
			data_out=8'bzzzzzzzz;
			if (bus_done ==1)
				state = 3;
			else 
				state = 2;
		end
		3:begin 
			for(i=3; i>0; i=i-1) begin
				cache_memory[i]= cache_memory[i-1];
			end
			cache_memory[0]= bus_in[11:0];
			data_out = bus_in[7:0];
			done=1;
			bus_start = 0;
			bus_out = 12'bzzzzzzzzzzzz;
			hit = 0;
			state = 0;
		end
		default: begin
		done=0;
		bus_start=0;
		hit = 0;
		bus_out=12'bzzzzzzzzzzzz;
		data_out=8'bzzzzzzzz;
		state = 0;
		end
		endcase
	end	
endmodule