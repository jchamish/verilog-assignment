

module rename(
    // Architectural registers of instruction being renamed
    input [4:0] src1_ar,
    input [4:0] src2_ar,
    input [4:0] dst_ar,
    input [63:0] pc_in,         // Address of instruction
    input valid_in,             // Is Fetch providing a valid instruction?
    
    // Physical registers of instruction being dispatched
    output reg [7:0] src1_pr,
    output reg [7:0] src2_pr,
    output reg [7:0] dst_pr,
    output reg valid_out,       // Is an instruction being dispatched?
    
    // Interface to RoB for allocating physical register
    input [7:0] next_free,      // Index of new physical register
    input is_free,              // Is there a free physical register? (assume it is)
    output [4:0] alloc_arf, // Arch reg of destination
    output [63:0] alloc_pc, // Address of instruction being dispatched
    output do_alloc,        // Advance RoB tail pointer
    
    // Interface to RoB for retirement
    input [4:0] commit_arf,     // Arch reg of instruction being retired
    input [63:0] commit_result, // Value to commit to ARF
    input [63:0] commit_pc,     // Address of retiring instruction (ignore this)
    input [12:0] commit_flags,  // Exception codes (ignore)
    input commit_valid,         // Is an instruction being retired?
    );
    
// Declare array for register alias table (RAT)
reg [...] rat [...];

// Declare array for architectural register file (ARF)
reg [...] arf [...];

// Translate source register numbers by lookup in RAT
always @(posedge clock) begin
    ...
end

// Get source data from ARF
always @(posedge clock) begin
    ...
end

// Allocate physical register from RoB
assign ...

// Translate destination register number
always @(posedge clock) begin
    ...
end

// Update RAT with new arch to phys mapping of destination
always @(poedge clock) begin
    ...
end

// Update ARF on instruction retirement
always @(poedge clock) begin
    ...
end

// Update RAT on instruction retirement
always @(posedge clock) begin
    ...
end


endmodule

