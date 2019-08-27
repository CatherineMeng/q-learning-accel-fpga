//store tables in BRAMs
//width depends on range of q value, depth depends on number of states times num of actions

//assuming 64states, 4 actions, 256 s+a
//state: 5:0 action: 1:0    {s,a}: 7:0 
//q values stored on BRAM
module qtable #(parameter ADDR_WIDTH = 8, DATA_WIDTH = 8, DEPTH = 256) (
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
    input wire i_clk, //need this??
    output reg [DATA_WIDTH-1:0] o_data);

    always @ (i_read)
    begin
        case (i_addr)
            8'b00000000: o_data<= 8'b00000000;
            8'b00000000: o_data<= 8'b00000000;
            8'b00000000: o_data<= 8'b00000000;
            //... depends on the dataset??

            
            default :  o_data<= 8'b00000000;
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
            8'b00000000: o_data<= 8'b00000000;
            8'b00000000: o_data<= 8'b00000000;
            //... depends on the dataset??

            
            default :  o_data<= 8'b00000000;
        endcase    
    end
endmodule

//The 4-stage (3-stage?) pipeline
//inputs: state-action
module pipeline  #(parameter ADDR_WIDTH = 8, DATA_WIDTH = 8, MULT = 16) (
    input wire [5:0] s, //state
    input wire [3:0] alpha,
    input wire [3:0] gamma,
    output reg [5:0] nexts); //define these parameters later

    //used in stage 1
    reg[7:0] q;
    reg[7:0] r;
    reg[7:0] qmax;
    reg[7:0] oneminusa; //1-alpha
    reg[15:0] ag; //alpha*gamma
    reg[5:0] ends;
    reg[1:0] action;
    reg[1:0] numactions;
    
    //used in stage 2
    reg[15:0] ar;
    reg[15:0] oneminusaq; //(1-alpha)q
    reg[23:0] agqmax;
    
    //used in stage 3
    reg [23:0] sum;

    reg clk;
    //used for q table reading & writing 
    reg [ADDR_WIDTH-1:0] addr_q;  
    reg wflag_q; //0 or 1
    reg [DATA_WIDTH-1:0] data_in_q;
    wire [DATA_WIDTH-1:0] data_out_q;

    //used for qmax table reading & writing
    reg [ADDR_WIDTH-1:0] addr_qmax;
    reg wflag_qmax; //0 or 1
    reg [DATA_WIDTH-1:0] data_in_qmax;
    wire [DATA_WIDTH-1:0] data_out_qmax;

    //used for r table reading
    reg [ADDR_WIDTH-1:0] addr_r;
    reg rflag_r; //0 or 1
    wire [DATA_WIDTH-1:0] data_out_r;

    //used for finding next state
    reg [ADDR_WIDTH-1:0] addr_next;
    reg rflag_next;
    wire [DATA_WIDTH-1:0] data_out_next;

    //--------------stage 1-----------------
    always @(posedge clk) begin

        //Random action generator -> draws a
        action<=$urandom%4;
        //locate Q value, reward from q and reward table
        //rflag_next from q table
        addr_q<=s*numactions+action; //{s,action}? save a multiplier?
        wflag_q<=0;
        q<=data_out_q;
        
        //reward from r table
        addr_r<=s*numactions+action; //{s,action}? save a multiplier?
        rflag_r<=1;
        r<=data_out_r;

        //----------------------------------------------break into 2 stages?-------------------------------
        //locate next state nexts from nexts table:
        addr_next<=s*numactions+action; //{s,action}? save a multiplier?
        rflag_next=1;//now data_out_next is next state, which will be used as address for looking up Qmax value

        //locate Qmax at next state from Qmax table
        addr_qmax<=data_out_next;
        wflag_qmax<=0;
        qmax<=data_out_qmax;
        //----------------------------------------------break into 2 stages?-------------------------------
        //calculate 1-a and a*g 
        ag <= alpha*gamma;
        oneminusa <= 8'b0001_0000 - alpha;
        

        s<=data_out_next; //???????????how to feed state as input through the policy action order

        //if (s == ends) $finish 
    end     

    //--------------stage 2-----------------

    // combine stage 2 and 3?
    //always @(qmax or r or q or ag or oneminusa) begin 
    always @(posedge clk) begin
        //calculations of q learning function
        ar<=alpha*r;
        oneminusaq<=oneminusa*q;
        agqmax<=ag*qmax;
    end

    //--------------stage 3-----------------
    //ways @(ar or agqmax or oneminusaq) begin
    always @(posedge clk) begin
                //adder
        sum <= ar + oneminusaq + agqmax;
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
        addr_q<=s*numactions+action; //or {s,action} ??
        data_in_q<=sum;
    end

    qtable qt0(
        .i_clk(clk), 
        .i_addr(addr_q), 
        .i_write(wflag_q), 
        .i_data(data_in_q),
        .o_data(data_out_q));

    qmaxtable qmaxt0(
        .i_clk(clk), 
        .i_addr(addr_r), 
        .i_write(wflag_qmax), 
        .i_data(data_in_qmax),
        .o_data(data_out_qmax));

    rtable rt0(
        .i_addr(addr_r), 
        .i_read(rflag_r), 
        .o_data(data_out_r));

    nextstable next0(
        .i_addr(addr_next), 
        .i_read(rflag_next), 
        .o_data(data_out_next));
endmodule