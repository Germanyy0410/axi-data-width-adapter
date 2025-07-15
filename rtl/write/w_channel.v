module w_channel #(
  parameter MAX_BURST_LEN   = 256,
  parameter M_DATA_WIDTH    = 128,
  parameter S_DATA_WIDTH    = 32,
  parameter MAX_SUB_TRANS   = M_DATA_WIDTH / S_DATA_WIDTH,
  parameter W_FIFO_DEPTH    = 8,
  parameter XFER_D_IN       = 3
)(
  input wire                        aclk            ,
  input wire                        arst_n          ,

  input wire  [M_DATA_WIDTH-1:0]    m_wdata         ,
  input wire                        m_wvalid        ,
  input wire                        s_wready        ,
  input wire                        m_wlast         ,

  output reg  [S_DATA_WIDTH-1:0]    s_wdata         ,
  output reg                        s_wvalid        ,
  output reg                        m_wready        ,
  output reg                        s_wlast         ,

  output wire                       wr_last_xfer    ,
  output reg                        w_done          ,

  input wire  [XFER_D_IN-1:0]       xfer_data_o     ,
  input wire                        xfer_empty_o    ,
  output wire                       xfer_rd_valid_i
);

  // ==========================
  // ==   wire declaration   ==
  // ==========================
  wire                      m_w_handshake                           ;
  wire                      s_w_handshake                           ;
  wire                      wr_last_sub_xfer                        ;
  wire  [XFER_D_IN-1:0]     sub_xfer_cnt_p                          ;
  wire                      s_new_data_en                           ;
  wire  [S_DATA_WIDTH-1:0]  s_wdata_arr       [MAX_SUB_TRANS-1:0]   ;

  // ==========================
  // ==   reg declaration    ==
  // ==========================
  reg   [MAX_SUB_TRANS-1:0] idx                                     ;
  reg   [MAX_SUB_TRANS-1:0] idx_p                                   ;
  reg   [S_DATA_WIDTH-1:0]  s_wdata_p                               ;
  reg                       s_wlast_p                               ;
  reg                       s_wvalid_p                              ;
  reg                       m_wready_p                              ;
  reg   [XFER_D_IN-1:0]     sub_xfer_cnt                            ;
  reg                       wr_last_sub_xfer_reg                    ;
  reg                       w_done_p                                ;

  // =========================
  // ==   wire assignment   ==
  // =========================
  wire m_w_handshaked;
  assign m_w_handshake      = (m_wvalid && m_wready);
  assign m_w_handshaked     = m_w_handshake ? 1'b1 : (wr_last_sub_xfer ? 1'b0 : 1'b1);
  assign s_w_handshake      = (s_wvalid && s_wready);
  assign wr_last_sub_xfer   = (idx == (sub_xfer_cnt - 1));
  assign wr_last_xfer       = (m_wlast && s_w_handshake && wr_last_sub_xfer);
  assign s_new_data_en      = (s_w_handshake && (idx != 0)) || (m_w_handshaked && (idx == 0)) && ~xfer_empty_o;

  // =============================
  // ==   [AW] get xfer_data    ==
  // =============================
  assign xfer_rd_valid_i = m_w_handshaked && ~xfer_empty_o;
  assign sub_xfer_cnt_p = (xfer_rd_valid_i) ? xfer_data_o : sub_xfer_cnt;

  always @(posedge aclk or negedge arst_n) begin
    if (!arst_n) begin
      sub_xfer_cnt <= 0;
    end else begin
      sub_xfer_cnt <= sub_xfer_cnt_p;
    end
  end

  // =========================
  // ==      m_wready       ==
  // =========================

  always @(*) begin
    m_wready_p = m_wready;
    if (m_w_handshake) begin
      m_wready_p = 1'b0;
    end else if (wr_last_sub_xfer) begin
      m_wready_p = 1'b1;
    end
  end

  always @(posedge aclk or negedge arst_n) begin
    if (!arst_n) begin
      m_wready <= 1'b1;
    end else begin
      m_wready <= m_wready_p;
    end
  end

  // =========================
  // ==      s_wvalid       ==
  // =========================
  always @(posedge aclk) begin
    wr_last_sub_xfer_reg <= wr_last_sub_xfer;
  end

  always @(*) begin
    s_wvalid_p = s_wvalid;
    if (idx_p != 0) begin
      s_wvalid_p = 1'b1;
    end else if (wr_last_sub_xfer_reg && !m_wvalid) begin
      s_wvalid_p = 1'b0;
    end
  end

  always @(posedge aclk or negedge arst_n) begin
    if (!arst_n) begin
      s_wvalid <= 1'b0;
    end else begin
      s_wvalid <= s_wvalid_p;
    end
  end

  // ===========================
  // ==      Split wdata      ==
  // ===========================
  reg [M_DATA_WIDTH-1:0] wdata;
  reg [M_DATA_WIDTH-1:0] wdata_p;
  genvar i;

  always @(*) begin
    wdata_p = wdata;
    if (m_w_handshake) begin
      wdata_p = m_wdata;
    end
  end

  always @(posedge aclk or negedge arst_n) begin
    if (!arst_n) begin
      wdata <= 0;
    end else begin
      wdata <= wdata_p;
    end
  end

  generate
    for (i = 0; i < MAX_SUB_TRANS; i = i + 1) begin
      assign s_wdata_arr[MAX_SUB_TRANS-i-1] = wdata_p[(i+1)*S_DATA_WIDTH-1 : i*S_DATA_WIDTH];
    end
  endgenerate

  // -- -- [idx]
  always @(*) begin
    idx_p = idx;
    if (wr_last_sub_xfer && s_w_handshake) begin
      idx_p = 0;
    end else if (s_new_data_en) begin
      idx_p = idx + 1;
    end
  end

  always @(posedge aclk or negedge arst_n) begin
    if (!arst_n) begin
      idx <= {MAX_SUB_TRANS{1'b0}};
    end else begin
      idx <= idx_p;
    end
  end

  // =============================
  // ==         s_wdata         ==
  // =============================
  reg [7:0] s_xfer_cnt;
  reg [7:0] s_xfer_cnt_p;

  always @(*) begin
    s_wdata_p     = s_wdata;
    s_xfer_cnt_p  = s_xfer_cnt;
    if (s_new_data_en) begin
      s_wdata_p     = s_wdata_arr[idx];
      s_xfer_cnt_p  = s_xfer_cnt + 1'b1;
    end else if (m_wlast) begin
      s_xfer_cnt_p  = 0;
    end
  end

  always @(posedge aclk or negedge arst_n) begin
    if (!arst_n) begin
      s_xfer_cnt  <= 8'b0;
      s_wdata     <= {M_DATA_WIDTH{1'b0}};
    end else begin
      s_xfer_cnt  <= s_xfer_cnt_p;
      s_wdata     <= s_wdata_p;
    end
  end

  // =============================
  // ==         s_wlast         ==
  // =============================
  always @(*) begin
    s_wlast_p = s_wlast;

    if ((m_wlast && wr_last_sub_xfer) || (s_xfer_cnt == MAX_BURST_LEN - 1)) begin
      s_wlast_p = 1'b1;
    end else if (s_wlast && s_w_handshake) begin
      s_wlast_p = 1'b0;
    end
  end

  always @(*) begin
    w_done_p = w_done;
    if (s_wlast && s_w_handshake) begin
      w_done_p = 1'b1;
    end else if (w_done) begin
      w_done_p = 1'b0;
    end
  end

  always @(posedge aclk or negedge arst_n) begin
    if (!arst_n) begin
      s_wlast <= 1'b0;
      w_done  <= 1'b0;
    end else begin
      s_wlast <= s_wlast_p;
      w_done  <= w_done_p;
    end
  end
endmodule