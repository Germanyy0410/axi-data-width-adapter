module aw_channel #(
  parameter _32_BIT         = 3'b101,
  parameter _64_BIT         = 3'b110,
  parameter _128_BIT        = 3'b111,

  parameter LEN_WIDTH       = 8,
  parameter SIZE_WIDTH      = 3,
  parameter BURST_WIDTH     = 2,
  parameter MAX_BURST_LEN   = 256,
  parameter MAX_AXLEN       = 255,

  parameter ADDR_WIDTH      = 32,
  parameter AWID_WIDTH      = 3,

  parameter AW_FIFO_DEPTH   = 8,
  parameter FF_DATA_IN      = AWID_WIDTH + SIZE_WIDTH + LEN_WIDTH + BURST_WIDTH + ADDR_WIDTH,
  parameter XFER_D_IN       = 3,
  parameter RESP_ARR_WIDTH  = 9

)(
  input wire                        aclk              ,
  input wire                        arst_n            ,

  input wire  [LEN_WIDTH-1:0]       m_awlen           ,
  input wire  [SIZE_WIDTH-1:0]      m_awsize          ,
  input wire  [BURST_WIDTH-1:0]     m_awburst         ,

  input wire  [AWID_WIDTH-1:0]      m_awid            ,
  input wire  [ADDR_WIDTH-1:0]      m_awaddr          ,
  input wire                        m_awvalid         ,
  input wire                        s_awready         ,

  output wire [LEN_WIDTH-1:0]       s_awlen           ,
  output wire [SIZE_WIDTH-1:0]      s_awsize          ,
  output wire [BURST_WIDTH-1:0]     s_awburst         ,

  output wire [AWID_WIDTH-1:0]      s_awid            ,
  output wire [ADDR_WIDTH-1:0]      s_awaddr          ,
  output reg                        s_awvalid         ,
  output reg                        m_awready         ,

  output wire [XFER_D_IN-1:0]       xfer_data_i       ,
  output wire                       xfer_wr_valid_i   ,

  output reg  [AWID_WIDTH-1:0]      awid              ,
  output wire [2:0]                 aw_total_sub_txn  ,
  output reg                        m_aw_handshake_q1
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
  wire                    m_aw_handshake    ;
  wire                    s_aw_handshake    ;
  // -- output logic
  wire [SIZE_WIDTH-1:0]   s_awsize_p        ;
  wire                    m_awready_p       ;
  // -- split_txn logic
  wire                    split_txn_en_p    ;

  // ==========================
  // ==   reg declaration    ==
  // ==========================
  // -- output logic
  reg                     s_awvalid_p       ;
  // -- input buffer
  reg  [AWID_WIDTH-1:0]   awid_p            ;
  reg  [ADDR_WIDTH-1:0]   awaddr            ;
  reg  [ADDR_WIDTH-1:0]   awaddr_p          ;
  reg  [LEN_WIDTH-1:0]    awlen             ;
  reg  [LEN_WIDTH-1:0]    awlen_p           ;
  reg  [SIZE_WIDTH-1:0]   awsize            ;
  reg  [SIZE_WIDTH-1:0]   awsize_p          ;
  reg  [BURST_WIDTH-1:0]  awburst           ;
  reg  [BURST_WIDTH-1:0]  awburst_p         ;
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
  assign m_aw_handshake = (m_awvalid && m_awready);
  assign s_aw_handshake = (s_awvalid && s_awready);

  always @(posedge aclk) begin
    m_aw_handshake_q1 <= m_aw_handshake;
  end

  // =========================
  // ==== module instance ====
  // =========================
  upsizer_fifo #(
    .DATA_WIDTH(FF_DATA_IN),
    .FIFO_DEPTH(AW_FIFO_DEPTH)
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
  // ==      s_awsize       ==
  // =========================
  assign s_awsize = _32_BIT;

  // =========================
  // ==      m_awready      ==
  // =========================
  assign m_awready_p = m_aw_handshake ? 1'b0 : ((total_sub_xfer_p <= MAX_BURST_LEN) ? 1'b1 : m_awready);

  always @(posedge aclk or negedge arst_n) begin
    if (!arst_n) begin
      m_awready <= 0;
    end else begin
      m_awready <= m_awready_p;
    end
  end

  // =========================
  // ==      s_awvalid      ==
  // =========================
  always @(*) begin
    s_awvalid_p = s_awvalid;

    if ((s_awvalid && ~split_txn_en_p)) begin
      s_awvalid_p = 1'b0;
    end else if ((total_sub_xfer_p <= MAX_BURST_LEN && m_aw_handshake) || split_txn_en_p) begin
      s_awvalid_p = 1'b1;
    end
  end

  always @(posedge aclk or negedge arst_n) begin
    if (!arst_n) begin
      s_awvalid <= 0;
    end else begin
      s_awvalid <= s_awvalid_p;
    end
  end

  // =============================
  // ==   buffer information    ==
  // =============================
  always @(*) begin
    awid_p    = awid;
    awaddr_p  = awaddr;
    awsize_p  = awsize;
    awlen_p   = awlen;
    awburst_p = awburst;
    if (m_aw_handshake) begin
      awid_p    = m_awid;
      awaddr_p  = m_awaddr;
      awsize_p  = m_awsize;
      awlen_p   = m_awlen;
      awburst_p = m_awburst;
    end
  end

  always @(posedge aclk or negedge arst_n) begin
    if (!arst_n) begin
      awid    <= 0;
      awaddr  <= 0;
      awsize  <= 0;
      awlen   <= 0;
      awburst <= 0;
    end else begin
      awid    <= awid_p;
      awaddr  <= awaddr_p;
      awsize  <= awsize_p;
      awlen   <= awlen_p;
      awburst <= awburst_p;
    end
  end

  // ======================================
  // ==         data structure           ==
  // ==   [id][size][len][burst][addr]   ==
  // ======================================
  assign m_data_i = { awid, awsize, total_sub_xfer - 1, awburst, awaddr };

  // ===============================
  // ==     burst calculation     ==
  // ===============================
  always @(*) begin
    sub_xfer_cnt_p    = sub_xfer_cnt;
    total_sub_xfer_p  = total_sub_xfer;
    total_sub_txn_p   = total_sub_txn;
    i_p               = i;

    if (m_aw_handshake) begin
      i_p = 3'b0;
      case (awsize_p)
        _32_BIT: begin
          sub_xfer_cnt_p    = 3'd1;
          total_sub_xfer_p  = (awlen_p + 1);
        end
        _64_BIT: begin
          sub_xfer_cnt_p    = 3'd2;
          total_sub_xfer_p  = {1'b0, awlen_p + 1};
        end
        _128_BIT: begin
          sub_xfer_cnt_p    = 3'd4;
          total_sub_xfer_p  = {2'b00, awlen_p + 1};
        end
        default: begin
          sub_xfer_cnt_p    = 3'd1;
          total_sub_xfer_p  = {3'b000, awlen_p + 1};
        end
      endcase
      total_sub_txn_p = {8'b0, total_sub_xfer_p} + 1;
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
  assign xfer_data_i      = sub_xfer_cnt_p;
  assign xfer_wr_valid_i  = m_aw_handshake;
  // -- B
  assign aw_total_sub_txn = total_sub_txn;

  // =================================
  // ==    split transaction(s)     ==
  // =================================
  always @(*) begin
    wr_valid_logic_p = wr_valid_logic;

    if (total_sub_xfer <= MAX_BURST_LEN && total_sub_xfer > 0 && ~m_aw_handshake) begin
      wr_valid_logic_p = 1'b0;
    end else if (m_aw_handshake && ~wr_valid_logic) begin
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
  assign rd_valid  = ~empty_o && s_aw_handshake;
  assign data_i      = (|total_sub_xfer_p[10:8]) ?
                        { awid_p, 3'b101, MAX_AXLEN                 , awburst_p, awaddr_p + (i_p << 2) } :
                        { awid_p, 3'b101, total_sub_xfer_p[7:0] - 1 , awburst_p, awaddr_p + (i_p << 2) } ;

  // ===============================
  // ==    send addr to slave     ==
  // ===============================
  assign split_txn_en_p = m_aw_handshake ? (~(total_sub_xfer_p <= MAX_BURST_LEN)) : split_txn_en;

  always @(posedge aclk or negedge arst_n) begin
    if (!arst_n) begin
      split_txn_en <= 1'b0;
    end else begin
      split_txn_en <= split_txn_en_p;
    end
  end

  assign {s_awid, s_awsize_p, s_awlen, s_awburst, s_awaddr} = split_txn_en ? data_o : m_data_i;
endmodule