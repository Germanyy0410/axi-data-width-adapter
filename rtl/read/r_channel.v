module r_channel #(
  parameter M_DATA_WIDTH  = 128,
  parameter S_DATA_WIDTH  = 32,
  parameter RID_WIDTH     = 3,
  parameter RESP_WIDTH    = 2,

  parameter SUB_TXN_CNT   = 3,
  parameter SUB_XFER_CNT  = 3,

  parameter FF_DATA_OUT   = SUB_TXN_CNT + SUB_XFER_CNT
)(
  input wire                      aclk,
  input wire                      arst_n,

  input wire  [RID_WIDTH-1:0]     s_rid,
  input wire  [S_DATA_WIDTH-1:0]  s_rdata,
  input wire                      s_rvalid,
  input wire                      m_rready,
  input wire                      s_rlast,
  input wire  [RESP_WIDTH-1:0]    s_rresp,

  output reg  [RID_WIDTH-1:0]     m_rid,
  output wire [M_DATA_WIDTH-1:0]  m_rdata,
  output reg                      m_rlast,
  output reg                      m_rvalid,
  output wire                     s_rready,
  output reg  [RESP_WIDTH-1:0]    m_rresp,

  input wire  [FF_DATA_OUT-1:0]   xfer_data_o,
  output reg                      xfer_rd_valid_i
);
  // ==========================
  // ==   wire declaration   ==
  // ==========================
  wire                      s_r_handshake;
  wire                      rd_last_sub_xfer;
  wire  [SUB_XFER_CNT-1:0]  sub_xfer_cnt;
  wire  [SUB_XFER_CNT-1:0]  total_sub_txn;
  wire                      m_rvalid_p;
  wire                      m_rlast_p;

  // ==========================
  // ==   reg declaration    ==
  // ==========================
  wire  [RID_WIDTH-1:0]     m_rid_p;
  reg   [M_DATA_WIDTH-1:0]  rdata;
  reg   [M_DATA_WIDTH-1:0]  rdata_p;
  reg   [S_DATA_WIDTH-1:0]  s_rdata_arr   [3:0];
  reg   [S_DATA_WIDTH-1:0]  s_rdata_arr_p [3:0];
  reg   [SUB_XFER_CNT-1:0]  i;
  reg   [SUB_XFER_CNT-1:0]  i_p;
  reg   [SUB_TXN_CNT-1:0]   s_rlast_cnt;
  reg   [SUB_TXN_CNT-1:0]   s_rlast_cnt_p;
  reg   [RESP_WIDTH-1:0]    rresp_hold;
  wire  [RESP_WIDTH-1:0]    rresp_hold_p;
  wire  [RESP_WIDTH-1:0]    m_rresp_p;
  wire                      xfer_rd_valid_i_p;
  wire                      slv_data_to_mst;

  // =========================
  // ==   wire assignment   ==
  // =========================
  assign s_r_handshake    = s_rvalid && m_rready;
  assign rd_last_sub_xfer = (i == sub_xfer_cnt - 1);
  assign slv_data_to_mst  = (i == sub_xfer_cnt - 1) && s_r_handshake;

  // =========================
  // ==       m_rid         ==
  // =========================
  assign m_rid_p = slv_data_to_mst ? s_rid : m_rid;
  // -- output
  always @(posedge aclk or negedge arst_n) begin
    if (!arst_n) begin
      m_rid <= 0;
    end else begin
      m_rid <= m_rid_p;
    end
  end

  // =========================
  // ==      s_rready       ==
  // =========================
  assign s_rready = m_rready;

  // =========================
  // ==      m_rdata        ==
  // =========================
  // -- Get [sub_xfer_cnt] & [total_sub_txn] from FIFO
  assign sub_xfer_cnt       = xfer_data_o[5:3];
  assign total_sub_txn      = xfer_data_o[2:0];
  // -- -- rd_valid
  assign xfer_rd_valid_i_p  = rd_last_sub_xfer;
  always @(posedge aclk or negedge arst_n) begin
    if (!arst_n) begin
      xfer_rd_valid_i <= 1'b1;
    end else begin
      xfer_rd_valid_i <= xfer_rd_valid_i_p;
    end
  end

  // -- Calculate array index
  always @(*) begin
    i_p = i;
    if (rd_last_sub_xfer) begin
      i_p = 0;
    end else if (s_r_handshake) begin
      i_p = i + 1;
    end
  end

  always @(posedge aclk or negedge arst_n) begin
    if (!arst_n) begin
      i <= 0;
    end else begin
      i <= i_p;
    end
  end

  // -- Assign [s_rdata] to array
  always @(*) begin
    s_rdata_arr_p[0] = s_rdata_arr[0];
    s_rdata_arr_p[1] = s_rdata_arr[1];
    s_rdata_arr_p[2] = s_rdata_arr[2];
    s_rdata_arr_p[3] = s_rdata_arr[3];
    if (s_r_handshake) begin
      s_rdata_arr_p[i] = s_rdata;
    end else if (rd_last_sub_xfer) begin
      s_rdata_arr_p[0] = 0;
      s_rdata_arr_p[1] = 0;
      s_rdata_arr_p[2] = 0;
      s_rdata_arr_p[3] = 0;
    end
  end

  genvar k;
  generate
    for (k = 0; k < 4; k = k + 1) begin
      always @(posedge aclk or negedge arst_n) begin
        if (!arst_n) begin
          s_rdata_arr[k] <= 0;
        end else begin
          s_rdata_arr[k] <= s_rdata_arr_p[k];
        end
      end
    end
  endgenerate

  // -- Concat [rdata]
  always @(*) begin
    rdata_p = rdata;
    if ((i == sub_xfer_cnt - 1) && s_r_handshake) begin
      case (i)
        0: rdata_p = s_rdata_arr_p[0];
        1: rdata_p = {s_rdata_arr_p[1], s_rdata_arr_p[0]};
        2: rdata_p = {s_rdata_arr_p[2], s_rdata_arr_p[1], s_rdata_arr_p[0]};
        3: rdata_p = {s_rdata_arr_p[3], s_rdata_arr_p[2], s_rdata_arr_p[1], s_rdata_arr_p[0]};
        default: rdata_p = rdata;
      endcase
    end
  end

  always @(posedge aclk or negedge arst_n) begin
    if (!arst_n) begin
      rdata <= 0;
    end else begin
      rdata <= rdata_p;
    end
  end

  // -- output
  assign m_rdata = rdata;

  // =========================
  // ==      m_rvalid       ==
  // =========================
  assign m_rvalid_p = s_rvalid && rd_last_sub_xfer;

  always @(posedge aclk or negedge arst_n) begin
    if (!arst_n) begin
      m_rvalid <= 0;
    end else begin
      m_rvalid <= m_rvalid_p;
    end
  end

  // =========================
  // ==      m_rlast        ==
  // =========================
  // -- Calculate the number of [rlast]
  always @(*) begin
    s_rlast_cnt_p = s_rlast_cnt;
    if (s_rlast && (s_rlast_cnt == (total_sub_txn - 1))) begin
      s_rlast_cnt_p = 0;
    end else if (s_rlast) begin
      s_rlast_cnt_p = s_rlast_cnt + 1;
    end
  end

  always @(posedge aclk or negedge arst_n) begin
    if (!arst_n) begin
      s_rlast_cnt <= 0;
    end else begin
      s_rlast_cnt <= s_rlast_cnt_p;
    end
  end

  assign m_rlast_p = s_rlast && (s_rlast_cnt == (total_sub_txn - 1)) && rd_last_sub_xfer;
  // -- output
  always @(posedge aclk or negedge arst_n) begin
    if (!arst_n) begin
      m_rlast <= 0;
    end else begin
      m_rlast <= m_rlast_p;
    end
  end

  // =========================
  // ==      m_rresp        ==
  // =========================
  // -- Hold [rresp] until the last response is received
  assign rresp_hold_p = s_r_handshake ? (rresp_hold | s_rresp) : rresp_hold;

  always @(posedge aclk or negedge arst_n) begin
    if (!arst_n) begin
      rresp_hold <= 2'b0;
    end else begin
      rresp_hold <= rresp_hold_p;
    end
  end

  assign m_rresp_p = (m_rlast_p) ? rresp_hold : m_rresp;
  // -- output
  always @(posedge aclk or negedge arst_n) begin
    if (!arst_n) begin
      m_rresp <= 2'b0;
    end else begin
      m_rresp <= m_rresp_p;
    end
  end
endmodule