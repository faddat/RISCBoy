// Basically ok for PWMing an LED, and not much else
// 8 bit integer divider
// 8 bit value, double buffered on counter rollover
// what more do you need?

module pwm_tiny (
	input wire clk,
	input wire rst_n,
	
	// APB Port
	input wire apbs_psel,
	input wire apbs_penable,
	input wire apbs_pwrite,
	input wire [15:0] apbs_paddr,
	input wire [31:0] apbs_pwdata,
	output wire [31:0] apbs_prdata,
	output wire apbs_pready,
	output wire apbs_pslverr,

	output wire padout
);

localparam W_DIV = 8;
localparam W_CTR = 8;

wire rst_n_sync;

reset_sync #(
	.N_CYCLES (2)
) inst_reset_sync (
	.clk       (clk),
	.rst_n_in  (rst_n),
	.rst_n_out (rst_n_sync)
);

wire [W_DIV-1:0] div;
wire [W_CTR-1:0] pwm_val;
wire en;
wire inv;

reg  [W_DIV-1:0] ctr_div;
reg  [W_CTR-1:0] ctr_pwm;
reg  [W_CTR-1:0] pwm_val_dbuf;
reg              pwm_out;

assign padout = pwm_out ^ inv;

always @ (posedge clk or negedge rst_n_sync) begin
	if (!rst_n_sync) begin
		ctr_div <= 1'b1 | {W_DIV{1'b0}};
		ctr_pwm <= {W_CTR{1'b0}};
		pwm_val_dbuf <= {W_CTR{1'b0}};
		pwm_out <= 1'b0;
	end else if (!en) begin
		ctr_div <= 1'b1 | {W_DIV{1'b0}};
		ctr_pwm <= pwm_val;
		pwm_val_dbuf <= pwm_val;
		pwm_out <= 1'b0;
	end else begin
		ctr_div <= ctr_div - 1'b1;
		if (ctr_div == 1) begin
			ctr_div <= div;
			ctr_pwm <= ctr_pwm - 1'b1;
			if (ctr_pwm == 0) begin
				pwm_out <= 1'b0;
				pwm_val_dbuf <= pwm_val;
			end else if (ctr_pwm == pwm_val_dbuf) begin
				pwm_out <= 1'b1;
			end
		end
	end
end

pwm_tiny_regs inst_pwm_regs (
	.clk          (clk),
	.rst_n        (rst_n_sync),
	.apbs_psel    (apbs_psel),
	.apbs_penable (apbs_penable),
	.apbs_pwrite  (apbs_pwrite),
	.apbs_paddr   (apbs_paddr),
	.apbs_pwdata  (apbs_pwdata),
	.apbs_prdata  (apbs_prdata),
	.apbs_pready  (apbs_pready),
	.apbs_pslverr (apbs_pslverr),
	.ctrl_val_o   (pwm_val),
	.ctrl_div_o   (div),
	.ctrl_en_o    (en),
	.ctrl_inv_o   (inv)
);

endmodule
