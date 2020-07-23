


module reorder_buffer(
    input clock,
    input _reset,
    
    // Allocate free slot (in order)
    output [7:0] next_free,
    output is_free,
    input [4:0] alloc_arf,
    input [63:0] alloc_pc,
    input do_alloc,
    
    // Writing completed instructions (out of order)
    input [7:0] write_slot,
    input [63:0] write_result,
    input [11:0] write_flags,
    input do_write,
    
    // Reading physical register file (out of order)
    input [7:0] read_slot,
    output reg [63:0] read_result,
    output reg read_valid,
    
    // Commit (in order)
    output reg [4:0] commit_arf,
    output reg [63:0] commit_result,
    output reg [63:0] commit_pc,
    output reg [12:0] commit_flags,
    output reg commit_valid,
    input can_commit
);


// RoB queue
reg [63:0] results [0:255];
reg [7:0] arf_num [0:255];
reg [63:0] ins_pc [0:255];
reg [11:0] flags [0:255];
reg result_valid [0:255];

reg [7:0] head;
reg [7:0] tail;


// Doing commit or allocate?
wire doing_alloc = is_free && do_alloc;
wire ready_to_commit = result_valid[head];
wire is_empty;
wire doing_commit = can_commit && ready_to_commit && !is_empty;


// Free entries
reg [8:0] free_entries;
reg [8:0] used_entries;
assign is_free = free_entries[8];  /* not full */
assign is_empty = used_entries[8];

always @(posedge clock or negedge _reset) begin
    if (_reset == 0) begin
        free_entries <= 511;
        used_entries <= 256;
    end else begin
        case ({doing_alloc, doing_commit})
            0, 3:  /* do nothing */;
            1:     free_entries <= free_entries + 1;
            2:     free_entries <= free_entries - 1;
        endcase
        case ({doing_alloc, doing_commit})
            0, 3:  /* do nothing */;
            1:     used_entries <= used_entries + 1;
            2:     used_entries <= used_entries - 1;
        endcase
    end
end


// Perform allocation
assign next_free = tail;

always @(posedge clock or negedge _reset) begin
    if (_reset == 0) begin
        tail <= 0;
    end else begin
        if (doing_alloc) begin
            result_valid[tail] <= 0;
            arf_num[tail] <= alloc_arf;
            ins_pc[tail] <= alloc_pc;
            tail <= tail + 1;  // automatically wraps
        end
    end
end


// Write completed result
always @(posedge clock) begin
    if (do_write) begin
        results[write_slot] <= write_result;
        flags[write_slot] <= write_flags;
        result_valid[write_slot] <= 1;
    end
end


// Read PRF
always @(posedge clock) begin
    read_result <= results[read_slot];
    read_valid <= result_valid[read_slot];
end


// Perform commit
always @(posedge clock) begin
    commit_valid <= result_valid[head] && !is_empty;
    commit_result <= results[head];
    commit_arf <= arf_num[head];
    commit_flags <= flags[head];
    commit_pc <= ins_pc[head];
end

always @(posedge clock or negedge _reset) begin
    if (_reset == 0) begin
        head <= 0;
    end else begin
        if (doing_commit) begin
            head <= head + 1;
        end
    end
end


endmodule
