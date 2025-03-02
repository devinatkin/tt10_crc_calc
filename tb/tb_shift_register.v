module tb_shift_register;

    parameter WIDTH = 8;
    reg clk, rst_n, load, shift, dir;
    reg [WIDTH-1:0] data_in;
    wire [WIDTH-1:0] data_out;

    // Instantiate the Shift Register Module
    shift_register #(.WIDTH(WIDTH)) uut (
        .clk(clk),
        .rst_n(rst_n),
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

        // Initialize signals
        clk = 0; rst_n = 0; load = 0; shift = 0; dir = 0; data_in = 8'b10101010;
        expected = 0;

        // Reset sequence
        #10 rst_n = 1; // Release reset

        // Load data
        #10 load = 1;
        #10 load = 0;
        expected = data_in;

        // Check load operation
        if (data_out !== expected) begin
            $display("TEST FAILED: Load failed. Expected %b, Got %b", expected, data_out);
            $stop;
        end else begin
            $display("TEST PASSED: Load successful.");
        end

        // Shift Left 3 times
        for (i = 0; i < 3; i = i + 1) begin
            shift = 1; dir = 0;
            expected = {expected[WIDTH-2:0], expected[WIDTH-1]}; // Proper shift left
            #10;
            if (data_out !== expected) begin
                $display("TEST FAILED: Shift Left %0d failed. Expected %b, Got %b", i+1, expected, data_out);
                $stop;
            end
        end
        shift = 0;
        #30;
        $display("TEST PASSED: Shift Left works correctly.");

        // Shift Right 3 times
        for (i = 0; i < 3; i = i + 1) begin
            #10 shift = 1; dir = 1;
            expected = {expected[WIDTH-1], expected[WIDTH-2:0]}; // Proper shift right
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