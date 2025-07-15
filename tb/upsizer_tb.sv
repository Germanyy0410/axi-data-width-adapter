`timescale 1ns / 1ps

// `define _32_BIT_MODE                    1
`define _64_BIT_MODE                    2
// `define _128_BIT_MODE                   3

// `define DEBUG_MODE                      1
// `define VCS_DEBUG_MODE                  1

`include "/define.svh"
`include "/transaction.sv"

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

  `include "/helper.sv"
  `include "/tasks/write_task.sv"
  `include "/tasks/read_task.sv"
  `include "/checker.sv"

  int all_pass, all_total;
  int wr_which_test, rd_which_test;
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
    m_rready_i  = 1'b0;
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
    #200;
    $display(aw_info_monitor);
    $display(wdata_monitor);
    $display(ar_info_monitor);
    $display(rdata_monitor);
    all_pass  = pass_aw_info_checker  + pass_wdata_checker  + pass_ar_info_checker  + pass_rdata_checker;
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

`ifdef VCS_DEBUG_MODE
  initial begin
    $fsdbDumpfile("dump.fsdb");
    $fsdbDumpvars;
  end
`endif

endmodule


