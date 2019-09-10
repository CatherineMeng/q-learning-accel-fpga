`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/02/2019 10:53:28 AM
// Design Name: 
// Module Name: pipeline
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


//store tables in BRAMs
//width depends on range of q value, depth depends on number of states times num of actions

//The 4-stage (3-stage?) pipeline
//inputs: state-action
module pipeline  #(parameter ADDR_WIDTH = 8, DATA_WIDTH = 8, DEPTH = 16) ( input clk,input ce,output[23:0] sum);

    //used in stage 1
    reg[7:0] alpha; //xxxx.xxxx 0000_0010=0.125, fixed point representation for alpha and gamma
    reg[7:0] gamma;
    reg[7:0] q; //q value
    reg[7:0] r; //reward
    reg[7:0] qmax;
    reg[7:0] oneminusa; //1-alpha
    reg[15:0] ag; //alpha*gamma
    reg[5:0] s ; //2^6 possible states (8x8 (x,y) grid, s[5:3]s -> x, s[2:0] -> y)
    reg[5:0] current_s ;
    reg[5:0] current_s1 ;
    reg[5:0] current_s2 ;
    reg[5:0] current_s3 ;
    reg[5:0] current_s4 ;
    
    reg[2:0] sx ; // s[5:3]s -> x, 
    reg[2:0] sy ; // s[2:0]   -> y)
    //reg[5:0] ends; //end state assiume 111111(8,8)
    reg[5:0] nexts; //next state for state transition
    reg[1:0] action; //2^2 possible actions 00->left 01->up 10->right 11->dowm

    //used in stage 2
    
    //used in stage 3
    reg [23:0] sum;

    //used in stage 1 and 4
    //used for q table reading & writing 
    reg [7:0] addrr_q;  
    reg [7:0] addrw_q;
    //reg [7:0] addrr_q_tmp;
    //reg [7:0] addr_r_tmp;
    reg rflag_q; //0 or 1
    reg wflag_q; //0 or 1
    reg [DATA_WIDTH-1:0] data_in_q;
    wire [DATA_WIDTH-1:0] data_out_q;

    //used for qmax table reading & writing
    reg [5:0] addrr_qmax;
    reg [5:0] addrw_qmax;
    reg rflag_qmax; //0 or 1
    reg wflag_qmax; //0 or 1
    reg [DATA_WIDTH-1:0] data_in_qmax;
    wire [DATA_WIDTH-1:0] data_out_qmax;

    //used for r table reading
    reg [ADDR_WIDTH-1:0] addr_r;
    reg rflag_r; //0 or 1
    wire [DATA_WIDTH-1:0] data_out_r;

    /*used for finding next state
    reg [ADDR_WIDTH-1:0] addr_next;
    reg rflag_next;
    wire [DATA_WIDTH-1:0] data_out_next;*/

    ///initial begin
    initial begin 
        s<=6'b000_000;
        current_s<=6'b000000;
        nexts<=6'b000000;
        wflag_q<=0;
        wflag_qmax<=0;
        rflag_q<=0;
        rflag_qmax<=0;

    end
    //--------------stage 1-----------------
    always @(posedge clk) begin
        //if(ce) begin

        //Random action generator -> draws a
        action<=$urandom%4;
        //calculate 1-a and a*g 
        alpha<=8'b0000_0010;
        gamma<=8'b0000_0010;
        //scaling factor=2.0**-4.0 _
        ag <= alpha*gamma;
        oneminusa <= 8'b0001_0000 - alpha;        
        
        //locate next state
        sx<=s[5:3];sy<=s[2:0]; 
        if (sy==3'b000 && action==2'b00) begin //left wall 
            nexts<=s;
        end
        else if (sx==3'b000 && action==2'b01) begin //up wall
            nexts<=s;      
        end
        else if (sy==3'b111 && action==2'b10) begin //right wall
            nexts<=s;      
        end
        else if (sx==3'b111 && action==2'b11) begin //down wall
            nexts<=s;     
        end
        else begin
            case (action)
                2'b00: nexts<=s-6'b001000;//to the left by 1
                2'b01: nexts<=s-6'b000001;//to the up by 1
                2'b10: nexts<=s+6'b001000;//to the right by 1
                2'b11: nexts<=s+6'b000001;//to the down by 1
            //default:
            endcase
            //nexts<={sx,sy};
        end
        
        //get address for q and r and qmax

        addrr_q<={s,action}; 
        addr_r<={s,action};
        addrr_qmax<=nexts;
        $display("stage 1 s: %06b, action:%02b", s,action);
        $display("stage 1 nexts: %06b", nexts);
        $display("stage 1 addrr_q:%08b, addr_r:%08b, addr_qmax:%06b", addrr_q,addr_r,addrr_qmax);
        
        //wait and transit the state
        current_s<=s;
        #10  s<=nexts; //dont know how long but I'll make it 5ns wait
    //end  
    end   
    
    //--------------stage 2-----------------
    always @(posedge clk) begin
    //if(ce) begin
    //locate q value from q table, save in q register
   // $display("stage 2 s: %06b,current_s: %06b, action:%02b, addrr_q,%08b", s,current_s,action,addrr_q);
        rflag_q<=1;
        q<=data_out_q;
        
        rflag_r<=1;
        r<=data_out_r;
        $display("stage 2 r: %02h", r);
        $display("stage 2 q: %02h", q);
        //locate Qmax at next state from Qmax table
        
        rflag_qmax<=1;
        qmax<=data_out_qmax;
        //$display("stage 2 nexts: %06b", nexts);
        //$display("stage 2 addrr_qmax: %06b", addrr_qmax);
        $display("stage 2 qmax: %02h", qmax);
   // end
    end
    
    //--------------stage 3-----------------
    //always @(qmax or r or q or ag or oneminusa) begin 
    always @(posedge clk) begin
    //if(ce) begin
        //calculations of q learning function
                //adder
        sum <= alpha*r + oneminusa*q + ag*qmax;
        $display("stage 3 sum: %04h", sum);
        //end

    //end
    end

    //--------------stage 4-----------------
    //always @(sum) begin
    always @(posedge clk) begin
   // if(ce) begin
        //write back to qmax table
        if (sum>q)begin
            wflag_qmax<=1;
            addrw_qmax<=current_s;
            data_in_qmax<=sum;
            $display("stage 4 update qmax data_in_qmax: %02h", data_in_qmax);
            $display("stage 4 update qmax addrw_qmax: %06b", addrw_qmax);
        end
        //write back to q table
        wflag_q<=1;
        addrw_q<={current_s,action}; 
        data_in_q<=sum;
        $display("stage 4 update q data_in_q: %02h", data_in_q);
        $display("stage 4 update q addrw_q: %08b", addrw_q);
                //stop the pipeline if reached end state
                wflag_q<=1;
        if (current_s == 6'b111111) begin
            $finish;
        end
    //end
    end
        
    qtable qt0(
        .i_clk(clk),
        .i_addr_r(addrr_q), 
        .i_addr_w(addrw_q),
        .i_read_en(rflag_q), 
        .i_write_en(wflag_q),
        .i_data(data_in_q),
        .o_data(data_out_q)); 

    qmaxtable qmaxt0(
        .i_clk(clk),
        .i_addr_r(addrr_qmax), 
        .i_addr_w(addrw_qmax), 
        .i_read_en(rflag_qmax),
        .i_write_en(wflag_qmax),
        .i_data(data_in_qmax),
        .o_data(data_out_qmax)); 

    rtable rt0(
        .i_clk(clk),
        .i_addr(addr_r), 
        .i_read(rflag_r), 
        .o_data(data_out_r));

endmodule