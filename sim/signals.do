onerror resume
wave activate Wave0
wave tags F0 
wave update off
wave zoom range 0 323432
wave add upsizer_tb.dut.u_aw_channel.aclk -tag F0 -radix hexadecimal -foregroundcolor #00aa00
wave group {AW CHANNEL} -backgroundcolor #004466
wave group {AW CHANNEL:Master} -backgroundcolor #006666
wave add -group {AW CHANNEL:Master} upsizer_tb.dut.u_aw_channel.m_awaddr -tag F0 -radix decimal -foregroundcolor #00aa00
wave add -group {AW CHANNEL:Master} upsizer_tb.dut.u_aw_channel.u_m_aw_fifo.data_i -tag F0 -radix hexadecimal -foregroundcolor #00aa00
wave add -group {AW CHANNEL:Master} upsizer_tb.dut.u_aw_channel.u_m_aw_fifo.data_o -tag F0 -radix hexadecimal -foregroundcolor #00aa00
wave group {AW CHANNEL:Master:M_FIFO} -backgroundcolor #226600
wave add -group {AW CHANNEL:Master:M_FIFO} upsizer_tb.dut.u_aw_channel.u_m_aw_fifo.wr_valid_i -tag F0 -radix hexadecimal -foregroundcolor #00aa00
wave add -group {AW CHANNEL:Master:M_FIFO} upsizer_tb.dut.u_aw_channel.u_m_aw_fifo.rd_valid_i -tag F0 -radix hexadecimal -foregroundcolor #00aa00
wave spacer -group {AW CHANNEL:Master:M_FIFO} {}
wave group {AW CHANNEL:Internal} -backgroundcolor #666600
wave add -group {AW CHANNEL:Internal} upsizer_tb.dut.u_aw_channel.awaddr -tag F0 -radix decimal -foregroundcolor #00aa00
wave add -group {AW CHANNEL:Internal} upsizer_tb.dut.u_aw_channel.total_sub_xfer_p -tag F0 -radix decimal
wave add -group {AW CHANNEL:Internal} upsizer_tb.dut.u_aw_channel.i_p -tag F0 -radix hexadecimal
wave add -group {AW CHANNEL:Internal} upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_i -tag F0 -radix hexadecimal -foregroundcolor #00aa00
wave add -group {AW CHANNEL:Internal} upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o -tag F0 -radix hexadecimal -subitemconfig { {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[44]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[43]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[42]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[41]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[40]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[39]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[38]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[37]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[36]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[35]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[34]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[33]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[32]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[31]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[30]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[29]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[28]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[27]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[26]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[25]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[24]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[23]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[22]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[21]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[20]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[19]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[18]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[17]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[16]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[15]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[14]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[13]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[12]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[11]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[10]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[9]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[8]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[7]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[6]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[5]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[4]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[3]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[2]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[1]} {-radix hexadecimal} {upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.data_o[0]} {-radix hexadecimal} } -foregroundcolor #00aa00
wave group {AW CHANNEL:Internal:S_FIFO} -backgroundcolor #664400
wave add -group {AW CHANNEL:Internal:S_FIFO} upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.wr_valid_i -tag F0 -radix hexadecimal -foregroundcolor #00aa00
wave add -group {AW CHANNEL:Internal:S_FIFO} upsizer_tb.dut.u_aw_channel.u_s_aw_fifo.rd_valid_i -tag F0 -radix hexadecimal -foregroundcolor #00aa00
wave spacer -group {AW CHANNEL:Internal:S_FIFO} {}
wave group {AW CHANNEL:Slave} -backgroundcolor #660000
wave add -group {AW CHANNEL:Slave} upsizer_tb.dut.u_aw_channel.s_awaddr -tag F0 -radix decimal -foregroundcolor #00aa00
wave insertion [expr [wave index insertpoint] + 1]
wave group {W CHANNEL} -backgroundcolor #004466
wave group {W CHANNEL:Master} -backgroundcolor #006666
wave add -group {W CHANNEL:Master} upsizer_tb.dut.u_w_channel.m_wdata -tag F0 -radix hexadecimal
wave add -group {W CHANNEL:Master} upsizer_tb.dut.u_w_channel.data_i -tag F0 -radix hexadecimal
wave add -group {W CHANNEL:Master} upsizer_tb.dut.u_w_channel.data_o -tag F0 -radix hexadecimal
wave group {W CHANNEL:Master:W_FIFO} -backgroundcolor #226600
wave add -group {W CHANNEL:Master:W_FIFO} upsizer_tb.dut.u_w_channel.wr_valid_i -tag F0 -radix hexadecimal
wave add -group {W CHANNEL:Master:W_FIFO} upsizer_tb.dut.u_w_channel.rd_valid_i -tag F0 -radix hexadecimal
wave insertion [expr [wave index insertpoint] + 1]
wave spacer -group {W CHANNEL:Master} {}
wave insertion [expr [wave index insertpoint] + 1]
wave add -group {W CHANNEL} upsizer_tb.dut.u_w_channel.wr_last_xfer -tag F0 -radix hexadecimal
wave add -group {W CHANNEL} upsizer_tb.dut.u_w_channel.sub_xfer_cnt -tag F0 -radix hexadecimal
wave add -group {W CHANNEL} upsizer_tb.dut.u_w_channel.wr_last_sub_xfer -tag F0 -radix hexadecimal -select
wave group {W CHANNEL:Internal} -backgroundcolor #666600
wave add -group {W CHANNEL:Internal} upsizer_tb.dut.u_w_channel.s_wdata_arr -tag F0 -radix hexadecimal
wave add -group {W CHANNEL:Internal} upsizer_tb.dut.u_w_channel.idx -tag F0 -radix hexadecimal
wave add -group {W CHANNEL:Internal} upsizer_tb.dut.u_w_channel.idx_p -tag F0 -radix hexadecimal
wave spacer -group {W CHANNEL:Internal} {}
wave insertion [expr [wave index insertpoint] + 1]
wave group {W CHANNEL:Slave} -backgroundcolor #664400
wave add -group {W CHANNEL:Slave} upsizer_tb.dut.u_w_channel.s_wdata -tag F0 -radix hexadecimal
wave insertion [expr [wave index insertpoint] + 1]
wave insertion [expr [wave index insertpoint] + 1]
wave group {W CHANNEL:Master:W_FIFO} -collapse
wave group {AW CHANNEL:Internal:S_FIFO} -collapse
wave group {AW CHANNEL:Master:M_FIFO} -collapse
wave group {AW CHANNEL} -collapse
wave update on
wave top 0
wave filter settings -pattern * -leaf_name_only 1 -history {*} -signal_type 255 
