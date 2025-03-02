`timescale 1ns/1ps
module tb_tt_um_devinatkin_crc;

  parameter WIDTH = 8;

  // Testbench signals
  reg         clk;
  reg         rst_n;
  reg  [7:0]  ui_in;   // Dedicated inputs: each bit controls a function in the DUT
  wire [7:0]  uo_out;  // CRC output from DUT

  // Instantiate the top-level module
  tt_um_devinatkin_crc #(.WIDTH(WIDTH)) dut (
    .ui_in(ui_in),
    .uo_out(uo_out),
    .clk(clk),
    .rst_n(rst_n)
  );

  // Clock generation: 10 ns period
  initial clk = 0;
  always #5 clk = ~clk;

  //-------------------------------------------------------------------------
  // Task: serial_load_byte
  //
  // Loads an 8-bit value serially into one of the shift registers.
  //   - select == 0: load CRC_POLY using ui_in[0] (data) and ui_in[3] (load)
  //   - select == 1: load CRC_INIT using ui_in[1] (data) and ui_in[2] (load)
  // Bits are loaded MSB first.
  //-------------------------------------------------------------------------
  task serial_load_byte;
    input [7:0] byte_to_load;
    input       select; // 0: CRC_POLY, 1: CRC_INIT
    integer i;
    begin
      for (i = 0; i < WIDTH; i = i + 1) begin
         if (select == 0) begin
            // For CRC_POLY: drive data (ui_in[0]) and assert load (ui_in[3])
            ui_in[0] = byte_to_load[7-i];  // load MSB first
            ui_in[3] = 1;
            // Ensure other control bits are low
            ui_in[1] = 0; ui_in[2] = 0; ui_in[6] = 0; ui_in[7] = 0;
         end
         else begin
            // For CRC_INIT: drive data (ui_in[1]) and assert load (ui_in[2])
            ui_in[1] = byte_to_load[7-i];  // load MSB first
            ui_in[2] = 1;
            // Ensure other control bits are low
            ui_in[0] = 0; ui_in[3] = 0; ui_in[6] = 0; ui_in[7] = 0;
         end
         #1;               // Small delay for signal stabilization
         @(posedge clk);  // Load is captured at the rising edge
         // Deassert the load signal after the clock edge
         if (select == 0)
            ui_in[3] = 0;
         else
            ui_in[2] = 0;
         #5;  // Wait a short time before loading the next bit
      end
    end
  endtask

  //-------------------------------------------------------------------------
  // Test Sequence
  //-------------------------------------------------------------------------
  integer j;
  initial begin
    $dumpfile("tb_tt_um_devinatkin_crc.vcd");
    $dumpvars(0,tb_tt_um_devinatkin_crc);
    // Initialize inputs and assert reset
    ui_in = 8'b0;
    rst_n = 0;
    #20;
    rst_n = 1; // Release reset

    // Set static control signals:
    // ui_in[5] drives crc_rst for the CRC module; set it high so that crc_calc isn’t held in reset.
    ui_in[5] = 1;
    // Deassert any shift operations by default.
    ui_in[6] = 0; // crc_init_shift
    ui_in[7] = 0; // crc_poly_shift

    //-------------------------------------------------------------------------
    // Serially load the CRC polynomial
    // Example: 8'b11001100
    $display("Loading CRC POLY: 8'b11001100");
    serial_load_byte(8'b11001100, 0);

    //-------------------------------------------------------------------------
    // Serially load the CRC initial value
    // Example: 8'b10101010
    $display("Loading CRC INIT: 8'b10101010");
    serial_load_byte(8'b10101010, 1);

    //-------------------------------------------------------------------------
    // Feed data bits into the CRC calculation module.
    // Here we drive ui_in[4] (data_in for crc_calc) with a sample 8-bit sequence:
    // Example: 8'b11110000 (MSB first: first four ones then four zeros)
    $display("Feeding data bits: 8'b11110000");
    for (j = 0; j < 8; j = j + 1) begin
       ui_in[4] = (j < 4) ? 1'b1 : 1'b0;
       @(posedge clk);
       #1;
    end

    //-------------------------------------------------------------------------
    // Allow time for the CRC calculation to complete
    #50;
    $display("Final CRC Output: %b", uo_out);

    $finish;
  end

endmodule
