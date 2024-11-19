/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_devinatkin_crc (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    crc_calc #(
        .CRC_WIDTH(8)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(ui_in[0]),
        .crc_init(8'h00),
        .crc_poly(8'h1D),
        .crc_out(uo_out)
    );

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = ui_in + ui_in;  // Example: ou_out is the sum of ui_in and uio_in

  // List all unused inputs to prevent warnings
  wire _unused = &{clk, rst_n, 1'b0};

endmodule
