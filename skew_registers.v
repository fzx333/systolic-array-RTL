module en_reg #(parameter DATA_WIDTH = 16) (
  input clk,
  input rst_n,
  input en,
  input [DATA_WIDTH - 1 : 0] din,
  output [DATA_WIDTH - 1 : 0] dout
);

  reg [DATA_WIDTH - 1 : 0] r;

  always @ (posedge clk) begin
    if (rst_n) begin
      if (en) begin
        r <= din;
      end
    end else begin
      r <= 0;
    end
  end

  assign dout = r;
endmodule

module skew_registers
#(
  parameter DATA_WIDTH = 16,
  parameter N = 4
)(
  input clk,
  input rst_n,
  input en,
  input wire [DATA_WIDTH * N - 1 : 0] packed_din,
  output wire [DATA_WIDTH * N - 1 : 0] packed_dout
);

  wire [DATA_WIDTH - 1 : 0] din [N - 1 : 0];
  wire [DATA_WIDTH - 1 : 0] dout [N - 1 : 0];
  wire [DATA_WIDTH - 1 : 0] d_w [N : 0][N - 1 : 0];
  // Generate unpacked array assignments from flat bus
  genvar i;
  generate
    for (i = 0; i < N; i = i + 1) begin : unpack_loop1
      assign din[i] = packed_din[i * DATA_WIDTH +: DATA_WIDTH];
    end
  endgenerate
  generate
    for (i = 0; i < N; i = i + 1) begin : unpack_loop2
      assign packed_dout[i * DATA_WIDTH +: DATA_WIDTH] = dout[i];
    end
  endgenerate

  genvar y, x;

  generate
    for (y = 0; y < N; y = y + 1) begin: row
      for (x = 0; x < y; x = x + 1) begin: col
        if (x == 0) begin : left
          assign d_w[x][y] = din[y];
        end
        if (x == y - 1) begin : right
          assign dout[y] = d_w[x + 1][y];
        end
        en_reg #(.DATA_WIDTH(DATA_WIDTH)) skew_r (
          .clk(clk),
          .rst_n(rst_n),
          .en(en),
          .din(d_w[x][y]),
          .dout(d_w[x + 1][y])
        );
      end
    end
  endgenerate
 
  assign dout[0] = din[0];
endmodule
