// Verilog Module for Calculating a CRC
// Author: Devin Atkin


// CRC Based on the CRC videos by Ben Eater on YouTube
// https://www.youtube.com/watch?v=sNkERQlK8j8 (Explanation of the CRC Hardware Design)
// https://www.youtube.com/watch?v=izG7qT0EpBw (Explanation of the CRC Algorithm)

module crc_calc #(parameter CRC_WIDTH = 8)(
    input wire clk,
    input wire rst_n,
    input wire data_in,
    input wire [CRC_WIDTH-1:0] crc_init,
    input wire [CRC_WIDTH-1:0] crc_poly,
    output reg [CRC_WIDTH-1:0]crc_out
    );
    
    // CRC Register
    reg [CRC_WIDTH-1:0] crc_reg;
    // CRC Calculation
    always@(posedge clk) begin
        if (!rst_n) begin                       // Active Low Synchronous Reset
            crc_reg <= crc_init;                // Initialize the CRC Register
        end else begin
            // Shift the CRC Register while xoring with the feedback register
            if (crc_poly[0]) begin
                crc_reg[0] <= data_in ^ crc_reg[CRC_WIDTH-1];
            end else begin
                crc_reg[0] <= data_in;
            end
            for (int i = 1; i < CRC_WIDTH; i = i + 1) begin
                if (crc_poly[i]) begin
                    crc_reg[i] <= crc_reg[i-1] ^ crc_reg[CRC_WIDTH-1];
                end else begin
                    crc_reg[i] <= crc_reg[i-1];
                end
            end
        end
    end
    
    assign crc_out = crc_reg; // Output the CRC Register


    
endmodule