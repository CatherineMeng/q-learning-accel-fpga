/assuming 64states, 4 actions, 256 s+a
//state: 5:0 action: 1:0    s+a: 7:0 
//q values stored on BRAM
module qtable #(parameter ADDR_WIDTH = 8, DATA_WIDTH = 8, DEPTH = 256) (
    input wire i_clk,
    input wire [ADDR_WIDTH-1:0] i_addr_r, 
    input wire [ADDR_WIDTH-1:0] i_addr_w, 
    input wire i_write_en,
    input wire [DATA_WIDTH-1:0] i_data,
    output reg [DATA_WIDTH-1:0] o_data
    //output reg [DATA_WIDTH-1:0] o_data2 
    ); 
    integer i;
    reg [DATA_WIDTH-1:0] memory_array [0:DEPTH-1]; 
    
    initial begin    
     memory_array[0] <= 0;     
        for (i=0;i<DEPTH;i=i+1) begin
            memory_array[i] <= i;
        end
     //$readmemb("C:\Users\myuan\Desktop\q-learning-accel-fpga\qt_mem_init.txt",memory_array);
    end
    
    always @ (posedge i_clk)
    begin
            if(i_write_en) begin
                memory_array[i_addr_w] <= i_data;
            end
            //else begin
                o_data <= memory_array[i_addr_r];
            //end     
    end
endmodule 