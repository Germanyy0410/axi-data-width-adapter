module ar_channel #(
  parameter MASTER        = 0,
  parameter SLAVE         = 1,
  parameter ARLEN         = 2,

  parameter _32_BIT       = 3'b101,
  parameter _64_BIT       = 3'b110,
  parameter _128_BIT      = 3'b111,

  parameter LEN_WIDTH     = 8,
  parameter SIZE_WIDTH    = 3,
  parameter BURST_WIDTH   = 2,
  parameter MAX_BURST_LEN = 256,
  parameter MAX_AXLEN     = 8'd255,

  parameter ADDR_WIDTH    = 32,
  parameter ARID_WIDTH    = 3,

  parameter AR_FIFO_DEPTH = 8,
  parameter FF_DATA_IN    = SIZE_WIDTH + LEN_WIDTH + BURST_WIDTH + ADDR_WIDTH
)(
  input wire                      aclk,
  input wire                      arst_n,

  input wire  [LEN_WIDTH-1:0]     m_arlen,
  input wire  [SIZE_WIDTH-1:0]    m_arsize,
  input wire  [BURST_WIDTH-1:0]   m_arburst,

  input wire  [ARID_WIDTH-1:0]    m_arid,
  input wire  [ADDR_WIDTH-1:0]    m_araddr,
  input wire                      m_arvalid,
  input wire                      s_arready,

  output reg  [LEN_WIDTH-1:0]     s_arlen,
  output reg  [SIZE_WIDTH-1:0]    s_arsize,
  output reg  [BURST_WIDTH-1:0]   s_arburst,

  output wire [ARID_WIDTH-1:0]    s_arid,
  output reg  [ADDR_WIDTH-1:0]    s_araddr,
  output reg                      s_arvalid,
  output wire                     m_arready
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

  wire [SIZE_WIDTH-1:0]   arsize;
  wire [LEN_WIDTH-1:0]    arlen;
  wire [BURST_WIDTH-1:0]  arburst;
  wire [ADDR_WIDTH-1:0]   araddr;
  wire                    ar_handshake;

  reg  [2:0]              sub_xfer_cnt;
  reg  [2:0]              sub_xfer_cnt_p;
  reg  [10:0]             total_sub_xfer;
  reg  [10:0]             total_sub_xfer_p;
  reg  [2:0]              i;
  reg  [2:0]              i_p;
  assign ar_handshake = (m_arvalid && s_arready);

  // =========================
  // ==== Module Instance ====
  // =========================
  upsizer_fifo #(
    .DATA_WIDTH(FF_DATA_IN),
    .FIFO_DEPTH(AR_FIFO_DEPTH)
  )
  u_m_ar_fifo (
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
    .FIFO_DEPTH(AR_FIFO_DEPTH)
  )
  u_s_ar_fifo (
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
    .FIFO_DEPTH(AR_FIFO_DEPTH)
  )
  u_arlen_fifo (
    .almost_empty_o(almost_empty_o[ARLEN]),
    .almost_full_o (almost_full_o[ARLEN]),
    .clk           (aclk),
    .rst_n         (arst_n),
    .data_i        (data_i[ARLEN]),
    .data_o        (data_o[ARLEN]),
    .empty_o       (empty_o[ARLEN]),
    .full_o        (full_o[ARLEN]),
    .rd_valid_i    (rd_valid_i[ARLEN]),
    .wr_valid_i    (wr_valid_i[ARLEN])
  );

  // =========================
  // ====== Output wire ======
  // =========================
  assign s_arid     = m_arid;
  assign s_arvalid  = m_arvalid;
  assign m_arready  = s_arready;

  // =====================================
  // ===== [M] Push m_addr to FIFO =======
  // =====================================
  reg [FF_DATA_IN-1:0]  m_data_out;
  reg [FF_DATA_IN-1:0]  m_data_out_p;

  assign data_i[MASTER]     = {m_arsize, m_arlen, m_arburst, m_araddr};
  assign wr_valid_i[MASTER] = m_arvalid && s_arready;
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

  assign {arsize, arlen, arburst, araddr} = m_data_out_p;

  // =====================================
  // ======= [IN] Calculate burst ========
  // =====================================
  always @(*) begin
    sub_xfer_cnt_p    = sub_xfer_cnt;
    total_sub_xfer_p  = total_sub_xfer;
    i_p               = i;

    if (rd_valid_i[MASTER]) begin
      i_p = 3'b0;
      case (arsize)
        _32_BIT: begin
          sub_xfer_cnt_p    = 3'd1;
          total_sub_xfer_p  = (arlen + 1);
        end
        _64_BIT: begin
          sub_xfer_cnt_p    = 3'd2;
          total_sub_xfer_p  = (arlen + 1) << 1;
        end
        _128_BIT: begin
          sub_xfer_cnt_p = 3'd4;
          total_sub_xfer_p  = (arlen + 1) << 2;
        end
        default: begin
          sub_xfer_cnt_p    = 3'd1;
          total_sub_xfer_p  = (arlen + 1);
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
  assign rd_valid_i[SLAVE]  = ~empty_o[SLAVE] && ar_handshake;
  assign data_i[SLAVE]      = (|total_sub_xfer_p[10:8]) ?
                              {3'b101, MAX_AXLEN            , arburst, araddr + (i_p << 2)} :
                              {3'b101, total_sub_xfer_p[7:0], arburst, araddr + (i_p << 2)};

  // =====================================
  // ====== [S] Send addr to slave =======
  // =====================================
  wire [SIZE_WIDTH-1:0]   skip_arsize;
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

  assign {skip_arsize_p, s_arlen, s_arburst, s_araddr} = split_txn_en_p ? data_o[SLAVE] : data_o[MASTER];

endmodule