`timescale 1ns/1ps

module tb1;

    reg        clk;
    reg        rst;
    reg  [3:0] multiplier;
    reg  [3:0] multiplicand;
    wire [7:0] product;
    wire       done;

    
    optimisedmultiplier uut (
        .clk(clk),
        .rst(rst),
        .multiplier(multiplier),
        .multiplicand(multiplicand),
        .product(product),
        .done(done)
    );

    // Generate Clock: 10ns period
    always #5 clk = ~clk;

    initial begin
        
        clk          = 0;
        rst          = 1;
        multiplier   = 4'd0;
        multiplicand = 4'd0;

        // Apply reset
        #20;
        rst = 0;
        #10;

        // Test Case 1: 7 * 11 = 77
        $display("Starting Test 1: 7 * 11");
        multiplicand = 4'd7; 
        multiplier   = 4'd11; 

        // Wait for the 'done' signal flag
        @(posedge done);
        #2;
        $display("Result: %0d * %0d = %0d (Binary: %b)", multiplicand, multiplier, product, product);

        #20;

        // Test Case 2: 6 * 9 = 54
        $display("----------------------------------------");
        $display("Starting Test 2: 5 * 3");
        multiplicand = 4'd6;  
        multiplier   = 4'd9;  

        @(posedge done);
        #2;
        $display("Result: %0d * %0d = %0d (Binary: %b)", multiplicand, multiplier, product, product);

        #30;
        $display("----------------------------------------");
        $display("Simulation Finished Successfully.");
        $finish;
    end

endmodule