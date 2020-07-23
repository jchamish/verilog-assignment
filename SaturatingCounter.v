/*
Name: Joseph Chamish

*/

module SaturatCounter #( 
	parameter BITS = 1 // 2
) (
input clock,
input taken,
input [BITS:0] CounterInput;
output [BITS:0] Counter
);

// States 
parameter T  = 2'b11, T1 = 2'b10, N = 2'b00, N1 = 2'b01;

reg [BITS:0] state = 2'b11;


always @ (posedge clock) begin
   case(state)
     T : begin
	        if(taken) begin
	        	if(CounterInput > 0 && CounterInput < 3 ){
	        		Counter = CounterInput + 1;	
	        	} else begin
	        		Counter = CounterInput;
	        	end	        
	        	state = T;
	        end else begin
	        	if(CounterInput > 0 && CounterInput < 3 ){
	        		Counter = CounterInput - 1;	
	        	} else begin
	        		Counter = CounterInput;
	        	end        
	        	state = T1;
	        end
        end
    T1 : begin
    		if(taken) begin 
	    			if(CounterInput > 0 && CounterInput < 3 ){
	    				Counter = CounterInput + 1;	
	    			} else begin
	    				Counter = CounterInput;
	    			end
	    			state = T;
    		end else begin
    			if(CounterInput > 0 && CounterInput < 4 ){
    				Counter = CounterInput - 1;	
    			} else begin
    				Counter = CounterInput;
    			end
    			state = N1;
    		end
        end
    N1 : begin
    		if(taken) begin 
    			if(CounterInput > 0 && CounterInput < 3 ){
    				Counter = CounterInput + 1;	
    			} else begin
    				Counter = CounterInput;
    			end
    			state = T1;
    		end else begin
    			if(CounterInput > 0 && CounterInput < 3 ){
    				Counter = CounterInput - 1;	
    			} else begin
    				Counter = CounterInput;
    			end
    			state = N;
    		end
        end
    N : begin
    		if(taken) begin 
	    			if(CounterInput > 0 && CounterInput < 3 ){
	    				Counter = CounterInput + 1;	
	    			} else begin
	    				Counter = CounterInput;
	    			end
	    			state = N1;
    		end else begin
    			if(CounterInput > 0 && CounterInput < 3 ){
    				Counter = CounterInput - 1;	
    			} else begin
    				Counter = CounterInput;
    			end
    			state = N;
    		end
        end
default : begin
			Counter = 2'b00;
      	end
   endcase

endmodule // End of Module arbiter