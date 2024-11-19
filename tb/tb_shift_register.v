module tb_shift_register;

    parameter WIDTH = 8;
    reg clk, rst, load, shift, dir;
    reg [WIDTH-1:0] data_in;
    wire [WIDTH-1:0] data_out;
    
    // Instantiate the Shift Register Module
    shift_register #(.WIDTH(WIDTH)) uut (
        .clk(clk),
        .rst(rst),
        .load(load),
        .shift(shift),
        .dir(dir),
        .data_in(data_in),
        .data_out(data_out)
    );

    always #5 clk = ~clk;  // Clock generator (10ns period)

    initial begin
        // Test variables
        reg [WIDTH-1:0] expected;
        integer i;
        
        clk = 0; rst = 1; load = 0; shift = 0; dir = 0; data_in = 8'b10101010;
        #10 rst = 0; // Release reset
        
        // Load data
        #10 load = 1; #10 load = 0;
        
        if (data_out !== data_in) begin
            $display("TEST FAILED: Load failed. Expected %b, Got %b", data_in, data_out);
            $stop;
        end else begin
            $display("TEST PASSED: Load successful.");
        end

        // Shift Left 3 times
        expected = data_in;
        for (i = 0; i < 3; i = i + 1) begin
            #10 shift = 1; dir = 0;
            expected = {expected[WIDTH-2:0], expected[WIDTH-1]}; // Shift left
            #10;
            if (data_out !== expected) begin
                $display("TEST FAILED: Shift Left %d failed. Expected %b, Got %b", i+1, expected, data_out);
                $stop;
            end
        end
        shift = 0;
        $display("TEST PASSED: Shift Left works correctly.");

        // Shift Right 3 times
        expected = data_out;
        for (i = 0; i < 3; i = i + 1) begin
            #10 shift = 1; dir = 1;
            expected = {expected[0], expected[WIDTH-1:1]}; // Shift right
            #10;
            if (data_out !== expected) begin
                $display("TEST FAILED: Shift Right %d failed. Expected %b, Got %b", i+1, expected, data_out);
                $stop;
            end
        end
        shift = 0;
        $display("TEST PASSED: Shift Right works correctly.");

        // Final success message
        $display("ALL TESTS PASSED!");
        #10 $finish;
    end

endmodule
