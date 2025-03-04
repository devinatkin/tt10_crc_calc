module tb_shift_register;

    parameter WIDTH = 8;
    reg clk, rst_n, load, shift, dir;
    // data_in is now a 1-bit signal
    reg data_in;
    wire [WIDTH-1:0] data_out;

    // Instantiate the shift register (new version)
    shift_register #(.WIDTH(WIDTH)) uut (
        .clk(clk),
        .rst_n(rst_n),
        .load(load),
        .shift(shift),
        .dir(dir),
        .data_in(data_in),
        .data_out(data_out)
    );

    // Clock generator: period = 10 ns
    always #5 clk = ~clk;

    // For checking the operation
    reg [WIDTH-1:0] expected;
    reg [WIDTH-1:0] serial_data; // Full 8-bit pattern to load serially.
    integer i;

    initial begin
        // Initialize signals
        clk      = 0;
        rst_n    = 0;
        load     = 0;
        shift    = 0;
        dir      = 0;
        data_in  = 0;
        expected = 0;
        // Serial data pattern. Note: bits are loaded MSB-first.
        serial_data = 8'b10101010;

        // Reset sequence
        #10 rst_n = 1;  // Release reset

        // Serial Load – one bit per clock cycle.
        // Insert a small delay after asserting load before the clock edge.
        load    = 1;
        for (i = 0; i < WIDTH; i = i + 1) begin
            // Drive data_in with the next bit (MSB first)
            data_in = serial_data[WIDTH-1-i];
            
            #10;
            // Update expected value as per design: {data_in, previous[WIDTH-2:0]}
            expected = serial_data >> (WIDTH - i - 1);
 
            // Check serial load result
            if (data_out !== expected) begin
                $display("TEST FAILED: Serial load failed. Expected %b, Got %b", expected, data_out);
                $stop;
            end
        end

        load    = 0;
        serial_data = 8'b10101010;

        // Check serial load result
        if (data_out !== serial_data) begin
            $display("TEST FAILED: Serial load failed. Expected %b, Got %b", serial_data, data_out);
            $stop;
        end else begin
            $display("TEST PASSED: Serial load successful.");
        end

        // Shift Left 3 times (rotate left)
        for (i = 0; i < 3; i = i + 1) begin
            shift = 1;  
            dir   = 0;  // 0 = shift left
            expected = {expected[WIDTH-2:0], expected[WIDTH-1]};  // Rotate left update
            #10;
            if (data_out !== expected) begin
                $display("TEST FAILED: Shift Left %0d failed. Expected %b, Got %b", i+1, expected, data_out);
                $stop;
            end
        end
        $display("TEST PASSED: Shift Left works correctly.");

        // Shift Right 3 times (rotate right)
        for (i = 0; i < 3; i = i + 1) begin
            shift = 1;
            dir   = 1;  // 1 = shift right
            expected = {expected[WIDTH-1], expected[WIDTH-2:0]};  // Rotate right update
            @(posedge clk);
            shift = 0;
            #10;
            if (data_out !== expected) begin
                $display("TEST FAILED: Shift Right %0d failed. Expected %b, Got %b", i+1, expected, data_out);
                $stop;
            end
        end
        $display("TEST PASSED: Shift Right works correctly.");

        // Final message
        $display("ALL TESTS PASSED!");
        #10 $finish;
    end

endmodule
