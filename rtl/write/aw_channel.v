module aw_channel #(
  parameter MASTER        = 0,
  parameter SLAVE         = 1,
  parameter AWLEN         = 2,

  parameter _32_BIT       = 3'b101,
  parameter _64_BIT       = 3'b110,
  parameter _128_BIT      = 3'b111,

  parameter LEN_WIDTH     = 8,
  parameter SIZE_WIDTH    = 3,
  parameter BURST_WIDTH   = 2,
  parameter MAX_BURST_LEN = 256,
  parameter MAX_AXLEN     = 8'd255,

  parameter ADDR_WIDTH    = 32,
  parameter AWID_WIDTH    = 3,

  parameter AW_FIFO_DEPTH = 8,
  parameter FF_DATA_IN    = SIZE_WIDTH + LEN_WIDTH + BURST_WIDTH + ADDR_WIDTH
)(
  input wire                      aclk,
  input wire                      arst_n,

  input wire  [LEN_WIDTH-1:0]     m_awlen,
  input wire  [SIZE_WIDTH-1:0]    m_awsize,
  input wire  [BURST_WIDTH-1:0]   m_awburst,

  input wire  [AWID_WIDTH-1:0]    m_awid,
  input wire  [ADDR_WIDTH-1:0]    m_awaddr,
  input wire                      m_awvalid,
  input wire                      s_awready,

  output reg  [LEN_WIDTH-1:0]     s_awlen,
  output reg  [SIZE_WIDTH-1:0]    s_awsize,
  output reg  [BURST_WIDTH-1:0]   s_awburst,

  output wire [AWID_WIDTH-1:0]    s_awid,
  output reg  [ADDR_WIDTH-1:0]    s_awaddr,
  output reg                      s_awvalid,
  output wire                     m_awready
);
  // =========================
  // ==== Internal signal ====
  // =========================
  wire                    clk             [2:0];
  wire                    rst_n           [2:0];
  wire [FF_DATA_IN-1:0]   data_i          [2:0];
  wire [FF_DATA_IN-1:0]   data_o          [2:0];
  wire                    wr_valid_i      [2:0];
  wire                    rd_valid_i      [2:0];
  wire                    almost_empty_o  [2:0];
  wire                    empty_o         [2:0];
  wire                    almost_full_o   [2:0];
  wire                    full_o          [2:0];

  wire [SIZE_WIDTH-1:0]   awsize;
  wire [LEN_WIDTH-1:0]    awlen;
  wire [BURST_WIDTH-1:0]  awburst;
  wire [ADDR_WIDTH-1:0]   awaddr;
  wire                    aw_handshake;

  reg  [2:0]              sub_xfer_cnt;
  reg  [2:0]              sub_xfer_cnt_p;
  reg  [10:0]             total_sub_xfer;
  reg  [10:0]             total_sub_xfer_p;
  reg  [2:0]              i;
  reg  [2:0]              i_p;
  assign aw_handshake = (m_awvalid && s_awready);

  // =========================
  // ==== Module Instance ====
  // =========================
  upsizer_fifo #(
    .DATA_WIDTH(FF_DATA_IN),
    .FIFO_DEPTH(AW_FIFO_DEPTH)
  )
  u_m_aw_fifo (
    .almost_empty_o(almost_empty_o[MASTER]),
    .almost_full_o (almost_full_o[MASTER]),
    .clk           (aclk),
    .rst_n         (arst_n),
    .data_i        (data_i[MASTER]),
    .data_o        (data_o[MASTER]),
    .empty_o       (empty_o[MASTER]),
    .full_o        (full_o[MASTER]),
    .rd_valid_i    (rd_valid_i[MASTER]),
    .wr_valid_i    (wr_valid_i[MASTER])
  );

  upsizer_fifo #(
    .DATA_WIDTH(FF_DATA_IN),
    .FIFO_DEPTH(AW_FIFO_DEPTH)
  )
  u_s_aw_fifo (
    .almost_empty_o(almost_empty_o[SLAVE]),
    .almost_full_o (almost_full_o[SLAVE]),
    .clk           (aclk),
    .rst_n         (arst_n),
    .data_i        (data_i[SLAVE]),
    .data_o        (data_o[SLAVE]),
    .empty_o       (empty_o[SLAVE]),
    .full_o        (full_o[SLAVE]),
    .rd_valid_i    (rd_valid_i[SLAVE]),
    .wr_valid_i    (wr_valid_i[SLAVE])
  );

  upsizer_fifo #(
    .DATA_WIDTH(LEN_WIDTH),
    .FIFO_DEPTH(AW_FIFO_DEPTH)
  )
  u_awlen_fifo (
    .almost_empty_o(almost_empty_o[AWLEN]),
    .almost_full_o (almost_full_o[AWLEN]),
    .clk           (aclk),
    .rst_n         (arst_n),
    .data_i        (data_i[AWLEN]),
    .data_o        (data_o[AWLEN]),
    .empty_o       (empty_o[AWLEN]),
    .full_o        (full_o[AWLEN]),
    .rd_valid_i    (rd_valid_i[AWLEN]),
    .wr_valid_i    (wr_valid_i[AWLEN])
  );

  // =========================
  // ====== Output wire ======
  // =========================
  assign s_awid     = m_awid;
  assign s_awvalid  = m_awvalid;
  assign m_awready  = s_awready;

  // =====================================
  // ===== [M] Push m_addr to FIFO =======
  // =====================================
  reg [FF_DATA_IN-1:0]  m_data_out;
  reg [FF_DATA_IN-1:0]  m_data_out_p;

  assign data_i[MASTER]     = {m_awsize, m_awlen, m_awburst, m_awaddr};
  assign wr_valid_i[MASTER] = m_awvalid && s_awready;
  assign rd_valid_i[MASTER] = (total_sub_xfer <= MAX_BURST_LEN) ? 1'b1 : 1'b0;

  // -- data_o
  always @(*) begin
    m_data_out_p = m_data_out;
    if (rd_valid_i[MASTER]) m_data_out_p = data_o[MASTER];
  end

  always @(posedge aclk) begin
    if (!arst_n) m_data_out <= 0;
    else m_data_out <= m_data_out_p;
  end

  assign {awsize, awlen, awburst, awaddr} = m_data_out_p;

  // =====================================
  // ======= [IN] Calculate burst ========
  // =====================================
  always @(*) begin
    sub_xfer_cnt_p    = sub_xfer_cnt;
    total_sub_xfer_p  = total_sub_xfer;
    i_p               = i;

    if (rd_valid_i[MASTER]) begin
      i_p = 3'b0;
      case (awsize)
        _32_BIT: begin
          sub_xfer_cnt_p    = 3'd1;
          total_sub_xfer_p  = (awlen + 1);
        end
        _64_BIT: begin
          sub_xfer_cnt_p    = 3'd2;
          total_sub_xfer_p  = (awlen + 1) << 1;
        end
        _128_BIT: begin
          sub_xfer_cnt_p = 3'd4;
          total_sub_xfer_p  = (awlen + 1) << 2;
        end
        default: begin
          sub_xfer_cnt_p    = 3'd1;
          total_sub_xfer_p  = (awlen + 1);
        end
      endcase
    end else if (|total_sub_xfer[10:8]) begin
      total_sub_xfer_p  = total_sub_xfer - MAX_BURST_LEN;
      i_p               = i + 1;
    end
  end

  always @(posedge aclk) begin
    if (!arst_n) begin
      sub_xfer_cnt    <= 3'd1;
      total_sub_xfer  <= 11'd0;
      i               <= 3'b0;
    end else begin
      sub_xfer_cnt    <= sub_xfer_cnt_p;
      total_sub_xfer  <= total_sub_xfer_p;
      i               <= i_p;
    end
  end

  // =====================================
  // ==== [IN] Split transaction(s) ======
  // =====================================
  reg s_wr_valid_i;
  reg s_wr_valid_i_p;

  always @(*) begin
    s_wr_valid_i_p = s_wr_valid_i;
    if (rd_valid_i[MASTER] && ~s_wr_valid_i) begin
      s_wr_valid_i_p = 1'b1;
    end
  end

  always @(posedge aclk) begin
    if (!arst_n) begin
      s_wr_valid_i <= 1'b0;
    end else begin
      s_wr_valid_i <= s_wr_valid_i_p;
    end
  end

  assign wr_valid_i[SLAVE]  = s_wr_valid_i_p;
  assign rd_valid_i[SLAVE]  = ~empty_o[SLAVE] && aw_handshake;
  assign data_i[SLAVE]      = (|total_sub_xfer_p[10:8]) ?
                              {3'b101, MAX_AXLEN            , awburst, awaddr + (i_p << 2)} :
                              {3'b101, total_sub_xfer_p[7:0], awburst, awaddr + (i_p << 2)};

  // =====================================
  // ====== [S] Send addr to slave =======
  // =====================================
  wire [SIZE_WIDTH-1:0]   skip_awsize;
  reg                     split_txn_en;
  reg                     split_txn_en_p;

  always @(*) begin
    split_txn_en_p = split_txn_en;
    if (rd_valid_i[MASTER] && total_sub_xfer_p <= MAX_BURST_LEN) begin
      split_txn_en_p = 1'b0;
    end else if (rd_valid_i[MASTER] && total_sub_xfer_p > MAX_BURST_LEN) begin
      split_txn_en_p = 1'b1;
    end
  end

  always @(posedge aclk) begin
    if (!arst_n) begin
      split_txn_en <= 1'b0;
    end else begin
      split_txn_en <= split_txn_en_p;
    end
  end

  assign {skip_awsize_p, s_awlen, s_awburst, s_awaddr} = split_txn_en_p ? data_o[SLAVE] : data_o[MASTER];

endmodule