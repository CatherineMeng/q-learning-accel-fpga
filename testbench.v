module pipeline_testbench  #(parameter ADDR_WIDTH = 8, DATA_WIDTH = 8, DEPTH = 16) ();

    always begin
        #5 clk = ~clk;  // timescale is 1ns so #5 provides 100MHz clock ?????? what clock frequency do we choose?
    end

    initial begin
        s<=0;

        clk=1;

        //initialize all r(read) flags to 0, w(write) flags to??
        //initialize q table, r table, qmax table
        //--------------code here-----------????????????????
    end




endmodule