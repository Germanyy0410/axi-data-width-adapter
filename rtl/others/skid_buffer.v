module skid_buffer #(
  parameter DATA_WIDTH = 8  // Added "parameter" keyword for parameterization
) (
  input clk,
  input rst_n,

  input   [DATA_WIDTH-1:0]  bwd_data_i,
  input                     bwd_valid_i,
  input                     fwd_ready_i,

  output  [DATA_WIDTH-1:0]  fwd_data_o,
  output                    bwd_ready_o,
  output                    fwd_valid_o
);
  // ==========================
  // ==   wire declaration   ==
  // ==========================
  wire                        bwd_handshake;
  wire                        fwd_handshake;

  // ==========================
  // ==   reg declaration    ==
  // ==========================
  reg [DATA_WIDTH-1:0]        bwd_data;
  reg [DATA_WIDTH-1:0]        bwd_data_reg;
  reg                         bwd_ready;
  reg                         bwd_ready_reg;

  reg                         fwd_valid;
  reg                         fwd_valid_reg;
  reg [DATA_WIDTH-1:0]        fwd_data;
  reg [DATA_WIDTH-1:0]        fwd_data_reg;

  // =========================
  // ==   wire assignment   ==
  // =========================
  // -- output
  assign fwd_data_o     = fwd_data_reg;
  assign fwd_valid_o    = fwd_valid_reg;
  assign bwd_ready_o    = bwd_ready_reg;
  // -- internal
  assign bwd_handshake  = bwd_valid_i & bwd_ready_o;
  assign fwd_handshake  = fwd_valid_o & fwd_ready_i;

  always @(*) begin
    bwd_data  = bwd_data_reg;
    fwd_data  = fwd_data_reg;
    bwd_ready = bwd_ready_reg;
    fwd_valid = fwd_valid_reg;

    if (bwd_handshake && fwd_handshake) begin
      fwd_data = bwd_data_i;
    end else if (bwd_handshake) begin
      if (fwd_valid_reg) begin
        // Data is held in the skid buffer since fwd_valid_reg is already set
        bwd_data  = bwd_data_i;
        bwd_ready = 1'b0;  // Stop accepting new data until the buffer is cleared
      end else begin
        // No valid data in the skid buffer, so forward data directly
        fwd_data  = bwd_data_i;
        fwd_valid = 1'b1;
      end
    end else if (fwd_handshake) begin
      if (bwd_ready_reg) begin
        fwd_valid = 1'b0;  // Data has been sent, so reset fwd_valid
      end else begin
        fwd_data  = bwd_data_reg;  // Forward the held data
        bwd_ready = 1'b1;          // Buffer is now ready to accept new data
      end
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      fwd_valid_reg <= 1'b0;
      bwd_data_reg  <= {DATA_WIDTH{1'b0}};
      fwd_data_reg  <= {DATA_WIDTH{1'b0}};
      bwd_ready_reg <= 1'b1;
    end else begin
      fwd_valid_reg <= fwd_valid;
      fwd_data_reg  <= fwd_data;
      bwd_data_reg  <= bwd_data;
      bwd_ready_reg <= bwd_ready;
    end
  end
endmodule
