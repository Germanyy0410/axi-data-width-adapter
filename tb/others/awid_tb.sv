`timescale 1ns / 1ps

module awid_tb #(
  parameter AWID_WIDTH      = 3,
  parameter BID_WIDTH       = 3,
  parameter BRESP_WIDTH     = 2,
  parameter RESP_ARR_WIDTH  = 9
)();

  logic                      aclk;
  logic                      arst_n;
  logic [AWID_WIDTH-1:0]     awid;
  logic [2:0]                total_sub_txn;
  logic                      m_aw_handshake;
  logic                      s_b_handshake;
  logic [BRESP_WIDTH-1:0]    s_bresp;
  logic [BID_WIDTH-1:0]      s_bid;
  logic                      rd_valid;
  logic [RESP_ARR_WIDTH-1:0] resp;

  awid #(
    .AWID_WIDTH(AWID_WIDTH),
    .BID_WIDTH(BID_WIDTH),
    .BRESP_WIDTH(BRESP_WIDTH),
    .RESP_ARR_WIDTH(RESP_ARR_WIDTH)
  ) dut (.*);

  always #10 aclk = ~aclk;

  initial begin
    aclk      = 1'b1;
    arst_n    = 1'b0;
    m_aw_handshake = 1'b0;
    s_b_handshake = 1'b0;
    s_bresp = 0;
    s_bid = 0;
    #22;
    arst_n  = 1'b1;
    #18;

    #20.01;
    awid = 'd1;
    total_sub_txn = 'd3;
    m_aw_handshake = 1'b1;

    #20.01;
    awid = 'd2;
    total_sub_txn = 'd2;
    m_aw_handshake = 1'b1;

    #20.01;
    awid = 'd3;
    total_sub_txn = 'd4;
    m_aw_handshake = 1'b1;

    #20.01;
    awid = 'd1;
    total_sub_txn = 'd5;
    m_aw_handshake = 1'b1;

    #20.01;
    awid = 'd2;
    total_sub_txn = 'd2;
    m_aw_handshake = 1'b1;

    #20.01;
    m_aw_handshake = 1'b0;

    #60.01;
    s_b_handshake = 1'b1;
    s_bresp = 'd0;
    s_bid = 'd1;
    #20.01;
    s_b_handshake = 1'b1;
    s_bresp = 'd2;
    s_bid = 'd1;
    #20.01;
    s_b_handshake = 1'b1;
    s_bresp = 'd0;
    s_bid = 'd1;

    #20.01;
    s_b_handshake = 1'b1;
    s_bresp = 'd0;
    s_bid = 'd1;
    #20.01;
    s_b_handshake = 1'b1;
    s_bresp = 'd2;
    s_bid = 'd1;
    #20.01;
    s_b_handshake = 1'b1;
    s_bresp = 'd0;
    s_bid = 'd1;
    #20.01;
    s_b_handshake = 1'b0;
    s_bresp = 'd2;
    s_bid = 'd1;
  end

endmodule