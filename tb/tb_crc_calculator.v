`timescale 1ns/1ps

`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %m: signal != value"); \
            $finish; \
        end

module tb_crc_calc;

    // Parameters
    parameter CRC_WIDTH = 8;
    parameter DATA_WIDTH = 8;

    // Inputs
    reg clk;
    reg rst_n;
    reg data_in;
    reg [CRC_WIDTH-1:0] crc_init;
    reg [CRC_WIDTH-1:0] crc_poly;

    // Outputs
    wire [CRC_WIDTH-1:0] crc_out;

    reg [15:0] test_data;

    // Instantiate the CRC calculation module
    crc_calc #(
        .CRC_WIDTH(CRC_WIDTH)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .crc_init(crc_init),
        .crc_poly(crc_poly),
        .crc_out(crc_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 ns clock period
    end

    // Test sequence
    initial begin
        // Initialize inputs
        rst_n = 0;
        data_in = 0;
        crc_init = 8'h00;  // Initial CRC value
        crc_poly = 8'hD5;  // Example polynomial for CRC-8

        // Reset
        #10;
        rst_n = 1;

        // Apply test data
        test_data = 16'h1234; // Example test data

        // Apply data to CRC calculator in a loop
        for (int i = 15; i >= 0; i = i - 1) begin
            data_in = test_data[i];
            #10;
        end
        for (int i = 0; i < 8; i = i + 1) begin
            data_in = 0;
            #10;
        end
        
        `assert (crc_out, 8'hAE) // Expected CRC value
        $display("CRC Output: %h", crc_out);
        #100;

        // Initialize inputs
        rst_n = 0;
        data_in = 0;
        crc_init = 8'h00;  // Initial CRC value
        crc_poly = 8'h1D;  // Example polynomial for CRC-8

        // Reset
        #10;
        rst_n = 1;

        // Apply test data
        test_data = 16'h1234; // Example test data

        // Apply data to CRC calculator in a loop
        for (int i = 15; i >= 0; i = i - 1) begin
            data_in = test_data[i];
            #10;
        end
        for (int i = 0; i < 8; i = i + 1) begin
            data_in = 0;
            #10;
        end

        `assert (crc_out, 8'h12) // Expected CRC value
        $display("CRC-8/GSM-A CRC Output: %h", crc_out);
        #100;

        $finish; // End simulation
    end

    // Monitor signals
    // initial begin
    //     $monitor("Time = %0t | rst_n = %b | data_in = %b | crc_init = %h | crc_poly = %h | crc_out = %h",
    //              $time, rst_n, data_in, crc_init, crc_poly, crc_out);
    // end

endmodule
