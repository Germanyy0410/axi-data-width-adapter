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