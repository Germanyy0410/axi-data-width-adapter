module b_channel #(
  parameter AWID_WIDTH      = 3,
  parameter BID_WIDTH       = 3,
  parameter BRESP_WIDTH     = 2,
  parameter STATUS_WIDTH    = 0,
  parameter SUB_XFER_CNT    = 3,
  parameter AWID            = 5,
  parameter RESP_ARR_WIDTH  = 9
)(
  input                             aclk,
  input                             arst_n,

  input wire  [BID_WIDTH-1:0]       s_bid,
  input wire                        s_bvalid,
  input wire                        m_bready,
  input wire  [BRESP_WIDTH-1:0]     s_bresp,

  output reg  [BID_WIDTH-1:0]       m_bid,
  output reg                        m_bvalid,
  output reg                        s_bready,
  output reg  [BRESP_WIDTH-1:0]     m_bresp,

  input wire                        w_done,
  input wire                        rd_valid,
  input wire [RESP_ARR_WIDTH-1:0]   resp,
  output wire                       s_b_handshake
);

  // ==============================
  // ==   internal declaration   ==
  // ==============================
  wire                      m_b_handshake;
  wire  [BRESP_WIDTH-1:0]   m_bresp_p;

  reg                       m_bvalid_p;
  reg                       s_bready_p;
  wire  [BID_WIDTH-1:0]     m_bid_p;
  reg                       s_wlast_q1;

  // =========================
  // ==   wire assignment   ==
  // =========================
  assign s_b_handshake  = (s_bvalid && s_bready);
  assign m_b_handshake  = (m_bvalid && m_bready);

  // ===========================
  // ==        m_bid          ==
  // ===========================
  assign m_bid_p = (rd_valid) ? resp[8:6] : m_bid;

  always @(posedge aclk or negedge arst_n) begin
    if (!arst_n) begin
      m_bid <= 0;
    end else begin
      m_bid <= m_bid_p;
    end
  end

  // ===========================
  // ==       m_bvalid        ==
  // ===========================
  always @(*) begin
    m_bvalid_p = m_bvalid;
    if (rd_valid) begin
      m_bvalid_p = 1'b1;
    end else if (m_b_handshake) begin
      m_bvalid_p = 1'b0;
    end
  end

  always @(posedge aclk or negedge arst_n) begin
    if (!arst_n) begin
      m_bvalid <= 0;
    end else begin
      m_bvalid <= m_bvalid_p;
    end
  end

  // ===========================
  // ==       s_bready        ==
  // ===========================
  always @(*) begin
    s_bready_p = s_bready;
    if (w_done) begin
      s_bready_p = 1'b1;
    end else if (s_b_handshake) begin
      s_bready_p = 1'b0;
    end
  end

  always @(posedge aclk or negedge arst_n) begin
    if (!arst_n) begin
      s_bready <= 1'b1;
    end else begin
      s_bready <= s_bready_p;
    end
  end

  // ===========================
  // ==        m_bresp        ==
  // ===========================
  assign m_bresp_p = (rd_valid) ? resp[2:1] : m_bresp;

  always @(posedge aclk or negedge arst_n) begin
    if (!arst_n) begin
      m_bresp <= 2'b00;
    end else begin
      m_bresp <= m_bresp_p;
    end
  end
endmodule