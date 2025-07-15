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

            c1;
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