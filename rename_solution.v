

module rename(
    // Architectural registers of instruction being renamed
    input [4:0] src1_ar,
    input [4:0] src2_ar,
    input [4:0] dst_ar,
    input [63:0] pc_in,         // Address of instruction
    input valid_in,             // Is Fetch providing a valid instruction?
    
    // Physical registers of instruction being dispatched
    output reg [7:0] src1_pr,
    output reg [63:0] src1_dat, // Data from ARF
    output reg src1_valid,      // Data from ARF is valid
    output reg [7:0] src2_pr,
    output reg [63:0] src2_dat, // Data from ARF
    output reg src2_valid,      // Data from ARF is valid
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
    input [7:0] commit_prf,     // Phys reg if instruction being retired
    input [63:0] commit_result, // Value to commit to ARF
    input [63:0] commit_pc,     // Address of retiring instruction (ignore this)
    input [12:0] commit_flags,  // Exception codes (ignore)
    input commit_valid,         // Is an instruction being retired?
    );
    
// Declare array for register alias table (RAT)
reg [7:0] rat [0:31];
reg [0:31] in_prf;

// Declare array for architectural register file (ARF)
reg [63:0] arf [0:31];

// Translate source register numbers by lookup in RAT
always @(posedge clock) begin
    src1_pr <= rat[src1_ar];
    src2_pr <= rat[src2_ar];
end

// Get source data from ARF
always @(posedge clock) begin
    src1_data <= arf[src1_ar];
    src1_valid <= !in_prf[src1_ar];
    src2_data <= arf[src2_ar];
    src2_valid <= !in_prf[src2_ar];
end

// Allocate physical register from RoB
assign do_alloc = valid_in;
assign alloc_arf = dst_ar;
assign alloc_pc = pc_in;

// Translate destination register number
always @(posedge clock) begin
    dst_pr <= next_free;
    valid_out <= valid_in;  // Gotta put this somewhere
end

// Update RAT with new arch to phys mapping of destination
always @(poedge clock) begin
    rat[dst_ar] <= next_free;
    in_prf[dst_ar] <= 1;
end

// Update ARF on instruction retirement
always @(poedge clock) begin
    if (commit_valid) begin
        arf[commit_arf] <= commit_result;
    end
end

// Update RAT on instruction retirement
always @(posedge clock) begin
    if (commit_valid) begin
        if (rat[commit_ar] == commit_prf && in_prf[commit_ar]) begin
            rat[commit_ar] = commit_ar;     // Entirely redundant but shown on slide
            in_prf[commit_ar] = 0;
        end
    end
end


endmodule

