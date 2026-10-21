`timescale 1ns/1ps

module tb;

   
    reg       clk;
    reg       rst;
    reg [3:0] req;

    
    wire [3:0] gnt;

    
    roundrobin uut (
        .clk(clk),
        .rst(rst),
        .req(req),
        .gnt(gnt)
    );

    // Generate Clock: 
    always #5 clk = ~clk;

    initial begin
        
        clk = 0;
        rst = 1;
        req = 4'b0000;

        // Apply reset for 20ns
        #20;
        rst = 0;
        
       
        $display("Starting Fairness Test: All 4 Requestors Active");
        

        // Keep all 4 requestors active continuously (4'b1111)
        #10;
        req = 4'b1111;

        // Let it run for 70ns (7 clock cycles) to watch the rotation loop
        #70;

        $display("Testing Sparse Requests: Only Reqs 3 and 2 active");
        
        req = 4'b1100; // Only Req 3 and Req 2 asking
        #40;

        // Drop all requests
        req = 4'b0000;
        #30;

        $display("Simulation Finished");
        
        $finish;
    end

    // Monitor and print results on every rising clock edge
    always @(posedge clk) begin
        if (!rst) begin
            $display("Time = %03d ns | req = %b | gnt = %b", $time, req, gnt);
        end
    end

endmodule
//waveform explanation
//when reset is high no requester is given gnt
//when all requesters are active req=1111(f),gnt rotates between all the requesters(0001->0010->0100->1000)
//when 3 and 2 are requesting initially the lowest index(2) gets gnt, priority then goes to requester 3,request 2 gets masked and gnt goes to requester 3(gnt=1000=8)
//none request and gnt=0000