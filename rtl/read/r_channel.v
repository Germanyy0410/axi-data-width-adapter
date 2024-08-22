module aw_channel #(
  parameter MASTER        = 0,
  parameter SLAVE         = 1,

  parameter _32_BIT       = 3'b101,
  parameter _64_BIT       = 3'b110,
  parameter _128_BIT      = 3'b111,

  parameter LEN_WIDTH     = 8,
  parameter SIZE_WIDTH    = 3,
  parameter BURST_WIDTH   = 2,
  parameter MAX_BURST_LEN = 256,

  parameter S_DATA_WIDTH  = 32,
  parameter RID_WIDTH     = 3,

  parameter R_FIFO_DEPTH  = 8,
  parameter FF_DATA_IN    = SIZE_WIDTH + LEN_WIDTH + BURST_WIDTH + ADDR_WIDTH
)(
  input wire                      aclk,
  input wire                      arst_n,

  input wire  [RID_WIDTH-1:0]     m_rid,
  input wire                      s_rvalid,
  input wire                      m_rready,
  input wire                      s_rlast,
  input wire  [1:0]               s_rresp,

  output wire [ARID_WIDTH-1:0]    m_rid,
  output reg  [ADDR_WIDTH-1:0]    m_rvalid,
  output reg                      s_rready,
  output wire                     m_rlast,
  output wire [1:0]               m_rresp
);

  // =========================
  // ==== Internal signal ====
  // =========================
  wire                clk             [1:0];
  wire                rst_n           [1:0];
  wire [FF_DATA_IN:0] data_i          [1:0];
  wire [FF_DATA_IN:0] data_o          [1:0];
  wire                wr_valid_i      [1:0];
  wire                rd_valid_i      [1:0];
  wire                almost_empty_o  [1:0];
  reg                 empty_o         [1:0];
  wire                almost_full_o   [1:0];
  wire                full_o          [1:0];

  // =========================
  // ==== Module Instance ====
  // =========================
  upsizer_fifo #(
    .DATA_WIDTH(FF_DATA_IN),
    .FIFO_DEPTH(AW_FIFO_DEPTH)
  )
  u_m_ar_fifo (
    .almost_empty_o(almost_empty_o[MASTER]),
    .almost_full_o (almost_full_o[MASTER]),
    .clk           (aclk[MASTER]),
    .data_i        (data_i[MASTER]),
    .data_o        (data_o[MASTER]),
    .empty_o       (empty_o[MASTER]),
    .full_o        (full_o[MASTER]),
    .rd_valid_i    (rd_valid_i[MASTER]),
    .rst_n         (arst_n[MASTER]),
    .wr_valid_i    (wr_valid_i[MASTER])
  );

  upsizer_fifo #(
    .DATA_WIDTH(FF_DATA_IN),
    .FIFO_DEPTH(AW_FIFO_DEPTH)
  )
  u_s_ar_fifo (
    .almost_empty_o(almost_empty_o[SLAVE]),
    .almost_full_o (almost_full_o[SLAVE]),
    .clk           (aclk[SLAVE]),
    .data_i        (data_i[SLAVE]),
    .data_o        (data_o[SLAVE]),
    .empty_o       (empty_o[SLAVE]),
    .full_o        (full_o[SLAVE]),
    .rd_valid_i    (rd_valid_i[SLAVE]),
    .rst_n         (arst_n[SLAVE]),
    .wr_valid_i    (wr_valid_i[SLAVE])
  );

  // =====================================
  // ======= [IN] Calculate burst ========
  // =====================================
  reg [S_DATA_WIDTH-1:0]  s_rdata_arr [3:0];
  reg [2:0] i;
  reg [2:0] i_p;

  always @(*) begin
    i_p = i;
    if (s_rvalid && m_rready) begin
      i = i + 1;
    end
  end

  always @(posedge aclk) begin
    if (!arst_n) begin
      i <= 0;
    end else begin
      i <= i_p;
    end
  end

  assign s_rdata_arr[i] = s_rdata;

endmodule