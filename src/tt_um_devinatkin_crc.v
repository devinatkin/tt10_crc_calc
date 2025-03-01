/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_devinatkin_crc (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output reg  [7:0] uo_out,   // Dedicated outputs
    input  wire       clk,      // Clock
    input  wire       rst_n     // Active-low reset
);

    reg [7:0] crc_init;
    reg [7:0] crc_poly;
    reg data_in;
    reg crc_enable;

    // Instantiate State Machine for Loading Configuration
    crc_config_loader config_loader (
        .clk(clk),
        .rst_n(rst_n),
        .ui_in(ui_in[0]),
        .crc_init(crc_init),
        .crc_poly(crc_poly),
        .data_out(data_in),
        .crc_enable(crc_enable)
    );

    // CRC Calculation Module
    crc_calc #(
        .CRC_WIDTH(8)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .crc_init(crc_init),
        .crc_poly(crc_poly),
        .crc_out(uo_out)
    );

endmodule
