module shift_register #(
    parameter WIDTH = 8  // Default width is 8 bits
)(
    input wire clk,       // Clock input
    input wire rst,       // Asynchronous reset (active high)
    input wire load,      // Load enable signal
    input wire shift,     // Shift enable signal
    input wire dir,       // Direction: 0 = Shift Left, 1 = Shift Right
    input wire [WIDTH-1:0] data_in,  // Parallel input data
    output reg [WIDTH-1:0] data_out  // Shift register output
);

always @(posedge clk) begin
    if (rst) begin
        data_out <= 0;  // Reset register to 0
    end 
    else if (load) begin
        data_out <= data_in;  // Load data into the shift register
    end 
    else if (shift) begin
        if (dir) begin
            data_out <= {data_out[0], data_out[WIDTH-1:1]};  // Shift Right
        end 
        else begin
            data_out <= {data_out[WIDTH-2:0], data_out[WIDTH-1]};  // Shift Left
        end
    end
end

endmodule
