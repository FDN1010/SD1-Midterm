`default_nettype none

module accumulator (
    //ports
    //inputs
    input wire i_clk, //Clock signal
    input wire i_load_en, //Determine whether A is updated
    input wire [7:0] i_data_in, //New data to be written to A

    //outputs
    output wire [7:0] o_A //Updated value of A

);

reg [7:0] A;

assign o_A = A;


always @(posedge i_clk) begin
    A <= i_load_en ? i_data_in : A;
end

//TODO
//Need to add reset logic and potentially the second clock
    
endmodule

`default_nettype wire
