// `define PIPLINE

module fp_mul (
`ifdef PIPLINE
    input         clk,
    input         rst_n,
`endif
    input  [15:0] a,
    input  [15:0] b,
    output [15:0] c
    );

    wire [15:0] c_tmp;
    wire        c_sign,a_zero,b_zero;
    wire [4:0] sum_exponent, biased_sum_exponent;
    wire [15:0] multiplier_input1,multiplier_input2;

    wire [31:0] multiplier_output;
    wire [14:0] normalized_out;
    wire [21:0] mantissa_prod;
    wire c1,c2,underflow,overflow;

    assign overflow = (c1 && c2 && ~biased_sum_exponent[4]) ? 1'b1 :1'b0;
    assign underflow = (~c1 && ~c2 && biased_sum_exponent[4]) ? 1'b1:1'b0;

    assign a_zero = ~(|a);
    assign b_zero = ~(|b);
    assign c_sign = a[15] ^ b[15];
    assign multiplier_input1 = {5'b0,1'b1,a[9:0]};
    assign multiplier_input2 = {5'b0,1'b1,b[9:0]};
    
    assign c = ((a_zero | b_zero) ? 16'b0 : c_tmp);
    assign c_tmp = {c_sign,normalized_out};


`ifdef PIPLINE

    reg [31:0] multiplier_output_tmp;
    
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            multiplier_output_tmp <= 32'b0;
        end else begin
            multiplier_output_tmp <= multiplier_output;
        end
    end
    
    assign mantissa_prod = multiplier_output_tmp[21:0];
    mul16x16 u1(clk,rst_n,multiplier_input1,multiplier_input2,multiplier_output);

`else 

    assign mantissa_prod = multiplier_output[21:0];
    mul16x16 u1(multiplier_input1,multiplier_input2,multiplier_output);

`endif
    
    cla_nbit #(.n(5)) u2(a[14:10],b[14:10],1'b0,sum_exponent,c1); // add exponent
    cla_nbit #(.n(5)) u3(sum_exponent, 5'b10001,1'b0,biased_sum_exponent,c2); // minus bias
    mul_normalizer u4(biased_sum_exponent,mantissa_prod,normalized_out);

endmodule
