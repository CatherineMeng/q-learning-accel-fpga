`timescale 1ns / 1ps
//qmax values stored on BRAM
//width depends on range of q value, depth depends on number of states 
module qmaxtable #(parameter ADDR_WIDTH = 6, DATA_WIDTH = 8, DEPTH = 64) (
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
    //initialize the bram: depends on the test case
    /*initial begin
     memory_array[0] <= 0;
        for (i=0;i<DEPTH;i=i+1) begin
            memory_array[i] <= 8'b0000_0000;
        end
    end*/
     //$readmemb("C:\Users\myuan\Desktop\q-learning-accel-fpga\qt_mem_init.txt",memory_array);
    //end
    
    always @ (posedge i_clk)
    begin
            if (i_rst) begin
             memory_array[0] <= 0;
                for (i=0;i<DEPTH;i=i+1) begin
                    memory_array[i] <= 8'b0000_0000;
                end
            end
            if(i_write_en) begin
                memory_array[i_addr_w] <= i_data;
                $display("qmax written %02h in: %06b", i_data, i_addr_w);
            end
            if(i_read_en) begin
                o_data <= memory_array[i_addr_r];
                $display("qmax read %02h from: %06b", o_data, i_addr_r);
            end     
    end
endmodule 