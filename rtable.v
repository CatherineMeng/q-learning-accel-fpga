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
module rtable #(parameter ADDR_WIDTH = 8, DATA_WIDTH = 8, DEPTH = 256) (
    input wire i_clk,
    input wire [ADDR_WIDTH-1:0] i_addr, 
    input wire i_read, //need this??
    output reg [DATA_WIDTH-1:0] o_data);

    always @ (posedge i_clk)
    begin
        case (i_addr)
            8'b00000000: o_data<= 8'b00000000;
            8'b00000001: o_data<= 8'b00000001;
            8'b00000010: o_data<= 8'b00000010;
            //... depends on the dataset??

            
            default :  o_data<= 8'b11110111;
        endcase    
    end
endmodule