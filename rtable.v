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
            //up walls
            8'b000_000_01: o_data<= -8'b1111_1111;  //-255
            8'b000_001_01: o_data<= -8'b1111_1111;
            8'b000_010_01: o_data<= -8'b1111_1111;
            8'b000_011_01: o_data<= -8'b1111_1111;
            8'b000_100_01: o_data<= -8'b1111_1111;
            8'b000_101_01: o_data<= -8'b1111_1111;
            8'b000_110_01: o_data<= -8'b1111_1111;
            8'b000_111_01: o_data<= -8'b1111_1111;
            //LEFT WALLS
            8'b000_000_00: o_data<= -8'b1111_1111;
            8'b001_000_00: o_data<= -8'b1111_1111;  //-255
            8'b010_000_00: o_data<= -8'b1111_1111;
            8'b011_000_00: o_data<= -8'b1111_1111;
            8'b100_000_00: o_data<= -8'b1111_1111;
            8'b101_000_00: o_data<= -8'b1111_1111;
            8'b110_000_00: o_data<= -8'b1111_1111;
            8'b111_000_00: o_data<= -8'b1111_1111;
            ///down walls
            8'b111_000_11: o_data<= -8'b1111_1111;
            8'b111_001_11: o_data<= -8'b1111_1111;
            8'b111_010_11: o_data<= -8'b1111_1111;
            8'b111_011_11: o_data<= -8'b1111_1111;
            8'b111_100_11: o_data<= -8'b1111_1111;
            8'b111_101_11: o_data<= -8'b1111_1111;
            8'b111_110_11: o_data<= -8'b1111_1111;
            8'b111_111_11: o_data<= -8'b1111_1111;
            //right walls
            8'b000_111_10: o_data<= -8'b1111_1111;
            8'b001_111_10: o_data<= -8'b1111_1111;  //-255
            8'b010_111_10: o_data<= -8'b1111_1111;
            8'b011_111_10: o_data<= -8'b1111_1111;
            8'b100_111_10: o_data<= -8'b1111_1111;
            8'b101_111_10: o_data<= -8'b1111_1111;
            8'b110_111_10: o_data<= -8'b1111_1111;
            8'b111_111_10: o_data<= -8'b1111_1111;

            //(8,8): goal state, (7,8)=>11 or (8,7)=>10 gets big reward
            8'b110_111_11: o_data<= 8'b1111_1111;
            8'b111_110_10: o_data<= 8'b1111_1111;
            //... depends on the dataset?? 

            
            default :  o_data<= 8'b0000_0000; //others no reward
        endcase    
        $display("r read %02h from: %08b\n", o_data, i_addr);
    end
endmodule
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
            //up walls
            8'b000_000_01: o_data<= -8'b1111_1111;  //-255
            8'b000_001_01: o_data<= -8'b1111_1111;
            8'b000_010_01: o_data<= -8'b1111_1111;
            8'b000_011_01: o_data<= -8'b1111_1111;
            8'b000_100_01: o_data<= -8'b1111_1111;
            8'b000_101_01: o_data<= -8'b1111_1111;
            8'b000_110_01: o_data<= -8'b1111_1111;
            8'b000_111_01: o_data<= -8'b1111_1111;
            //LEFT WALLS
            8'b000_000_00: o_data<= -8'b1111_1111;
            8'b001_000_00: o_data<= -8'b1111_1111;  //-255
            8'b010_000_00: o_data<= -8'b1111_1111;
            8'b011_000_00: o_data<= -8'b1111_1111;
            8'b100_000_00: o_data<= -8'b1111_1111;
            8'b101_000_00: o_data<= -8'b1111_1111;
            8'b110_000_00: o_data<= -8'b1111_1111;
            8'b111_000_00: o_data<= -8'b1111_1111;
            ///down walls
            8'b111_000_11: o_data<= -8'b1111_1111;
            8'b111_001_11: o_data<= -8'b1111_1111;
            8'b111_010_11: o_data<= -8'b1111_1111;
            8'b111_011_11: o_data<= -8'b1111_1111;
            8'b111_100_11: o_data<= -8'b1111_1111;
            8'b111_101_11: o_data<= -8'b1111_1111;
            8'b111_110_11: o_data<= -8'b1111_1111;
            8'b111_111_11: o_data<= -8'b1111_1111;
            //right walls
            8'b000_111_10: o_data<= -8'b1111_1111;
            8'b001_111_10: o_data<= -8'b1111_1111;  //-255
            8'b010_111_10: o_data<= -8'b1111_1111;
            8'b011_111_10: o_data<= -8'b1111_1111;
            8'b100_111_10: o_data<= -8'b1111_1111;
            8'b101_111_10: o_data<= -8'b1111_1111;
            8'b110_111_10: o_data<= -8'b1111_1111;
            8'b111_111_10: o_data<= -8'b1111_1111;

            //(8,8): goal state, (7,8)=>11 or (8,7)=>10 gets big reward
            8'b110_111_11: o_data<= 8'b1111_1111;
            8'b111_110_10: o_data<= 8'b1111_1111;
            //... depends on the dataset?? 

            
            default :  o_data<= 8'b0000_0000; //others no reward
        endcase    
        $display("r read %02h from: %08b\n", o_data, i_addr);
    end
endmodule
