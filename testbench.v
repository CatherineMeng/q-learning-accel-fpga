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
  reg [1:0] a;
  //reg[7:0] alpha_in;
  //reg[7:0] gamma_in;
  wire [23:0] out;

    initial begin
        i_clk<=1;
        //#5
        i_rst<=1;
        
        #5 i_rst<=0; 
        forever begin
        #10 a<=$urandom%4;
        end      
        //alpha_in=8'b0000_0001;
        //gamma_in=8'b0000_0001;
    end
    
    always begin 
    #5 i_clk=~i_clk;

    end
    

     
    pipeline test(
    .clk(i_clk),
    .rst(i_rst),
    .action(a),
    //.cina(ina),
    //.cinb(inb),
    //.alpha(alpha_in),
    //.gamma(gamma_in),
    .sum(out));

endmodule
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
  reg [1:0] a;
  //reg[7:0] alpha_in;
  //reg[7:0] gamma_in;
  wire [23:0] out;

    initial begin
        i_clk<=1;
        //#5
        i_rst<=1;
        
        #5 i_rst<=0; 
        forever begin
        #10 a<=$urandom%4;
        end      
        //alpha_in=8'b0000_0001;
        //gamma_in=8'b0000_0001;
    end
    
    always begin 
    #5 i_clk=~i_clk;

    end
    

     
    pipeline test(
    .clk(i_clk),
    .rst(i_rst),
    .action(a),
    //.cina(ina),
    //.cinb(inb),
    //.alpha(alpha_in),
    //.gamma(gamma_in),
    .sum(out));

endmodule
