`default_nettype none

module stack_pointer (
    //Ports Here
    //inputs
    input wire i_clk,              //Clock signal
    input wire [15:0] i_data_in,   //New stack pointer value
    input wire i_load_en,         //Load new SP value
    input wire i_inc_en,          //Increment SP by 1
    input wire i_dec_en,          //Decrement SP by 1

    //outputs
    output wire [15:0] o_SP       //Current stack pointer value
);

reg [15:0] SP;

assign o_SP = SP;

always @(posedge i_clk) begin
    SP <= i_load_en ? i_data_in : //Load new SP value
          i_inc_en ? SP + 16'd1 : //Increment SP by 1
          i_dec_en ? SP - 16'd1 : //Decrement SP by 1
          SP; //Base case: if no enable is set then SP remains unchanged
end

endmodule

`default_nettype wire
