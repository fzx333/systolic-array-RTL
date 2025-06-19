`define INPUT_WIDTH 16
`define WEIGHT_WIDTH 16
`define PSUM_WIDTH 32
`define ARRAY_HEIGHT 4
`define ARRAY_WIDTH 4

module systolic_array_with_skew_tb;

  reg clk;
  reg rst_n;
  // reg weight_wen_r [`ARRAY_HEIGHT - 1 : 0];
  reg [`WEIGHT_WIDTH - 1 : 0] weight_r [`ARRAY_WIDTH - 1 : 0];
  reg input_en_r;
  reg process_en_r;
  reg [`INPUT_WIDTH - 1 : 0] input_r [`ARRAY_HEIGHT - 1 : 0];
  // reg [`PSUM_WIDTH - 1 : 0] ofmap_in_r [`ARRAY_WIDTH - 1 : 0];
  wire [`PSUM_WIDTH - 1 : 0] psum_out_r [`ARRAY_WIDTH - 1 : 0];

  always #10 clk =~clk;
  
  systolic_array_with_skew
  #( 
    .INPUT_WIDTH(`INPUT_WIDTH),
    .WEIGHT_WIDTH(`WEIGHT_WIDTH),
    .PSUM_WIDTH(`PSUM_WIDTH),
    .ARRAY_HEIGHT(`ARRAY_HEIGHT),
    .ARRAY_WIDTH(`ARRAY_WIDTH)
  ) systolic_array_with_skew_inst (
    .clk(clk),
    .rst_n(rst_n),
    .process_en(process_en_r),
    .input_en(input_en_r),
    // .weight_wen(weight_wen_r),
    .input_in(input_r),
    .weight_in(weight_r),
    // .ofmap_in(ofmap_in_r),
    .psum_out(psum_out_r)
  );

  integer x;
  integer y;

  initial begin
    clk <= 0;
    rst_n <= 1;
    input_en_r <= 0;
    process_en_r <= 0;
    #20 rst_n <= 0;
    #20 rst_n <= 1;
    input_en_r <= 1;
    input_r[0] <= 1;
    input_r[1] <= 2;
    input_r[2] <= 3;
    input_r[3] <= 4;
    $display("%t: output = %d %d %d %d", $time, psum_out_r[0], psum_out_r[1], psum_out_r[2], psum_out_r[3]);
    #20
    input_en_r <= 1;
    input_r[0] <= 5;
    input_r[1] <= 6;
    input_r[2] <= 7;
    input_r[3] <= 8;
    $display("%t: output = %d %d %d %d", $time, psum_out_r[0], psum_out_r[1], psum_out_r[2], psum_out_r[3]);
    #20 
    input_en_r <= 1;
    input_r[0] <= 9;
    input_r[1] <= 10;
    input_r[2] <= 11;
    input_r[3] <= 12;
    $display("%t: output = %d %d %d %d", $time, psum_out_r[0], psum_out_r[1], psum_out_r[2], psum_out_r[3]);
    #20
    input_en_r <= 1;
    input_r[0] <= 13;
    input_r[1] <= 14;
    input_r[2] <= 15;
    input_r[3] <= 16;
    $display("%t: output = %d %d %d %d", $time, psum_out_r[0], psum_out_r[1], psum_out_r[2], psum_out_r[3]);
    #20 
    input_en_r <= 0;
    process_en_r <= 1;
    weight_r[0] <= 4;
    weight_r[1] <= 3;
    weight_r[2] <= 2;
    weight_r[3] <= 1;
    $display("%t: output = %d %d %d %d", $time, psum_out_r[0], psum_out_r[1], psum_out_r[2], psum_out_r[3]);
    #20 
    input_en_r <= 0;
    process_en_r <= 1;
    weight_r[0] <= 8;
    weight_r[1] <= 7;
    weight_r[2] <= 6;
    weight_r[3] <= 5;
    $display("%t: output = %d %d %d %d", $time, psum_out_r[0], psum_out_r[1], psum_out_r[2], psum_out_r[3]);
    #20 
    input_en_r <= 0;
    process_en_r <= 1;
    weight_r[0] <= 12;
    weight_r[1] <= 11;
    weight_r[2] <= 10;
    weight_r[3] <= 9;
    $display("%t: output = %d %d %d %d", $time, psum_out_r[0], psum_out_r[1], psum_out_r[2], psum_out_r[3]);
    #20 
    input_en_r <= 0;
    process_en_r <= 1;
    weight_r[0] <= 16;
    weight_r[1] <= 15;
    weight_r[2] <= 14;
    weight_r[3] <= 13;
    $display("%t: output = %d %d %d %d", $time, psum_out_r[0], psum_out_r[1], psum_out_r[2], psum_out_r[3]);
    #20
    $display("%t: output = %d %d %d %d", $time, psum_out_r[0], psum_out_r[1], psum_out_r[2], psum_out_r[3]);
    #20
    $display("%t: output = %d %d %d %d", $time, psum_out_r[0], psum_out_r[1], psum_out_r[2], psum_out_r[3]);
    #20
    $display("%t: output = %d %d %d %d", $time, psum_out_r[0], psum_out_r[1], psum_out_r[2], psum_out_r[3]);
    #20
    $display("%t: output = %d %d %d %d", $time, psum_out_r[0], psum_out_r[1], psum_out_r[2], psum_out_r[3]);
    assert(psum_out_r[0] == 1*1 + 2*5 + 3* 9 + 4*13);
    assert(psum_out_r[1] == 1*2 + 2*6 + 3*10 + 4*14);
    assert(psum_out_r[2] == 1*3 + 2*7 + 3*11 + 4*15);
    assert(psum_out_r[3] == 1*4 + 2*8 + 3*12 + 4*16);
    #20 
    $display("%t: output = %d %d %d %d", $time, psum_out_r[0], psum_out_r[1], psum_out_r[2], psum_out_r[3]);
    assert(psum_out_r[0] == 5*1 + 6*5 + 7* 9 + 8*13);
    assert(psum_out_r[1] == 5*2 + 6*6 + 7*10 + 8*14);
    assert(psum_out_r[2] == 5*3 + 6*7 + 7*11 + 8*15);
    assert(psum_out_r[3] == 5*4 + 6*8 + 7*12 + 8*16);
    #20 
    $display("%t: output = %d %d %d %d", $time, psum_out_r[0], psum_out_r[1], psum_out_r[2], psum_out_r[3]);
    assert(psum_out_r[0] == 9*1 + 10*5 + 11* 9 + 12*13);
    assert(psum_out_r[1] == 9*2 + 10*6 + 11*10 + 12*14);
    assert(psum_out_r[2] == 9*3 + 10*7 + 11*11 + 12*15);
    assert(psum_out_r[3] == 9*4 + 10*8 + 11*12 + 12*16);
    #20 
    $display("%t: output = %d %d %d %d", $time, psum_out_r[0], psum_out_r[1], psum_out_r[2], psum_out_r[3]);
    assert(psum_out_r[0] == 13*1 + 14*5 + 15* 9 + 16*13);
    assert(psum_out_r[1] == 13*2 + 14*6 + 15*10 + 16*14);
    assert(psum_out_r[2] == 13*3 + 14*7 + 15*11 + 16*15);
    assert(psum_out_r[3] == 13*4 + 14*8 + 15*12 + 16*16);
    #20
    $display("Test finished!");
  end

  initial $monitor("%t: output = %d %d %d %d", $time, psum_out_r[0], psum_out_r[1], psum_out_r[2], psum_out_r[3]);
 
//   initial begin
//     $vcdplusfile("dump.vcd");
//     $vcdplusmemon();
//     $vcdpluson(0, systolic_array_with_skew_tb);
//     #20000000;
//     $finish(2);
//   end

endmodule
