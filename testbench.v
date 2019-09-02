
module tb( );
  reg i_clk;
  reg[7:0] alpha_in;
  reg[7:0] gamma_in;

    initial begin
        i_clk=1;
        alpha_in=8'b0000_0001;
        gamma_in=8'b0000_0001;
    end
    
    always begin 
    #5 i_clk=~i_clk;
    end
     
    pipeline test(
    .clk(i_clk),
    //.cina(ina),
    //.cinb(inb),
    .alpha(alpha_in),
    .gamma(gamma_in));

endmodule