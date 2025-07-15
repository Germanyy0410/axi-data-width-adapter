module upsizer #(
  parameter SKID_BUFFER_EN    = 1,

  parameter WRITE             = 0,
  parameter READ              = 1,
  parameter M_DATA_WIDTH      = 128,

  parameter S_DATA_WIDTH      = 32,
  parameter ADDR_WIDTH        = 32,

  parameter AWID_WIDTH        = 3,
  parameter LEN_WIDTH         = 8,
  parameter SIZE_WIDTH        = 3,
  parameter BURST_WIDTH       = 2,
  parameter BID_WIDTH         = 3,
  parameter ARID_WIDTH        = 3,
  parameter RID_WIDTH         = 3,
  parameter RESP_WIDTH        = 2,

  parameter XFER_FF_WIDTH     = 3,
  parameter RD_XFER_FF_WIDTH  = 6,
  parameter RESP_ARR_WIDTH    = 9
)(
  input                       aclk,
  input                       arst_n,

  // -- Write transaction
  input   [LEN_WIDTH-1:0]     m_awlen_i,
  input   [SIZE_WIDTH-1:0]    m_awsize_i,
  input   [BURST_WIDTH-1:0]   m_awburst_i,

  input   [AWID_WIDTH-1:0]    m_awid_i,
  input   [ADDR_WIDTH-1:0]    m_awaddr_i,
  input                       m_awvalid_i,
  input                       s_awready_i,

  input   [M_DATA_WIDTH-1:0]  m_wdata_i,
  input                       m_wvalid_i,
  input                       s_wready_i,
  input                       m_wlast_i,

  input   [BID_WIDTH-1:0]     s_bid_i,
  input                       s_bvalid_i,
  input                       m_bready_i,
  input   [RESP_WIDTH-1:0]    s_bresp_i,

  output  [LEN_WIDTH-1:0]     s_awlen_o,
  output  [SIZE_WIDTH-1:0]    s_awsize_o,
  output  [BURST_WIDTH-1:0]   s_awburst_o,

  output  [AWID_WIDTH-1:0]    s_awid_o,
  output  [ADDR_WIDTH-1:0]    s_awaddr_o,
  output                      s_awvalid_o,
  output                      m_awready_o,

  output  [S_DATA_WIDTH-1:0]  s_wdata_o,
  output                      s_wvalid_o,
  output                      m_wready_o,
  output                      s_wlast_o,

  output  [BID_WIDTH-1:0]     m_bid_o,
  output                      m_bvalid_o,
  output                      s_bready_o,
  output  [RESP_WIDTH-1:0]    m_bresp_o,

  // -- Read transaction
  input   [LEN_WIDTH-1:0]     m_arlen_i,
  input   [SIZE_WIDTH-1:0]    m_arsize_i,
  input   [BURST_WIDTH-1:0]   m_arburst_i,

  input   [ARID_WIDTH-1:0]    m_arid_i,
  input   [ADDR_WIDTH-1:0]    m_araddr_i,
  input                       m_arvalid_i,
  input                       s_arready_i,

  input   [RID_WIDTH-1:0]     s_rid_i,
  input   [S_DATA_WIDTH-1:0]  s_rdata_i,
  input                       s_rvalid_i,
  input                       m_rready_i,
  input                       s_rlast_i,
  input   [RESP_WIDTH-1:0]    s_rresp_i,

  output  [LEN_WIDTH-1:0]     s_arlen_o,
  output  [SIZE_WIDTH-1:0]    s_arsize_o,
  output  [BURST_WIDTH-1:0]   s_arburst_o,

  output  [ARID_WIDTH-1:0]    s_arid_o,
  output  [ADDR_WIDTH-1:0]    s_araddr_o,
  output                      s_arvalid_o,
  output                      m_arready_o,

  output  [RID_WIDTH-1:0]     m_rid_o,
  output  [M_DATA_WIDTH-1:0]  m_rdata_o,
  output                      m_rvalid_o,
  output                      s_rready_o,
  output                      m_rlast_o,
  output  [RESP_WIDTH-1:0]    m_rresp_o
);
  generate;
    if (SKID_BUFFER_EN == 1) begin : SKID_BUFFER_ENABLE
      localparam AW_SB_WIDTH = LEN_WIDTH + SIZE_WIDTH + BURST_WIDTH + AWID_WIDTH + ADDR_WIDTH + 1;
      localparam W_SB_WIDTH  = M_DATA_WIDTH + 1 + 1;
      localparam B_SB_WIDTH  = BID_WIDTH + 2 + 1;
      localparam AR_SB_WIDTH = LEN_WIDTH + SIZE_WIDTH + BURST_WIDTH + ARID_WIDTH + ADDR_WIDTH + 1;
      localparam R_SB_WIDTH  = RID_WIDTH + S_DATA_WIDTH + 1 + 1;

      // =============== skid buffer ===================
      wire   [LEN_WIDTH-1:0]     m_awlen;
      wire   [SIZE_WIDTH-1:0]    m_awsize;
      wire   [BURST_WIDTH-1:0]   m_awburst;

      wire   [AWID_WIDTH-1:0]    m_awid;
      wire   [ADDR_WIDTH-1:0]    m_awaddr;
      wire                       m_awvalid;
      wire                       s_awready;
      wire                       m_awready;

      wire   [M_DATA_WIDTH-1:0]  m_wdata;
      wire                       m_wvalid;
      wire                       s_wready;
      wire                       m_wready;
      wire                       m_wlast;
      wire                       w_done;

      wire   [BID_WIDTH-1:0]     s_bid;
      wire                       m_bvalid;
      wire                       s_bvalid;
      wire                       m_bready;
      wire   [1:0]               s_bresp;

      // -- Read transaction
      wire   [LEN_WIDTH-1:0]     m_arlen;
      wire   [SIZE_WIDTH-1:0]    m_arsize;
      wire   [BURST_WIDTH-1:0]   m_arburst;

      wire   [ARID_WIDTH-1:0]    m_arid;
      wire   [ADDR_WIDTH-1:0]    m_araddr;
      wire                       m_arvalid;
      wire                       m_arready;
      wire                       s_arready;

      wire   [RID_WIDTH-1:0]     s_rid;
      wire   [S_DATA_WIDTH-1:0]  s_rdata;
      wire                       s_rvalid;
      wire                       m_rvalid;
      wire                       s_rready;
      wire                       m_rready;
      wire                       s_rlast;
      wire   [1:0]               s_rresp;

      wire   [AW_SB_WIDTH-1:0]   sb_aw_data_i;
      wire   [AW_SB_WIDTH-1:0]   sb_aw_data_o;

      wire   [W_SB_WIDTH-1:0]    sb_w_data_i;
      wire   [W_SB_WIDTH-1:0]    sb_w_data_o;

      wire   [B_SB_WIDTH-1:0]    sb_b_data_i;
      wire   [B_SB_WIDTH-1:0]    sb_b_data_o;

      wire   [AR_SB_WIDTH-1:0]   sb_ar_data_i;
      wire   [AR_SB_WIDTH-1:0]   sb_ar_data_o;

      wire   [R_SB_WIDTH-1:0]    sb_r_data_i;
      wire   [R_SB_WIDTH-1:0]    sb_r_data_o;

      // -- AW
      assign sb_aw_data_i = { m_awlen_i, m_awsize_i, m_awburst_i, m_awid_i, m_awaddr_i };
      assign {m_awlen, m_awsize, m_awburst, m_awid, m_awaddr} = sb_aw_data_o;

      skid_buffer #(
        .DATA_WIDTH(AW_SB_WIDTH)
      ) u_aw_skid_buffer (
        .clk(aclk),
        .rst_n(arst_n),
        .bwd_data_i(sb_aw_data_i),
        .fwd_data_o(sb_aw_data_o),
        .bwd_valid_i(m_awvalid_i),
        .fwd_valid_o(m_awvalid),
        .fwd_ready_i(m_awready),
        .bwd_ready_o(m_awready_o)
      );

      // -- W
      assign sb_w_data_i = { m_wdata_i, m_wlast_i };
      assign {m_wdata, m_wlast} = sb_w_data_o;

      skid_buffer #(
        .DATA_WIDTH(W_SB_WIDTH)
      ) u_w_skid_buffer (
        .clk(aclk),
        .rst_n(arst_n),
        .bwd_data_i(sb_w_data_i),
        .fwd_data_o(sb_w_data_o),
        .bwd_valid_i(m_wvalid_i),
        .fwd_valid_o(m_wvalid),
        .fwd_ready_i(m_wready),
        .bwd_ready_o(m_wready_o)
      );

      // -- B
      assign sb_b_data_i = { s_bid_i, s_bresp_i };
      assign {s_bid, s_bresp} = sb_b_data_o;

      skid_buffer #(
        .DATA_WIDTH(B_SB_WIDTH)
      ) u_b_skid_buffer (
        .clk(aclk),
        .rst_n(arst_n),
        .bwd_data_i(sb_b_data_i),
        .fwd_data_o(sb_b_data_o),
        .bwd_valid_i(m_bvalid),
        .fwd_valid_o(m_bvalid_o),
        .fwd_ready_i(m_bready_i),
        .bwd_ready_o(m_bready)
      );

      // -- AR
      assign sb_ar_data_i = { m_arlen_i, m_arsize_i, m_arburst_i, m_arid_i, m_araddr_i };
      assign {m_arlen, m_arsize, m_arburst, m_arid, m_araddr} = sb_ar_data_o;

      skid_buffer #(
        .DATA_WIDTH(AR_SB_WIDTH)
      ) u_ar_skid_buffer (
        .clk(aclk),
        .rst_n(arst_n),
        .bwd_data_i(sb_ar_data_i),
        .fwd_data_o(sb_ar_data_o),
        .bwd_valid_i(m_arvalid_i),
        .fwd_valid_o(m_arvalid),
        .fwd_ready_i(m_arready),
        .bwd_ready_o(m_arready_o)
      );

      // -- R
      assign sb_r_data_i = { s_rid_i, s_rdata_i, s_rlast_i, s_rresp_i };
      assign {s_rid, s_rdata, s_rlast, s_rresp} = sb_r_data_o;

      skid_buffer #(
        .DATA_WIDTH(R_SB_WIDTH)
      ) u_r_skid_buffer (
        .clk(aclk),
        .rst_n(arst_n),
        .bwd_data_i(sb_r_data_i),
        .fwd_data_o(sb_r_data_o),
        .bwd_valid_i(s_rvalid_i),
        .fwd_valid_o(s_rvalid),
        .fwd_ready_i(s_rready),
        .bwd_ready_o(s_rready_o)
      );
      // ===============================================


      // ==================== FIFO =====================
      wire [XFER_FF_WIDTH-1:0]    wr_xfer_data_i;
      wire [XFER_FF_WIDTH-1:0]    wr_xfer_data_o;
      wire                        wr_xfer_wr_valid_i;
      wire                        wr_xfer_rd_valid_i;
      wire                        wr_xfer_almost_empty_o;
      wire                        wr_xfer_empty_o;
      wire                        wr_xfer_almost_full_o;
      wire                        wr_xfer_full_o;

      wire [RD_XFER_FF_WIDTH-1:0] rd_xfer_data_i;
      wire [RD_XFER_FF_WIDTH-1:0] rd_xfer_data_o;
      wire                        rd_xfer_wr_valid_i;
      wire                        rd_xfer_rd_valid_i;
      wire                        rd_xfer_almost_empty_o;
      wire                        rd_xfer_empty_o;
      wire                        rd_xfer_almost_full_o;
      wire                        rd_xfer_full_o;
      // ===============================================

      wire [AWID_WIDTH-1:0]       awid;
      wire                        m_aw_handshake;
      wire [2:0]                  aw_total_sub_txn;

      wire [RESP_ARR_WIDTH-1:0]   resp;
      wire                        rd_valid;
      wire                        s_b_handshake;

      // -- AW channel
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
        .s_awready(s_awready_i),

        .s_awlen(s_awlen_o),
        .s_awsize(s_awsize_o),
        .s_awburst(s_awburst_o),

        .s_awid(s_awid_o),
        .s_awaddr(s_awaddr_o),
        .s_awvalid(s_awvalid_o),
        .m_awready(m_awready),

        .xfer_data_i(wr_xfer_data_i),
        .xfer_wr_valid_i(wr_xfer_wr_valid_i),

        .awid(awid),
        .aw_total_sub_txn(aw_total_sub_txn),
        .m_aw_handshake_q1(m_aw_handshake)
      );

      // -- -- w_fifo -> sub_xfer_cnt
      upsizer_fifo #(
        .DATA_WIDTH(XFER_FF_WIDTH)
      )
      u_w_sub_xfer_cnt_fifo (
        .almost_empty_o(wr_xfer_almost_empty_o),
        .almost_full_o (wr_xfer_almost_full_o),
        .clk           (aclk),
        .rst_n         (arst_n),
        .data_i        (wr_xfer_data_i),
        .data_o        (wr_xfer_data_o),
        .empty_o       (wr_xfer_empty_o),
        .full_o        (wr_xfer_full_o),
        .rd_valid_i    (wr_xfer_rd_valid_i),
        .wr_valid_i    (wr_xfer_wr_valid_i)
      );

      // -- W channel
      w_channel #(
        .M_DATA_WIDTH(M_DATA_WIDTH),
        .S_DATA_WIDTH(S_DATA_WIDTH)
      ) u_w_channel(
        .aclk(aclk),
        .arst_n(arst_n),

        .m_wdata(m_wdata),
        .m_wvalid(m_wvalid),
        .s_wready(s_wready_i),
        .m_wlast(m_wlast),

        .s_wdata(s_wdata_o),
        .s_wvalid(s_wvalid_o),
        .m_wready(m_wready),
        .s_wlast(s_wlast_o),
        .w_done(w_done),

        .xfer_empty_o(wr_xfer_empty_o),
        .xfer_data_o(wr_xfer_data_o),
        .xfer_rd_valid_i(wr_xfer_rd_valid_i)
      );

      // -- -- awid for B channel
      awid #(
        .AWID_WIDTH(AWID_WIDTH),
        .BID_WIDTH(BID_WIDTH),
        .RESP_ARR_WIDTH(RESP_ARR_WIDTH)
      ) u_awid (
        .aclk(aclk),
        .arst_n(arst_n),

        .awid(m_awid),
        .total_sub_txn(aw_total_sub_txn),
        .m_aw_handshake(m_aw_handshake),

        .s_b_handshake(s_b_handshake),
        .s_bresp(s_bresp),
        .s_bid(s_bid),

        .rd_valid(rd_valid),
        .resp(resp)
      );

      // -- B channel
      b_channel #(
        .BID_WIDTH(BID_WIDTH)
      ) u_b_channel(
        .aclk(aclk),
        .arst_n(arst_n),

        .s_bid(s_bid),
        .s_bvalid(s_bvalid_i),
        .m_bready(m_bready),
        .s_bresp(s_bresp),

        .m_bid(m_bid_o),
        .m_bvalid(m_bvalid),
        .s_bready(s_bready_o),
        .m_bresp(m_bresp_o),

        .w_done(w_done),
        .rd_valid(rd_valid),
        .resp(resp),
        .s_b_handshake(s_b_handshake)
      );

      // -- AR channel
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
        .s_arready(s_arready_i),

        .s_arlen(s_arlen_o),
        .s_arsize(s_arsize_o),
        .s_arburst(s_arburst_o),

        .s_arid(s_arid_o),
        .s_araddr(s_araddr_o),
        .s_arvalid(s_arvalid_o),
        .m_arready(m_arready),

        .xfer_data_i(rd_xfer_data_i),
        .xfer_wr_valid_i(rd_xfer_wr_valid_i)
      );

      // -- -- r_fifo -> sub_xfer_cnt
      upsizer_fifo #(
        .DATA_WIDTH(RD_XFER_FF_WIDTH)
      )
      u_r_sub_xfer_cnt_fifo (
        .almost_empty_o(rd_xfer_almost_empty_o),
        .almost_full_o (rd_xfer_almost_full_o),
        .clk           (aclk),
        .rst_n         (arst_n),
        .data_i        (rd_xfer_data_i),
        .data_o        (rd_xfer_data_o),
        .empty_o       (rd_xfer_empty_o),
        .full_o        (rd_xfer_full_o),
        .rd_valid_i    (rd_xfer_rd_valid_i),
        .wr_valid_i    (rd_xfer_wr_valid_i)
      );

      // -- R channel
      r_channel #(
        .M_DATA_WIDTH(M_DATA_WIDTH),
        .S_DATA_WIDTH(S_DATA_WIDTH)
      ) u_r_channel(
        .aclk(aclk),
        .arst_n(arst_n),

        .m_rid(m_rid_o),
        .m_rdata(m_rdata_o),
        .m_rvalid(m_rvalid_o),
        .m_rready(m_rready_i),
        .m_rlast(m_rlast_o),
        .m_rresp(m_rresp_o),

        .s_rid(s_rid),
        .s_rdata(s_rdata),
        .s_rvalid(s_rvalid),
        .s_rready(s_rready),
        .s_rlast(s_rlast),
        .s_rresp(s_rresp),

        .xfer_data_o(rd_xfer_data_o),
        .xfer_rd_valid_i(rd_xfer_rd_valid_i)
      );
    end else if (SKID_BUFFER_EN == 0) begin : SKID_BUFFER_DISABLE
      // ==================== FIFO =====================
      wire [XFER_FF_WIDTH-1:0]    wr_xfer_data_i;
      wire [XFER_FF_WIDTH-1:0]    wr_xfer_data_o;
      wire                        wr_xfer_wr_valid_i;
      wire                        wr_xfer_rd_valid_i;
      wire                        wr_xfer_almost_empty_o;
      wire                        wr_xfer_empty_o;
      wire                        wr_xfer_almost_full_o;
      wire                        wr_xfer_full_o;

      wire [RD_XFER_FF_WIDTH-1:0] rd_xfer_data_i;
      wire [RD_XFER_FF_WIDTH-1:0] rd_xfer_data_o;
      wire                        rd_xfer_wr_valid_i;
      wire                        rd_xfer_rd_valid_i;
      wire                        rd_xfer_almost_empty_o;
      wire                        rd_xfer_empty_o;
      wire                        rd_xfer_almost_full_o;
      wire                        rd_xfer_full_o;
      // ===============================================

      wire [AWID_WIDTH-1:0]       awid;
      wire                        m_aw_handshake;
      wire [2:0]                  aw_total_sub_txn;
      wire                        w_done;

      wire [RESP_ARR_WIDTH-1:0]   resp;
      wire                        rd_valid;
      wire                        s_b_handshake;

      // -- AW channel
      aw_channel #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .AWID_WIDTH(AWID_WIDTH)
      ) u_aw_channel(
        .aclk(aclk),
        .arst_n(arst_n),

        .m_awlen(m_awlen_i),
        .m_awsize(m_awsize_i),
        .m_awburst(m_awburst_i),

        .m_awid(m_awid_i),
        .m_awaddr(m_awaddr_i),
        .m_awvalid(m_awvalid_i),
        .s_awready(s_awready_i),

        .s_awlen(s_awlen_o),
        .s_awsize(s_awsize_o),
        .s_awburst(s_awburst_o),

        .s_awid(s_awid_o),
        .s_awaddr(s_awaddr_o),
        .s_awvalid(s_awvalid_o),
        .m_awready(m_awready_o),

        .xfer_data_i(wr_xfer_data_i),
        .xfer_wr_valid_i(wr_xfer_wr_valid_i),

        .awid(awid),
        .aw_total_sub_txn(aw_total_sub_txn),
        .m_aw_handshake_q1(m_aw_handshake)
      );

      // -- -- w_fifo -> sub_xfer_cnt
      upsizer_fifo #(
        .DATA_WIDTH(XFER_FF_WIDTH)
      )
      u_w_sub_xfer_cnt_fifo (
        .almost_empty_o(wr_xfer_almost_empty_o),
        .almost_full_o (wr_xfer_almost_full_o),
        .clk           (aclk),
        .rst_n         (arst_n),
        .data_i        (wr_xfer_data_i),
        .data_o        (wr_xfer_data_o),
        .empty_o       (wr_xfer_empty_o),
        .full_o        (wr_xfer_full_o),
        .rd_valid_i    (wr_xfer_rd_valid_i),
        .wr_valid_i    (wr_xfer_wr_valid_i)
      );

      // -- W channel
      w_channel #(
        .M_DATA_WIDTH(M_DATA_WIDTH),
        .S_DATA_WIDTH(S_DATA_WIDTH)
      ) u_w_channel(
        .aclk(aclk),
        .arst_n(arst_n),

        .m_wdata(m_wdata_i),
        .m_wvalid(m_wvalid_i),
        .s_wready(s_wready_i),
        .m_wlast(m_wlast_i),

        .s_wdata(s_wdata_o),
        .s_wvalid(s_wvalid_o),
        .m_wready(m_wready_o),
        .s_wlast(s_wlast_o),
        .w_done(w_done),

        .xfer_empty_o(wr_xfer_empty_o),
        .xfer_data_o(wr_xfer_data_o),
        .xfer_rd_valid_i(wr_xfer_rd_valid_i)
      );

      // -- -- awid for B channel
      awid #(
        .AWID_WIDTH(AWID_WIDTH),
        .BID_WIDTH(BID_WIDTH),
        .RESP_ARR_WIDTH(RESP_ARR_WIDTH)
      ) u_awid (
        .aclk(aclk),
        .arst_n(arst_n),

        .awid(m_awid_i),
        .total_sub_txn(aw_total_sub_txn),
        .m_aw_handshake(m_aw_handshake),

        .s_b_handshake(s_b_handshake),
        .s_bresp(s_bresp_i),
        .s_bid(s_bid_i),

        .rd_valid(rd_valid),
        .resp(resp)
      );

      // -- B channel
      b_channel #(
        .BID_WIDTH(BID_WIDTH)
      ) u_b_channel(
        .aclk(aclk),
        .arst_n(arst_n),

        .s_bid(s_bid_i),
        .s_bvalid(s_bvalid_i),
        .m_bready(m_bready_i),
        .s_bresp(s_bresp_i),

        .m_bid(m_bid_o),
        .m_bvalid(m_bvalid_o),
        .s_bready(s_bready_o),
        .m_bresp(m_bresp_o),

        .w_done(w_done),
        .rd_valid(rd_valid),
        .resp(resp),
        .s_b_handshake(s_b_handshake)
      );

      // -- AR channel
      ar_channel #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .ARID_WIDTH(ARID_WIDTH)
      ) u_ar_channel(
        .aclk(aclk),
        .arst_n(arst_n),

        .m_arlen(m_arlen_i),
        .m_arsize(m_arsize_i),
        .m_arburst(m_arburst_i),

        .m_arid(m_arid_i),
        .m_araddr(m_araddr_i),
        .m_arvalid(m_arvalid_i),
        .s_arready(s_arready_i),

        .s_arlen(s_arlen_o),
        .s_arsize(s_arsize_o),
        .s_arburst(s_arburst_o),

        .s_arid(s_arid_o),
        .s_araddr(s_araddr_o),
        .s_arvalid(s_arvalid_o),
        .m_arready(m_arready_o),

        .xfer_data_i(rd_xfer_data_i),
        .xfer_wr_valid_i(rd_xfer_wr_valid_i)
      );

      // -- -- r_fifo -> sub_xfer_cnt
      upsizer_fifo #(
        .DATA_WIDTH(RD_XFER_FF_WIDTH)
      )
      u_r_sub_xfer_cnt_fifo (
        .almost_empty_o(rd_xfer_almost_empty_o),
        .almost_full_o (rd_xfer_almost_full_o),
        .clk           (aclk),
        .rst_n         (arst_n),
        .data_i        (rd_xfer_data_i),
        .data_o        (rd_xfer_data_o),
        .empty_o       (rd_xfer_empty_o),
        .full_o        (rd_xfer_full_o),
        .rd_valid_i    (rd_xfer_rd_valid_i),
        .wr_valid_i    (rd_xfer_wr_valid_i)
      );

      // -- R channel
      r_channel #(
        .M_DATA_WIDTH(M_DATA_WIDTH),
        .S_DATA_WIDTH(S_DATA_WIDTH)
      ) u_r_channel(
        .aclk(aclk),
        .arst_n(arst_n),

        .m_rid(m_rid_o),
        .m_rdata(m_rdata_o),
        .m_rvalid(m_rvalid_o),
        .m_rready(m_rready_i),
        .m_rlast(m_rlast_o),
        .m_rresp(m_rresp_o),

        .s_rid(s_rid_i),
        .s_rdata(s_rdata_i),
        .s_rvalid(s_rvalid_i),
        .s_rready(s_rready_o),
        .s_rlast(s_rlast_i),
        .s_rresp(s_rresp_i),

        .xfer_data_o(rd_xfer_data_o),
        .xfer_rd_valid_i(rd_xfer_rd_valid_i)
      );
    end
  endgenerate
endmodule
