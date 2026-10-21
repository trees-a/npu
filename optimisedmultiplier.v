module optimisedmultipler(
    input  wire        clk,
    input  wire        rst,
    input  wire [3:0]  multiplier,
    input  wire [3:0]  multiplicand,
    output reg  [7:0]  product,
    output reg         done
);

    reg [3:0] A, Q, M;
    reg       C;
    reg [2:0] count;
    reg [4:0] sum;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            A       <= 4'b0000;
            Q       <= 4'b0000;
            M       <= 4'b0000;
            C       <= 1'b0;
            product <= 8'b0;
            done    <= 1'b0;
            count   <= 3'd0;
        end else begin
            done <= 1'b0;

            if (count == 0) begin
                // Load new operands and reset count to 4 when finishing a cycle
                A     <= 4'b0000;
                Q     <= multiplier;
                M     <= multiplicand;
                C     <= 1'b0;
                count <= 3'd4;
            end 
            else if (count > 0) begin
                // Step 1 & 2: Conditional Add
                if (Q[0]) begin
                   {C,A} <= {1'b0, A} + {1'b0, M};
                end else begin
                    {C,A} <= {1'b0, A};
                end

                // Step 3: Shift Right combined {C, A, Q} chain
                C <= 1'b0;
                A <= {C, A[3:1]};
                Q <= {A[0], Q[3:1]};

                count <= count - 1'b1;

                // Check if this was the 4th and final cycle
                if (count == 3'd1) begin
                    done    <= 1'b1;
                    product <= { C,A,Q};
                end
            end
        end
    end

endmodule
