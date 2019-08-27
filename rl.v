//store tables in BRAMs
//width depends on range of q value, depth depends on number of states times num of actions

//assuming 64states, 4 actions, 256 s+a
//state: 5:0 action: 1:0    s+a: 7:0 
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
    input reg read, //need this??
    output reg [DATA_WIDTH-1:0] o_data);

    always @ (i_addr)
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
    input reg read,
    output reg [DATA_WIDTH-1:0] o_data);

    always @ (read or i_addr) //???
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
module pipeline  #(parameter ADDR_WIDTH = 8, DATA_WIDTH = 8, DEPTH = 256) (
        input reg[7:0] alpha, input reg[7:0] gamma);

    //used in stage 1
    reg[7:0] q;
    reg[7:0] r;
    reg[7:0] qmax;
    reg[7:0] oneminusa;
    reg[15:0] ag; //alpha*gamma
    reg[4:0] s;
    reg[4:0] ends;
    reg[4:0] nexts;
    reg[4:0] action;
    //used in stage 2
    reg[15:0] ar;
    reg[15:0] oneminusa; //1-alpha
    reg[23:0] agqmax;
    //used in stage 3
    reg [23:0] sum;

    reg clk;
    //used for q table reading & writing 
    reg [ADDR_WIDTH-1:0] addrq;  
    wire wflagq; //0 or 1
    reg [DATA_WIDTH-1:0] data_inq;
    reg [DATA_WIDTH-1:0] data_outq;

    //used for qmax table reading & writing
    reg [ADDR_WIDTH-1:0] addrqmax;
    wire wflagqmax; //0 or 1
    reg [DATA_WIDTH-1:0] data_inqmax;
    reg [DATA_WIDTH-1:0] data_outqmax;

    //used for r table reading & writing
    reg [ADDR_WIDTH-1:0] addrr;
    reg wflagr; //0 or 1
    reg [DATA_WIDTH-1:0] data_outr;

    //used for finding next state
    reg [ADDR_WIDTH-1:0] addrnext;
    reg read;
    reg [DATA_WIDTH-1:0] data_outnext;

    always begin
        #5 clk = ~clk;  // timescale is 1ns so #5 provides 100MHz clock ?????? what clock frequency do we choose?
    end

    initial begin
        s<=0;

        //initialize q table, r table, qmax table
        //------code here------????????????????
    end
    //--------------stage 1-----------------
    always @(posedge clk) begin

        //Random action generator -> draws a
        action<=$urandom%10;
        //locate and read Q value, reward from q and reward table
        //read from q table
        addrq<=s*numactions+a;
        wflagq<=0;
        q<=data_outq;
        //read from r table
        addrr<=s*numactions+a;
        wflagr<=0;
        r<=data_outr;

        //locate next state nexts from nexts table:
        addrnext<=s*numactions+a;
        nexts<=data_outnext;

        //locate Qmax at next state from Qmax table
        addrqmax<=nexts;
        qmax<=data_outqmax;

        //calculate 1-a and a*g 
        ag <= alpha*gamma;
        oneminusa <= 8'b0001_0000 - a;
        

        s<=nexts;
    end     

    //--------------stage 2-----------------

    // combine stage 2 and 3?
    always @(posedge clk) begin
        //calculations of q learning function
        //while (k<steplimit)
        ar<=alpha*r;
        oneminusaq<=oneminusa*q;
        agqmax<=ag*qmax;
    end

    //--------------stage 3-----------------
    always @(posedge clk) begin
        //while (k<steplimit)
                //adder
        sum <= ar + oneminusaq + agqmax;
        //end

    end

    //--------------stage 4-----------------
    always @(posedge clk) begin

        //write back to q table

        //write back to qmax table

        //state <- 

    end

    qtable #(.ADDR_WIDTH (8), .DATA_WIDTH(8), .DEPTH(256) qt0(
        .i_clk(clk), 
        .i_addr(addrq), 
        .i_write(wflagq), 
        .i_data(data_inq),
        .o_data(data_outq));

    qmaxtable #(.ADDR_WIDTH (8), .DATA_WIDTH(8), .DEPTH(256) qt0(
        .i_clk(clk), 
        .i_addr(addrr), 
        .i_write(wflagqmax), 
        .i_data(data_inqmax),
        .o_data(data_outqmax));

    rtable #(.ADDR_WIDTH (8), .DATA_WIDTH(8), .DEPTH(256) qt0(
        .i_addr(addrr), 
        .read(wflagr), 
        .o_data(data_outr));

    nextstable #(.ADDR_WIDTH (8), .DATA_WIDTH(8), .DEPTH(256) qt0(
        .i_addr(addrnext), 
        .read(read), 
        .o_data(data_outnext));

endmodule