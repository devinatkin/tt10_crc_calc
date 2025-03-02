`timescale 1ns / 1ps

module crc_config_loader_tb;

    reg clk;
    reg rst_n;
    reg ui_in;
    wire [7:0] crc_init;
    wire [7:0] crc_poly;
    wire data_out;
    wire crc_enable;

    // Instantiate the module under test
    crc_config_loader uut (
        .clk(clk),
        .rst_n(rst_n),
        .ui_in(ui_in),
        .crc_init(crc_init),
        .crc_poly(crc_poly),
        .data_out(data_out),
        .crc_enable(crc_enable)
    );

    // Clock generation
    always #5 clk = ~clk; // 10ns period -> 100MHz clock

    // Test sequence
    initial begin
        $dumpfile("crc_config_loader.vcd");
        $dumpvars(0, crc_config_loader_tb);

        clk = 0;
        rst_n = 0;
        ui_in = 0;

        // Reset the module
        #10 rst_n = 1;

        // Load CRC initialization value (8 bits)
        $display("Loading crc_init...");
        send_bits(8'b11010101);
        
        // Load CRC polynomial (8 bits)
        $display("Loading crc_poly...");
        send_bits(8'b10111011);
        
        // Send input data bits
        $display("Sending data...");
        send_bits(8'b11110000);

        #50;
        $display("Test complete.");
        $stop;
    end

    // Task to send bits serially
    task send_bits;
        input [7:0] data;
        integer i;
        begin
            for (i = 7; i >= 0; i = i - 1) begin
                ui_in = data[i];
                #10; // Wait one clock cycle per bit
            end
        end
    endtask

endmodule
