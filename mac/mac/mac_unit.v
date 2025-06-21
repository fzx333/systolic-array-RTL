// No pipelined/piplined MAC
// Version: 1.0

// Description:

	// Function : mac_out = in_a * in_b + in_c.  Work for FP16. Default FP16 are signed number


module mac_unit
(
`ifdef PIPLINE
	input            clk,
	input            rst_n,
`endif
	input     [15:0] in_a, // multiplier input1
	input     [15:0] in_b, // multiplier input2
	input     [15:0] in_c, // adder input2 ; adder input1 = in_a * in_b
	output    [15:0] mac_out
);

	wire [15:0] mul_out;

	fp_add add(
	`ifdef PIPLINE
		.clk   (clk    ),
		.rst_n (rst_n  ),
	`endif 
		.a     (mul_out),
		.b     ( in_c  ),
		.c     (mac_out)
	);


	fp_mul mul(
	`ifdef PIPLINE
		.clk   (clk    ),
		.rst_n (rst_n  ),
	`endif 
		.a     ( in_a  ),
		.b     ( in_b  ),
		.c     (mul_out)
	);

endmodule	
