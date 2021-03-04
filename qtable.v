`timescale 1ns / 1ps
//assuming 64states, 4 actions, 256 s+a
//state: 5:0 action: 1:0    s+a: 7:0 
//q values stored on BRAM
module qtable #(parameter ADDR_WIDTH = 8, DATA_WIDTH = 32, DEPTH = 256) (
    input wire i_clk,
    input wire i_rst,
    input wire [ADDR_WIDTH-1:0] i_addr_r, 
    input wire [ADDR_WIDTH-1:0] i_addr_w, 
    input wire i_read_en,
    input wire i_write_en,
    input wire [DATA_WIDTH-1:0] i_data,
    output reg [DATA_WIDTH-1:0] o_data
    //output reg [DATA_WIDTH-1:0] o_data2 
    ); 
    integer i;
    reg [DATA_WIDTH-1:0] memory_array [0:DEPTH-1]; 
        
    always @ (posedge i_clk)
    begin
            if(i_write_en) begin
                memory_array[i_addr_w] <= i_data;
                $display("q written %02h in: %08b", i_data, i_addr_w);
            end
            if(i_read_en) begin
                o_data <= memory_array[i_addr_r];
                $display("q read %02h from: %08b", o_data, i_addr_r);
            end     
    end
endmodule 
