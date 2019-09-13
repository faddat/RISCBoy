/*******************************************************************************
*                          AUTOGENERATED BY REGBLOCK                           *
*                            Do not edit manually.                             *
*          Edit the source file (or regblock utility) and regenerate.          *
*******************************************************************************/

// Block name           : riscboy_ppu
// Bus type             : apb
// Bus data width       : 32
// Bus address width    : 16

module riscboy_ppu_regs (
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
	
	// Register interfaces
	output reg [15:0] lcd_pxfifo_o,
	output reg lcd_pxfifo_wen,
	input wire  lcd_csr_pxfifo_empty_i,
	input wire  lcd_csr_pxfifo_full_i,
	input wire [5:0] lcd_csr_pxfifo_level_i,
	output reg  lcd_csr_lcd_cs_o,
	output reg  lcd_csr_lcd_dc_o,
	input wire  lcd_csr_tx_busy_i,
	output reg [4:0] lcd_csr_lcd_shiftcnt_o
);

// APB adapter
wire [31:0] wdata = apbs_pwdata;
reg [31:0] rdata;
wire wen = apbs_psel && apbs_penable && apbs_pwrite;
wire ren = apbs_psel && apbs_penable && !apbs_pwrite;
wire [15:0] addr = apbs_paddr & 16'h7;
assign apbs_prdata = rdata;
assign apbs_pready = 1'b1;
assign apbs_pslverr = 1'b0;

localparam ADDR_LCD_PXFIFO = 0;
localparam ADDR_LCD_CSR = 4;

wire __lcd_pxfifo_wen = wen && addr == ADDR_LCD_PXFIFO;
wire __lcd_pxfifo_ren = ren && addr == ADDR_LCD_PXFIFO;
wire __lcd_csr_wen = wen && addr == ADDR_LCD_CSR;
wire __lcd_csr_ren = ren && addr == ADDR_LCD_CSR;

wire [15:0] lcd_pxfifo_wdata = wdata[15:0];
wire [15:0] lcd_pxfifo_rdata;
wire [31:0] __lcd_pxfifo_rdata = {16'h0, lcd_pxfifo_rdata};
assign lcd_pxfifo_rdata = 16'h0;

wire  lcd_csr_pxfifo_empty_wdata = wdata[0];
wire  lcd_csr_pxfifo_empty_rdata;
wire  lcd_csr_pxfifo_full_wdata = wdata[1];
wire  lcd_csr_pxfifo_full_rdata;
wire [5:0] lcd_csr_pxfifo_level_wdata = wdata[7:2];
wire [5:0] lcd_csr_pxfifo_level_rdata;
wire  lcd_csr_lcd_cs_wdata = wdata[8];
wire  lcd_csr_lcd_cs_rdata;
wire  lcd_csr_lcd_dc_wdata = wdata[9];
wire  lcd_csr_lcd_dc_rdata;
wire  lcd_csr_tx_busy_wdata = wdata[10];
wire  lcd_csr_tx_busy_rdata;
wire [4:0] lcd_csr_lcd_shiftcnt_wdata = wdata[20:16];
wire [4:0] lcd_csr_lcd_shiftcnt_rdata;
wire [31:0] __lcd_csr_rdata = {11'h0, lcd_csr_lcd_shiftcnt_rdata, 5'h0, lcd_csr_tx_busy_rdata, lcd_csr_lcd_dc_rdata, lcd_csr_lcd_cs_rdata, lcd_csr_pxfifo_level_rdata, lcd_csr_pxfifo_full_rdata, lcd_csr_pxfifo_empty_rdata};
assign lcd_csr_pxfifo_empty_rdata = lcd_csr_pxfifo_empty_i;
assign lcd_csr_pxfifo_full_rdata = lcd_csr_pxfifo_full_i;
assign lcd_csr_pxfifo_level_rdata = lcd_csr_pxfifo_level_i;
assign lcd_csr_lcd_cs_rdata = lcd_csr_lcd_cs_o;
assign lcd_csr_lcd_dc_rdata = lcd_csr_lcd_dc_o;
assign lcd_csr_tx_busy_rdata = lcd_csr_tx_busy_i;
assign lcd_csr_lcd_shiftcnt_rdata = lcd_csr_lcd_shiftcnt_o;

always @ (*) begin
	case (addr)
		ADDR_LCD_PXFIFO: rdata = __lcd_pxfifo_rdata;
		ADDR_LCD_CSR: rdata = __lcd_csr_rdata;
		default: rdata = 32'h0;
	endcase
	lcd_pxfifo_wen = __lcd_pxfifo_wen;
	lcd_pxfifo_o = lcd_pxfifo_wdata;
end

always @ (posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		lcd_csr_lcd_cs_o <= 1'h1;
		lcd_csr_lcd_dc_o <= 1'h0;
		lcd_csr_lcd_shiftcnt_o <= 5'h0;
	end else begin
		if (__lcd_csr_wen)
			lcd_csr_lcd_cs_o <= lcd_csr_lcd_cs_wdata;
		if (__lcd_csr_wen)
			lcd_csr_lcd_dc_o <= lcd_csr_lcd_dc_wdata;
		if (__lcd_csr_wen)
			lcd_csr_lcd_shiftcnt_o <= lcd_csr_lcd_shiftcnt_wdata;
	end
end

endmodule
