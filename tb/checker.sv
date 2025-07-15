  string pass = "\033[32m[PASSED]\033[0m";
  string fail = "\033[31m[FAILED]\033[0m";
  string aw   = "\033[34m[AW]\033[0m";
  string w    = "\033[35m[W ]\033[0m";
  string b    = "\033[36m[B ]\033[0m";
  string ar   = "\033[38;5;51m[AR]\033[0m";
  string r    = "\033[33m[R ]\033[0m";
  string aw_info_monitor  = "";
  string wdata_monitor    = "";
  string ar_info_monitor  = "";
  string rdata_monitor    = "";

  // ====================== [AW_INFO checker] =========================
  int pass_aw_info_checker, total_aw_info_checker;
  task AW_info_checker;
    Ax_info golden_AW_info;
    forever begin
      #0.1;
      wait(s_awvalid_o);
      if (golden_AW_queue.try_get(golden_AW_info)) begin
        if (golden_AW_info.addr == s_awaddr_o && golden_AW_info.len == s_awlen_o) begin
          pass_aw_info_checker++;
          total_aw_info_checker++;
          aw_info_monitor = {aw_info_monitor, $sformatf("%s %s -> AW_info mapped \tat %0t ns\n", pass, aw, $time)};
        `ifdef DEBUG_MODE
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
    #40;
    forever begin
      #0.01;
      wait(s_wvalid_o);
      if (golden_wdata_queue.try_get(golden_wdata)) begin
        if (golden_wdata == s_wdata_o) begin
          pass_wdata_checker++;
          total_wdata_checker++;
          wdata_monitor = {wdata_monitor, $sformatf("%s %s -> Data mapped \t\tat %0t ns\n", pass, w, $time)};
        `ifdef DEBUG_MODE
          wdata_monitor = {wdata_monitor, $sformatf("\t[Data = %0d]\n", golden_wdata)};
        `endif
        end else begin
          total_wdata_checker++;
          $display("%s %s -> Data unmapped \tat %0t ns\n\t\tExpected: %0d - Got: %0d", fail, w, $time, golden_wdata, s_wdata_o);
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
        `ifdef DEBUG_MODE
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
      if (golden_rdata_queue.try_get(golden_rdata)) begin
        if (golden_rdata == m_rdata_o) begin
          pass_rdata_checker++;
          total_rdata_checker++;
          rdata_monitor = {rdata_monitor, $sformatf("%s %s -> Data mapped \t\tat %0t ns\n", pass, r, $time)};
        `ifdef DEBUG_MODE
          rdata_monitor = {rdata_monitor, $sformatf("\t[Data = %0d]\n", golden_rdata)};
        `endif
        end else begin
          total_rdata_checker++;
          $display("%s %s -> Data unmapped \tat %0t ns\n\t\tExpected: {%0d, %0d} - Got: {%0d, %0d}", fail, r, $time, golden_rdata[63:32], golden_rdata[31:0], m_rdata_o[63:32], m_rdata_o[31:0]);
        end
      end
      c1;
    end
  endtask

  initial begin
    rdata_checker;
  end
  // ==================================================================