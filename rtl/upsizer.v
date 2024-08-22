`timescale 1ns / 1ps

module upsizer #(

  parameter M_DATA_WIDTH  = 128,

  parameter S_DATA_WIDTH  = 32,
  parameter ADDR_WIDTH    = 32,

  parameter AWID_WIDTH    = 3,
  parameter LEN_WIDTH     = 8,
  parameter SIZE_WIDTH    = 3,
  parameter BURST_WIDTH   = 2,
  parameter BID_WIDTH     = 3,
  parameter ARID_WIDTH    = 3,
  parameter RID_WIDTH     = 3
)(
  input                       aclk,
  input                       arst_n,

  // =====================================
  // =====     Write transaction     =====
  // =====================================
  input   [LEN_WIDTH-1:0]     m_awlen,
  input   [SIZE_WIDTH-1:0]    m_awsize,
  input   [BURST_WIDTH-1:0]   m_awburst,

  input   [AWID_WIDTH-1:0]    m_awid,
  input   [ADDR_WIDTH-1:0]    m_awaddr,
  input                       m_awvalid,
  input                       s_awready,

  input   [M_DATA_WIDTH-1:0]  m_wdata,
  input                       m_wvalid,
  input                       s_wready,
  input                       m_wlast,

  input   [BID_WIDTH-1:0]     s_bid,
  input                       s_bvalid,
  input                       m_bready,
  input   [1:0]               s_bresp,

  output  [LEN_WIDTH-1:0]     s_awlen,
  output  [SIZE_WIDTH-1:0]    s_awsize,
  output  [BURST_WIDTH-1:0]   s_awburst,

  output  [AWID_WIDTH-1:0]    s_awid,
  output  [ADDR_WIDTH-1:0]    s_awaddr,
  output                      s_awvalid,
  output                      m_awready,

  output  [S_DATA_WIDTH-1:0]  s_wdata,
  output                      s_wvalid,
  output                      m_wready,
  output                      s_wlast,

  output  [BID_WIDTH-1:0]     m_bid,
  output                      m_bvalid,
  output                      s_bready,
  output  [1:0]               m_bresp,

  // =====================================
  // =====     Read transaction     ======
  // =====================================
  input   [LEN_WIDTH-1:0]     m_arlen,
  input   [SIZE_WIDTH-1:0]    m_arsize,
  input   [BURST_WIDTH-1:0]   m_arburst,

  input   [ARID_WIDTH-1:0]    m_arid,
  input   [ADDR_WIDTH-1:0]    m_araddr,
  input                       m_arvalid,
  input                       s_arready,

  input   [M_DATA_WIDTH-1:0]  s_rdata,
  input                       s_rvalid,
  input                       m_rready,
  input                       s_rlast,

  output  [LEN_WIDTH-1:0]     s_arlen,
  output  [SIZE_WIDTH-1:0]    s_arsize,
  output  [BURST_WIDTH-1:0]   s_arburst,

  output  [ARID_WIDTH-1:0]    s_arid,
  output  [ADDR_WIDTH-1:0]    s_araddr,
  output                      s_arvalid,
  output                      m_arready,

  output  [S_DATA_WIDTH-1:0]  m_rdata,
  output                      m_rvalid,
  output                      s_rready,
  output                      m_rlast
);

  aw_channel #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .AWID_WIDTH(AWID_WIDTH)
  ) u_aw_channel(
    .aclk(aclk),
    .arst_n(arst_n),

    .m_awlen(m_awlen),
    .m_awsize(m_awsize),
    .m_awburst(m_awburst),

    .m_awid(m_awid),
    .m_awaddr(m_awaddr),
    .m_awvalid(m_awvalid),
    .s_awready(s_awready),

    .s_awlen(s_awlen),
    .s_awsize(s_awsize),
    .s_awburst(s_awburst),

    .s_awid(s_awid),
    .s_awaddr(s_awaddr),
    .s_awvalid(s_awvalid),
    .m_awready(m_awready)
  );

  w_channel #(
    .M_DATA_WIDTH(M_DATA_WIDTH),
    .S_DATA_WIDTH(S_DATA_WIDTH)
  ) u_w_channel(
    .aclk(aclk),
    .arst_n(arst_n),

    .m_wdata(m_wdata),
    .m_wvalid(m_wvalid),
    .s_wready(s_wready),
    .m_wlast(m_wlast),

    .s_wdata(s_wdata),
    .s_wvalid(s_wvalid),
    .m_wready(m_wready),
    .s_wlast(s_wlast)
  );

  b_channel #(
    .BID_WIDTH(BID_WIDTH)
  ) u_b_channel(
    .aclk(aclk),
    .arst_n(arst_n),

    .s_bid(s_bid),
    .s_bvalid(s_bvalid),
    .m_bready(m_bready),
    .s_bresp(s_bresp),

    .m_bid(m_bid),
    .m_bvalid(m_bvalid),
    .s_bready(s_bready),
    .m_bresp(m_bresp)
  );

  ar_channel #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .ARID_WIDTH(ARID_WIDTH)
  ) u_ar_channel(
    .aclk(aclk),
    .arst_n(arst_n),

    .m_arlen(m_arlen),
    .m_arsize(m_arsize),
    .m_arburst(m_arburst),

    .m_arid(m_arid),
    .m_araddr(m_araddr),
    .m_arvalid(m_arvalid),
    .s_arready(s_arready),

    .s_arlen(s_arlen),
    .s_arsize(s_arsize),
    .s_arburst(s_arburst),

    .s_arid(s_arid),
    .s_araddr(s_araddr),
    .s_arvalid(s_arvalid),
    .m_arready(m_arready)
  );

  // r_channel #(
  //   .M_DATA_WIDTH(M_DATA_WIDTH),
  //   .S_DATA_WIDTH(S_DATA_WIDTH)
  // ) u_r_channel(
  //   .aclk(aclk),
  //   .arst_n(arst_n),

  //   .m_rdata(m_rdata),
  //   .m_rvalid(m_rvalid),
  //   .m_rready(m_rready),
  //   .m_rlast(m_rlast),
  //   .m_rresp(m_rresp),

  //   .s_rdata(s_rdata),
  //   .s_rvalid(s_rvalid),
  //   .s_rready(s_rready),
  //   .s_rlast(s_rlast),
  //   .s_rresp(s_rresp)
  // );
endmodule
