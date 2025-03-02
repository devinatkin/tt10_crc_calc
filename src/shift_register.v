module shift_register #(
    parameter WIDTH = 8  // Default width is 8 bits
)(
    input wire clk,       // Clock input
    input wire rst_n,     // Asynchronous reset (active low)
    input wire load,      // Load enable signal
    input wire shift,     // Shift enable signal
    input wire dir,       // Direction: 0 = Shift Left, 1 = Shift Right
    input wire data_in,  // Serial Data Input
    output reg [WIDTH-1:0] data_out  // Parallel Data Output
);

always @(posedge clk) begin
    if (!rst_n) begin
        data_out <= 0;  // Reset register to 0
    end 
    else if (load) begin
        data_out <= {data_out[WIDTH-2:0], data_in};  // Load data into the shift register
    end
    else if (shift) begin
        if (dir) begin
            data_out <= {data_out[WIDTH-1], data_out[WIDTH-2:0]};  // Shift Right
        end 
        else begin
            data_out <= {data_out[WIDTH-2:0], data_out[WIDTH-1]};  // Shift Left
        end
    end
end

endmodule
