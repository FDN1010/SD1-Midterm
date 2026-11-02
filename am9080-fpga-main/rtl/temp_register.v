`default_nettype none


module temp_register (
    //ports
    //inputs
    input wire i_clk, //Clock signal

    input wire [7:0] i_ACT_data_in, //New data to be written to ACT
    input wire i_ACT_load, //Determine whether TMP is updated

    input wire [7:0]i_TMP_data_in, //New data to be written to TMP
    input wire i_TMP_load, //Determine whether TMP is updated

    //outputs
    output wire [7:0]o_ACT, //updated value of ACT
    output wire [7:0] o_TMP //updated value of TMP
);
    reg [7:0] ACT, TMP;

    assign o_ACT = ACT;
    assign o_TMP = TMP;

    always @(posedge i_clk) begin
        ACT <= i_ACT_load ? i_ACT_data_in : ACT;
        TMP <= i_TMP_load ? i_TMP_data_in : TMP;
    end 

    //TODO
    //Need to add reset logic and potentially the second clock


endmodule

`default_nettype wire
