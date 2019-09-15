module rtable #(parameter ADDR_WIDTH = 8, DATA_WIDTH = 32, DEPTH = 256) (
    input wire i_clk,
    input wire [ADDR_WIDTH-1:0] i_addr, 
    input wire i_read, //need this??
    output reg [DATA_WIDTH-1:0] o_data);

    always @ (posedge i_clk)
    begin
        case (i_addr)
            //left walls
            8'b000_000_00: o_data<= -{DATA_WIDTH{1'b1}};  //-255
            8'b000_001_00: o_data<= -{DATA_WIDTH{1'b1}};
            8'b000_010_00: o_data<= -{DATA_WIDTH{1'b1}};
            8'b000_011_00: o_data<= -{DATA_WIDTH{1'b1}};
            8'b000_100_00: o_data<= -{DATA_WIDTH{1'b1}};
            8'b000_101_00: o_data<= -{DATA_WIDTH{1'b1}};
            8'b000_110_00: o_data<= -{DATA_WIDTH{1'b1}};
            8'b000_111_00: o_data<= -{DATA_WIDTH{1'b1}};
            //up WALLS
            8'b000_000_01: o_data<= -{DATA_WIDTH{1'b1}};
            8'b001_000_01: o_data<= -{DATA_WIDTH{1'b1}};  //-255
            8'b010_000_01: o_data<= -{DATA_WIDTH{1'b1}};
            8'b011_000_01: o_data<= -{DATA_WIDTH{1'b1}};
            8'b100_000_01: o_data<= -{DATA_WIDTH{1'b1}};
            8'b101_000_01: o_data<= -{DATA_WIDTH{1'b1}};
            8'b110_000_01: o_data<= -{DATA_WIDTH{1'b1}};
            8'b111_000_01: o_data<= -{DATA_WIDTH{1'b1}};
            ///right walls
            8'b111_000_10: o_data<= -{DATA_WIDTH{1'b1}};
            8'b111_001_10: o_data<= -{DATA_WIDTH{1'b1}};
            8'b111_010_10: o_data<= -{DATA_WIDTH{1'b1}};
            8'b111_011_10: o_data<= -{DATA_WIDTH{1'b1}};
            8'b111_100_10: o_data<= -{DATA_WIDTH{1'b1}};
            8'b111_101_10: o_data<= -{DATA_WIDTH{1'b1}};
            8'b111_110_10: o_data<= -{DATA_WIDTH{1'b1}};
            8'b111_111_10: o_data<= -{DATA_WIDTH{1'b1}};
            //rdown walls
            8'b000_111_11: o_data<= -{DATA_WIDTH{1'b1}};
            8'b001_111_11: o_data<= -{DATA_WIDTH{1'b1}};  //-255
            8'b010_111_11: o_data<= -{DATA_WIDTH{1'b1}};
            8'b011_111_11: o_data<= -{DATA_WIDTH{1'b1}};
            8'b100_111_11: o_data<= -{DATA_WIDTH{1'b1}};
            8'b101_111_11: o_data<= -{DATA_WIDTH{1'b1}};
            8'b110_111_11: o_data<= -{DATA_WIDTH{1'b1}};
            8'b111_111_11: o_data<= -{DATA_WIDTH{1'b1}};

            //(8,8): goal state, (7,8)=>11 or (8,7)=>10 gets big reward
            8'b110_111_11: o_data<= {DATA_WIDTH{1'b1}};
            8'b111_110_10: o_data<= {DATA_WIDTH{1'b1}};
            //... depends on the dataset?? 

            
            default :  o_data<= {DATA_WIDTH{1'b0}}; //others no reward
        endcase    
        $display("r read %02h from: %08b\n", o_data, i_addr);
    end
endmodule