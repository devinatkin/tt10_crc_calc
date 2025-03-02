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
    parameter WIDTH = 8;

    reg [7:0] crc_init;
    reg [7:0] crc_poly;

    reg crc_poly_data_in;
    reg crc_init_data_in;
    reg crc_init_load;
    reg crc_poly_load;
    reg crc_init_shift;
    reg crc_poly_shift;

    reg data_in;
    reg crc_rst_n;

    shift_register #(.WIDTH(WIDTH)) CRC_POLY_LOADER (
        .clk(clk),
        .rst_n(rst_n),
        .load(crc_poly_load),
        .shift(crc_poly_shift),
        .dir(1'b1),
        .data_in(crc_poly_data_in),
        .data_out(crc_poly)
    );


    shift_register #(.WIDTH(WIDTH)) CRC_INIT_LOADER(
        .clk(clk),
        .rst_n(rst_n),
        .load(crc_init_load),
        .shift(crc_init_shift),
        .dir(1'b1),
        .data_in(crc_init_data_in),
        .data_out(crc_init)
    );

    // CRC Calculation Module
    crc_calc #(
        .CRC_WIDTH(WIDTH)
    ) uut (
        .clk(clk),
        .rst_n(rst_n && crc_rst_n),
        .data_in(data_in),
        .crc_init(crc_init),
        .crc_poly(crc_poly),
        .crc_out(uo_out)
    );

    assign crc_poly_data_in = ui_in[0];
    assign crc_init_data_in = ui_in[1];
    assign crc_init_load = ui_in[2];
    assign crc_poly_load = ui_in[3];
    assign data_in = ui_in[4];
    assign crc_rst_n = ui_in[5];
    assign crc_init_shift = ui_in[6];
    assign crc_poly_shift = ui_in[7];

endmodule
