//store tables in BRAMs
//width depends on range of q value, depth depends on number of states times num of actions

//assuming 64states, 4 actions, 256 s+a
//state: 5:0 action: 1:0    s+a: 7:0 
//q values stored on BRAM
module qtable #(parameter ADDR_WIDTH = 8, DATA_WIDTH = 8, DEPTH = 256) (
    input wire i_clk,
    input wire [ADDR_WIDTH-1:0] i_addr, 
    input wire [ADDR_WIDTH-1:0] i_addr2, 
    input wire i_write,
    input wire [DATA_WIDTH-1:0] i_data,
    output reg [DATA_WIDTH-1:0] o_data,
    output reg [DATA_WIDTH-1:0] o_data2 
    );

    reg [DATA_WIDTH-1:0] memory_array [0:DEPTH-1]; 

    always @ (posedge i_clk)
    begin
            if(i_write) begin
                memory_array[i_addr] <= i_data;
            end
            else begin
                o_data <= memory_array[i_addr];
            end     
    end
endmodule

//qmax values stored on BRAM
//width depends on range of q value, depth depends on number of states 
module qmaxtable #(parameter ADDR_WIDTH = 8, DATA_WIDTH = 8, DEPTH = 64) (
    input wire i_clk,
    input wire [ADDR_WIDTH-1:0] i_addr, 
    input wire i_write,
    input wire [DATA_WIDTH-1:0] i_data,
    output reg [DATA_WIDTH-1:0] o_data 
    );

    reg [DATA_WIDTH-1:0] memory_array [0:DEPTH-1]; 

    always @ (posedge i_clk)
    begin
        if(i_write) begin
            memory_array[i_addr] <= i_data;
        end
        else begin
            o_data <= memory_array[i_addr];
        end     
    end
endmodule

//r table implemented as ROM
//width depends on range of reward value, depth depends on number of states times num of actions
module rtable #(parameter ADDR_WIDTH = 8, DATA_WIDTH = 8, DEPTH = 256) (
    input wire [ADDR_WIDTH-1:0] i_addr, 
    input wire i_read, //need this??
    output reg [DATA_WIDTH-1:0] o_data);

    always @ (i_read)
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

//map to next state using ROM LUT
module nextstable #(parameter ADDR_WIDTH = 8, DATA_WIDTH = 8, DEPTH = 64) (
    input wire [ADDR_WIDTH-1:0] i_addr, 
    input wire i_read,
    output reg [DATA_WIDTH-1:0] o_data);

    always @ (i_read) 
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

//The 4-stage (3-stage?) pipeline
//inputs: state-action
module pipeline  #(parameter ADDR_WIDTH = 8, DATA_WIDTH = 8, DEPTH = 16) (input[7:0] alpha, input[7:0] gamma);

    //used in stage 1
    reg[7:0] q;
    reg[7:0] r;
    reg[7:0] qmax;
    reg[7:0] oneminusa; //1-alpha
    reg[15:0] ag; //alpha*gamma
    reg[5:0] s ;
    reg[5:0] ends;
    reg[5:0] nexts; 
    reg[1:0] action;
    //reg[1:0] numactions;
    //used in stage 2
    
    //used in stage 3
    reg [23:0] sum;

    reg clk;
    //used for q table rflag_nexting & writing 
    reg [ADDR_WIDTH-1:0] addr_q;  
    reg wflag_q; //0 or 1
    reg [DATA_WIDTH-1:0] data_in_q;
    wire [DATA_WIDTH-1:0] data_out_q;

    //used for qmax table rflag_nexting & writing
    reg [ADDR_WIDTH-1:0] addr_qmax;
    reg wflag_qmax; //0 or 1
    reg [DATA_WIDTH-1:0] data_in_qmax;
    wire [DATA_WIDTH-1:0] data_out_qmax;

    //used for r table rflag_nexting & writing
    reg [ADDR_WIDTH-1:0] addr_r;
    reg rflag_r; //0 or 1
    wire [DATA_WIDTH-1:0] data_out_r;

    //used for finding next state
    reg [ADDR_WIDTH-1:0] addr_next;
    reg rflag_next;
    wire [DATA_WIDTH-1:0] data_out_next;

    ///initial begin
    //--------------stage 1-----------------
    always @(posedge clk) begin

        //Random action generator -> draws a
        action<=$urandom%4;
        //locate Q value, reward from q and reward table
        //rflag_next from q table
        addr_q<={s,action}; //{s,action}? save a multiplier?
        wflag_q<=0;
        q<=data_out_q;
        
        //reward from r table
        addr_r<={s,action}; //{s,action}? save a multiplier?
        rflag_r<=1;
        r<=data_out_r;

        //locate next state nexts from nexts table:
        addr_next<={s,action}; //{s,action}? save a multiplier?
        rflag_next<=1;//now data_out_next is next state, which will be used as address for looking up Qmax value
        nexts<=data_out_next;


        //calculate 1-a and a*g 
        ag <= alpha*gamma;
        oneminusa <= 8'b0001_0000 - alpha;
        

        //s<=data_out_next; //???????????how to feed state as input through the policy action order

        //if (s == ends) $finish 
    end     
    
    //--------------stage 2-----------------
    always @(posedge clk) begin
        //locate Qmax at next state from Qmax table
        addr_qmax<=nexts;
        wflag_qmax<=0;
        qmax<=data_out_qmax;
    end
    
    //--------------stage 3-----------------
    //always @(qmax or r or q or ag or oneminusa) begin 
    always @(posedge clk) begin
        //calculations of q learning function
                //adder
        sum <= alpha*r + oneminusa*q + ag*qmax;
        //end

    end

    //--------------stage 4-----------------
    //always @(sum) begin
    always @(posedge clk) begin


        //write back to qmax table
        if (sum>q)begin
            wflag_qmax<=1;
            addr_qmax<=s;
            data_in_qmax<=sum;
        end;

        //write back to q table
        wflag_q<=1;
        addr_q<={s,action}; //or {s,action} ??
        data_in_q<=sum;
    end
    //end



endmodule