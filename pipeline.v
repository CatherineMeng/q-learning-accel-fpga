//store tables in BRAMs
//width depends on range of q value, depth depends on number of states times num of actions

//The 4-stage (3-stage?) pipeline
//inputs: state-action
module pipeline  #(parameter ADDR_WIDTH = 8, DATA_WIDTH = 8, DEPTH = 16) ( input clk, input[7:0] alpha, input[7:0] gamma);

    //used in stage 1
    reg[7:0] q; //q value
    reg[7:0] r; //reward
    reg[7:0] qmax;
    reg[7:0] oneminusa; //1-alpha
    reg[15:0] ag; //alpha*gamma
    reg[5:0] s ; //2^6 possible states (8x8 grid, s[5:3]s -> x, s[2:0] -> y)
    reg[5:0] current_s ;
    reg[2:0] sx ; // s[5:3]s -> x, 
    reg[2:0] sy ; // s[2:0] -> y)
    //reg[5:0] ends; //end state assiume 111111(8,8)
    reg[5:0] nexts; //next state for state transition
    reg[1:0] action; //2^2 possible actions 00->left 01->up 10->right 11->dowm

    //used in stage 2
    
    //used in stage 3
    reg [23:0] sum;

    //used for q table rflag_nexting & writing 
    reg [ADDR_WIDTH-1:0] addrr_q;  
    reg [ADDR_WIDTH-1:0] addrw_q;
    reg wflag_q; //0 or 1
    reg [DATA_WIDTH-1:0] data_in_q;
    wire [DATA_WIDTH-1:0] data_out_q;

    //used for qmax table rflag_nexting & writing
    reg [ADDR_WIDTH-1:0] addrr_qmax;
    reg [ADDR_WIDTH-1:0] addrw_qmax;
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
        sx<=s[5:3];sy<=s[2:0];
        //locate next state 
        if (s[2:0]==3'b000 && action==2'b00) begin //left wall 
            nexts<=s;
        end
        else if (s[5:3]==3'b000 && action==2'b01) begin //up wall
            nexts<=s;      
        end
        else if (s[2:0]==3'b111 && action==2'b10) begin //right wall
            nexts<=s;      
        end
        else if (s[5:3]==3'b111 && action==2'b11) begin //down wall
            nexts<=s;     
        end
        else begin
            case (action)
                2'b00: sx<=sx-3'b001;//to the left by 1
                2'b01: sy<=sy-3'b001;//to the up by 1
                2'b10: sx<=sx+3'b001;//to the right by 1
                2'b11: sy<=sy+3'b001;//to the down by 1
            //default:
            endcase
            nexts<={sx,sy};
        end
        
        //locate q value from q table, save in q register
        addrr_q<={s,action}; 
        wflag_q<=0;
        q<=data_out_q;
        
        //locate reward from r table
        addr_r<={s,action}; 
        rflag_r<=1;
        r<=data_out_r;

        //calculate 1-a and a*g 
        ag <= alpha*gamma;
        oneminusa <= 8'b0001_0000 - alpha;
        
        //stop the pipeline if reached end state
        if (s == 6'b111111) begin
            $finish;
        end 
        //wait and transit the state
        current_s<=s;
        #5 s<=nexts; //dont know how long but I'll make it 5ns wait
    end     
    
    //--------------stage 2-----------------
    always @(posedge clk) begin
        //locate Qmax at next state from Qmax table
        addrr_qmax<=nexts;
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
            addrw_qmax<={current_s,action};
            data_in_qmax<=sum;
        end
        //write back to q table
        wflag_q<=1;
        addrr_q<={current_s,action}; 
        data_in_q<=sum;
    end
        
    qtable qt0(
        .i_clk(clk),
        .i_addr_r(addrr_q), 
        .i_addr_w(addrw_q), 
        .i_write_en(wflag_q),
        .i_data(data_in_q),
        .o_data(data_out_q)); 

    qmaxtable qmaxt0(
        .i_clk(clk),
        .i_addr_r(addrr_qmax), 
        .i_addr_w(addrw_qmax), 
        .i_write_en(wflag_qmax),
        .i_data(data_in_qmax),
        .o_data(data_out_qmax)); 

    rtable rt0(
        .i_clk(clk),
        .i_addr(addr_r), 
        .i_read(rflag_r), 
        .o_data(data_out_r));

endmodule