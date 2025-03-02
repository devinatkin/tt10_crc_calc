# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ui_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 5)

    dut._log.info("Loading CRC initialization value")
    crc_init_value = 0xD5  # Example CRC initialization value
    for i in range(8):
        dut.ui_in.value = (crc_init_value >> (7 - i)) & 1
        await ClockCycles(dut.clk, 1)
    
    dut._log.info("Loading CRC polynomial")
    crc_poly_value = 0xBB  # Example CRC polynomial value
    for i in range(8):
        dut.ui_in.value = (crc_poly_value >> (7 - i)) & 1
        await ClockCycles(dut.clk, 1)
    
    dut._log.info("Sending data bits")
    test_data = 0xF0  # Example input data
    for i in range(8):
        dut.ui_in.value = (test_data >> (7 - i)) & 1
        await ClockCycles(dut.clk, 1)
    
    await ClockCycles(dut.clk, 5)
    dut._log.info(f"CRC Output: {dut.uo_out.value}")

    # Example assertion for verification (modify based on expected CRC output)
    expected_crc = 0x3A  # Replace with the actual expected CRC result
    assert dut.uo_out.value == expected_crc, f"CRC mismatch: expected {expected_crc}, got {dut.uo_out.value}"
    
    dut._log.info("Test complete")
