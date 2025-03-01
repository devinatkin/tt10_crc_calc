/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module crc_config_loader (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       ui_in,      // Serial input bit
    output reg [7:0]  crc_init,   // CRC initialization value
    output reg [7:0]  crc_poly,   // CRC polynomial
    output reg        data_out,   // Shifted input data
    output reg        crc_enable  // Enables CRC operation
);

    reg [3:0] bit_count;
    reg [1:0] state;

    // State Encoding
    localparam STATE_INIT  = 2'b00;
    localparam STATE_POLY  = 2'b01;
    localparam STATE_DATA  = 2'b10;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            crc_init  <= 8'h00;
            crc_poly  <= 8'h00;
            bit_count <= 0;
            state     <= STATE_INIT;
            crc_enable <= 0;
        end 
        else begin
            case (state)
                // Load crc_init from ui_in
                STATE_INIT: begin
                    crc_init[7:0] <= {crc_init[6:0], ui_in};
                    bit_count <= bit_count + 1;
                    if (bit_count == 7) begin
                        bit_count <= 0;
                        state <= STATE_POLY;
                    end
                end

                // Load crc_poly from ui_in
                STATE_POLY: begin
                    crc_poly[7:0] <= {crc_poly[6:0], ui_in};
                    bit_count <= bit_count + 1;
                    if (bit_count == 7) begin
                        bit_count <= 0;
                        state <= STATE_DATA;
                    end
                end

                // Shift in data to CRC calculation
                STATE_DATA: begin
                    data_out <= ui_in;  // Pass input data
                    crc_enable <= 1;
                end
            endcase
        end
    end

endmodule
