
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