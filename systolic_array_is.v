// This module contains two components: a systolic array of MAC units, and
// registers that skew the weights going into the systolic array.

module systolic_array
#( 
  parameter INPUT_WIDTH = 16,
  parameter WEIGHT_WIDTH = 16,
  parameter PSUM_WIDTH = 32,
  parameter ARRAY_HEIGHT = 4,
  parameter ARRAY_WIDTH = 4
)(
  input clk,
  input rst_n,
  input process_en,
  input input_en,
  input signed [INPUT_WIDTH - 1 : 0] input_in [ARRAY_HEIGHT - 1 : 0],
  input signed [WEIGHT_WIDTH - 1 : 0] weight_in [ARRAY_WIDTH - 1 : 0],
  // input signed [PSUM_WIDTH - 1 : 0] psum_in [ARRAY_WIDTH - 1 : 0],
  output signed [PSUM_WIDTH - 1 : 0] psum_out [ARRAY_WIDTH - 1 : 0]
);

  // Weight skew registers: There are two sets of skew registers, each
  // instantiated in a triangular pattern.
  
  wire signed [WEIGHT_WIDTH - 1 : 0] weight_in_skewed [ARRAY_WIDTH - 1 : 0];

  skew_registers
  #(
    .DATA_WIDTH(WEIGHT_WIDTH),
    .N(ARRAY_WIDTH)
  ) weight_in_skew_registers_inst (
    .clk(clk),
    .rst_n(rst_n),
    .en(process_en),
    .din(weight_in),
    .dout(weight_in_skewed)
  );
  
  // Systolic array
  
  // Generate a systolic array of MAC units, input_in is the vector of inputs that
  // enters into the left column of MACs, and propagates towards the right.
  // weight_in_skewed (generated in the code above) is the vector of weights that
  // enters into the top row of MACs, and propagates downwards. psum_in is the vecto
  // of partial sums that enters into the left column of MACs and gets accumulated
  // on as it moves towards the right. psum_out is the vector of partial sums that
  // is the output of last column of MACs, and it is also the output of the systolic array.

  wire signed [INPUT_WIDTH - 1 : 0] input_w [ARRAY_HEIGHT - 1 : 0][ARRAY_WIDTH : 0];
  wire signed [WEIGHT_WIDTH - 1 : 0] weight_w [ARRAY_HEIGHT: 0][ARRAY_WIDTH - 1 : 0];
  wire signed [PSUM_WIDTH - 1 : 0] psum_w [ARRAY_HEIGHT -1 : 0][ARRAY_WIDTH: 0];

  generate
    for (x = 0; x < ARRAY_HEIGHT; x = x + 1) begin: row
      for (y = 0; y < ARRAY_WIDTH; y = y + 1) begin: col
        if (y == 0) begin
          assign input_w[x][y] = input_in[x];
        end
        if (x == 0) begin
          assign weight_w[x][y] = weight_in_skewed[y];
        end
        if (y == 0) begin
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
  wire signed [PSUM_WIDTH- 1 : 0] psum_out_skewed [ARRAY_HEIGHT - 1 : 0];
  wire signed [PSUM_WIDTH- 1 : 0] psum_out_unskewed [ARRAY_HEIGHT - 1 : 0];


  skew_registers
  #(
    .DATA_WIDTH(PSUM_WIDTH),
    .N(ARRAY_HEIGHT)
  ) psum_out_unskew_registers_inst (
    .clk(clk),
    .rst_n(rst_n),
    .en(process_en),
    .din(psum_out_skewed),
    .dout(psum_out_unskewed)
  );

  // Because the 0th entry in the array must be delayed the most which is
  // opposite from the way the skew resgiters are generated, so we just
  // flip the inputs to them
  genvar y;
  generate
    for (x = 0; x < ARRAY_HEIGHT; x++) begin: reverse 
      assign psum_out_skewed[x] = psum_w[ARRAY_HEIGHT - 1 - x][ARRAY_WIDTH];
      assign psum_out[x] = psum_out_unskewed[ARRAY_HEIGHT - 1 - x];
    end
  endgenerate

endmodule
