module b_channel #(
  parameter BID_WIDTH = 3
)(
  input                           aclk,
  input                           arst_n,

  input wire  [BID_WIDTH-1:0]     s_bid,
  input wire                      s_bvalid,
  input wire                      m_bready,
  input wire  [1:0]               s_bresp,

  output wire [BID_WIDTH-1:0]     m_bid,
  output reg                      m_bvalid,
  output reg                      s_bready,
  output reg  [1:0]               m_bresp,

  input  wire                     wr_last_sub_xfer,
  input  wire                     wr_last_xfer
);
  // =========================
  // ==== Internal signal ====
  // =========================
  wire          m_b_handshake;
  wire          s_b_handshake;
  reg           m_bvalid_p;
  reg           bvalid_en;
  reg           bvalid_en_p;
  reg           s_bready_p;
  reg   [1:0]   m_bresp_hold;
  reg   [1:0]   m_bresp_hold_p;
  reg   [1:0]   m_bresp_p;

  assign m_bid          = s_bid;
  assign s_b_handshake  = (s_bvalid && s_bready);
  assign m_b_handshake  = (m_bvalid && m_bready);

  // =====================================
  // ===== [S] Only send last_bvalid =====
  // =====================================
  always @(*) begin
    bvalid_en_p = bvalid_en;
    if (wr_last_xfer) bvalid_en_p = 1'b1;
    else if (m_b_handshake) bvalid_en_p = 1'b0;
  end

  always @(posedge aclk) begin
    if (!arst_n) begin
      bvalid_en <= 0;
    end else begin
      bvalid_en <= bvalid_en_p;
    end
  end

  always @(*) begin
    m_bvalid_p = m_bvalid;
    if (bvalid_en) m_bvalid_p = s_bvalid;
  end

  always @(posedge aclk) begin
    if (!arst_n) begin
      m_bvalid <= 0;
    end else begin
      m_bvalid <= m_bvalid_p;
    end
  end

  // =====================================
  // ======= [IN] Assert s_bready ========
  // =====================================
  always @(*) begin
    s_bready_p = s_bready;
    if (m_bready) begin
      s_bready_p = m_bready;
    end else if (s_b_handshake) begin
      s_bready_p = 1'b0;
    end else if (wr_last_sub_xfer) begin
      s_bready_p = 1'b1;
    end
  end

  always @(posedge aclk) begin
    if (!arst_n) begin
      s_bready <= 1'b0;
    end else begin
      s_bready <= s_bready_p;
    end
  end

  // =====================================
  // ======== [S] Hold s_bresp ===========
  // =====================================
  always @(*) begin
    m_bresp_hold_p  = m_bresp_hold;
    m_bresp_p       = m_bresp;

    if (s_b_handshake && s_bresp[1]) begin
      m_bresp_hold_p = s_bresp;
    end

    if (m_b_handshake) begin
      m_bresp_p = m_bresp_hold;
    end
  end

  always @(posedge aclk) begin
    if (!arst_n) begin
      m_bresp_hold  <= 2'b00;
      m_bresp       <= 2'b00;

    end else begin
      m_bresp_hold  <= m_bresp_hold_p;
      m_bresp       <= m_bresp_p;
    end
  end
endmodule