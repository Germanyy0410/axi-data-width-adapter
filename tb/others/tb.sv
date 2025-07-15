`timescale 1ns / 1ps

// `define _32_BIT_MODE  1
// `define _64_BIT_MODE  2
`define _128_BIT_MODE 3

typedef enum logic [2:0] {
  _32_BIT       = 3'b101,
  _64_BIT       = 3'b110,
  _128_BIT      = 3'b111
} burst_size_t;

module upsizer_tb #(

`ifdef _32_BIT_MODE
  parameter M_DATA_WIDTH  = 32,
`elsif _64_BIT_MODE
  parameter M_DATA_WIDTH  = 64,
`elsif _128_BIT_MODE
  parameter M_DATA_WIDTH  = 128,
`else
  parameter M_DATA_WIDTH  = 32,
`endif

  parameter LEN_WIDTH     = 8,
  parameter SIZE_WIDTH    = 3,
  parameter BURST_WIDTH   = 2,

  parameter ADDR_WIDTH    = 32,
  parameter AWID_WIDTH    = 3,
  parameter S_DATA_WIDTH  = 32,
  parameter BID_WIDTH     = 3
  )();
  reg aclk;
  reg arst_n;

  reg           [LEN_WIDTH-1:0]     m_awlen;
  burst_size_t  [SIZE_WIDTH-1:0]    m_awsize;
  reg           [BURST_WIDTH-1:0]   m_awburst;

  reg           [AWID_WIDTH-1:0]    m_awid;
  reg           [ADDR_WIDTH-1:0]    m_awaddr;
  reg                               m_awvalid;
  reg                               s_awready;

  reg           [M_DATA_WIDTH-1:0]  m_wdata;
  reg                               m_wvalid;
  reg                               s_wready;
  reg                               m_wlast;

  reg           [BID_WIDTH-1:0]     s_bid;
  reg                               s_bvalid;
  reg                               m_bready;
  reg           [1:0]               s_bresp;

  reg           [LEN_WIDTH-1:0]     m_arlen;
  burst_size_t  [SIZE_WIDTH-1:0]    m_arsize;
  reg           [BURST_WIDTH-1:0]   m_arburst;

  reg           [AWID_WIDTH-1:0]    m_arid;
  reg           [ADDR_WIDTH-1:0]    m_araddr;
  reg                               m_arvalid;
  reg                               s_arready;

  reg           [S_DATA_WIDTH-1:0]  s_rdata;
  reg                               s_rvalid;
  reg                               m_rready;
  reg                               s_rlast;

  upsizer dut (
    .aclk(aclk),
    .arst_n(arst_n),
    .m_awlen_i(m_awlen),
    .m_awsize_i(m_awsize),
    .m_awburst_i(m_awburst),
    .m_awid_i(m_awid),
    .m_awaddr_i(m_awaddr),
    .m_awvalid_i(m_awvalid),
    .s_awready_i(s_awready),
    .m_wdata_i(m_wdata),
    .m_wvalid_i(m_wvalid),
    .s_wready_i(s_wready),
    .m_wlast_i(m_wlast),
    .s_bid_i(s_bid),
    .s_bvalid_i(s_bvalid),
    .m_bready_i(m_bready),
    .s_bresp_i(s_bresp),

    .m_arlen_i(m_arlen),
    .m_arsize_i(m_arsize),
    .m_arburst_i(m_arburst),
    .m_arid_i(m_arid),
    .m_araddr_i(m_araddr),
    .m_arvalid_i(m_arvalid),
    .s_arready_i(s_arready),
    .s_rdata_i(s_rdata),
    .s_rvalid_i(s_rvalid),
    .m_rready_i(m_rready),
    .s_rlast_i(s_rlast)
  );
  always #10 aclk = ~aclk;

  initial begin
    aclk = 1'b1;
    arst_n = 1'b0;
  end

  initial begin
    #11.01;
    m_awid = 0;
    arst_n = 1'b1;
    #9;
    m_awaddr = 32'd2;
    m_awsize = _128_BIT;
    m_awlen  = 8'd255;
    m_awburst = 2'b01;
    m_awvalid = 1'b1;
    s_awready = 1'b1;

    #20.1;
    m_awaddr = 32'd3;
    #20;
    #1;
    m_awaddr = 32'd4;
    #20.1;
    m_awaddr = 32'd5;
    #20.1;
    m_awaddr = 32'd6;
    #20.1;
    m_awaddr = 32'd7;
    #20;
    #1;
    m_awaddr = 32'd8;
    #20.1;
    m_awaddr = 32'd9;
    #20.1;
    m_awaddr = 32'd10;
    #20.1;
    m_awaddr = 32'd11;
    #20.1;
    m_awaddr = 32'd12;
  end

  initial begin
    aclk = 1'b1;
    arst_n = 1'b0;

    #11.01;
    m_awid = 0;
    arst_n = 1'b1;
    #29;
    m_wdata = { 32'd5, 32'd6, 32'd7, 32'd8 };
    m_wvalid = 1'b1;
    s_wready = 1'b1;
    m_wlast = 1'b0;
    #20.1;
    m_wvalid = 1'b0;
    m_wdata = { 32'd1, 32'd2, 32'd3, 32'd4 };
    #20.1;
    m_wdata = { 32'd9, 32'd10, 32'd11, 32'd12 };
    #20.1;
    m_wdata = { 32'd13, 32'd14, 32'd15, 32'd16 };
    #40.1;
    m_wvalid = 1'b1;
  end

  initial begin
    aclk = 1'b1;
    arst_n = 1'b0;

    #11.01;
    m_arid = 0;
    arst_n = 1'b1;
    #9;
    m_araddr = 32'd2;
    m_arsize = _128_BIT;
    m_arlen  = 8'd2;
    m_arburst = 2'b01;
    m_arvalid = 1'b1;
    s_arready = 1'b1;
    s_rlast   = 1'b0;

    #20.1;
    m_araddr = 32'd3;
    #20;
    #1;
    m_araddr = 32'd4;
    m_rready  = 1'b1;
    s_rvalid = 1'b1;
    s_rdata  = 32'd1;
    #20.1;
    m_araddr = 32'd5;
    s_rdata  = 32'd2;
    #20.1;
    m_araddr = 32'd6;
    s_rdata  = 32'd3;
    #20.1;
    m_araddr = 32'd7;
    s_rdata  = 32'd4;
    #20;
    #1;
    m_araddr = 32'd8;
    s_rdata  = 32'd5;
    #20.1;
    m_araddr = 32'd9;
    s_rdata  = 32'd6;
    #20.1;
    m_araddr = 32'd10;
    s_rdata  = 32'd7;
    #20.1;
    m_araddr = 32'd11;
    s_rdata  = 32'd8;
    s_rlast   = 1'b1;
    #20.1;
    m_araddr = 32'd12;
  end

  initial begin
    #5000;
    $finish();
  end
endmodule