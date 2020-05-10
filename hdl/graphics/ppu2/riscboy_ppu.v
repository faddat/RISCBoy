/**********************************************************************
 * DO WHAT THE FUCK YOU WANT TO AND DON'T BLAME US PUBLIC LICENSE     *
 *                    Version 3, April 2008                           *
 *                                                                    *
 * Copyright (C) 2020 Luke Wren                                       *
 *                                                                    *
 * Everyone is permitted to copy and distribute verbatim or modified  *
 * copies of this license document and accompanying software, and     *
 * changing either is allowed.                                        *
 *                                                                    *
 *   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION  *
 *                                                                    *
 * 0. You just DO WHAT THE FUCK YOU WANT TO.                          *
 * 1. We're NOT RESPONSIBLE WHEN IT DOESN'T FUCKING WORK.             *
 *                                                                    *
 *********************************************************************/

// Pixel processing unit, version 2
`default_nettype none

module riscboy_ppu #(
	parameter W_HADDR = 32,
	parameter W_HDATA = 32,
	parameter W_DATA = 16,
	parameter ADDR_MASK = 32'h2007ffff,
	parameter W_COORD_SX = 9, // Do not modify
	parameter W_COORD_SY = 8, // Do not modify
	parameter W_PIXDATA = 16  // Do not modify
) (
	input  wire                  clk,
	input  wire                  rst_n,

	output wire                  irq,

	// AHB-lite master port
	output wire [W_HADDR-1:0]    ahblm_haddr,
	output wire                  ahblm_hwrite,
	output wire [1:0]            ahblm_htrans,
	output wire [2:0]            ahblm_hsize,
	output wire [2:0]            ahblm_hburst,
	output wire [3:0]            ahblm_hprot,
	output wire                  ahblm_hmastlock,
	input  wire                  ahblm_hready,
	input  wire                  ahblm_hresp,
	output wire [W_HDATA-1:0]    ahblm_hwdata,
	input  wire [W_HDATA-1:0]    ahblm_hrdata,

	// APB slave port
	input  wire                  apbs_psel,
	input  wire                  apbs_penable,
	input  wire                  apbs_pwrite,
	input  wire [15:0]           apbs_paddr,
	input  wire [W_HDATA-1:0]    apbs_pwdata,
	output wire [W_HDATA-1:0]    apbs_prdata,
	output wire                  apbs_pready,
	output wire                  apbs_pslverr,

	// Scanbuf read port interface for dispctrl
	input  wire [W_COORD_SX-1:0] scanout_raddr,
	input  wire                  scanout_ren,
	output wire [W_PIXDATA-1:0]  scanout_rdata,
	output wire                  scanout_buf_rdy,
	input  wire                  scanout_buf_release
);

`include "riscboy_ppu_const.vh"

localparam W_LCD_PIXDATA = 16;
localparam W_COORD_UV = 10;
localparam W_COORD_FRAC = 8;

// ----------------------------------------------------------------------------
// Regblock

wire                      csr_run;
wire                      csr_running;
wire                      csr_halt_hsync;
wire                      csr_halt_vsync;

wire [W_COORD_SX-1:0]     dispsize_w;
wire [W_COORD_SY-1:0]     dispsize_h;

wire [W_HADDR-1:0]        cproc_pc_wdata;
wire                      cproc_pc_wen;

wire                      ints_vsync;
wire                      ints_hsync;
wire                      inte_vsync;
wire                      inte_hsync;
wire                      vsync;
wire                      hsync;

ppu_regs regs (
	.clk                    (clk),
	.rst_n                  (rst_n),

	.apbs_psel              (apbs_psel && !apbs_paddr[11]), // TODO clean up this hack for mapping palette RAM at 2kB
	.apbs_penable           (apbs_penable),
	.apbs_pwrite            (apbs_pwrite),
	.apbs_paddr             (apbs_paddr),
	.apbs_pwdata            (apbs_pwdata),
	.apbs_prdata            (apbs_prdata),
	.apbs_pready            (apbs_pready),
	.apbs_pslverr           (apbs_pslverr),

	.csr_run_o              (csr_run),
	.csr_running_i          (csr_running),
	.csr_halt_hsync_o       (csr_halt_hsync),
	.csr_halt_vsync_o       (csr_halt_vsync),

	.dispsize_w_o           (dispsize_w),
	.dispsize_h_o           (dispsize_h),

	.cproc_pc_o             (cproc_pc_wdata),
	.cproc_pc_wen           (cproc_pc_wen),

	.ints_vsync_i           (vsync),
	.ints_vsync_o           (ints_vsync),
	.ints_hsync_i           (hsync),
	.ints_hsync_o           (ints_hsync),
	.inte_vsync_o           (inte_vsync),
	.inte_hsync_o           (inte_hsync)
);

// ----------------------------------------------------------------------------
// Vsync and run/halt logic
//
// We don't allow the user to halt the PPU arbitrarily, to avoid some very
// messy cleanup. Always run until either end of scanline or end of frame,
// depending on user config (both of which are triggered by a command
// processor SYNC instruction). Optionally, an IRQ is generated on either of
// these events.

reg [W_COORD_SY-1:0] raster_y;
reg                  ppu_running;

// hsync is generated by the cproc's SYNC instruction
assign vsync = hsync && raster_y == dispsize_h;
assign csr_running = ppu_running;

always @ (posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		raster_y <= {W_COORD_SY{1'b0}};
		ppu_running <= 1'b0;
	end else begin
		raster_y <= vsync ? {W_COORD_SY{1'b0}} : raster_y + hsync;
		ppu_running <= (ppu_running || csr_run)
			&& !(vsync && csr_halt_vsync)
			&& !(hsync && csr_halt_hsync);
	end
end

assign irq = |({ints_hsync, ints_vsync} & {inte_hsync, inte_vsync});

// ----------------------------------------------------------------------------
// Command processor

wire                  cproc_bus_aph_vld;
wire                  cproc_bus_aph_rdy;
wire [W_HADDR-1:0]    cproc_bus_aph_addr;
wire [1:0]            cproc_bus_aph_size = 2'h2;
wire                  cproc_bus_dph_vld;
wire [W_HDATA-1:0]    cproc_bus_dph_data;

wire                  blitter_scanbuf_rdy;

wire                  cgen_start_affine;
wire                  cgen_start_simple;
wire [W_COORD_UV-1:0] cgen_raster_offs_x;
wire [W_COORD_UV-1:0] cgen_raster_offs_y;
wire [W_HDATA-1:0]    cgen_aparam_data;
wire                  cgen_aparam_vld;
wire                  cgen_aparam_rdy;

wire                  span_start;
wire [W_COORD_SX-1:0] span_x0;
wire [W_COORD_SX-1:0] span_count;
wire [W_SPANTYPE-1:0] span_type;
wire [1:0]            span_pixmode;
wire [2:0]            span_paloffs;
wire [14:0]           span_fill_colour;
wire [W_HADDR-1:0]    span_tilemap_ptr;
wire [W_HADDR-1:0]    span_texture_ptr;
wire [2:0]            span_texsize;
wire                  span_tilesize;
wire                  span_ablit_halfsize;
wire                  span_done;

riscboy_ppu_cproc #(
	.W_COORD_SX       (W_COORD_SX),
	.W_COORD_SY       (W_COORD_SY),
	.W_COORD_UV       (W_COORD_UV),
	.W_SPAN_TYPE      (W_SPANTYPE),
	.GLOBAL_ADDR_MASK (ADDR_MASK),
	.W_ADDR           (W_HADDR),
	.W_DATA           (W_HDATA)
) cproc (
	.clk                 (clk),
	.rst_n               (rst_n),

	.ppu_running         (ppu_running),
	.entrypoint          (cproc_pc_wdata),
	.entrypoint_vld      (cproc_pc_wen),

	.bus_addr_vld        (cproc_bus_aph_vld),
	.bus_addr_rdy        (cproc_bus_aph_rdy),
	.bus_addr            (cproc_bus_aph_addr),
	.bus_data_vld        (cproc_bus_dph_vld),
	.bus_data            (cproc_bus_dph_data),

	.beam_y              (raster_y),
	.hsync               (hsync),
	.scanbuf_rdy         (blitter_scanbuf_rdy),

	.cgen_start_affine   (cgen_start_affine),
	.cgen_start_simple   (cgen_start_simple),
	.cgen_raster_offs_x  (cgen_raster_offs_x),
	.cgen_raster_offs_y  (cgen_raster_offs_y),
	.cgen_aparam_data    (cgen_aparam_data),
	.cgen_aparam_vld     (cgen_aparam_vld),
	.cgen_aparam_rdy     (cgen_aparam_rdy),

	.span_start          (span_start),
	.span_x0             (span_x0),
	.span_count          (span_count),
	.span_type           (span_type),
	.span_pixmode        (span_pixmode),
	.span_paloffs        (span_paloffs),
	.span_fill_colour    (span_fill_colour),
	.span_tilemap_ptr    (span_tilemap_ptr),
	.span_texture_ptr    (span_texture_ptr),
	.span_texsize        (span_texsize),
	.span_tilesize       (span_tilesize),
	.span_ablit_halfsize (span_ablit_halfsize),
	.span_done           (span_done)
);

// ----------------------------------------------------------------------------
// Address generation

wire [W_COORD_UV-1:0] cgen_out_u;
wire [W_COORD_UV-1:0] cgen_out_v;
wire                  cgen_out_vld;
wire                  cgen_out_rdy_tile;
wire                  cgen_out_rdy_blit;
wire                  cgen_out_rdy = cgen_out_rdy_tile || cgen_out_rdy_blit;

`ifdef FORMAL
always @ (posedge clk) if (rst_n) assert(!(cgen_out_rdy_tile && cgen_out_rdy_blit));
`endif

riscboy_ppu_affine_coord_gen #(
	.W_COORD_INT  (W_COORD_UV),
	.W_COORD_FRAC (W_COORD_FRAC),
	.W_BUS_DATA   (W_HDATA)
) cgen (
	.clk           (clk),
	.rst_n         (rst_n),
	.start_affine  (cgen_start_affine),
	.start_simple  (cgen_start_simple),
	.raster_offs_x (cgen_raster_offs_x),
	.raster_offs_y (cgen_raster_offs_y),
	.aparam_data   (cgen_aparam_data),
	.aparam_vld    (cgen_aparam_vld),
	.aparam_rdy    (cgen_aparam_rdy),
	.out_u         (cgen_out_u),
	.out_v         (cgen_out_v),
	.out_vld       (cgen_out_vld),
	.out_rdy       (cgen_out_rdy)
);

wire                  tile_bus_aph_vld;
wire                  tile_bus_aph_rdy;
wire [1:0]            tile_bus_aph_size;
wire [W_HADDR-1:0]    tile_bus_aph_addr;
wire                  tile_bus_dph_vld;
wire [W_HDATA-1:0]    tile_bus_dph_data;

wire [3:0]            tinfo_u;
wire [3:0]            tinfo_v;
wire [W_TILENUM-1:0]  tinfo_tilenum;
wire                  tinfo_discard;
wire                  tinfo_vld;
wire                  tinfo_rdy;

riscboy_ppu_tile_agu #(
	.W_ADDR      (W_HADDR),
	.W_DATA      (W_HDATA),
	.ADDR_MASK   (ADDR_MASK),
	.W_COORD_UV  (W_COORD_UV),
	.W_COORD_SX  (W_COORD_SX),
	.W_SPAN_TYPE (W_SPANTYPE),
	.W_TILE_NUM  (W_TILENUM)
) tile_agu (
	.clk              (clk),
	.rst_n            (rst_n),

	.bus_addr_vld     (tile_bus_aph_vld),
	.bus_addr_rdy     (tile_bus_aph_rdy),
	.bus_size         (tile_bus_aph_size),
	.bus_addr         (tile_bus_aph_addr),
	.bus_data_vld     (tile_bus_dph_vld),
	.bus_data         (tile_bus_dph_data),

	.span_start       (span_start),
	.span_count       (span_count),
	.span_type        (span_type),
	.span_tilemap_ptr (span_tilemap_ptr),
	.span_texsize     (span_texsize),
	.span_tilesize    (span_tilesize),
	.span_done        (/* unused */),

	.cgen_u           (cgen_out_u),
	.cgen_v           (cgen_out_v),
	.cgen_vld         (cgen_out_vld),
	.cgen_rdy         (cgen_out_rdy_tile),

	.tinfo_u          (tinfo_u),
	.tinfo_v          (tinfo_v),
	.tinfo_tilenum    (tinfo_tilenum),
	.tinfo_discard    (tinfo_discard),
	.tinfo_vld        (tinfo_vld),
	.tinfo_rdy        (tinfo_rdy)
);

wire                  pixel_bus_aph_vld;
wire                  pixel_bus_aph_rdy;
wire [W_HADDR-1:0]    pixel_bus_aph_addr;
wire [1:0]            pixel_bus_aph_size;
wire                  pixel_bus_dph_vld;
wire [W_HDATA-1:0]    pixel_bus_dph_data;

wire [3:0]            pinfo_u;
wire                  pinfo_discard;
wire                  pinfo_vld;
wire                  pinfo_rdy;

riscboy_ppu_pixel_agu #(
	.W_COORD_SX  (W_COORD_SX),
	.W_COORD_UV  (W_COORD_UV),
	.W_SPAN_TYPE (W_SPANTYPE),
	.ADDR_MASK   (ADDR_MASK),
	.W_ADDR      (W_HADDR)
) pixel_agu (
	.clk                 (clk),
	.rst_n               (rst_n),

	.bus_addr_vld        (pixel_bus_aph_vld),
	.bus_addr_rdy        (pixel_bus_aph_rdy),
	.bus_size            (pixel_bus_aph_size),
	.bus_addr            (pixel_bus_aph_addr),

	.span_start          (span_start),
	.span_count          (span_count),
	.span_type           (span_type),
	.span_pixmode        (span_pixmode),
	.span_texture_ptr    (span_texture_ptr),
	.span_texsize        (span_texsize),
	.span_tilesize       (span_tilesize),
	.span_ablit_halfsize (span_ablit_halfsize),
	.span_done           (/* unused */),

	.cgen_u              (cgen_out_u),
	.cgen_v              (cgen_out_v),
	.cgen_vld            (cgen_out_vld),
	.cgen_rdy            (cgen_out_rdy_blit),

	.tinfo_u             (tinfo_u),
	.tinfo_v             (tinfo_v),
	.tinfo_tilenum       (tinfo_tilenum),
	.tinfo_discard       (tinfo_discard),
	.tinfo_vld           (tinfo_vld),
	.tinfo_rdy           (tinfo_rdy),

	.pinfo_u             (pinfo_u),
	.pinfo_discard       (pinfo_discard),
	.pinfo_vld           (pinfo_vld),
	.pinfo_rdy           (pinfo_rdy)
);


// ----------------------------------------------------------------------------
// Pixel data unpack

wire                  blender_in_vld;
wire                  blender_in_blank;
wire [W_PIXDATA-1:0]  blender_in_data;
wire                  blender_in_paletted;

riscboy_ppu_pixel_unpack #(
	.W_COORD_SX  (W_COORD_SX),
	.W_SPAN_TYPE (W_SPANTYPE)
) pixel_unpack (
	.clk              (clk),
	.rst_n            (rst_n),

	.in_data          (pixel_bus_dph_data[W_PIXDATA-1:0]),
	.in_vld           (pixel_bus_dph_vld),

	.pinfo_u          (pinfo_u),
	.pinfo_discard    (pinfo_discard),
	.pinfo_vld        (pinfo_vld),
	.pinfo_rdy        (pinfo_rdy),

	.span_start       (span_start),
	.span_x0          (span_x0),
	.span_count       (span_count),
	.span_type        (span_type),
	.span_pixmode     (span_pixmode),
	.span_paloffs     (span_paloffs),
	.span_fill_colour (span_fill_colour),
	.span_done        (/* unused */),

	.out_vld          (blender_in_vld),
	.out_blank        (blender_in_blank),
	.out_data         (blender_in_data),
	.out_paletted     (blender_in_paletted)
);


// ----------------------------------------------------------------------------
// Scanline buffers, blender and scanout

// Currently we are just doing 1-bit transparency, so blender does not require
// read-modify-write. This means all writes are from blender, and all reads
// are from scanout, so the read/write buses are commoned up across the two
// scanline buffers, and we just decode *strobes* based on which scanbuf the
// blender/scanout is operating on.

reg                   blitter_current_scanbuf;
reg                   scanout_current_scanbuf;
reg  [1:0]            scanbuf_dirty;

wire [W_COORD_SX-1:0] scanbuf_waddr;
wire [W_PIXDATA-2:0]  scanbuf_wdata;
wire                  scanbuf_wen;

wire [W_PIXDATA-2:0]  scanbuf_rdata0;
wire [W_PIXDATA-2:0]  scanbuf_rdata1;

sram_sync_1r1w #(
	.WIDTH (W_PIXDATA - 1), // no alpha
	.DEPTH (1 << W_COORD_SX)
) scanbuf0 (
	.clk   (clk),
	.waddr (scanbuf_waddr),
	.wdata (scanbuf_wdata),
	.wen   (scanbuf_wen && !blitter_current_scanbuf),
	.raddr (scanout_raddr),
	.rdata (scanbuf_rdata0),
	.ren   (scanout_ren && !scanout_current_scanbuf)
);

sram_sync_1r1w #(
	.WIDTH (W_PIXDATA - 1),
	.DEPTH (1 << W_COORD_SX)
) scanbuf1 (
	.clk   (clk),
	.waddr (scanbuf_waddr),
	.wdata (scanbuf_wdata),
	.wen   (scanbuf_wen && blitter_current_scanbuf),
	.raddr (scanout_raddr),
	.rdata (scanbuf_rdata1),
	.ren   (scanout_ren && scanout_current_scanbuf)
);

riscboy_ppu_blender #(
	.W_PIXDATA     (W_PIXDATA),
	.W_COORD_SX    (W_COORD_SX),
	.W_PALETTE_IDX (8)
) blender (
	.clk           (clk),
	.rst_n         (rst_n),

	.in_vld        (blender_in_vld),
	.in_data       (blender_in_data),
	.in_paletted   (blender_in_paletted),
	.in_blank      (blender_in_blank),

	.pram_waddr    (apbs_paddr[8:1]), // TODO this sucks
	.pram_wdata    (apbs_pwdata[W_PIXDATA-1:0]),
	.pram_wen      (apbs_pwrite && apbs_penable && apbs_psel && apbs_paddr[11]),

	.scanbuf_waddr (scanbuf_waddr),
	.scanbuf_wdata (scanbuf_wdata),
	.scanbuf_wen   (scanbuf_wen),

	.span_start    (span_start),
	.span_x0       (span_x0),
	.span_count    (span_count),
	.span_done     (span_done)
);

// Track scanbuffer clean/dirty flags, and which buffer the blitter and scanout
// intend to access

always @ (posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		blitter_current_scanbuf <= 1'b0;
		scanout_current_scanbuf <= 1'b0;
		scanbuf_dirty <= 2'b00;
	end else begin
		if (hsync) begin
			blitter_current_scanbuf <= !blitter_current_scanbuf;
			scanbuf_dirty[blitter_current_scanbuf] <= 1'b1;
		end
		if (scanout_buf_release) begin
			scanout_current_scanbuf <= !scanout_current_scanbuf;
			scanbuf_dirty[scanout_current_scanbuf] <= 1'b0;
		end
	end
end

assign blitter_scanbuf_rdy = !scanbuf_dirty[blitter_current_scanbuf];

// Register which scanbuf was last read from by scanout, so we can mux in
// correct rdata (Note that the SPI dispctrl can read from *different*
// scanbufs on two consecutive cycles if the PPU is overrunning the display)

reg scanout_buf_last_read;
always @ (posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		scanout_buf_last_read <= 1'b0;
	end else if (scanout_ren) begin
		scanout_buf_last_read <= scanout_current_scanbuf;
	end
end

assign scanout_buf_rdy = scanbuf_dirty[scanout_current_scanbuf];
wire [W_PIXDATA-2:0] scanout_rdata_raw = scanout_buf_last_read ? scanbuf_rdata1 : scanbuf_rdata0;
// scanout_rdata is in RGB565 format, not RGB555
assign scanout_rdata = {scanout_rdata_raw[14:5], 1'b0, scanout_rdata_raw[4:0]};

// ----------------------------------------------------------------------------
// Busmaster

riscboy_ppu_busmaster #(
	.N_REQ     (3),
	.W_ADDR    (W_HADDR),
	.W_DATA    (W_HDATA),
	.ADDR_MASK (ADDR_MASK)
) busmaster (
	.clk             (clk),
	.rst_n           (rst_n),
	.ppu_running     (ppu_running),

	// Lowest significance wins
	.req_aph_vld     ({pixel_bus_aph_vld  , tile_bus_aph_vld  , cproc_bus_aph_vld  }),
	.req_aph_rdy     ({pixel_bus_aph_rdy  , tile_bus_aph_rdy  , cproc_bus_aph_rdy  }),
	.req_aph_addr    ({pixel_bus_aph_addr , tile_bus_aph_addr , cproc_bus_aph_addr }),
	.req_aph_size    ({pixel_bus_aph_size , tile_bus_aph_size , cproc_bus_aph_size }),
	.req_dph_vld     ({pixel_bus_dph_vld  , tile_bus_dph_vld  , cproc_bus_dph_vld  }),
	.req_dph_data    ({pixel_bus_dph_data , tile_bus_dph_data , cproc_bus_dph_data }),

	.ahblm_haddr     (ahblm_haddr),
	.ahblm_hwrite    (ahblm_hwrite),
	.ahblm_htrans    (ahblm_htrans),
	.ahblm_hsize     (ahblm_hsize),
	.ahblm_hburst    (ahblm_hburst),
	.ahblm_hprot     (ahblm_hprot),
	.ahblm_hmastlock (ahblm_hmastlock),
	.ahblm_hready    (ahblm_hready),
	.ahblm_hresp     (ahblm_hresp),
	.ahblm_hwdata    (ahblm_hwdata),
	.ahblm_hrdata    (ahblm_hrdata)
);


endmodule
