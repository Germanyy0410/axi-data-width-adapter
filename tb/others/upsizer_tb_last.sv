`timescale 1ns / 1ps

// `define _32_BIT_MODE                    1
`define _64_BIT_MODE                    2
// `define _128_BIT_MODE                   3

// `define OUTPUT_RESULT_MODE              1

`define _32_BIT                         3'b101
`define _64_BIT                         3'b110
`define _128_BIT                        3'b111
// -- 32-bit
`define WRITE_32_SINGLE                 1
`define WRITE_32_MULTIPLE               2
// -- 64-bit
`define WRITE_64_SINGLE                 3
`define WRITE_64_SINGLE_HOLD            4
`define WRITE_64_MULTIPLE               5
`define WRITE_64_MULTIPLE_SPLIT         6
`define WRITE_64_MULTIPLE_SPLIT_ERR     7
// -- 128-bit
`define WRITE_128_SINGLE                8
`define WRITE_128_SINGLE_HOLD           9
`define WRITE_128_MULTIPLE              10
`define WRITE_128_MULTIPLE_SPLIT        11
`define WRITE_128_MULTIPLE_SPLIT_ERR    12
// -- 32-bit
`define READ_32_SINGLE                  13
`define READ_32_MULTIPLE                14
// -- 64-bit
`define READ_64_SINGLE                  15
`define READ_64_SINGLE_HOLD             16
`define READ_64_MULTIPLE                17
`define READ_64_MULTIPLE_SPLIT          18
`define READ_64_MULTIPLE_SPLIT_ERR      19
// -- 128-bit
`define READ_128_SINGLE                 20
`define READ_128_SINGLE_HOLD            21
`define READ_128_MULTIPLE               22
`define READ_128_MULTIPLE_SPLIT         23
`define READ_128_MULTIPLE_SPLIT_ERR     24

`define ADDR_WIDTH                      32
`define ID_WIDTH                        3
`define LEN_WIDTH                       8
`define SIZE_WIDTH                      3
`define BURST_WIDTH                     2

`define DATA_WIDTH_32_BIT               32
`define DATA_WIDTH_64_BIT               64
`define DATA_WIDTH_128_BIT              128

`define RESP_WIDTH                      2

typedef struct {
  bit  [`ADDR_WIDTH-1:0]    addr;
  bit  [`ID_WIDTH-1:0]      id;
  bit  [`SIZE_WIDTH-1:0]    size;
  bit  [`LEN_WIDTH-1:0]     len;
  bit  [`LEN_WIDTH+1:0]     max_len;
  bit  [`BURST_WIDTH-1:0]   burst;
} Ax_info;

// ======================== class definition ========================
class upsizer_wr_32_transaction #(int mode = `WRITE_32_SINGLE);
  // -- aw
  rand bit  [`ADDR_WIDTH-1:0]           addr;
  rand bit  [`ID_WIDTH-1:0]             id;
  rand bit  [`SIZE_WIDTH-1:0]           size;
  rand bit  [`LEN_WIDTH-1:0]            len;
  rand bit  [`BURST_WIDTH-1:0]          burst;
  // -- w
  rand bit  [`DATA_WIDTH_32_BIT-1:0]    data;
  // -- b
  rand bit  [`RESP_WIDTH-1:0]           resp;

  constraint c_mode {
    if (mode == `WRITE_32_SINGLE) {
      len == 0;
    }
    else if (mode == `WRITE_32_MULTIPLE) {
      len == 4;
    }
    burst == 2'b01;
    size  == `_32_BIT;
    resp dist { 2'b00 :/ 1, 2'b01 :/1 };
  }
endclass

class upsizer_wr_64_transaction #(int mode = `WRITE_64_SINGLE);
  // -- aw
  rand bit  [`ADDR_WIDTH-1:0]           addr_0;
  rand bit  [`ADDR_WIDTH-1:0]           addr;
  rand bit  [`ID_WIDTH-1:0]             id;
  rand bit  [`SIZE_WIDTH-1:0]           size;
  rand bit  [`LEN_WIDTH-1:0]            len;
  rand bit  [`BURST_WIDTH-1:0]          burst;
  // -- w
  rand bit  [`DATA_WIDTH_32_BIT-1:0]    data_0;
  rand bit  [`DATA_WIDTH_64_BIT-1:0]    data;
  // -- b
  rand bit  [`RESP_WIDTH-1:0]           resp;
  rand bit  [`RESP_WIDTH-1:0]           resp_0;
  rand bit  [`RESP_WIDTH-1:0]           resp_1;

  constraint c_mode {
    size    == `_64_BIT;
    burst   == 2'b01;
    // -- data
    data_0  >= 32'd0;
    data_0  <= 32'd99;
    data    == {data_0, data_0 + 1};

    if (mode == `WRITE_64_SINGLE) {
      len == 8'd0;
      resp dist { 2'b00 :/ 1, 2'b01 :/1 };
    }
    else if (mode == `WRITE_64_MULTIPLE) {
      addr  >= 32'd0;
      addr  <= 32'd100;
      len == 8'd4;
      resp dist { 2'b00 :/ 1, 2'b01 :/1 };
    }
    else if (mode == `WRITE_64_MULTIPLE_SPLIT || mode == `WRITE_64_MULTIPLE_SPLIT_ERR) {
      // -- addr
      addr  >= 32'd0;
      addr  <= 32'd100;
      // -- len
      len == 8'd149;
      if (mode == `WRITE_64_MULTIPLE_SPLIT) {
        resp_0 dist { 2'b00 :/ 1, 2'b01 :/1 };
        resp_1 dist { 2'b00 :/ 1, 2'b01 :/1 };
      } else if (mode == `WRITE_64_MULTIPLE_SPLIT_ERR) {
        resp_0 dist { 2'b10 :/ 1, 2'b11 :/1 };
        resp_1 dist { 2'b10 :/ 1, 2'b11 :/1 };
      }
    }
  }
endclass

class upsizer_wr_128_transaction #(int mode = `WRITE_128_SINGLE);
  // -- aw
  rand bit  [`ADDR_WIDTH-1:0]           addr_0;
  rand bit  [`ADDR_WIDTH-1:0]           addr;
  rand bit  [`ID_WIDTH-1:0]             id;
  rand bit  [`SIZE_WIDTH-1:0]           size;
  rand bit  [`LEN_WIDTH-1:0]            len;
  rand bit  [`BURST_WIDTH-1:0]          burst;
  // -- w
  rand bit  [`DATA_WIDTH_32_BIT-1:0]    data_0;
  rand bit  [`DATA_WIDTH_128_BIT-1:0]   data;
  // -- b
  rand bit  [`RESP_WIDTH-1:0]           resp;

  constraint c_mode {
    size    == `_128_BIT;
    burst   == 2'b01;
    // -- data
    data_0  >= 32'd0;
    data_0  <= 32'd39;
    data    == {data_0, data_0 + 1, data_0 + 2, data_0 + 3};

    if (mode == `WRITE_128_SINGLE) {
      len == 8'd0;
      resp dist { 2'b00 :/ 1, 2'b01 :/1 };
    }
    else if (mode == `WRITE_128_MULTIPLE) {
      // -- addr
      addr  >= 32'd0;
      addr  <= 32'd39;
      // -- len
      len == 8'd2;
      resp dist { 2'b00 :/ 1, 2'b01 :/1 };
    }
    else if (mode == `WRITE_128_MULTIPLE_SPLIT || mode == `WRITE_128_MULTIPLE_SPLIT_ERR) {
      // -- addr
      addr  >= 32'd0;
      addr  <= 32'd39;
      // -- len
      len == 8'd255;
      if (mode == `WRITE_128_MULTIPLE_SPLIT) {
        resp dist { 2'b00 :/ 1, 2'b01 :/1 };
      } else if (mode == `WRITE_128_MULTIPLE_SPLIT_ERR) {
        resp dist { 2'b10 :/ 1, 2'b11 :/1 };
      }
    }
  }
endclass

class upsizer_rd_32_transaction #(int mode = `READ_32_SINGLE);
  // -- aw
  rand bit  [`ADDR_WIDTH-1:0]           addr;
  rand bit  [`ID_WIDTH-1:0]             id;
  rand bit  [`SIZE_WIDTH-1:0]           size;
  rand bit  [`LEN_WIDTH-1:0]            len;
  rand bit  [`BURST_WIDTH-1:0]          burst;
  // -- w
  rand bit  [`DATA_WIDTH_32_BIT-1:0]    data;
  // -- b
  rand bit  [`RESP_WIDTH-1:0]           resp;

  constraint c_mode {
    if (mode == `READ_32_SINGLE) {
      len == 0;
    }
    else if (mode == `READ_32_MULTIPLE) {
      len == 4;
    }
    burst == 2'b01;
    size  == `_32_BIT;
    resp dist { 2'b00 :/ 1, 2'b01 :/1 };
  }
endclass

class upsizer_rd_64_transaction #(int mode = `READ_64_SINGLE);
  // -- ar
  rand bit  [`ADDR_WIDTH-1:0]           addr_0;
  rand bit  [`ADDR_WIDTH-1:0]           addr;
  rand bit  [`ID_WIDTH-1:0]             id;
  rand bit  [`SIZE_WIDTH-1:0]           size;
  rand bit  [`LEN_WIDTH-1:0]            len;
  rand bit  [`BURST_WIDTH-1:0]          burst;
  // -- r
  rand bit  [`DATA_WIDTH_32_BIT-1:0]    data_0;
  rand bit  [`DATA_WIDTH_64_BIT-1:0]    data;
  rand bit  [`RESP_WIDTH-1:0]           resp;
  rand bit  [`RESP_WIDTH-1:0]           resp_0;
  rand bit  [`RESP_WIDTH-1:0]           resp_1;

  constraint c_mode {
    size    == `_64_BIT;
    burst   == 2'b01;
    // -- data
    data_0  >= 32'd1;
    data_0  <= 32'd88;
    data    == {data_0 + 1, data_0};

    if (mode == `READ_64_SINGLE) {
      len == 8'd0;
      resp dist { 2'b00 :/ 1, 2'b01 :/1 };
    }
    else if (mode == `READ_64_MULTIPLE) {
      addr  >= 32'd0;
      addr  <= 32'd100;
      len == 8'd4;
      resp dist { 2'b00 :/ 1, 2'b01 :/1 };
    }
    else if (mode == `READ_64_MULTIPLE_SPLIT || mode == `READ_64_MULTIPLE_SPLIT_ERR) {
      // -- addr
      addr  >= 32'd0;
      addr  <= 32'd100;
      // -- len
      len == 8'd149;
      if (mode == `READ_64_MULTIPLE_SPLIT) {
        resp_0 dist { 2'b00 :/ 1, 2'b01 :/1 };
        resp_1 dist { 2'b00 :/ 1, 2'b01 :/1 };
      } else if (mode == `READ_64_MULTIPLE_SPLIT_ERR) {
        resp_0 dist { 2'b10 :/ 1, 2'b11 :/1 };
        resp_1 dist { 2'b10 :/ 1, 2'b11 :/1 };
      }
    }
  }
endclass

class upsizer_rd_128_transaction #(int mode = `READ_128_SINGLE);
  // -- aw
  rand bit  [`ADDR_WIDTH-1:0]           addr_0;
  rand bit  [`ADDR_WIDTH-1:0]           addr;
  rand bit  [`ID_WIDTH-1:0]             id;
  rand bit  [`SIZE_WIDTH-1:0]           size;
  rand bit  [`LEN_WIDTH-1:0]            len;
  rand bit  [`BURST_WIDTH-1:0]          burst;
  // -- w
  rand bit  [`DATA_WIDTH_32_BIT-1:0]    data_0;
  rand bit  [`DATA_WIDTH_128_BIT-1:0]   data;
  // -- b
  rand bit  [`RESP_WIDTH-1:0]           resp;

  constraint c_mode {
    size    == `_128_BIT;
    burst   == 2'b01;
    // -- data
    data_0  >= 32'd0;
    data_0  <= 32'd39;
    data    == {data_0 + 3, data_0 + 2, data_0 + 1, data_0};

    if (mode == `READ_128_SINGLE) {
      len == 8'd0;
      resp dist { 2'b00 :/ 1, 2'b01 :/1 };
    }
    else if (mode == `READ_128_MULTIPLE) {
      // -- addr
      addr  >= 32'd0;
      addr  <= 32'd39;
      // -- len
      len == 8'd2;
      resp dist { 2'b00 :/ 1, 2'b01 :/1 };
    }
    else if (mode == `READ_128_MULTIPLE_SPLIT || mode == `READ_128_MULTIPLE_SPLIT_ERR) {
      // -- addr
      addr  >= 32'd0;
      addr  <= 32'd39;
      // -- len
      len == 8'd255;
      if (mode == `READ_128_MULTIPLE_SPLIT) {
        resp dist { 2'b00 :/ 1, 2'b01 :/1 };
      } else if (mode == `READ_128_MULTIPLE_SPLIT_ERR) {
        resp dist { 2'b10 :/ 1, 2'b11 :/1 };
      }
    }
  }
endclass
// ==================================================================

module upsizer_tb #(
`ifdef _32_BIT_MODE
  parameter M_DATA_WIDTH  = 32,
`elsif _64_BIT_MODE
  parameter M_DATA_WIDTH  = 64,
`elsif _128_BIT_MODE
  parameter M_DATA_WIDTH  = 128,
`else
  parameter M_DATA_WIDTH  = 32,
`endif

  parameter LEN_WIDTH     = 8,
  parameter SIZE_WIDTH    = 3,
  parameter BURST_WIDTH   = 2,

  parameter ADDR_WIDTH    = 32,
  parameter AWID_WIDTH    = 3,
  parameter S_DATA_WIDTH  = 32,
  parameter BID_WIDTH     = 3,
  parameter ARID_WIDTH    = 3,
  parameter RID_WIDTH     = 3

)();

  logic                       aclk;
  logic                       arst_n;

  // -- Write transaction
  logic   [LEN_WIDTH-1:0]     m_awlen_i;
  logic   [SIZE_WIDTH-1:0]    m_awsize_i;
  logic   [BURST_WIDTH-1:0]   m_awburst_i;

  logic   [AWID_WIDTH-1:0]    m_awid_i;
  logic   [ADDR_WIDTH-1:0]    m_awaddr_i;
  logic                       m_awvalid_i;
  logic                       s_awready_i;

  logic   [M_DATA_WIDTH-1:0]  m_wdata_i;
  logic                       m_wvalid_i;
  logic                       s_wready_i;
  logic                       m_wlast_i;

  logic   [BID_WIDTH-1:0]     s_bid_i;
  logic                       s_bvalid_i;
  logic                       m_bready_i;
  logic   [1:0]               s_bresp_i;

  logic   [LEN_WIDTH-1:0]     s_awlen_o;
  logic   [SIZE_WIDTH-1:0]    s_awsize_o;
  logic   [BURST_WIDTH-1:0]   s_awburst_o;

  logic   [AWID_WIDTH-1:0]    s_awid_o;
  logic   [ADDR_WIDTH-1:0]    s_awaddr_o;
  logic                       s_awvalid_o;
  logic                       m_awready_o;

  logic   [S_DATA_WIDTH-1:0]  s_wdata_o;
  logic                       s_wvalid_o;
  logic                       m_wready_o;
  logic                       s_wlast_o;

  logic   [BID_WIDTH-1:0]     m_bid_o;
  logic                       m_bvalid_o;
  logic                       s_bready_o;
  logic   [1:0]               m_bresp_o;

  // -- Read transaction
  logic   [LEN_WIDTH-1:0]     m_arlen_i;
  logic   [SIZE_WIDTH-1:0]    m_arsize_i;
  logic   [BURST_WIDTH-1:0]   m_arburst_i;

  logic   [ARID_WIDTH-1:0]    m_arid_i;
  logic   [ADDR_WIDTH-1:0]    m_araddr_i;
  logic                       m_arvalid_i;
  logic                       s_arready_i;

  logic   [RID_WIDTH-1:0]     s_rid_i;
  logic   [S_DATA_WIDTH-1:0]  s_rdata_i;
  logic                       s_rvalid_i;
  logic                       m_rready_i;
  logic                       s_rlast_i;
  logic   [1:0]               s_rresp_i;

  logic   [LEN_WIDTH-1:0]     s_arlen_o;
  logic   [SIZE_WIDTH-1:0]    s_arsize_o;
  logic   [BURST_WIDTH-1:0]   s_arburst_o;

  logic   [ARID_WIDTH-1:0]    s_arid_o;
  logic   [ADDR_WIDTH-1:0]    s_araddr_o;
  logic                       s_arvalid_o;
  logic                       m_arready_o;

  logic   [RID_WIDTH-1:0]     m_rid_o;
  logic   [M_DATA_WIDTH-1:0]  m_rdata_o;
  logic                       m_rvalid_o;
  logic                       s_rready_o;
  logic                       m_rlast_o;
  logic   [1:0]               m_rresp_o;

  upsizer #(.M_DATA_WIDTH(M_DATA_WIDTH)) dut (.*);

  `include "helper.sv"

  // ====================== class initialization ======================
  // -- 32-bit
  upsizer_wr_32_transaction #(`WRITE_32_SINGLE)                 txn_wr_32_v0    ;
  upsizer_wr_32_transaction #(`WRITE_32_MULTIPLE)               txn_wr_32_v1    ;
  // -- 64-bit
  upsizer_wr_64_transaction #(`WRITE_64_SINGLE)                 txn_wr_64_v0    ;
  upsizer_wr_64_transaction #(`WRITE_64_MULTIPLE)               txn_wr_64_v1    ;
  upsizer_wr_64_transaction #(`WRITE_64_MULTIPLE_SPLIT)         txn_wr_64_v2    ;
  upsizer_wr_64_transaction #(`WRITE_64_MULTIPLE_SPLIT_ERR)     txn_wr_64_v3    ;
  // -- 128-bit
  upsizer_wr_128_transaction #(`WRITE_128_SINGLE)               txn_wr_128_v0   ;
  upsizer_wr_128_transaction #(`WRITE_128_MULTIPLE)             txn_wr_128_v1   ;
  upsizer_wr_128_transaction #(`WRITE_128_MULTIPLE_SPLIT)       txn_wr_128_v2   ;
  upsizer_wr_128_transaction #(`WRITE_128_MULTIPLE_SPLIT_ERR)   txn_wr_128_v3   ;
  // -- checker
  // -- -- AW
  mailbox #(Ax_info) golden_AW_queue;
  Ax_info AW_temp_0, AW_temp_1, AW_temp_2, AW_temp_3;
  // -- -- W
  mailbox #(bit [31:0]) golden_wdata_queue;
  bit [31:0] golden_wdata;
  // -- -- B
  mailbox #(bit [`ID_WIDTH-1:0]) golden_bid_queue;
  bit [`ID_WIDTH-1:0] golden_bid;
  // -- -- pending
  integer AW_pending  = 1;
  integer W_pending   = 1;
  integer B_pending   = 1;
  integer m_W_done    = 0;
  // ==================================================================


  // ========================== [WR_32_BIT] ===========================
  task automatic WR_32_BIT_TASK(input integer mode);
    if (mode == `WRITE_32_SINGLE) begin
      txn_wr_32_v0 = new();
      assert(txn_wr_32_v0.randomize()) else $error("Randomization failed");
      // -- aw
      m_awid_i    = txn_wr_32_v0.id;
      m_awaddr_i  = txn_wr_32_v0.addr;
      m_awsize_i  = txn_wr_32_v0.size;
      m_awlen_i   = txn_wr_32_v0.len;
      m_awburst_i = txn_wr_32_v0.burst;
      m_awvalid_i = 1'b1;
      s_awready_i = 1'b1;
      wait (m_awready_o == 1'b1);
      m_awvalid_i = 1'b0;
      // -- w
      m_wdata_i   = txn_wr_32_v0.data;
      m_wvalid_i  = 1'b1;
      s_wready_i  = 1'b1;
      m_wlast_i   = 1'b1;
      wait (m_wready_o == 1'b1);
      m_wvalid_i = 1'b0;
      m_wlast_i  = 1'b0;
      // -- b
      s_bvalid_i = txn_wr_32_v0.resp;
      m_bready_i = 1'b1;
      s_bvalid_i = 1'b1;
      c1;
      m_bready_i = 1'b0;
      s_bvalid_i = 1'b0;
    end else if (mode == `WRITE_32_MULTIPLE) begin
      txn_wr_32_v1 = new();
      assert(txn_wr_32_v1.randomize()) else $error("Randomization failed");
      // -- aw
      m_awid_i    = txn_wr_32_v1.id;
      m_awaddr_i  = txn_wr_32_v1.addr;
      m_awsize_i  = txn_wr_32_v1.size;
      m_awlen_i   = txn_wr_32_v1.len;
      m_awburst_i = txn_wr_32_v1.burst;
      m_awvalid_i = 1'b1;
      s_awready_i = 1'b1;
      wait (m_awready_o == 1'b1);
      m_awvalid_i = 1'b0;
      // -- w
      for (integer i = 0; i < txn_wr_32_v1.len + 1; i = i + 1) begin
        if (i == txn_wr_32_v1.len) begin
          m_wlast_i = 1'b1;
        end else begin
          m_wlast_i = 1'b0;
        end
        txn_wr_32_v1.randomize(data);
        m_wdata_i   = txn_wr_32_v1.data;
        m_wvalid_i  = 1'b1;
        s_wready_i  = 1'b1;
        wait (m_wready_o == 1'b1);
        m_wvalid_i  = 1'b0;
      end
      m_wlast_i = 1'b0;
      // -- b
      s_bvalid_i = txn_wr_32_v0.resp;
      m_bready_i = 1'b1;
      s_bvalid_i = 1'b1;
      c1;
      m_bready_i = 1'b0;
      s_bvalid_i = 1'b0;
    end
  endtask
  // ==================================================================


  // ========================= [WR_64_BIT] ============================
  task automatic WR_64_BIT_TASK(input integer mode);

    if (mode == `WRITE_64_MULTIPLE) begin
      txn_wr_64_v1        = new();
      golden_AW_queue     = new();
      golden_wdata_queue  = new();

      assert(txn_wr_64_v1.randomize()) else $error("Randomization failed");

      fork
        forever begin : AW_channel_v1
          txn_wr_64_v1.randomize(id, addr, size, burst);

          AW_temp_0.id    = txn_wr_64_v1.id;
          AW_temp_0.addr  = txn_wr_64_v1.addr;
          AW_temp_0.size  = `_32_BIT;
          AW_temp_0.len   = txn_wr_64_v1.len * 2 + 1;
          AW_temp_0.burst = txn_wr_64_v1.burst;
          golden_AW_queue.put(AW_temp_0);

          m_awid_i    = txn_wr_64_v1.id;
          m_awaddr_i  = txn_wr_64_v1.addr;
          m_awsize_i  = txn_wr_64_v1.size;
          m_awlen_i   = txn_wr_64_v1.len;
          m_awburst_i = txn_wr_64_v1.burst;

          m_awvalid_i = 1'b1;
          s_awready_i = 1'b1;
          #0.1;
          wait (m_awready_o == 1'b1);
          #0.1;
          c1;
          m_awvalid_i = 1'b0;
        end

        forever begin : W_channel_v1
          for (integer i = 0; i < txn_wr_64_v1.len + 1; i = i + 1) begin
            if (i == txn_wr_64_v1.len) begin
              m_wlast_i = 1'b1;
            end else begin
              m_wlast_i = 1'b0;
            end

            txn_wr_64_v1.randomize();

            golden_wdata_queue.put(txn_wr_64_v1.data_0);
            golden_wdata_queue.put(txn_wr_64_v1.data_0 + 1);

            m_wdata_i   = txn_wr_64_v1.data;

            m_wvalid_i  = 1'b1;
            s_wready_i  = 1'b1;

            if (i == 0 && W_pending == 1) begin
              W_pending = 0;
              repeat(4) c1;
            end else begin
              repeat(2) c1;
            end
          end
          m_wlast_i = 1'b0;
        end

        begin : B_channel
          repeat(15) c1;
          s_bid_i    = txn_wr_64_v1.id;
          s_bvalid_i = txn_wr_64_v1.resp;
          m_bready_i = 1'b1;
          s_bvalid_i = 1'b1;
          c1;
          m_bready_i = 1'b0;
          s_bvalid_i = 1'b0;
        end
      join_none
    end


    else if (mode == `WRITE_64_MULTIPLE_SPLIT) begin
      txn_wr_64_v2 = new();
      golden_AW_queue = new();
      golden_wdata_queue = new();
      assert(txn_wr_64_v2.randomize()) else $error("Randomization failed");

      fork
        forever begin : AW_channel_v2
          for (int i = 0; i < 2; i = i + 1) begin
            if (i == 0) begin
              txn_wr_64_v2.randomize();
              // 1st transaction
              AW_temp_0.id      = txn_wr_64_v2.id;
              AW_temp_0.addr    = txn_wr_64_v2.addr;
              AW_temp_0.size    = `_32_BIT;
              AW_temp_0.len     = 8'd255;
              AW_temp_0.burst   = txn_wr_64_v2.burst;
              golden_AW_queue.put(AW_temp_0);
              // 2nd transaction
              AW_temp_1.id      = txn_wr_64_v2.id;
              AW_temp_1.addr    = txn_wr_64_v2.addr + 4;
              AW_temp_1.size    = `_32_BIT;
              AW_temp_1.len     = txn_wr_64_v2.len * 2 - 255;
              AW_temp_1.burst   = txn_wr_64_v2.burst;
              golden_AW_queue.put(AW_temp_1);

              m_awid_i    = txn_wr_64_v2.id;
              m_awaddr_i  = txn_wr_64_v2.addr;
              m_awsize_i  = txn_wr_64_v2.size;
              m_awlen_i   = txn_wr_64_v2.len;
              m_awburst_i = txn_wr_64_v2.burst;
            end

          end
          #0.1;
          m_awvalid_i = 1'b1;
          s_awready_i = 1'b1;
          #0.1;
          wait (m_awready_o == 1'b1);
          #0.1;
          c1;
        end

        forever begin : W_channel_v2
          for (int i = 0; i < 2; i = i + 1) begin
            if (i == 0) begin     : txn_1st
              for (int k = 0; k < 256; k = k + 1) begin
                if (k == 255) begin
                  m_wlast_i = 1'b1;
                end else begin
                  m_wlast_i = 1'b0;
                end

                txn_wr_64_v2.randomize();

                golden_wdata_queue.put(txn_wr_64_v2.data_0);
                golden_wdata_queue.put(txn_wr_64_v2.data_0 + 1);

                m_wdata_i  = txn_wr_64_v2.data;

                m_wvalid_i = 1'b1;
                s_wready_i = 1'b1;

                if (k == 0 && W_pending == 1) begin
                  W_pending = 0;
                  repeat(4) c1;
                end else begin
                  repeat(2) c1;
                end
              end
              m_wlast_i = 1'b0;
            end else begin        : txn_2nd
              for (int k = 0; k < 44; k = k + 1) begin
                if (k == 43) begin
                  m_wlast_i = 1'b1;
                end else begin
                  m_wlast_i = 1'b0;
                end

                txn_wr_64_v2.randomize();

                golden_wdata_queue.put(txn_wr_64_v2.data_0);
                golden_wdata_queue.put(txn_wr_64_v2.data_0 + 1);

                m_wdata_i  = txn_wr_64_v2.data;

                m_wvalid_i = 1'b1;
                s_wready_i = 1'b1;

                if (k == 0 && W_pending == 1) begin
                  W_pending = 0;
                  repeat(4) c1;
                end else begin
                  repeat(2) c1;
                end
              end
            end
          end
        end
      join_none
    end

  endtask
  // ==================================================================


  // ========================= [WR_128_BIT] ===========================
  task automatic WR_128_BIT_TASK(input integer mode);

    if (mode == `WRITE_128_MULTIPLE) begin
      txn_wr_128_v1       = new();
      golden_AW_queue     = new();
      golden_wdata_queue  = new();
      golden_bid_queue    = new();
      assert(txn_wr_128_v1.randomize()) else $error("Randomization failed");

      fork
        forever begin : AW_channel_v3
          txn_wr_128_v1.randomize(id, addr, size, burst);

          AW_temp_0.id    = txn_wr_128_v1.id;
          AW_temp_0.addr  = txn_wr_128_v1.addr;
          AW_temp_0.size  = `_32_BIT;
          AW_temp_0.len   = txn_wr_128_v1.len * 4 + 3;
          AW_temp_0.burst = txn_wr_128_v1.burst;
          golden_AW_queue.put(AW_temp_0);
          golden_bid_queue.put(txn_wr_128_v1.id);

          m_awid_i    = txn_wr_128_v1.id;
          m_awaddr_i  = txn_wr_128_v1.addr;
          m_awsize_i  = txn_wr_128_v1.size;
          m_awlen_i   = txn_wr_128_v1.len;
          m_awburst_i = txn_wr_128_v1.burst;

          m_awvalid_i = 1'b1;
          s_awready_i = 1'b1;
          c3;
          wait (m_awready_o == 1'b1);
          c1;
          m_awvalid_i = 1'b0;
        end

        forever begin : W_channel_v3
          for (integer i = 0; i < txn_wr_128_v1.len + 1; i = i + 1) begin
            if (i == txn_wr_128_v1.len) begin
              m_wlast_i = 1'b1;
            end else begin
              m_wlast_i = 1'b0;
            end

            txn_wr_128_v1.randomize();

            golden_wdata_queue.put(txn_wr_128_v1.data_0);
            golden_wdata_queue.put(txn_wr_128_v1.data_0 + 1);
            golden_wdata_queue.put(txn_wr_128_v1.data_0 + 2);
            golden_wdata_queue.put(txn_wr_128_v1.data_0 + 3);

            m_wdata_i   = txn_wr_128_v1.data;

            c3;
            m_wvalid_i  = 1'b1;
            s_wready_i  = 1'b1;

            // if (i == 0 && W_pending == 1) begin
            //   W_pending = 0;
            //   repeat(1) c1;
            // end else begin
            //   repeat(5) c1;
            // end

            wait (m_wready_o == 1'b1);
            c1;
          end
        end

        forever begin : B_channel_v3
          if (B_pending == 1) begin
            B_pending = 0;
            repeat(15) c1;
          end else begin
            repeat(1) c1;
          end
          if (golden_bid_queue.try_get(golden_bid)) begin
            s_bid_i    = golden_bid;
            s_bvalid_i = 1'b1;
            m_bready_i = 1'b1;
            s_bresp_i  = txn_wr_128_v1.resp;
            c1;
            m_bready_i = 1'b0;
            s_bvalid_i = 1'b0;
            c1;
          end
        end

      join_none
    end


    else if (mode == `WRITE_128_MULTIPLE_SPLIT) begin
      txn_wr_128_v2       = new();
      golden_AW_queue     = new();
      golden_wdata_queue  = new();
      golden_bid_queue    = new();
      assert(txn_wr_128_v2.randomize()) else $error("Randomization failed");

      fork
        forever begin : AW_channel_v4
          txn_wr_128_v2.randomize();
          AW_temp_0.id    = txn_wr_128_v2.id;
          AW_temp_0.size  = `_32_BIT;
          AW_temp_0.len   = 8'd255;
          AW_temp_0.burst = txn_wr_128_v2.burst;
          // 1st transaction
          AW_temp_0.addr  = txn_wr_128_v2.addr;
          golden_AW_queue.put(AW_temp_0);
          // 2nd transaction
          AW_temp_0.addr  = txn_wr_128_v2.addr + 4;
          golden_AW_queue.put(AW_temp_0);
          // 3rd transaction
          AW_temp_0.addr  = txn_wr_128_v2.addr + 8;
          golden_AW_queue.put(AW_temp_0);
          // 4th transaction
          AW_temp_0.addr  = txn_wr_128_v2.addr + 12;
          golden_AW_queue.put(AW_temp_0);

          for (integer i = 0; i < 4; i = i + 1) begin
            golden_bid_queue.put(txn_wr_128_v2.id);
          end

          m_awid_i    = txn_wr_128_v2.id;
          m_awaddr_i  = txn_wr_128_v2.addr;
          m_awsize_i  = txn_wr_128_v2.size;
          m_awlen_i   = txn_wr_128_v2.len;
          m_awburst_i = txn_wr_128_v2.burst;

          #0.1;
          m_awvalid_i = 1'b1;
          s_awready_i = 1'b1;
          // wait (m_awready_o == 1'b1);

          if (AW_pending == 1) begin
            AW_pending = 0;
            repeat(1) c1;
          end else begin
            repeat(4) c1;
          end
        end

        forever begin : W_channel_v4
          for (integer i = 0; i < txn_wr_128_v2.len + 1; i = i + 1) begin
            if (i == txn_wr_128_v2.len) begin
              m_wlast_i = 1'b1;
            end else begin
              m_wlast_i = 1'b0;
            end

            txn_wr_128_v2.randomize();

            golden_wdata_queue.put(txn_wr_128_v2.data_0);
            golden_wdata_queue.put(txn_wr_128_v2.data_0 + 1);
            golden_wdata_queue.put(txn_wr_128_v2.data_0 + 2);
            golden_wdata_queue.put(txn_wr_128_v2.data_0 + 3);

            m_wdata_i   = txn_wr_128_v2.data;

            c3;
            m_wvalid_i  = 1'b1;
            s_wready_i  = 1'b1;

            // if (i == 0 && W_pending == 1) begin
            //   W_pending = 0;
            //   repeat(1) c1;
            // end else begin
            //   repeat(5) c1;
            // end

            wait (m_wready_o == 1'b1);
            c1;
          end
        end

        forever begin : B_channel_v4
          if (B_pending == 1) begin
            B_pending = 0;
            repeat(15) c1;
          end else begin
            repeat(1) c1;
          end
          if (golden_bid_queue.try_get(golden_bid)) begin
            s_bid_i    = golden_bid;
            s_bvalid_i = 1'b1;
            m_bready_i = 1'b1;
            s_bresp_i  = txn_wr_128_v2.resp;
            c1;
            m_bready_i = 1'b0;
            s_bvalid_i = 1'b0;
            repeat(5) c1;
          end
        end
      join_none

    end

  endtask
  // ==================================================================


  // ====================== class initialization ======================
  // -- 32-bit
  upsizer_rd_32_transaction #(`READ_32_SINGLE)                 txn_rd_32_v0    ;
  upsizer_rd_32_transaction #(`READ_32_MULTIPLE)               txn_rd_32_v1    ;
  // -- 64-bit
  upsizer_rd_64_transaction #(`READ_64_SINGLE)                 txn_rd_64_v0    ;
  upsizer_rd_64_transaction #(`READ_64_MULTIPLE)               txn_rd_64_v1    ;
  upsizer_rd_64_transaction #(`READ_64_MULTIPLE_SPLIT)         txn_rd_64_v2    ;
  upsizer_rd_64_transaction #(`READ_64_MULTIPLE_SPLIT_ERR)     txn_rd_64_v3    ;
  // -- 128-bit
  upsizer_rd_128_transaction #(`READ_128_SINGLE)               txn_rd_128_v0   ;
  upsizer_rd_128_transaction #(`READ_128_MULTIPLE)             txn_rd_128_v1   ;
  upsizer_rd_128_transaction #(`READ_128_MULTIPLE_SPLIT)       txn_rd_128_v2   ;
  upsizer_rd_128_transaction #(`READ_128_MULTIPLE_SPLIT_ERR)   txn_rd_128_v3   ;
  // -- checker
  // -- -- AR
  mailbox #(Ax_info) golden_AR_queue;
  Ax_info AR_temp_0, AR_temp_1, AR_temp_2, AR_temp_3;
  // -- -- R
  mailbox #(bit [M_DATA_WIDTH:0]) golden_rdata_queue;
  bit [M_DATA_WIDTH:0] golden_rdata;
  mailbox #(bit [`ID_WIDTH-1:0]) golden_rid_queue;
  bit [`ID_WIDTH-1:0] golden_rid;
  integer counter;
  // ==================================================================


  // ========================== [RD_32_BIT] ===========================
  task automatic RD_32_BIT_TASK(input integer mode);

    if (mode == `READ_32_SINGLE) begin

    end


    else if (mode == `READ_32_MULTIPLE) begin

    end

  endtask
  // ==================================================================


  // ========================= [RD_64_BIT] ============================
  task automatic RD_64_BIT_TASK(input integer mode);

    if (mode == `READ_64_MULTIPLE) begin
      txn_rd_64_v1        = new();
      golden_AR_queue     = new();
      golden_rdata_queue  = new();
      golden_rid_queue    = new();

      assert(txn_rd_64_v1.randomize()) else $error("Randomization failed");

      fork
        forever begin : AR_channel_64_v1
          txn_rd_64_v1.randomize(id, addr, size, burst);

          AR_temp_0.id    = txn_rd_64_v1.id;
          AR_temp_0.addr  = txn_rd_64_v1.addr;
          AR_temp_0.size  = `_32_BIT;
          AR_temp_0.len   = txn_rd_64_v1.len * 2 + 1;
          AR_temp_0.burst = txn_rd_64_v1.burst;
          golden_AR_queue.put(AR_temp_0);

          m_arid_i    = txn_rd_64_v1.id;
          m_araddr_i  = txn_rd_64_v1.addr;
          m_arsize_i  = txn_rd_64_v1.size;
          m_arlen_i   = txn_rd_64_v1.len;
          m_arburst_i = txn_rd_64_v1.burst;

          m_arvalid_i = 1'b1;
          s_arready_i = 1'b1;
          #0.1;
          wait (m_arready_o == 1'b1);
          #0.1;
          c1;
          m_arvalid_i = 1'b0;
        end

        forever begin : R_channel_64_v1
          txn_rd_64_v1.randomize();
          s_rid_i = txn_rd_64_v1.id;

          for (integer i = 0; i < txn_rd_64_v1.len; i = i + 1) begin
            s_rvalid_i  = 1'b1;
            m_rready_i  = 1'b1;

            txn_rd_64_v1.randomize();
            golden_rdata_queue.put(txn_rd_64_v1.data);

            s_rdata_i   = txn_rd_64_v1.data_0;
            #20.01;
            s_rdata_i   = txn_rd_64_v1.data_0 + 1;
            if (i == txn_rd_64_v1.len - 1) begin
              s_rlast_i = 1'b1;
              c1;
              s_rlast_i = 1'b0;
            end else begin
              c1;
            end
          end
        end
      join_none
    end

    else if (mode == `READ_64_MULTIPLE_SPLIT) begin
      txn_rd_64_v2        = new();
      golden_AR_queue     = new();
      golden_rdata_queue  = new();
      golden_rid_queue    = new();

      assert(txn_rd_64_v2.randomize()) else $error("Randomization failed");

      fork
        forever begin : AR_channel_64_v2
          for (int i = 0; i < 2; i = i + 1) begin
            txn_rd_64_v2.randomize(id, addr, size, burst);
            // 1st transaction
            AR_temp_0.id    = txn_rd_64_v2.id;
            AR_temp_0.addr  = txn_rd_64_v2.addr;
            AR_temp_0.size  = `_32_BIT;
            AR_temp_0.len   = 8'd255;
            AR_temp_0.burst = txn_rd_64_v2.burst;
            golden_AR_queue.put(AR_temp_0);
            // 2nd transaction
            AR_temp_1.id    = txn_rd_64_v2.id;
            AR_temp_1.addr  = txn_rd_64_v2.addr + 4;
            AR_temp_1.size  = `_32_BIT;
            AR_temp_1.len   = txn_rd_64_v2.len * 2 - 255;
            AR_temp_1.burst = txn_rd_64_v2.burst;
            golden_AR_queue.put(AR_temp_1);

            m_arid_i    = txn_rd_64_v2.id;
            m_araddr_i  = txn_rd_64_v2.addr;
            m_arsize_i  = txn_rd_64_v2.size;
            m_arlen_i   = txn_rd_64_v2.len;
            m_arburst_i = txn_rd_64_v2.burst;

            #0.1;
            m_arvalid_i = 1'b1;
            s_arready_i = 1'b1;
            #0.1;
            wait (m_arready_o == 1'b1);
            #0.1;
            c1;
          end
        end

        forever begin : R_channel_64_v2
          txn_rd_64_v2.randomize();
          s_rid_i = txn_rd_64_v2.id;

          counter = 0;

          for (integer i = 0; i < txn_rd_64_v2.len; i = i + 1) begin
            s_rvalid_i  = 1'b1;
            m_rready_i  = 1'b1;

            txn_rd_64_v2.randomize();
            golden_rdata_queue.put(txn_rd_64_v2.data);

            s_rdata_i   = txn_rd_64_v2.data_0;
            counter     = counter + 1;

            #20.01;
            s_rdata_i   = txn_rd_64_v2.data_0 + 1;
            counter     = counter + 1;
            if (counter == 8'd255) begin
              s_rlast_i = 1'b1;
              c1;
              s_rlast_i = 1'b0;
            end else begin
              c1;
            end
          end
        end
      join_none
    end

  endtask
  // ==================================================================


  // ========================= [RD_128_BIT] ===========================
  task automatic RD_128_BIT_TASK(input integer mode);

    if (mode == `READ_128_MULTIPLE) begin

    end


    else if (mode == `READ_128_MULTIPLE_SPLIT) begin

    end

  endtask
  // ==================================================================

  string pass = "\033[32m[PASSED]\033[0m";
  string fail = "\033[31m[FAILED]\033[0m";
  string aw   = "\033[34m[AW]\033[0m";
  string w    = "\033[35m[W ]\033[0m";
  string b    = "\033[36m[B ]\033[0m";
  string ar   = "\033[38;5;51m[AR]\033[0m";
  string r    = "\033[33m[R ]\033[0m";
  string aw_info_monitor = "";
  string wdata_monitor = "";
  string ar_info_monitor = "";
  string rdata_monitor = "";

  // ====================== [AW_INFO checker] =========================
  int pass_aw_info_checker, total_aw_info_checker;
  task AW_info_checker;
    Ax_info golden_AW_info;
    forever begin
      wait(s_awvalid_o);
      if (golden_AW_queue.try_get(golden_AW_info)) begin
        if (golden_AW_info.addr == s_awaddr_o && golden_AW_info.len == s_awlen_o) begin
          pass_aw_info_checker++;
          total_aw_info_checker++;
          aw_info_monitor = {aw_info_monitor, $sformatf("%s %s -> AW_info mapped \tat %0t ns\n", pass, aw, $time)};
        `ifdef OUTPUT_RESULT_MODE
          aw_info_monitor = {aw_info_monitor, $sformatf("\t[Addr = %0d] - [Id = %0d] - [Len = %0d]\n", golden_AW_info.addr, golden_AW_info.id, golden_AW_info.len)};
        `endif
        end else begin
          total_aw_info_checker++;
          $display("%s %s -> Address unmapped \tat %0t ns\n\t\tExpected: %0d - Got: %0d", fail, aw, $time, golden_AW_info.addr, dut.s_awaddr_o);
          $display("%s %s -> Length unmapped \tat %0t ns\n\t\tExpected: %0d - Got: %0d", fail, aw, $time, golden_AW_info.len, dut.s_awlen_o);
        end
      end
      c1;
    end
  endtask

  initial begin
    AW_info_checker;
  end
  // ==================================================================


  // ======================= [WDATA checker] ==========================
  int pass_wdata_checker, total_wdata_checker;
  task wdata_checker;
    forever begin
      #0.01;
      wait(s_wvalid_o);
      #0.01;
      if (golden_wdata_queue.try_get(golden_wdata)) begin
        if (golden_wdata == s_wdata_o) begin
          pass_wdata_checker++;
          total_wdata_checker++;
          wdata_monitor = {wdata_monitor, $sformatf("%s %s -> Data mapped \t\tat %0t ns\n", pass, w, $time)};
        `ifdef OUTPUT_RESULT_MODE
          wdata_monitor = {wdata_monitor, $sformatf("\t[Data = %0d]\n", golden_wdata)};
        `endif
        end else begin
          total_wdata_checker++;
          $display("%s %s -> Data unmapped \tat %0t ns\n\t\tExpected: %0d - Got: %0d", fail, w, golden_wdata, s_wdata_o, $time);
        end
      end
      c1;
    end
  endtask

  initial begin
    wdata_checker;
  end
  // ==================================================================


  // ====================== [AR_INFO checker] =========================
  int pass_ar_info_checker, total_ar_info_checker;
  task AR_info_checker;
    Ax_info golden_AR_info;
    forever begin
      #0.01;
      wait(s_arvalid_o);
      // $display("%0t",$time);
      if (golden_AR_queue.try_get(golden_AR_info)) begin
        if (golden_AR_info.addr == s_araddr_o && golden_AR_info.len == s_arlen_o) begin
          pass_ar_info_checker++;
          total_ar_info_checker++;
          ar_info_monitor = {ar_info_monitor, $sformatf("%s %s -> AR_info mapped \tat %0t ns\n", pass, ar, $time)};
        `ifdef OUTPUT_RESULT_MODE
          ar_info_monitor = {ar_info_monitor, $sformatf("\t[Addr = %0d] - [Id = %0d] - [Len = %0d]\n", golden_AR_info.addr, golden_AR_info.id, golden_AR_info.len)};
        `endif
        end else begin
          total_ar_info_checker++;
          $display("%s %s -> Address unmapped \tat %0t ns\n\t\tExpected: %0d - Got: %0d", fail, ar, $time, golden_AR_info.addr, dut.s_araddr_o);
          $display("%s %s -> Length unmapped \tat %0t ns\n\t\tExpected: %0d - Got: %0d", fail, ar, $time, golden_AR_info.len, dut.s_arlen_o);
        end
      end
      c1;
    end
  endtask

  initial begin
    AR_info_checker;
  end
  // ==================================================================


  // ======================= [RDATA checker] ==========================
  int pass_rdata_checker, total_rdata_checker;
  task rdata_checker;
    forever begin
      #0.01;
      wait(m_rvalid_o);
      #0.01;
      if (golden_rdata_queue.try_get(golden_rdata)) begin
        if (golden_rdata == m_rdata_o) begin
          pass_rdata_checker++;
          total_rdata_checker++;
          rdata_monitor = {rdata_monitor, $sformatf("%s %s -> Data mapped \t\tat %0t ns\n", pass, r, $time)};
        `ifdef OUTPUT_RESULT_MODE
          rdata_monitor = {rdata_monitor, $sformatf("\t[Data = %0d]\n", golden_rdata)};
        `endif
        end else begin
          total_rdata_checker++;
          $display("%s %s -> Data unmapped \tat %0t ns\n\t\tExpected: {%0d, %0d} - Got: {%0d, %0d}", fail, r, golden_rdata[63:32], golden_rdata[31:0], m_rdata_o[63:32], m_rdata_o[31:0], $time);
        end
      end
      c1;
    end
  endtask

  initial begin
    rdata_checker;
  end
  // ==================================================================

  int wr_which_test, rd_which_test;
  int num_transactions;
  int all_pass, all_total;
  string str[24] = { "WRITE_32_SINGLE", "WRITE_32_MULTIPLE", "WRITE_64_SINGLE", "WRITE_64_SINGLE_HOLD", "WRITE_64_MULTIPLE", "WRITE_64_MULTIPLE_SPLIT", "WRITE_64_MULTIPLE_SPLIT_ERR", "WRITE_128_SINGLE", "WRITE_128_SINGLE_HOLD", "WRITE_128_MULTIPLE", "WRITE_128_MULTIPLE_SPLIT", "WRITE_128_MULTIPLE_SPLIT_ERR", "READ_32_SINGLE", "READ_32_MULTIPLE", "READ_64_SINGLE", "READ_64_SINGLE_HOLD", "READ_64_MULTIPLE", "READ_64_MULTIPLE_SPLIT", "READ_64_MULTIPLE_SPLIT_ERR", "READ_128_SINGLE", "READ_128_SINGLE_HOLD", "READ_128_MULTIPLE", "READ_128_MULTIPLE_SPLIT", "READ_128_MULTIPLE_SPLIT_ERR" };

  initial begin
    #40;
    case (wr_which_test)
      `WRITE_32_SINGLE: begin
        WR_32_BIT_TASK(`WRITE_32_SINGLE);
      end

      `WRITE_32_MULTIPLE: begin
        WR_32_BIT_TASK(`WRITE_32_MULTIPLE);
      end

      `WRITE_64_MULTIPLE: begin
        WR_64_BIT_TASK(`WRITE_64_MULTIPLE);
      end

      `WRITE_64_MULTIPLE_SPLIT: begin
        WR_64_BIT_TASK(`WRITE_64_MULTIPLE_SPLIT);
      end

      `WRITE_128_MULTIPLE: begin
        WR_128_BIT_TASK(`WRITE_128_MULTIPLE);
      end

      `WRITE_128_MULTIPLE_SPLIT: begin
        WR_128_BIT_TASK(`WRITE_128_MULTIPLE_SPLIT);
      end

      default: begin
        WR_32_BIT_TASK(`WRITE_32_SINGLE);
      end
    endcase
  end

  initial begin
    #40;
    case (rd_which_test)
      `READ_32_SINGLE: begin
        RD_32_BIT_TASK(`READ_32_SINGLE);
      end

      `READ_32_MULTIPLE: begin
        RD_32_BIT_TASK(`READ_32_MULTIPLE);
      end

      `READ_64_MULTIPLE: begin
        RD_64_BIT_TASK(`READ_64_MULTIPLE);
      end

      `READ_64_MULTIPLE_SPLIT: begin
        RD_64_BIT_TASK(`READ_64_MULTIPLE_SPLIT);
      end

      `READ_128_MULTIPLE: begin
        RD_128_BIT_TASK(`READ_128_MULTIPLE);
      end

      `READ_128_MULTIPLE_SPLIT: begin
        RD_128_BIT_TASK(`READ_128_MULTIPLE_SPLIT);
      end

      default: begin
        WR_32_BIT_TASK(`READ_32_SINGLE);
      end
    endcase
  end

  always #10 aclk = ~aclk;

  initial begin
    aclk        = 1'b1;
    arst_n      = 1'b0;
    m_awvalid_i = 1'b0;
    m_wvalid_i  = 1'b0;
    s_rlast_i   = 1'b0;
    #22;
    arst_n      = 1'b1;
  end

  initial begin
    wr_which_test = `WRITE_64_MULTIPLE_SPLIT;
    rd_which_test = `READ_64_MULTIPLE_SPLIT;
    #40;
    $display("------------------------------------------------------");
    $display("|                       \033[38;5;220mBEGIN\033[0m                        |");
    $display("------------------------------------------------------");
    $display("          Testcase: \033[31m%s\033[0m", str[wr_which_test-1]);
    $display("          Testcase: \033[31m%s\033[0m\n", str[rd_which_test-1]);
    #20000;
    $display(aw_info_monitor);
    $display(wdata_monitor);
    $display(ar_info_monitor);
    $display(rdata_monitor);
    all_pass = pass_aw_info_checker + pass_wdata_checker + pass_ar_info_checker + pass_rdata_checker;
    all_total = total_aw_info_checker + total_wdata_checker + total_ar_info_checker + total_rdata_checker;

    $display("");
    $display("------------------------------------------------------");
    $display("|                  \033[38;5;220mREPORT SUMMARY\033[0m                    |");
    $display("------------------------------------------------------");
    $display("          Testcase: \033[31m%s\033[0m", str[wr_which_test-1]);
    $display("          Testcase: \033[31m%s\033[0m\n", str[rd_which_test-1]);

    $display("Write transaction test:");
    $display("     - AW_INFO            :           %3d | %3d", pass_aw_info_checker-1, total_wdata_checker);
    $display("     - WDATA              :           %3d | %3d", pass_wdata_checker, total_wdata_checker);
    $display("Read transaction test:");
    $display("     - AR_INFO            :           %3d | %3d", pass_ar_info_checker-1, total_rdata_checker);
    $display("     - RDATA              :           %3d | %3d", pass_rdata_checker, total_rdata_checker);

    $display("Summary:");
    $display("     Total items checked  :           %3d | %3d", all_pass, all_total);
    $display("     Overall              :             %0.1f%%", 100*(all_pass)/(all_total));
    $display("------------------------------------------------------");
    $display("|                        \033[38;5;220mEND\033[0m                         |");
    $display("------------------------------------------------------");
    $display("Stop here...");
    $display("\n\n");
    $finish();
  end



endmodule


