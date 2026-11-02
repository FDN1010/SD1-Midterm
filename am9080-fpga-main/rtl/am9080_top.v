module am9080_top {
    input wire clk,
    input wire rst,
    input wire turbo,

    //Address Bus
    output  wire    [15:0]  addr,

    //Data Bus
    input   wire    [7:0]   data_in,
    output  wire    [7:0]   data_out,
    input   wire            data_out_en,

    //Inputs
    input   wire            hold,       //Hold
    input   wire            ready,      //Ready
    input   wire            intr,       //Interrupt

    //Outputs
    output  wire            hold_a,     //Hold Acknowledgement
    output  wire            intr_en,    //Interrupt Enable
    output  wire            dbin,       //Data Bus In Control
    output  wire            sync,
    output  wire            wait_pin,
    output  wire            wr_not      //Active Low Write Not
};
endmodule