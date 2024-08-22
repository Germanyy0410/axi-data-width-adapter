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

  upsizer dut (
    .aclk(aclk),
    .arst_n(arst_n),
    .m_awlen(m_awlen),
    .m_awsize(m_awsize),
    .m_awburst(m_awburst),
    .m_awid(m_awid),
    .m_awaddr(m_awaddr),
    .m_awvalid(m_awvalid),
    .s_awready(s_awready),
    .m_wdata(m_wdata),
    .m_wvalid(m_wvalid),
    .s_wready(s_wready),
    .m_wlast(m_wlast),
    .s_bid(s_bid),
    .s_bvalid(s_bvalid),
    .m_bready(m_bready),
    .s_bresp(s_bresp)
  );
  always #10 aclk = ~aclk;

  initial begin
    aclk = 1'b1;
    arst_n = 1'b0;

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

    #5000;
    $finish();
  end

  initial begin
    aclk = 1'b1;
    arst_n = 1'b0;

    #11.01;
    m_awid = 0;
    arst_n = 1'b1;
    #9;
    m_wdata = { 32'd1, 32'd2, 32'd3, 32'd4 };
    m_wvalid = 1'b1;
    s_wready = 1'b1;
    #20.1;
    m_wdata = { 32'd5, 32'd6, 32'd7, 32'd8 };
    #20.1;
    m_wdata = { 32'd9, 32'd10, 32'd11, 32'd12 };
    #20.1;
    m_wdata = { 32'd13, 32'd14, 32'd15, 32'd16 };
  end
endmodule