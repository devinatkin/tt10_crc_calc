# Makefile for testing with iverilog and vvp

# Define the compiler and simulator
IVL = iverilog -g2012
VVP = vvp

# Output directory for simulation files
OUT_DIR = sim_out

# Create the output directory if it doesn't exist
$(shell mkdir -p $(OUT_DIR))

# Phony targets
.PHONY: all clean

all: tb_crc_calc

tb_crc_calc: 
	$(IVL) -o $(OUT_DIR)/$@.vvp ../src/crc_calculator.v tb_crc_calculator.v
	$(VVP) $(OUT_DIR)/$@.vvp

clean:
	@echo Cleaning up...
	rm -rf $(OUT_DIR)