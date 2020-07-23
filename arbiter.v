module arbiter(c1_go, c2_go, L2_start, bus_select, c2_done, c1_done, c1_start, c2_start, L2_done, clk);
output reg c1_go;
output reg c2_go;
output reg L2_start;
output reg [1:0] bus_select;//--bus_select;  0 cache1, 1 cache2, 2 L2cache, 3 xxxxxxxxxxxxx
input c2_done;
input c1_done;
input c1_start;
input c2_start;
input L2_done;
input clk;

reg [2:0] state;

always @ (posedge clk) begin
	case (state)
	0: begin   // wait
		c1_go = 0;
		c2_go = 0;
		L2_start = 0;
		bus_select =3;
		if(c1_start==1) begin
			state = 1;
		end
		else if(c2_start==1) begin
			state = 3;
		end
		else begin 
			state = 0;
		end  
	end
	1: begin    
		bus_select = 0;
		c1_go = 0;
		c2_go = 0;
		L2_start = 1;
		if(L2_done==1) begin
			state = 2;
		end
		else begin 
			state = 1;
		end  
	end
	2: begin    
		L2_start = 0;
		bus_select = 2;
		c1_go = 1;
		c2_go = 0;
		if(c1_done==1) begin
			state = 0;
		end
		else begin 
			state = 2;
		end  
	end
	3: begin    
		bus_select = 1;
		c1_go = 0;
		c2_go = 0;
		L2_start = 1;
		if(L2_done==1) begin
			state = 4;
		end
		else begin 
			state = 3;
		end  
	end
	4: begin    
		L2_start = 0;
		bus_select = 2;
		c1_go = 0;
		c2_go = 1;
		if(c2_done==1) begin
			state = 0;
		end
		else begin 
			state = 4;
		end  
	end
	default: begin
		L2_start = 0;
		bus_select = 3;
		c1_go = 0;
		c2_go = 0;
		state = 0;

	end	
endcase
end



endmodule
