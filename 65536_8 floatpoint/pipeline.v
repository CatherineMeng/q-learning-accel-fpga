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

//The 4-stage pipeline
//inputs: action
module pipeline  #(parameter ADDR_Q_WIDTH = 19,parameter ADDR_Qmax_WIDTH = 16, DATA_WIDTH = 32) ( input clk,input rst, input[2:0] action, output reg[63:0] sum);

    //used in stage 1
    reg[DATA_WIDTH-1:0] q; //q value
    reg[DATA_WIDTH-1:0] r; //reward
    reg[DATA_WIDTH-1:0] q1; //q value
    reg[DATA_WIDTH-1:0] r1; //reward
    reg[DATA_WIDTH-1:0] qmax;

    reg[ADDR_Qmax_WIDTH-1:0] s; //2^16 possible states (256x256 (x,y) grid, s[15:8]s -> x, s[7:0] -> y)
    reg[DATA_WIDTH-1:0] alpha;
    reg[DATA_WIDTH-1:0] gamma;
    reg[DATA_WIDTH-1:0] oneminusa; //1-alpha
    reg[DATA_WIDTH-1:0] ag; //alpha*gamma
    wire result_tvalid;
    wire result_tvalid2;
    wire result_tvalid3;
    
    //propagate for qmax writing address
    reg[ADDR_Qmax_WIDTH-1:0] current_s ;
    reg[ADDR_Qmax_WIDTH-1:0] current_s1 ;
    reg[ADDR_Qmax_WIDTH-1:0] current_s2 ;
    reg[ADDR_Qmax_WIDTH-1:0] current_s3 ;
    reg[ADDR_Qmax_WIDTH-1:0] current_s4 ;        
    //propagate for q writing address
    reg[2:0] current_a ;
    reg[2:0] current_a1 ;
    reg[2:0] current_a2 ;
    reg[2:0] current_a3 ;
    reg[2:0] current_a4 ;
        
    reg[7:0] sx ; // s[15:8]s -> x, 
    reg[7:0] sy ; // s[7:0]   -> y)
    reg[ADDR_Qmax_WIDTH-1:0] nexts; //next state for state transition

    //used in stage 2
    
    //used in stage 3
    //reg [23:0] sum;

    //used in stage 1 and 4
    //used for q table reading & writing 
    reg [ADDR_Q_WIDTH-1:0] addrr_q;  
    reg [ADDR_Q_WIDTH-1:0] addrw_q;
    //reg [7:0] addrr_q_tmp;
    //reg [7:0] addr_r_tmp;
    reg rflag_q; //0 or 1
    reg wflag_q; //0 or 1
    reg [DATA_WIDTH-1:0] data_in_q;
    wire [DATA_WIDTH-1:0] data_out_q;

    //used for qmax table reading & writing
    reg [ADDR_Qmax_WIDTH-1:0] addrr_qmax;
    reg [ADDR_Qmax_WIDTH-1:0] addrw_qmax;
    reg rflag_qmax; //0 or 1
    reg wflag_qmax; //0 or 1
    reg [DATA_WIDTH-1:0] data_in_qmax;
    wire [DATA_WIDTH-1:0] data_out_qmax;

    //used for r table reading
    reg [ADDR_Q_WIDTH-1:0] addr_r;
    reg rflag_r; //0 or 1
    wire [DATA_WIDTH-1:0] data_out_r;
    localparam sf = 2.0**-4.0;
    //--------------stage 1-----------------
    always @(posedge clk) begin
    //initialize state and action
        if (rst) begin
            s<= {16{1'b0}};
            current_s<={16{1'b0}};
            nexts<={16{1'b0}};
            alpha<=32'b00111111010011001100110011001101; //0.8
            gamma<=32'b00111111010011001100110011001101; //0.8

        end
 
        //calculate 1-a and a*g 
        //scaling factor=2.0**-4.0 _
        //ag <= alpha*gamma;
        ag<=32'b01000111101011100001011; //0.8*0.8
        //oneminusa <= 32'b00111111100000000000000000000000 - alpha; 
        oneminusa<=32'b10011001100110011001100;    //1-0.8   
        
        //locate next state
        sx<=s[15:8];sy<=s[7:0]; 
        if (sx=={8{1'b0}} && (action==3'b000)||(action==3'b001)||(action==3'b111)) begin //left wall 
            nexts<=s;
        end
        else if (sy=={8{1'b0}} && (action==3'b001)||(action==3'b010)||(action==3'b011)) begin //up wall
            nexts<=s;      
        end
        else if (sx=={8{1'b1}} &&(action==3'b011)||(action==3'b100)||(action==3'b101)) begin //right wall
            nexts<=s;      
        end
        else if (sy=={8{1'b1}} && (action==3'b101)||(action==3'b110)||(action==3'b111)) begin //down wall
            nexts<=s;     
        end
        else begin
            case (action)
                3'b000: nexts<=s-16'b0000_0001_0000_0000;//to the left by 1
                3'b001: nexts<=s-16'b0000_0001_0000_0001;//to the left-up by 1
                3'b010: nexts<=s-16'b0000_0000_0000_0001;//to the up by 1
                3'b011: nexts<=s-16'b0000_0000_0000_0001+16'b0000_0001_0000_0000;//to the up-right by 1
                3'b100: nexts<=s+16'b0000_0001_0000_0000;//to the right by 1
                3'b101: nexts<=s+16'b0000_0001_0000_0001;//to the right-down by 1
                3'b110: nexts<=s+16'b0000_0000_0000_0001;//to the down by 1
                3'b111: nexts<=s+16'b0000_0000_0000_0001-16'b0000_0001_0000_0000;//to the down-left by 1
            //default:
            endcase
            //nexts<={sx,sy};
        end
        
        //get address for q and r and qmax
        addrr_q<={s,action}; 
        addr_r<={s,action};
        addrr_qmax<=nexts;
        //$display("stage 1 s: %06b, action:%02b", s,action);
        //$display("stage 1 nexts: %06b", nexts);
        //$display("stage 1 addrr_q:%08b, addr_r:%08b, addr_qmax:%06b", addrr_q,addr_r,addrr_qmax);
        
        //wait and transit the state
        current_s<=s;
        current_s1<=current_s;
        current_a<=action;
        current_a1<=current_a;
        s<=nexts;  
    end   
    
    
    
    //--------------stage 2-----------------
    always @(posedge clk) begin
    //locate q value from q table, save in q register
   // $display("stage 2 s: %06b,current_s: %06b, action:%02b, addrr_q,%08b", s,current_s,action,addrr_q);
        rflag_q<=1;
        q<=data_out_q;
        q1<=q;
        
        rflag_r<=1;
        r<=data_out_r;
        r1<=r;
        //$display("stage 2 r1: %02h", r1);
        //$display("stage 2 q1: %02h", q1);
        //locate Qmax at next state from Qmax table
        
        rflag_qmax<=1;
        qmax<=data_out_qmax;
        //$display("stage 2 nexts: %06b", nexts);
        //$display("stage 2 addrr_qmax: %06b", addrr_qmax);
        //$display("stage 2 qmax: %02h", qmax);
        
        current_s2<=current_s1;
        current_a2<=current_a1;
        
    end
    
    //--------------stage 3-----------------
    //always @(qmax or r or q or ag or oneminusa) begin 
    
    wire [31:0] sum_part1;
    wire [31:0] sum_part2;
    wire [31:0] sum_part3;

    /*reg [31:0] sum_1;
    reg [31:0] sum_2;
    reg [31:0] sum_3;*/

    always@(posedge clk)
    begin
        //sum_part1 <= alpha*r1;
        //sum_part2 <= oneminusa*q1;
       //  sum_part3 <= ag*qmax;

        //calculations of q learning function
                //adder
        sum <= sum_part1 + sum_part2 + sum_part3;
        //$display("stage 3 sum: %04h", sum);
        
        current_s3<=current_s2;
        current_a3<=current_a2;
        current_s4<=current_s3;
        current_a4<=current_a3;

    end
    /*
    always @(posedge clk) begin
        //calculations of q learning function
                //adder
        sum <= alpha*r1 + oneminusa*q1 + ag*qmax;
        //sum <= alpha*r1*2**(-4) + oneminusa*q1*2**(-4) + ag*qmax*2**(-8);
        //$display("stage 3 sum: %04h", sum);
        
        current_s3<=current_s2;
        current_a3<=current_a2;
    end  */  
    
    

    //--------------stage 4-----------------
    //always @(sum) begin
    always @(posedge clk) begin
   // if(ce) begin
        //write back to qmax table
        if (sum>q)begin
            wflag_qmax<=1;
            addrw_qmax<=current_s3;
            data_in_qmax<=sum;
            //$display("stage 4 update qmax data_in_qmax: %02h", data_in_qmax);
            //$display("stage 4 update qmax addrw_qmax: %06b", addrw_qmax);
        end
        //write back to q table
        wflag_q<=1;
        addrw_q<={current_s3,current_a3}; 
        data_in_q<=sum;
        //$display("stage 4 update q data_in_q: %02h", data_in_q);
        //$display("stage 4 update q addrw_q: %08b", addrw_q);
        //stop the pipeline if reached end state
        //if (current_s3 == 6'b111111) begin
        //    $finish;
        //end
    //end
    end
        
    qtable qt0(
        .i_clk(clk),
        .i_rst(rst),
        .i_addr_r(addrr_q), 
        .i_addr_w(addrw_q),
        .i_read_en(rflag_q), 
        .i_write_en(wflag_q),
        .i_data(data_in_q),
        .o_data(data_out_q)); 

    qmaxtable qmaxt0(
        .i_clk(clk),
        .i_rst(rst),
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
        
    floating_point_0 sum1 (
      .aclk(clk),                                  // input wire aclk
      .s_axis_a_tvalid(1'b1),            // input wire s_axis_a_tvalid
      .s_axis_a_tdata(alpha),              // input wire [31 : 0] s_axis_a_tdata
      .s_axis_b_tvalid(1'b1),            // input wire s_axis_b_tvalid
      .s_axis_b_tdata(r1),              // input wire [31 : 0] s_axis_b_tdata
      .m_axis_result_tvalid(result_tvalid),  // output wire m_axis_result_tvalid
      .m_axis_result_tdata(sum_part1)    // output wire [31 : 0] m_axis_result_tdata
    );
    
    floating_point_0 sum2 (
      .aclk(clk),                                  // input wire aclk
      .s_axis_a_tvalid(1'b1),            // input wire s_axis_a_tvalid
      .s_axis_a_tdata(oneminusa),              // input wire [31 : 0] s_axis_a_tdata
      .s_axis_b_tvalid(1'b1),            // input wire s_axis_b_tvalid
      .s_axis_b_tdata(q1),              // input wire [31 : 0] s_axis_b_tdata
      .m_axis_result_tvalid(result_tvalid2),  // output wire m_axis_result_tvalid
      .m_axis_result_tdata(sum_part2)    // output wire [31 : 0] m_axis_result_tdata
    );    
    
    floating_point_0 sum3 (
      .aclk(clk),                                  // input wire aclk
      .s_axis_a_tvalid(1'b1),            // input wire s_axis_a_tvalid
      .s_axis_a_tdata(ag),              // input wire [31 : 0] s_axis_a_tdata
      .s_axis_b_tvalid(1'b1),            // input wire s_axis_b_tvalid
      .s_axis_b_tdata(qmax),               // input wire [31 : 0] s_axis_b_tdata
      .m_axis_result_tvalid(result_tvalid3),  // output wire m_axis_result_tvalid
      .m_axis_result_tdata(sum_part3 )    // output wire [31 : 0] m_axis_result_tdata
    );

endmodule