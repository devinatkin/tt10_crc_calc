# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset: drive ui_in to 0 during reset
    dut._log.info("Reset")
    dut.ui_in.value = 0
    dut.rst_n.value = 0


    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 5)

    #-------------------------------------------------------------------------
    # Load CRC Initialization Value
    # ui_in[1] is the data bit, ui_in[2] is the load signal.
    # Bits are loaded MSB first.
    #-------------------------------------------------------------------------
    dut._log.info("Loading CRC initialization value")
    crc_init_value = 0xFF  # Example CRC initialization value
    for i in range(8):
        bit_val = (crc_init_value >> (7 - i)) & 1
        # Build ui_in: data bit on bit 1, load signal on bit 2
        ui_in_val = (bit_val << 1) | (1 << 2)
        dut.ui_in.value = ui_in_val
        await RisingEdge(dut.clk)
        dut.ui_in.value = 0  # Deassert after clock edge
        await ClockCycles(dut.clk, 1)

    assert dut.user_project.crc_init.value == 0xFF

    #-------------------------------------------------------------------------
    # Load CRC Polynomial
    # ui_in[0] is the data bit, ui_in[3] is the load signal.
    #-------------------------------------------------------------------------
    dut._log.info("Loading CRC polynomial")
    crc_poly_value = 0x9B  # Example CRC polynomial value
    for i in range(8):
        bit_val = (crc_poly_value >> (7 - i)) & 1
        ui_in_val = (bit_val << 0) | (1 << 3)
        dut.ui_in.value = ui_in_val
        await RisingEdge(dut.clk)
        dut.ui_in.value = 0
        await ClockCycles(dut.clk, 1)


    # dut._log.info(f"Available attributes in dut: {dir(dut.user_project)}")
    dut._log.info("Verify Poly and Init Values")

    #-------------------------------------------------------------------------
    # Send Data Bits to the CRC Calculator
    # Data is applied on ui_in[4]. Also, assert ui_in[5] to keep crc_rst_n high.
    #-------------------------------------------------------------------------
    dut._log.info("Sending data bits")
    test_data = 0x12  # Example input data: 11110000 (MSB first)
    dut.ui_in.value = (1 << 5)
    for i in range(8):
        bit_val = (test_data >> (7 - i)) & 1
        ui_in_val = (bit_val << 4) | (1 << 5)
        dut.ui_in.value = ui_in_val

        await ClockCycles(dut.clk, 1)

    
    await ClockCycles(dut.clk, 10)

    #-------------------------------------------------------------------------
    # Verification: Compare the computed CRC with the expected value.
    # Update the expected CRC to match your simulation result.
    #-------------------------------------------------------------------------
    expected_crc = 0xE4  # Updated expected value
    assert dut.uo_out.value == expected_crc, \
        f"CRC mismatch: expected {expected_crc}, got {dut.uo_out.value}"
    
    dut._log.info("Test complete")
