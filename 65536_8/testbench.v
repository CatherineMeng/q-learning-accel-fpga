`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/02/2019 10:56:26 AM
// Design Name: 
// Module Name: testbench
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
module testbench( );
  reg i_clk;
  reg i_rst;
  reg [2:0] a;
    reg[31:0] al; //xxxx.xxxx 0000_0010=0.125, fixed point representation for alpha and gamma
    reg[31:0] ga;
  //reg[7:0] alpha_in;
  //reg[7:0] gamma_in;
  wire [95:0] out;

    initial begin
        i_clk<=1;
        //#5
        i_rst<=1;
        al<=8'b0000_0010;
        ga<=8'b0000_0010;
        
        #10 i_rst<=0; 
        forever begin
        #20 a<=$urandom%8;
        end      
        //alpha_in=8'b0000_0001;
        //gamma_in=8'b0000_0001;
    end
    
    always begin 
    #10 i_clk=~i_clk;

    end
       
    pipeline test(
    .clk(i_clk),
    .rst(i_rst),
    .action(a),
    //.alpha(al),
    //.gamma(ga),
    //.cina(ina),
    //.cinb(inb),
    //.alpha(alpha_in),
    //.gamma(gamma_in),
    .sum(out));

endmodule
