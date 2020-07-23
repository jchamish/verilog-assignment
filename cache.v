// Jonathan Banko
// Partner: Paul Mogren
// EECE 573 - Digital System Design II
// Project 3 - Cache
// Due: 3/14/14

// Purpose: Create a cache

`timescale 1ns/10ps

module cache #(parameter size_op=2,size_tag=16,size_data=16,size_array=64,size_index=6)
(output reg [size_data-1:0]data_out, output reg hit, input [size_op+size_tag+size_data-1:0]inputs, input clk/*, input [size_data-1:0]data_lower, input hit_lower*/);

// Create synchronization clock and memory block
reg [size_tag-1:0]tag_array[0:size_array-1];
reg [size_data-1:0]data_array[0:size_array-1];
reg [size_index:0]i;
reg initialized = 0;

// Create registers for task use
reg [size_index-1:0]index;
reg [size_index-1:0]eviction_queue[size_array-1:0];
reg found;

// Split input string into serparate inputs
wire [size_op-1:0]op_in;
wire [size_tag-1:0]tag_in;
wire [size_data-1:0]data_in;
reg [size_index-1:0]index_in;

assign op_in = inputs[size_op+size_tag+size_data-1:size_tag+size_data];
assign tag_in = inputs[size_tag+size_data-1:size_data];
assign data_in = inputs[size_data-1:0];

always @ (posedge clk) begin
//data_out = 'x;
case(op_in)
		0				:	begin flash_clear(); end
		1				:	begin read(data_out,hit,tag_in); end
		2				:	begin write(hit,tag_in,data_in); end
		default	:	begin /*$display("Operation: Defaulted to No-op");*/ no_op(); end
	endcase
end

/*// Block for processing results from next level cache
always @* begin
	if (hit == 0 && hit_lower == 1) begin
		write(hit, tag_in, data_lower);
		hit = 1;
		data_out = data_lower;
	end // if (hit == 0 && hit_lower == 1)
end*/

/*initial
begin
	for(i=0; i<size_array;i=i+1)
		eviction_queue[i] = i;
end*/

task flash_clear(); begin
	for (i=0; i<size_array; i=i+1) begin
		tag_array[i] = 0;
		data_array[i] = 0; end
end
endtask

task search(output reg [size_index-1:0]index_out, output reg hit, input [size_tag-1:0]tag); begin
	hit = 0;
	for (i=0; i<size_array; i=i+1) begin	// Search the tag_array for an entry matching the tag
		if (tag_array[i] == tag_in) begin
			hit = 1;
			index_out = i;
		end // If tag
	end // For i
//	if (hit == 0)
//		index_out = 'x;
end
endtask

task read(output reg [size_data-1:0]data, output reg hit, input [size_tag-1:0]tag); begin
	if (tag == 0) begin
//		data = 'x;
		hit = 0; end
	else begin	
	search(index, hit, tag);
	// On hit send data, otherwise send Z
	if (hit == 1) begin
		data = data_array[index];	end 
//		else begin
//			data = 'x; end // if (hit = 1)
end
end
endtask

task write(output reg hit, input [size_tag-1:0]tag, input [size_data-1:0]data); begin
	search(index, hit, tag);	
	// On hit overwrite, otherwise overwrite last in round-robin
	if (tag == 0)
		hit = 0;
	else begin
		if (hit == 1) begin
			data_array[index] = data;
		end else begin
			index = eviction_queue[0];
			tag_array[index] = tag;
			data_array[index] = data;
			updateEvictionQueue(index);
		end // if (hit = 1)
end	
//	$display("Tag Array: ", tag_array[index]);
//	$display("Data Array: ", data_array[index]);
end
endtask

// The update task
task updateEvictionQueue(input [size_index-1:0]update_index); begin
found = 0;
for (i = 0; i < size_array; i=i+1) begin
	if (eviction_queue[i] == update_index) begin
		found = 1;
	end
	// After index is found shift all other values down in queue
	if (found == 1) begin
	if (i < size_array - 1)
		eviction_queue[i] = eviction_queue[i+1];
	end
end
	eviction_queue[size_array-1] = update_index;
end
endtask

task no_op(); begin
end
endtask
endmodule
