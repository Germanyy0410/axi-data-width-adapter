module w_channel #(
  parameter MAX_BURST_LEN   = 256,
  parameter M_DATA_WIDTH    = 128,
  parameter S_DATA_WIDTH    = 32,
  parameter MAX_SUB_TRANS   = M_DATA_WIDTH / S_DATA_WIDTH,
  parameter W_FIFO_DEPTH    = 8
)(
  input                             aclk,
  input                             arst_n,

  input wire  [M_DATA_WIDTH-1:0]    m_wdata,
  input wire                        m_wvalid,
  input wire                        s_wready,
  input wire                        m_wlast,

  output reg  [S_DATA_WIDTH-1:0]    s_wdata,
  output reg                        s_wvalid,
  output wire                       m_wready,
  output reg                        s_wlast,

  input  wire                       new_trans,
  output wire                       wr_last_xfer,
  output wire [2:0]                 sub_xfer_cnt
);

  // =========================
  // ==== Internal signal ====
  // =========================
  wire                      clk;
  wire                      rst_n;
  wire  [M_DATA_WIDTH-1:0]  data_i;
  wire  [M_DATA_WIDTH-1:0]  data_o;
  wire                      wr_valid_i;
  wire                      rd_valid_i;
  wire                      almost_empty_o;
  wire                      empty_o;
  wire                      almost_full_o;
  wire                      full_o;

  wire                      w_handshake;
  wire                      wr_last_sub_xfer;

  reg   [S_DATA_WIDTH-1:0]  s_wdata_p;
  reg   [S_DATA_WIDTH-1:0]  s_wdata_arr [MAX_SUB_TRANS-1:0];
  reg   [MAX_SUB_TRANS-1:0] idx;
  reg   [MAX_SUB_TRANS-1:0] idx_p;
  reg                       s_wvalid_p;
  reg                       s_wlast_p;

  upsizer_fifo #(
    .DATA_WIDTH(M_DATA_WIDTH),
    .FIFO_DEPTH(W_FIFO_DEPTH)
  )
  u_wdata_fifo (
    .almost_empty_o(almost_empty_o),
    .almost_full_o (almost_full_o),
    .clk           (aclk),
    .rst_n         (arst_n),
    .data_i        (data_i),
    .data_o        (data_o),
    .empty_o       (empty_o),
    .full_o        (full_o),
    .rd_valid_i    (rd_valid_i),
    .wr_valid_i    (wr_valid_i)
  );

  assign w_handshake        = (m_wvalid && s_wready);
  assign sub_xfer_cnt       = M_DATA_WIDTH / S_DATA_WIDTH;

  // -- send wlast to b channel
  assign wr_last_sub_xfer   = (idx == (sub_xfer_cnt - 1));
  assign wr_last_xfer   = (m_wlast && w_handshake && wr_last_sub_xfer);
  b_channel u_b_channel (
    .wr_last_sub_xfer(wr_last_sub_xfer),
    .wr_last_xfer(wr_last_xfer)
  );

  // =========================
  // ====== Output wire ======
  // =========================
  assign s_wvalid  = m_wvalid;
  assign m_wready  = s_wready;

  // =====================================
  // ===== [M] Push m_wdata to FIFO ======
  // =====================================
  assign data_i     = m_wdata;
  assign wr_valid_i = m_wvalid && s_wready;

  reg rd_valid;
  reg rd_valid_p;

  always @(*) begin
    rd_valid_p = rd_valid;

    if (wr_last_sub_xfer && !empty_o) begin
      rd_valid_p = 1'b1;
    end else if (!empty_o) begin
      rd_valid_p = 1'b0;
    end
  end

  always @(posedge aclk) begin
    if (!arst_n) begin
      rd_valid <= 1'b1;
    end else begin
      rd_valid <= rd_valid_p;
    end
  end

  assign rd_valid_i = rd_valid;

  reg [M_DATA_WIDTH-1:0] wdata;
  reg [M_DATA_WIDTH-1:0] wdata_p;

  always @(*) begin
    wdata_p = wdata;
    if (rd_valid_i) wdata_p = data_o;
  end

  always @(posedge aclk) begin
    if (!arst_n) begin
      wdata <= 0;
    end else begin
      wdata <= wdata_p;
    end
  end

  // =====================================
  // ========= [IN] Split wdata ==========
  // =====================================
  genvar i;
  generate
    for (i = 0; i < MAX_SUB_TRANS; i = i + 1) begin
      assign s_wdata_arr[MAX_SUB_TRANS-i-1] = wdata_p[(i+1)*S_DATA_WIDTH-1 : i*S_DATA_WIDTH];
    end
  endgenerate

  // -- -- [idx]
  always @(*) begin
    idx_p = idx;

    if (wr_last_sub_xfer && w_handshake) begin
      idx_p = 0;
    end else if ((w_handshake && idx) || (!idx && !rd_valid_i)) begin
      idx_p = idx + 1;
    end
  end

  always @(posedge aclk) begin
    if (!arst_n) begin
      idx <= {MAX_SUB_TRANS{1'b0}};
    end else begin
      idx <= idx_p;
    end
  end

  // =====================================
  // ======== [S] Get wdata[31:0] ========
  // =====================================
  reg [7:0] s_xfer_cnt;
  reg [7:0] s_xfer_cnt_p;

  always @(*) begin
    s_wdata_p     = s_wdata;
    s_xfer_cnt_p  = s_xfer_cnt;

    if ((idx_p && w_handshake) || (!idx_p && rd_valid && w_handshake)) begin
      s_wdata_p     = s_wdata_arr[idx_p];
      s_xfer_cnt_p  = s_xfer_cnt + 1'b1;
    end else if (m_wlast) begin
      s_xfer_cnt_p = 0;
    end
  end

  always @(posedge aclk) begin
    if (!arst_n) begin
      s_xfer_cnt  <= 8'b0;
      s_wdata     <= {M_DATA_WIDTH{1'b0}};
    end else begin
      s_xfer_cnt  <= s_xfer_cnt_p;
      s_wdata     <= s_wdata_p;
    end
  end

  // =====================================
  // ========== [S] Drive wlast ==========
  // =====================================
  always @(*) begin
    s_wlast_p = s_wlast;

    if ((m_wlast && wr_last_sub_xfer) || (s_xfer_cnt == MAX_BURST_LEN - 1)) begin
      s_wlast_p = 1'b1;
    end else if (s_wlast && w_handshake) begin
      s_wlast_p = 1'b0;
    end
  end

  always @(posedge aclk) begin
    if (!arst_n) begin
      s_wlast <= 1'b0;
    end else begin
      s_wlast <= s_wlast_p;
    end
  end
endmodule