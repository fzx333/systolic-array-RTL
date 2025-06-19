// Implement the functionality of one Processing Element (PE), which  is a
// scalar floating multiply-accumulate (MAC) unit, assuming input stationary.
// This unit performs one multiply and one accumulate per cycle. The current
// input (input_in) is multiplied with the stored weight (weight_reg) and
// added to the current output (psum_in), and the result is stored in the
// output register (psum_reg). The weight and output registers are only updated
// if process_en is high. Registered input and output are sent out.

// If input_en is high, then store the incoming input (input_in) into the
// input register (input_reg).

// Synchronously reset all registers when rst_n is low.



module mac
#(
  parameter INPUT_WIDTH = 16,
  parameter WEIGHT_WIDTH = 16,
  parameter PSUM_WIDTH = 32
)(
  input clk,
  input rst_n,
  input process_en,
  input input_en,
  input [INPUT_WIDTH - 1 : 0] input_in,
  input [WEIGHT_WIDTH - 1 : 0] weight_in,
  input [PSUM_WIDTH - 1 : 0] psum_in,
  output [INPUT_WIDTH - 1 : 0] input_out,
  output [WEIGHT_WIDTH - 1 : 0] weight_out,
  output [PSUM_WIDTH - 1 : 0] psum_out
);

  reg [WEIGHT_WIDTH - 1 : 0] weight_reg;
  reg [INPUT_WIDTH - 1 : 0] input_reg;
  reg [PSUM_WIDTH - 1 : 0] psum_reg;

  wire [PSUM_WIDTH - 1 : 0] psum_w;
  wire [PSUM_WIDTH - 1 : 0] mult_w;

  always @ (posedge clk) begin
    if (rst_n) begin
      if (input_en) begin
        input_reg <= input_in;      
      end
    end else begin
        input_reg <= 0;
    end
  end

  assign mult_w = input_reg * weight_in;
  assign psum_w = psum_in + mult_w;
  assign psum_out = psum_reg;
  assign input_out = input_reg;
  assign weight_out = weight_reg;

  always @ (posedge clk) begin
    if (rst_n) begin
      if (process_en) begin
        weight_reg <= weight_in;
        psum_reg <= psum_w;
      end
    end else begin
      weight_reg <= 0;
      psum_reg <= 0;
    end
  end
  /*
  always @ (posedge clk) begin
    if (process_en) begin
      $display("%m, ifmap = %h, weight = %h, psum_in = %h, psum_out = %h", 
                    input_in,   weight_reg,    psum_in,      psum_w);
    end
  end
  */
  // Your code ends here
endmodule
