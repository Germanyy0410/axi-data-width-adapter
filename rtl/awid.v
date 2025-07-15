module awid #(
  parameter AWID_WIDTH      = 3,
  parameter BID_WIDTH       = 3,
  parameter BRESP_WIDTH     = 2,
  parameter RESP_ARR_WIDTH  = 9
)(
  input wire                      aclk,
  input wire                      arst_n,
  input wire [AWID_WIDTH-1:0]     awid,
  input wire [2:0]                total_sub_txn,
  input wire                      m_aw_handshake,
  input wire                      s_b_handshake,
  input wire [BRESP_WIDTH-1:0]    s_bresp,
  input wire [BID_WIDTH-1:0]      s_bid,
  output reg                      rd_valid,
  output reg [RESP_ARR_WIDTH-1:0] resp
);
  // ==========================
  // ==   wire declaration   ==
  // ==========================
  wire [7:0]                wr_valid                          ;
  wire [AWID_WIDTH-1:0]     wr_addr_p             [0:7]       ;
  wire [AWID_WIDTH-1:0]     rd_addr_p             [0:7]       ;
  wire [RESP_ARR_WIDTH-1:0] data_i                [0:7]       ;
  wire [RESP_ARR_WIDTH-1:0] data_o                [0:7]       ;

  wire [RESP_ARR_WIDTH-1:0] resp_p                            ;
  wire                      rd_valid_p                        ;

  reg  [7:0]                pop_data_en_p                     ;
  reg  [AWID_WIDTH-1:0]     pop_awid_p            [0:7]       ;
  reg  [2:0]                pop_total_sub_txn_p   [0:7]       ;
  reg  [BRESP_WIDTH-1:0]    pop_bresp_p           [0:7]       ;

  // ==========================
  // ==   reg declaration    ==
  // ==========================
  reg  [RESP_ARR_WIDTH-1:0] memory                [0:7] [0:7] ;
  reg  [AWID_WIDTH-1:0]     wr_addr               [0:7]       ;
  reg  [AWID_WIDTH-1:0]     rd_addr               [0:7]       ;
  reg  [RESP_ARR_WIDTH-1:0] data                  [0:7]       ;

  reg  [7:0]                pop_data_en                       ;
  reg  [AWID_WIDTH-1:0]     pop_awid              [0:7]       ;
  reg  [2:0]                pop_total_sub_txn     [0:7]       ;
  reg  [BRESP_WIDTH-1:0]    pop_bresp             [0:7]       ;

  // ==========================================
  // ==           data structure             ==
  // ==  [id][total_sub_txn][bresp][valid]   ==
  // ==          [8:6][5:3][2:1][0]          ==
  // ==========================================
  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin
      assign data_i[i]    = (m_aw_handshake && (awid == i)) ? {awid, total_sub_txn, 2'b00, 1'b1} : 0;
      assign wr_valid[i]  = (m_aw_handshake && (awid == i)) ? 1'b1 : 1'b0;
      assign wr_addr_p[i]   = (m_aw_handshake && (awid == i)) ? (wr_addr[i] + 1) : wr_addr[i];
      assign rd_addr_p[i]   = (s_b_handshake && pop_total_sub_txn[i] == 0) ? (rd_addr[i] + 1) : rd_addr[i];
    end
  endgenerate

  generate
    for (i = 0; i < 8; i = i + 1) begin
      always @(posedge aclk) begin
        if (wr_valid[i]) begin
          memory[i][wr_addr[i]] <= data_i[i];
        end
        data[i] <= memory[i][rd_addr[i]];
      end
      assign data_o[i] = data[i];
    end
  endgenerate

  integer x;

  always @(*) begin
    for (x = 0; x < 8; x = x + 1) begin
      pop_data_en_p[x]        = pop_data_en[x];
      pop_awid_p[x]           = pop_awid[x];
      pop_total_sub_txn_p[x]  = pop_total_sub_txn[x];
      pop_bresp_p[x]          = pop_bresp[x];

      if (s_b_handshake && (pop_total_sub_txn[x] == 0) && (s_bid == x)) begin     // 1st response
        pop_data_en_p[x] = 1'b1;
      end else if (pop_data_en[x]) begin    // remain response
        pop_data_en_p[x] = 1'b0;
      end

      if (pop_data_en_p[x] && (s_bid == x)) begin
        pop_awid_p[x]           = data_o[x][8:6];
        pop_total_sub_txn_p[x]  = data_o[x][5:3] - 1;
        pop_bresp_p[x]          = data_o[x][2:1];
      end else if (s_b_handshake && (s_bid == x)) begin
        pop_total_sub_txn_p[x]  = pop_total_sub_txn[x] - 1;
        pop_bresp_p[x]          = (pop_bresp[x] | s_bresp);
      end
    end
  end

  generate
    for (i = 0; i < 8; i = i + 1) begin
      always @(posedge aclk or negedge arst_n) begin
        if (!arst_n) begin
          pop_data_en[i]        <= 0;
          pop_awid[i]           <= 0;
          pop_total_sub_txn[i]  <= 0;
          pop_bresp[i]          <= 0;
          wr_addr[i]            <= 0;
          rd_addr[i]            <= 0;
        end else begin
          pop_data_en[i]        <= pop_data_en_p[i];
          pop_awid[i]           <= pop_awid_p[i];
          pop_total_sub_txn[i]  <= pop_total_sub_txn_p[i];
          pop_bresp[i]          <= pop_bresp_p[i];
          wr_addr[i]            <= wr_addr_p[i];
          rd_addr[i]            <= rd_addr_p[i];
        end
      end
    end
  endgenerate

  assign rd_valid_p = (s_b_handshake && (pop_total_sub_txn_p[s_bid] == 0))
                      ? 1'b1
                      : (rd_valid)
                        ? 1'b0
                        : rd_valid;

  assign resp_p = { pop_awid[s_bid], pop_total_sub_txn[s_bid], pop_bresp[s_bid] };

  always @(posedge aclk or negedge arst_n) begin
    if (!arst_n) begin
      rd_valid  <= 0;
      resp      <= 0;
    end else begin
      rd_valid  <= rd_valid_p;
      resp      <= resp_p;
    end
  end
endmodule
