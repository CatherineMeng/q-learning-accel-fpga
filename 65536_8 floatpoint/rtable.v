`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/30/2019 02:20:03 PM
// Design Name: 
// Module Name: rtable
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//r table implemented as ROM
//width depends on range of reward value, depth depends on number of states times num of actions
module rtable #(parameter ADDR_WIDTH = 19, DATA_WIDTH = 32, DEPTH = 524288) (
    input wire i_clk,
    input wire [ADDR_WIDTH-1:0] i_addr, 
    input wire i_read, //need this??
    output reg [DATA_WIDTH-1:0] o_data);

    always @ (posedge i_clk)
    begin
        casez (i_addr)
            //left walls
            19'b0000_0000_????_????_000: o_data<= -32'b11000111100000000000000000000000;  //-65536
            19'b0000_0000_????_????_001: o_data<= -32'b11000111100000000000000000000000;  //-65536
            19'b0000_0000_????_????_111: o_data<= -32'b11000111100000000000000000000000;  //-65536

            //up WALLS
            19'b????_????_0000_0000_001: o_data<= -32'b11000111100000000000000000000000;  //-65536
            19'b????_????_0000_0000_010: o_data<= -32'b11000111100000000000000000000000;  //-65536
            19'b????_????_0000_0000_011: o_data<= -32'b11000111100000000000000000000000;  //-65536
            ///right walls
            19'b1111_1111_????_????_011: o_data<= -32'b11000111100000000000000000000000;  //-65536
            19'b1111_1111_????_????_100: o_data<= -32'b11000111100000000000000000000000;  //-65536
            19'b1111_1111_????_????_101: o_data<= -32'b11000111100000000000000000000000;  //-65536
            //down  walls
            19'b????_????_1111_1111_101: o_data<= -32'b11000111100000000000000000000000;  //-65536
            19'b????_????_1111_1111_110: o_data<= -32'b11000111100000000000000000000000;  //-65536
            19'b????_????_1111_1111_111: o_data<= -32'b11000111100000000000000000000000;  //-65536

            //(8,8): goal state, (7,8)=>11 or (8,7)=>10 gets big reward
            19'b1111_1110_1111_1111_100: o_data<= 32'b01000111100000000000000000000000; //65536
            19'b1111_1111_1111_1110_110: o_data<= 32'b01000111100000000000000000000000;
            19'b1111_1110_1111_1110_101: o_data<= 32'b01000111100000000000000000000000;
            //... depends on the dataset?? 

            
            default :  o_data<= {DATA_WIDTH{1'b0}}; //others no reward
        endcase    
        //$display("r read %02h from: %08b\n", o_data, i_addr);
    end
endmodule
