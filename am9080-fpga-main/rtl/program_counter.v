module program_counter (
    input wire          clk,
    input wire          rst,
    input wire          pc_incr,
    input wire          pc_load,
    input wire [15:0]   addr_load,
    output reg [15:0]   pc_out
);
    always @(posedge clk)begin
        pc_out <= rst ? 16'h0000 : pc_load ? addr_load : pc_incr ? pc_out + 16'd1 : pc_out;
    end
endmodule