`timescale 1ns/1ps

module roundrobin (
    input  wire       clk,
    input  wire       rst,
    input  wire [3:0] req,
    output reg  [3:0] gnt
);

    reg [3:0] priority_ptr; //records the current priority
    
    wire [3:0] masked_req;
    wire [3:0] next_gnt;

    
    // Block 1: Update Priority Pointer based on the current Grant
   
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            priority_ptr <= 4'b0001; // Default: Req 0 has highest priority
        end else if (|gnt) begin     // changes priority when a gnt changes
            case (gnt)
                4'b0001: priority_ptr <= 4'b0010; //shifts priority in cyclic manner
                4'b0010: priority_ptr <= 4'b0100; 
                4'b0100: priority_ptr <= 4'b1000; 
                4'b1000: priority_ptr <= 4'b0001; 
                default: priority_ptr <= 4'b0001;
            endcase
        end
    end

    
    // Block 2: Masking and Priority Encoder Logic (Combinational)
	 

    wire [3:0] mask;
    assign mask[0] = priority_ptr[0];
    assign mask[1] = priority_ptr[0] | priority_ptr[1];
    assign mask[2] = priority_ptr[0] | priority_ptr[1] | priority_ptr[2];
    assign mask[3] = 1'b1;

    // Apply mask and run through priority encoder
	 //removes requests with lower index than the current priority given by priority_ptr
    assign masked_req = req & mask;

    wire [3:0] masked_gnt, unmasked_gnt;//computes masked_gnt based on masked_req
    assign masked_gnt[0] =  masked_req[0];
    assign masked_gnt[1] =  masked_req[1] & ~masked_req[0];
    assign masked_gnt[2] =  masked_req[2] & ~masked_req[1] & ~masked_req[0];
    assign masked_gnt[3] =  masked_req[3] & ~masked_req[2] & ~masked_req[1] & ~masked_req[0];

    assign unmasked_gnt[0] =  req[0];//computes unmasked_req with original req input
    assign unmasked_gnt[1] =  req[1] & ~req[0];
    assign unmasked_gnt[2] =  req[2] & ~req[1] & ~req[0];
    assign unmasked_gnt[3] =  req[3] & ~req[2] & ~req[1] & ~req[0];

    assign next_gnt = (|masked_req) ? masked_gnt : unmasked_gnt;//decides bw final value of gnt 
// if masked_req is 0000( happens when only a requested with lower index than the current priority index requests,it uses unmaskedgnt
    // Register the final grant output on the clock edge
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            gnt <= 4'b0000;
        end else begin
            gnt <= next_gnt;
        end
    end

endmodule