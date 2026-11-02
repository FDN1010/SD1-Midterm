`default_nettype none

module instruction_register (
    //Ports Here
    //inputs
    input wire i_clk, //Clock signal
    input wire [7:0] i_data_in, //Instruction opcode
    input wire i_load_en, //Capture opcode

    //outputs
    output wire [7:0] o_opcode //Stored opcode supplied to decoder
);

reg [7:0] opcode;

assign o_opcode = opcode;

always @(posedge i_clk) begin
    opcode <= i_load_en ? i_data_in : opcode; //If i_load_en = 1 store new opcode
end

//TODO
//Need to add reset logic and potentially the second clock
    
endmodule

`default_nettype wire
