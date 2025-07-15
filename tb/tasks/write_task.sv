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

                #0.1;
                wait(m_wready_o);
                c1;
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

                #0.1;
                wait(m_wready_o);
                c1;
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