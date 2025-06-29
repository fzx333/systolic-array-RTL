// This module contains two components: a systolic array of MAC units, and
// registers that skew the weights going into the systolic array.

module systolic_array_is
#( 
  parameter INPUT_WIDTH = 16,
  parameter WEIGHT_WIDTH = 16,
  parameter PSUM_WIDTH = 16,
  parameter ARRAY_HEIGHT = 4,
  parameter ARRAY_WIDTH = 4
)(
  input clk,
  input rst_n,
  input process_en,
  input input_en,
  input [INPUT_WIDTH * ARRAY_HEIGHT - 1 : 0] packed_input_in,
  input [WEIGHT_WIDTH * ARRAY_WIDTH - 1 : 0] packed_weight_in,
  output [PSUM_WIDTH * ARRAY_HEIGHT - 1 : 0] packed_psum_out
);
  // Verilog does not support two dimensional arrays as ports of modules. 
  wire [INPUT_WIDTH - 1 : 0] input_in [ARRAY_HEIGHT - 1 : 0];
  // Generate unpacked array assignments from flat bus
  genvar i;
  generate
    for (i = 0; i < ARRAY_HEIGHT; i = i + 1) begin : unpack_loop1
      assign input_in[i] = packed_input_in[i * INPUT_WIDTH +: INPUT_WIDTH];
    end
  endgenerate


  // Weight skew registers: There are two sets of skew registers, each
  // instantiated in a triangular pattern.
  
  wire [WEIGHT_WIDTH - 1 : 0] weight_in_skewed [ARRAY_WIDTH - 1 : 0];
  wire [WEIGHT_WIDTH * ARRAY_WIDTH - 1 : 0] packed_weight_in_skewed;

  skew_registers
  #(
    .DATA_WIDTH(WEIGHT_WIDTH),
    .N(ARRAY_WIDTH)
  ) weight_in_skew_registers_inst (
    .clk(clk),
    .rst_n(rst_n),
    .en(process_en),
    .packed_din(packed_weight_in),
    .packed_dout(packed_weight_in_skewed)
  );
  // Generate unpacked array assignments from flat bus
  generate
    for (i = 0; i < ARRAY_WIDTH; i = i + 1) begin : unpack_loop2
      assign weight_in_skewed[i] = packed_weight_in_skewed[i * WEIGHT_WIDTH +: WEIGHT_WIDTH];
    end
  endgenerate
  
  // Systolic array
  
  // Generate a systolic array of MAC units, input_in is the vector of inputs that
  // enters into the left column of MACs, and propagates towards the right.
  // weight_in_skewed (generated in the code above) is the vector of weights that
  // enters into the top row of MACs, and propagates downwards. psum_in is the vecto
  // of partial sums that enters into the left column of MACs and gets accumulated
  // on as it moves towards the right. psum_out is the vector of partial sums that
  // is the output of last column of MACs, and it is also the output of the systolic array.

  wire [INPUT_WIDTH - 1 : 0] input_w [ARRAY_HEIGHT - 1 : 0][ARRAY_WIDTH : 0];
  wire [WEIGHT_WIDTH - 1 : 0] weight_w [ARRAY_HEIGHT: 0][ARRAY_WIDTH - 1 : 0];
  wire [PSUM_WIDTH - 1 : 0] psum_w [ARRAY_HEIGHT -1 : 0][ARRAY_WIDTH: 0];
  genvar x, y; 
  generate
    for (x = 0; x < ARRAY_HEIGHT; x = x + 1) begin: row
      for (y = 0; y < ARRAY_WIDTH; y = y + 1) begin: col
        if (y == 0) begin: left1
          assign input_w[x][y] = input_in[x];
        end
        if (x == 0) begin: top
          assign weight_w[x][y] = weight_in_skewed[y];
        end
        if (y == 0) begin : left2
          assign psum_w[x][y] = { PSUM_WIDTH { 1'b0 } };
        end
        // if (y == ARRAY_WIDTH - 1) begin
        //   assign psum_out_skewed[x] = psum_w[x][y + 1];
        // end
        pe_is #(
          .INPUT_WIDTH(INPUT_WIDTH),
          .WEIGHT_WIDTH(WEIGHT_WIDTH),
          .PSUM_WIDTH(PSUM_WIDTH)
        ) pe_is_inst (
          .clk(clk),
          .rst_n(rst_n),
          .process_en(process_en),
          .input_en(input_en),
          .input_in(input_w[x][y]),
          .weight_in(weight_w[x][y]),
          .psum_in(psum_w[x][y]),
          .input_out(input_w[x][y + 1]),
          .weight_out(weight_w[x + 1][y]),
          .psum_out(psum_w[x][y + 1])
        );
      end
    end
  endgenerate

  // The second set of registers unskews the output (psum_out)
  wire [PSUM_WIDTH - 1 : 0] psum_out_skewed [ARRAY_HEIGHT - 1 : 0];
  wire [PSUM_WIDTH * ARRAY_HEIGHT - 1 : 0] packed_psum_out_skewed;
  wire [PSUM_WIDTH * ARRAY_HEIGHT - 1 : 0] packed_psum_out_unskewed;
  generate
    for (i = 0; i < ARRAY_HEIGHT; i = i + 1) begin : unpack_loop3
      assign packed_psum_out_skewed[i * PSUM_WIDTH +: PSUM_WIDTH]  = psum_out_skewed[i];
    end
  endgenerate

  skew_registers
  #(
    .DATA_WIDTH(PSUM_WIDTH),
    .N(ARRAY_HEIGHT)
  ) psum_out_unskew_registers_inst (
    .clk(clk),
    .rst_n(rst_n),
    .en(process_en),
    .packed_din(packed_psum_out_skewed),
    .packed_dout(packed_psum_out_unskewed)
  );

  // Because the 0th entry in the array must be delayed the most which is
  // opposite from the way the skew resgiters are generated, so we just
  // flip the inputs to them

  generate
    for (x = 0; x < ARRAY_HEIGHT; x = x + 1) begin: reverse 
      assign psum_out_skewed[x] = psum_w[ARRAY_HEIGHT - 1 - x][ARRAY_WIDTH];
      assign packed_psum_out[PSUM_WIDTH * x +: PSUM_WIDTH] = packed_psum_out_unskewed[(ARRAY_HEIGHT - 1 - x) * PSUM_WIDTH +: PSUM_WIDTH];
    end
  endgenerate

endmodule
