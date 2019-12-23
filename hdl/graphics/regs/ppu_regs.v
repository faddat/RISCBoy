/*******************************************************************************
*                          AUTOGENERATED BY REGBLOCK                           *
*                            Do not edit manually.                             *
*          Edit the source file (or regblock utility) and regenerate.          *
*******************************************************************************/

// Block name           : ppu
// Bus type             : apb
// Bus data width       : 32
// Bus address width    : 16

module ppu_regs (
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
	output reg  csr_run_o,
	output reg  csr_halt_o,
	input wire  csr_running_i,
	output reg  csr_halt_hsync_o,
	output reg  csr_halt_vsync_o,
	output reg [11:0] dispsize_w_o,
	output reg [11:0] dispsize_h_o,
	output reg [14:0] default_bg_colour_o,
	input wire [11:0] beam_x_i,
	input wire [11:0] beam_y_i,
	output reg  bg0_csr_en_o,
	output reg [2:0] bg0_csr_pixmode_o,
	output reg  bg0_csr_transparency_o,
	output reg  bg0_csr_tilesize_o,
	output reg [3:0] bg0_csr_pfwidth_o,
	output reg [3:0] bg0_csr_pfheight_o,
	output reg [3:0] bg0_csr_paloffs_o,
	output reg  bg0_csr_flush_o,
	output reg [9:0] bg0_scroll_y_o,
	output reg [9:0] bg0_scroll_x_o,
	output reg [23:0] bg0_tsbase_o,
	output reg [23:0] bg0_tmbase_o,
	output reg  bg1_csr_en_o,
	output reg [2:0] bg1_csr_pixmode_o,
	output reg  bg1_csr_transparency_o,
	output reg  bg1_csr_tilesize_o,
	output reg [3:0] bg1_csr_pfwidth_o,
	output reg [3:0] bg1_csr_pfheight_o,
	output reg [3:0] bg1_csr_paloffs_o,
	output reg  bg1_csr_flush_o,
	output reg [9:0] bg1_scroll_y_o,
	output reg [9:0] bg1_scroll_x_o,
	output reg [23:0] bg1_tsbase_o,
	output reg [23:0] bg1_tmbase_o,
	output reg [15:0] lcd_pxfifo_o,
	output reg lcd_pxfifo_wen,
	input wire  lcd_csr_pxfifo_empty_i,
	input wire  lcd_csr_pxfifo_full_i,
	input wire [5:0] lcd_csr_pxfifo_level_i,
	output reg  lcd_csr_lcd_cs_o,
	output reg  lcd_csr_lcd_dc_o,
	input wire  lcd_csr_tx_busy_i,
	output reg [4:0] lcd_csr_lcd_shiftcnt_o,
	input wire  ints_vsync_i,
	output reg  ints_vsync_o,
	output reg ints_vsync_wen,
	output reg ints_vsync_ren,
	input wire  ints_hsync_i,
	output reg  ints_hsync_o,
	output reg ints_hsync_wen,
	output reg ints_hsync_ren,
	output reg  inte_vsync_o,
	output reg  inte_hsync_o
);

// APB adapter
wire [31:0] wdata = apbs_pwdata;
reg [31:0] rdata;
wire wen = apbs_psel && apbs_penable && apbs_pwrite;
wire ren = apbs_psel && apbs_penable && !apbs_pwrite;
wire [15:0] addr = apbs_paddr & 16'h3f;
assign apbs_prdata = rdata;
assign apbs_pready = 1'b1;
assign apbs_pslverr = 1'b0;

localparam ADDR_CSR = 0;
localparam ADDR_DISPSIZE = 4;
localparam ADDR_DEFAULT_BG_COLOUR = 8;
localparam ADDR_BEAM = 12;
localparam ADDR_BG0_CSR = 16;
localparam ADDR_BG0_SCROLL = 20;
localparam ADDR_BG0_TSBASE = 24;
localparam ADDR_BG0_TMBASE = 28;
localparam ADDR_BG1_CSR = 32;
localparam ADDR_BG1_SCROLL = 36;
localparam ADDR_BG1_TSBASE = 40;
localparam ADDR_BG1_TMBASE = 44;
localparam ADDR_LCD_PXFIFO = 48;
localparam ADDR_LCD_CSR = 52;
localparam ADDR_INTS = 56;
localparam ADDR_INTE = 60;

wire __csr_wen = wen && addr == ADDR_CSR;
wire __csr_ren = ren && addr == ADDR_CSR;
wire __dispsize_wen = wen && addr == ADDR_DISPSIZE;
wire __dispsize_ren = ren && addr == ADDR_DISPSIZE;
wire __default_bg_colour_wen = wen && addr == ADDR_DEFAULT_BG_COLOUR;
wire __default_bg_colour_ren = ren && addr == ADDR_DEFAULT_BG_COLOUR;
wire __beam_wen = wen && addr == ADDR_BEAM;
wire __beam_ren = ren && addr == ADDR_BEAM;
wire __bg0_csr_wen = wen && addr == ADDR_BG0_CSR;
wire __bg0_csr_ren = ren && addr == ADDR_BG0_CSR;
wire __bg0_scroll_wen = wen && addr == ADDR_BG0_SCROLL;
wire __bg0_scroll_ren = ren && addr == ADDR_BG0_SCROLL;
wire __bg0_tsbase_wen = wen && addr == ADDR_BG0_TSBASE;
wire __bg0_tsbase_ren = ren && addr == ADDR_BG0_TSBASE;
wire __bg0_tmbase_wen = wen && addr == ADDR_BG0_TMBASE;
wire __bg0_tmbase_ren = ren && addr == ADDR_BG0_TMBASE;
wire __bg1_csr_wen = wen && addr == ADDR_BG1_CSR;
wire __bg1_csr_ren = ren && addr == ADDR_BG1_CSR;
wire __bg1_scroll_wen = wen && addr == ADDR_BG1_SCROLL;
wire __bg1_scroll_ren = ren && addr == ADDR_BG1_SCROLL;
wire __bg1_tsbase_wen = wen && addr == ADDR_BG1_TSBASE;
wire __bg1_tsbase_ren = ren && addr == ADDR_BG1_TSBASE;
wire __bg1_tmbase_wen = wen && addr == ADDR_BG1_TMBASE;
wire __bg1_tmbase_ren = ren && addr == ADDR_BG1_TMBASE;
wire __lcd_pxfifo_wen = wen && addr == ADDR_LCD_PXFIFO;
wire __lcd_pxfifo_ren = ren && addr == ADDR_LCD_PXFIFO;
wire __lcd_csr_wen = wen && addr == ADDR_LCD_CSR;
wire __lcd_csr_ren = ren && addr == ADDR_LCD_CSR;
wire __ints_wen = wen && addr == ADDR_INTS;
wire __ints_ren = ren && addr == ADDR_INTS;
wire __inte_wen = wen && addr == ADDR_INTE;
wire __inte_ren = ren && addr == ADDR_INTE;

wire  csr_run_wdata = wdata[0];
wire  csr_run_rdata;
wire  csr_halt_wdata = wdata[1];
wire  csr_halt_rdata;
wire  csr_running_wdata = wdata[2];
wire  csr_running_rdata;
wire  csr_halt_hsync_wdata = wdata[3];
wire  csr_halt_hsync_rdata;
wire  csr_halt_vsync_wdata = wdata[4];
wire  csr_halt_vsync_rdata;
wire [31:0] __csr_rdata = {27'h0, csr_halt_vsync_rdata, csr_halt_hsync_rdata, csr_running_rdata, csr_halt_rdata, csr_run_rdata};
assign csr_run_rdata = 1'h0;
assign csr_halt_rdata = 1'h0;
assign csr_running_rdata = csr_running_i;
assign csr_halt_hsync_rdata = csr_halt_hsync_o;
assign csr_halt_vsync_rdata = csr_halt_vsync_o;

wire [11:0] dispsize_w_wdata = wdata[11:0];
wire [11:0] dispsize_w_rdata;
wire [11:0] dispsize_h_wdata = wdata[27:16];
wire [11:0] dispsize_h_rdata;
wire [31:0] __dispsize_rdata = {4'h0, dispsize_h_rdata, 4'h0, dispsize_w_rdata};
assign dispsize_w_rdata = dispsize_w_o;
assign dispsize_h_rdata = dispsize_h_o;

wire [14:0] default_bg_colour_wdata = wdata[14:0];
wire [14:0] default_bg_colour_rdata;
wire [31:0] __default_bg_colour_rdata = {17'h0, default_bg_colour_rdata};
assign default_bg_colour_rdata = default_bg_colour_o;

wire [11:0] beam_x_wdata = wdata[11:0];
wire [11:0] beam_x_rdata;
wire [11:0] beam_y_wdata = wdata[27:16];
wire [11:0] beam_y_rdata;
wire [31:0] __beam_rdata = {4'h0, beam_y_rdata, 4'h0, beam_x_rdata};
assign beam_x_rdata = beam_x_i;
assign beam_y_rdata = beam_y_i;

wire  bg0_csr_en_wdata = wdata[0];
wire  bg0_csr_en_rdata;
wire [2:0] bg0_csr_pixmode_wdata = wdata[3:1];
wire [2:0] bg0_csr_pixmode_rdata;
wire  bg0_csr_transparency_wdata = wdata[4];
wire  bg0_csr_transparency_rdata;
wire  bg0_csr_tilesize_wdata = wdata[5];
wire  bg0_csr_tilesize_rdata;
wire [3:0] bg0_csr_pfwidth_wdata = wdata[9:6];
wire [3:0] bg0_csr_pfwidth_rdata;
wire [3:0] bg0_csr_pfheight_wdata = wdata[13:10];
wire [3:0] bg0_csr_pfheight_rdata;
wire [3:0] bg0_csr_paloffs_wdata = wdata[19:16];
wire [3:0] bg0_csr_paloffs_rdata;
wire  bg0_csr_flush_wdata = wdata[31];
wire  bg0_csr_flush_rdata;
wire [31:0] __bg0_csr_rdata = {bg0_csr_flush_rdata, 11'h0, bg0_csr_paloffs_rdata, 2'h0, bg0_csr_pfheight_rdata, bg0_csr_pfwidth_rdata, bg0_csr_tilesize_rdata, bg0_csr_transparency_rdata, bg0_csr_pixmode_rdata, bg0_csr_en_rdata};
assign bg0_csr_en_rdata = bg0_csr_en_o;
assign bg0_csr_pixmode_rdata = bg0_csr_pixmode_o;
assign bg0_csr_transparency_rdata = bg0_csr_transparency_o;
assign bg0_csr_tilesize_rdata = bg0_csr_tilesize_o;
assign bg0_csr_pfwidth_rdata = bg0_csr_pfwidth_o;
assign bg0_csr_pfheight_rdata = bg0_csr_pfheight_o;
assign bg0_csr_paloffs_rdata = bg0_csr_paloffs_o;
assign bg0_csr_flush_rdata = 1'h0;

wire [9:0] bg0_scroll_y_wdata = wdata[25:16];
wire [9:0] bg0_scroll_y_rdata;
wire [9:0] bg0_scroll_x_wdata = wdata[9:0];
wire [9:0] bg0_scroll_x_rdata;
wire [31:0] __bg0_scroll_rdata = {6'h0, bg0_scroll_y_rdata, 6'h0, bg0_scroll_x_rdata};
assign bg0_scroll_y_rdata = bg0_scroll_y_o;
assign bg0_scroll_x_rdata = bg0_scroll_x_o;

wire [23:0] bg0_tsbase_wdata = wdata[31:8];
wire [23:0] bg0_tsbase_rdata;
wire [31:0] __bg0_tsbase_rdata = {bg0_tsbase_rdata, 8'h0};
assign bg0_tsbase_rdata = bg0_tsbase_o;

wire [23:0] bg0_tmbase_wdata = wdata[31:8];
wire [23:0] bg0_tmbase_rdata;
wire [31:0] __bg0_tmbase_rdata = {bg0_tmbase_rdata, 8'h0};
assign bg0_tmbase_rdata = bg0_tmbase_o;

wire  bg1_csr_en_wdata = wdata[0];
wire  bg1_csr_en_rdata;
wire [2:0] bg1_csr_pixmode_wdata = wdata[3:1];
wire [2:0] bg1_csr_pixmode_rdata;
wire  bg1_csr_transparency_wdata = wdata[4];
wire  bg1_csr_transparency_rdata;
wire  bg1_csr_tilesize_wdata = wdata[5];
wire  bg1_csr_tilesize_rdata;
wire [3:0] bg1_csr_pfwidth_wdata = wdata[9:6];
wire [3:0] bg1_csr_pfwidth_rdata;
wire [3:0] bg1_csr_pfheight_wdata = wdata[13:10];
wire [3:0] bg1_csr_pfheight_rdata;
wire [3:0] bg1_csr_paloffs_wdata = wdata[19:16];
wire [3:0] bg1_csr_paloffs_rdata;
wire  bg1_csr_flush_wdata = wdata[31];
wire  bg1_csr_flush_rdata;
wire [31:0] __bg1_csr_rdata = {bg1_csr_flush_rdata, 11'h0, bg1_csr_paloffs_rdata, 2'h0, bg1_csr_pfheight_rdata, bg1_csr_pfwidth_rdata, bg1_csr_tilesize_rdata, bg1_csr_transparency_rdata, bg1_csr_pixmode_rdata, bg1_csr_en_rdata};
assign bg1_csr_en_rdata = bg1_csr_en_o;
assign bg1_csr_pixmode_rdata = bg1_csr_pixmode_o;
assign bg1_csr_transparency_rdata = bg1_csr_transparency_o;
assign bg1_csr_tilesize_rdata = bg1_csr_tilesize_o;
assign bg1_csr_pfwidth_rdata = bg1_csr_pfwidth_o;
assign bg1_csr_pfheight_rdata = bg1_csr_pfheight_o;
assign bg1_csr_paloffs_rdata = bg1_csr_paloffs_o;
assign bg1_csr_flush_rdata = 1'h0;

wire [9:0] bg1_scroll_y_wdata = wdata[25:16];
wire [9:0] bg1_scroll_y_rdata;
wire [9:0] bg1_scroll_x_wdata = wdata[9:0];
wire [9:0] bg1_scroll_x_rdata;
wire [31:0] __bg1_scroll_rdata = {6'h0, bg1_scroll_y_rdata, 6'h0, bg1_scroll_x_rdata};
assign bg1_scroll_y_rdata = bg1_scroll_y_o;
assign bg1_scroll_x_rdata = bg1_scroll_x_o;

wire [23:0] bg1_tsbase_wdata = wdata[31:8];
wire [23:0] bg1_tsbase_rdata;
wire [31:0] __bg1_tsbase_rdata = {bg1_tsbase_rdata, 8'h0};
assign bg1_tsbase_rdata = bg1_tsbase_o;

wire [23:0] bg1_tmbase_wdata = wdata[31:8];
wire [23:0] bg1_tmbase_rdata;
wire [31:0] __bg1_tmbase_rdata = {bg1_tmbase_rdata, 8'h0};
assign bg1_tmbase_rdata = bg1_tmbase_o;

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

wire  ints_vsync_wdata = wdata[0];
wire  ints_vsync_rdata;
wire  ints_hsync_wdata = wdata[1];
wire  ints_hsync_rdata;
wire [31:0] __ints_rdata = {30'h0, ints_hsync_rdata, ints_vsync_rdata};
assign ints_vsync_rdata = ints_vsync_i;
assign ints_hsync_rdata = ints_hsync_i;

wire  inte_vsync_wdata = wdata[0];
wire  inte_vsync_rdata;
wire  inte_hsync_wdata = wdata[1];
wire  inte_hsync_rdata;
wire [31:0] __inte_rdata = {30'h0, inte_hsync_rdata, inte_vsync_rdata};
assign inte_vsync_rdata = inte_vsync_o;
assign inte_hsync_rdata = inte_hsync_o;

always @ (*) begin
	case (addr)
		ADDR_CSR: rdata = __csr_rdata;
		ADDR_DISPSIZE: rdata = __dispsize_rdata;
		ADDR_DEFAULT_BG_COLOUR: rdata = __default_bg_colour_rdata;
		ADDR_BEAM: rdata = __beam_rdata;
		ADDR_BG0_CSR: rdata = __bg0_csr_rdata;
		ADDR_BG0_SCROLL: rdata = __bg0_scroll_rdata;
		ADDR_BG0_TSBASE: rdata = __bg0_tsbase_rdata;
		ADDR_BG0_TMBASE: rdata = __bg0_tmbase_rdata;
		ADDR_BG1_CSR: rdata = __bg1_csr_rdata;
		ADDR_BG1_SCROLL: rdata = __bg1_scroll_rdata;
		ADDR_BG1_TSBASE: rdata = __bg1_tsbase_rdata;
		ADDR_BG1_TMBASE: rdata = __bg1_tmbase_rdata;
		ADDR_LCD_PXFIFO: rdata = __lcd_pxfifo_rdata;
		ADDR_LCD_CSR: rdata = __lcd_csr_rdata;
		ADDR_INTS: rdata = __ints_rdata;
		ADDR_INTE: rdata = __inte_rdata;
		default: rdata = 32'h0;
	endcase
	csr_run_o = csr_run_wdata & {1{__csr_wen}};
	csr_halt_o = csr_halt_wdata & {1{__csr_wen}};
	bg0_csr_flush_o = bg0_csr_flush_wdata & {1{__bg0_csr_wen}};
	bg1_csr_flush_o = bg1_csr_flush_wdata & {1{__bg1_csr_wen}};
	lcd_pxfifo_wen = __lcd_pxfifo_wen;
	lcd_pxfifo_o = lcd_pxfifo_wdata;
	ints_vsync_wen = __ints_wen;
	ints_vsync_o = ints_vsync_wdata;
	ints_vsync_ren = __ints_ren;
	ints_hsync_wen = __ints_wen;
	ints_hsync_o = ints_hsync_wdata;
	ints_hsync_ren = __ints_ren;
end

always @ (posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		csr_halt_hsync_o <= 1'h0;
		csr_halt_vsync_o <= 1'h0;
		dispsize_w_o <= 12'h0;
		dispsize_h_o <= 12'h0;
		default_bg_colour_o <= 15'h0;
		bg0_csr_en_o <= 1'h0;
		bg0_csr_pixmode_o <= 3'h0;
		bg0_csr_transparency_o <= 1'h0;
		bg0_csr_tilesize_o <= 1'h0;
		bg0_csr_pfwidth_o <= 4'h0;
		bg0_csr_pfheight_o <= 4'h0;
		bg0_csr_paloffs_o <= 4'h0;
		bg0_scroll_y_o <= 10'h0;
		bg0_scroll_x_o <= 10'h0;
		bg0_tsbase_o <= 24'h0;
		bg0_tmbase_o <= 24'h0;
		bg1_csr_en_o <= 1'h0;
		bg1_csr_pixmode_o <= 3'h0;
		bg1_csr_transparency_o <= 1'h0;
		bg1_csr_tilesize_o <= 1'h0;
		bg1_csr_pfwidth_o <= 4'h0;
		bg1_csr_pfheight_o <= 4'h0;
		bg1_csr_paloffs_o <= 4'h0;
		bg1_scroll_y_o <= 10'h0;
		bg1_scroll_x_o <= 10'h0;
		bg1_tsbase_o <= 24'h0;
		bg1_tmbase_o <= 24'h0;
		lcd_csr_lcd_cs_o <= 1'h1;
		lcd_csr_lcd_dc_o <= 1'h0;
		lcd_csr_lcd_shiftcnt_o <= 5'h0;
		inte_vsync_o <= 1'h0;
		inte_hsync_o <= 1'h0;
	end else begin
		if (__csr_wen)
			csr_halt_hsync_o <= csr_halt_hsync_wdata;
		if (__csr_wen)
			csr_halt_vsync_o <= csr_halt_vsync_wdata;
		if (__dispsize_wen)
			dispsize_w_o <= dispsize_w_wdata;
		if (__dispsize_wen)
			dispsize_h_o <= dispsize_h_wdata;
		if (__default_bg_colour_wen)
			default_bg_colour_o <= default_bg_colour_wdata;
		if (__bg0_csr_wen)
			bg0_csr_en_o <= bg0_csr_en_wdata;
		if (__bg0_csr_wen)
			bg0_csr_pixmode_o <= bg0_csr_pixmode_wdata;
		if (__bg0_csr_wen)
			bg0_csr_transparency_o <= bg0_csr_transparency_wdata;
		if (__bg0_csr_wen)
			bg0_csr_tilesize_o <= bg0_csr_tilesize_wdata;
		if (__bg0_csr_wen)
			bg0_csr_pfwidth_o <= bg0_csr_pfwidth_wdata;
		if (__bg0_csr_wen)
			bg0_csr_pfheight_o <= bg0_csr_pfheight_wdata;
		if (__bg0_csr_wen)
			bg0_csr_paloffs_o <= bg0_csr_paloffs_wdata;
		if (__bg0_scroll_wen)
			bg0_scroll_y_o <= bg0_scroll_y_wdata;
		if (__bg0_scroll_wen)
			bg0_scroll_x_o <= bg0_scroll_x_wdata;
		if (__bg0_tsbase_wen)
			bg0_tsbase_o <= bg0_tsbase_wdata;
		if (__bg0_tmbase_wen)
			bg0_tmbase_o <= bg0_tmbase_wdata;
		if (__bg1_csr_wen)
			bg1_csr_en_o <= bg1_csr_en_wdata;
		if (__bg1_csr_wen)
			bg1_csr_pixmode_o <= bg1_csr_pixmode_wdata;
		if (__bg1_csr_wen)
			bg1_csr_transparency_o <= bg1_csr_transparency_wdata;
		if (__bg1_csr_wen)
			bg1_csr_tilesize_o <= bg1_csr_tilesize_wdata;
		if (__bg1_csr_wen)
			bg1_csr_pfwidth_o <= bg1_csr_pfwidth_wdata;
		if (__bg1_csr_wen)
			bg1_csr_pfheight_o <= bg1_csr_pfheight_wdata;
		if (__bg1_csr_wen)
			bg1_csr_paloffs_o <= bg1_csr_paloffs_wdata;
		if (__bg1_scroll_wen)
			bg1_scroll_y_o <= bg1_scroll_y_wdata;
		if (__bg1_scroll_wen)
			bg1_scroll_x_o <= bg1_scroll_x_wdata;
		if (__bg1_tsbase_wen)
			bg1_tsbase_o <= bg1_tsbase_wdata;
		if (__bg1_tmbase_wen)
			bg1_tmbase_o <= bg1_tmbase_wdata;
		if (__lcd_csr_wen)
			lcd_csr_lcd_cs_o <= lcd_csr_lcd_cs_wdata;
		if (__lcd_csr_wen)
			lcd_csr_lcd_dc_o <= lcd_csr_lcd_dc_wdata;
		if (__lcd_csr_wen)
			lcd_csr_lcd_shiftcnt_o <= lcd_csr_lcd_shiftcnt_wdata;
		if (__inte_wen)
			inte_vsync_o <= inte_vsync_wdata;
		if (__inte_wen)
			inte_hsync_o <= inte_hsync_wdata;
	end
end

endmodule
