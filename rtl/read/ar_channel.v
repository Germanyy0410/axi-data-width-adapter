module ar_channel #(
  parameter _32_BIT         = 3'b101,
  parameter _64_BIT         = 3'b110,
  parameter _128_BIT        = 3'b111,

  parameter LEN_WIDTH       = 8,
  parameter SIZE_WIDTH      = 3,
  parameter BURST_WIDTH     = 2,
  parameter MAX_BURST_LEN   = 256,
  parameter MAX_AXLEN       = 255,

  parameter ADDR_WIDTH      = 32,
  parameter ARID_WIDTH      = 3,

  parameter AR_FIFO_DEPTH   = 8,
  parameter FF_DATA_IN      = ARID_WIDTH + SIZE_WIDTH + LEN_WIDTH + BURST_WIDTH + ADDR_WIDTH,
  parameter XFER_D_IN       = 6,
  parameter RESP_ARR_WIDTH  = 9

)(
  input wire                        aclk,
  input wire                        arst_n,

  input wire  [LEN_WIDTH-1:0]       m_arlen,
  input wire  [SIZE_WIDTH-1:0]      m_arsize,
  input wire  [BURST_WIDTH-1:0]     m_arburst,

  input wire  [ARID_WIDTH-1:0]      m_arid,
  input wire  [ADDR_WIDTH-1:0]      m_araddr,
  input wire                        m_arvalid,
  input wire                        s_arready,

  output wire [LEN_WIDTH-1:0]       s_arlen,
  output wire [SIZE_WIDTH-1:0]      s_arsize,
  output wire [BURST_WIDTH-1:0]     s_arburst,

  output wire [ARID_WIDTH-1:0]      s_arid,
  output wire [ADDR_WIDTH-1:0]      s_araddr,
  output reg                        s_arvalid,
  output reg                        m_arready,

  output wire [XFER_D_IN-1:0]       xfer_data_i,
  output wire                       xfer_wr_valid_i
);
  // ==========================
  // ==   wire declaration   ==
  // ==========================
  // -- fifo ports
wire [FF_DATA_IN-1:0]   data_i            ;
wire [FF_DATA_IN-1:0]   data_o            ;
wire                    wr_valid          ;
wire                    rd_valid          ;
wire                    empty_o           ;
wire                    full_o            ;
// -- input buffer
wire [FF_DATA_IN-1:0]   m_data_i          ;
// -- handshake
wire                    m_ar_handshake    ;
wire                    s_ar_handshake    ;
// -- output logic
wire [SIZE_WIDTH-1:0]   s_arsize_p        ;
wire                    m_arready_p       ;
// -- split_txn logic
wire                    split_txn_en_p    ;

// ==========================
// ==   reg declaration    ==
// ==========================
// -- output logic
reg                     s_arvalid_p       ;
// -- input buffer
reg  [ARID_WIDTH-1:0]   arid              ;
reg  [ARID_WIDTH-1:0]   arid_p            ;
reg  [ADDR_WIDTH-1:0]   araddr            ;
reg  [ADDR_WIDTH-1:0]   araddr_p          ;
reg  [LEN_WIDTH-1:0]    arlen             ;
reg  [LEN_WIDTH-1:0]    arlen_p           ;
reg  [SIZE_WIDTH-1:0]   arsize            ;
reg  [SIZE_WIDTH-1:0]   arsize_p          ;
reg  [BURST_WIDTH-1:0]  arburst           ;
reg  [BURST_WIDTH-1:0]  arburst_p         ;
// -- burst calc
reg  [2:0]              sub_xfer_cnt      ;
reg  [2:0]              sub_xfer_cnt_p    ;
reg  [10:0]             total_sub_xfer    ;
reg  [10:0]             total_sub_xfer_p  ;
reg  [2:0]              total_sub_txn     ;
reg  [2:0]              total_sub_txn_p   ;
reg  [2:0]              i                 ;
reg  [2:0]              i_p               ;
// -- split_txn reg
reg                     split_txn_en      ;
// -- wr_valid logic
reg                     wr_valid_logic    ;
reg                     wr_valid_logic_p  ;


// =========================
// ==   wire assignment   ==
// =========================
assign m_ar_handshake = (m_arvalid && m_arready);
assign s_ar_handshake = (s_arvalid && s_arready);

// =========================
// ==== module instance ====
// =========================
upsizer_fifo #(
  .DATA_WIDTH(FF_DATA_IN),
  .FIFO_DEPTH(AR_FIFO_DEPTH)
)
u_s_aw_fifo (
  .clk           (aclk),
  .rst_n         (arst_n),
  .data_i        (data_i),
  .data_o        (data_o),
  .full_o        (full_o),
  .empty_o       (empty_o),
  .rd_valid_i    (rd_valid),
  .wr_valid_i    (wr_valid)
);

// =========================
// ==      s_arsize       ==
// =========================
assign s_arsize = _32_BIT;

// =========================
// ==      m_arready      ==
// =========================
assign m_arready_p = m_ar_handshake ? 1'b0 : ((total_sub_xfer_p <= MAX_BURST_LEN) ? 1'b1 : m_arready);

always @(posedge aclk or negedge arst_n) begin
  if (!arst_n) begin
    m_arready <= 0;
  end else begin
    m_arready <= m_arready_p;
  end
end

// =========================
// ==      s_arvalid      ==
// =========================
always @(*) begin
  s_arvalid_p = s_arvalid;

  if ((s_arvalid && ~split_txn_en_p)) begin
    s_arvalid_p = 1'b0;
  end else if ((total_sub_xfer_p <= MAX_BURST_LEN && m_ar_handshake) || split_txn_en_p) begin
    s_arvalid_p = 1'b1;
  end
end

always @(posedge aclk or negedge arst_n) begin
  if (!arst_n) begin
    s_arvalid <= 0;
  end else begin
    s_arvalid <= s_arvalid_p;
  end
end

// =============================
// ==   buffer information    ==
// =============================
always @(*) begin
  arid_p    = arid;
  araddr_p  = araddr;
  arsize_p  = arsize;
  arlen_p   = arlen;
  arburst_p = arburst;
  if (m_ar_handshake) begin
    arid_p    = m_arid;
    araddr_p  = m_araddr;
    arsize_p  = m_arsize;
    arlen_p   = m_arlen;
    arburst_p = m_arburst;
  end
end

always @(posedge aclk or negedge arst_n) begin
  if (!arst_n) begin
    arid    <= 0;
    araddr  <= 0;
    arsize  <= 0;
    arlen   <= 0;
    arburst <= 0;
  end else begin
    arid    <= arid_p;
    araddr  <= araddr_p;
    arsize  <= arsize_p;
    arlen   <= arlen_p;
    arburst <= arburst_p;
  end
end

// ======================================
// ==         data structure           ==
// ==   [id][size][len][burst][addr]   ==
// ======================================
assign m_data_i = { arid, arsize, total_sub_xfer - 1, arburst, araddr };

// ===============================
// ==     burst calculation     ==
// ===============================
always @(*) begin
  sub_xfer_cnt_p    = sub_xfer_cnt;
  total_sub_xfer_p  = total_sub_xfer;
  total_sub_txn_p   = total_sub_txn;
  i_p               = i;

  if (m_ar_handshake) begin
    i_p = 3'b0;
    case (arsize_p)
      _32_BIT: begin
        sub_xfer_cnt_p    = 3'd1;
        total_sub_xfer_p  = (arlen_p + 1);
      end
      _64_BIT: begin
        sub_xfer_cnt_p    = 3'd2;
        total_sub_xfer_p  = (arlen_p + 1) << 1;
      end
      _128_BIT: begin
        sub_xfer_cnt_p    = 3'd4;
        total_sub_xfer_p  = (arlen_p + 1) << 2;
      end
      default: begin
        sub_xfer_cnt_p    = 3'd1;
        total_sub_xfer_p  = (arlen_p + 1);
      end
    endcase
    total_sub_txn_p = (total_sub_xfer_p) / 256 + 1;
  end else if (|total_sub_xfer[10:8]) begin
    total_sub_xfer_p  = total_sub_xfer - MAX_BURST_LEN;
    i_p               = i + 1;
  end
end

always @(posedge aclk or negedge arst_n) begin
  if (!arst_n) begin
    sub_xfer_cnt    <= 3'd1;
    total_sub_xfer  <= 11'd0;
    total_sub_txn   <= 3'd1;
    i               <= 3'b0;
  end else begin
    sub_xfer_cnt    <= sub_xfer_cnt_p;
    total_sub_xfer  <= total_sub_xfer_p;
    total_sub_txn   <= total_sub_txn_p;
    i               <= i_p;
  end
end

// ===============================
// ==  [W & B] send xfer_data   ==
// ===============================
// -- W
assign xfer_data_i      = {sub_xfer_cnt_p, total_sub_txn_p};
assign xfer_wr_valid_i  = m_ar_handshake;

// =================================
// ==    split transaction(s)     ==
// =================================
always @(*) begin
  wr_valid_logic_p = wr_valid_logic;

  if (total_sub_xfer <= MAX_BURST_LEN && total_sub_xfer > 0 && ~m_ar_handshake) begin
    wr_valid_logic_p = 1'b0;
  end else if (m_ar_handshake && ~wr_valid_logic) begin
    wr_valid_logic_p = 1'b1;
  end
end

always @(posedge aclk or negedge arst_n) begin
  if (!arst_n) begin
    wr_valid_logic <= 1'b0;
  end else begin
    wr_valid_logic <= wr_valid_logic_p;
  end
end

assign wr_valid  = wr_valid_logic_p;
assign rd_valid  = ~empty_o && s_ar_handshake;
assign data_i      = (|total_sub_xfer_p[10:8]) ?
                      { arid_p, 3'b101, MAX_AXLEN                 , arburst_p, araddr_p + (i_p << 2) } :
                      { arid_p, 3'b101, total_sub_xfer_p[7:0] - 1 , arburst_p, araddr_p + (i_p << 2) } ;

// ===============================
// ==    send addr to slave     ==
// ===============================
assign split_txn_en_p = m_ar_handshake ? (~(total_sub_xfer_p <= MAX_BURST_LEN)) : split_txn_en;

always @(posedge aclk or negedge arst_n) begin
  if (!arst_n) begin
    split_txn_en <= 1'b0;
  end else begin
    split_txn_en <= split_txn_en_p;
  end
end

assign {s_arid, s_arsize_p, s_arlen, s_arburst, s_araddr} = split_txn_en ? data_o : m_data_i;
endmodule