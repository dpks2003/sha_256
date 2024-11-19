module golden_data_storage #(
    parameter                   S_PORTS = 1,
    parameter                   M_PORTS = 1,
    parameter                   DEPTH   = 1024,
    parameter                   DWIDTH  = 8
)(
    input  wire                      clk,
    input  wire                      rst_n,
    input  wire                      rd_check_en,
    input  wire [S_PORTS-1:0]        s_ready,
    input  wire [S_PORTS-1:0]        s_valid,
    input  wire [S_PORTS*DWIDTH-1:0] s_wdata,
    output wire [M_PORTS-1:0]        m_rvalid,
    output wire [M_PORTS*DWIDTH-1:0] m_rdata,
    output wire                      storage_ready,
    output wire                      read_done
);


wire [DWIDTH-1:0] m0_wdata_int;
wire [DWIDTH-1:0] m1_wdata_int;
wire              rst_busy_0;
wire              rst_busy_1;
wire              read_done_0;
wire              read_done_1;

assign storage_ready = ~(rst_busy_0 | rst_busy_1);
assign m0_wdata_int  =  (s_wdata[23:16] & {DWIDTH{s_valid[2] & s_ready[2]}}) | (s_wdata[31:24] & {DWIDTH{s_valid[3] & s_ready[3]}});
assign m1_wdata_int  =  (s_wdata[7:0]   & {DWIDTH{s_valid[0] & s_ready[0]}}) | (s_wdata[15:8]  & {DWIDTH{s_valid[1] & s_ready[1]}});
assign m0_wr_en      =  (s_valid[2] & s_ready[2]) | (s_valid[3] & s_ready[3]);
assign m1_wr_en      =  (s_valid[0] & s_ready[0]) | (s_valid[1] & s_ready[1]);
assign read_done     = read_done_0 & read_done_1;

efx_fifo_top # (
    .FAMILY             ("TITANIUM"),
    .SYNC_CLK           (1),
    .BYPASS_RESET_SYNC  (0),
    .MODE               ("STANDARD"),
    .DEPTH              (DEPTH),
    .DATA_WIDTH         (DWIDTH),
    .PIPELINE_REG       (1),
    .OPTIONAL_FLAGS     (1),
    .OUTPUT_REG         (0),
    .PROGRAMMABLE_FULL  ("NONE"),
    .PROGRAMMABLE_EMPTY ("NONE"),
    .ASYM_WIDTH_RATIO   (4)
) m0_golden_data (
    .a_rst_i            (~rst_n),
    .clk_i              (clk),
    .wr_en_i            (m0_wr_en),
    .rd_en_i            (rd_check_en),
    .wdata              (m0_wdata_int),
    .full_o             (),
    .empty_o            (read_done_0),
    .almost_empty_o     (),
    .rd_valid_o         (m_rvalid[0]),
    .rdata              (m_rdata[7:0]),
    .rst_busy           (rst_busy_0)
);

efx_fifo_top # (
    .FAMILY             ("TITANIUM"),
    .SYNC_CLK           (1),
    .BYPASS_RESET_SYNC  (0),
    .MODE               ("STANDARD"),
    .DEPTH              (DEPTH),
    .DATA_WIDTH         (DWIDTH),
    .PIPELINE_REG       (1),
    .OPTIONAL_FLAGS     (1),
    .OUTPUT_REG         (0),
    .PROGRAMMABLE_FULL  ("NONE"),
    .PROGRAMMABLE_EMPTY ("NONE"),
    .ASYM_WIDTH_RATIO   (4)
) m1_golden_data (
    .a_rst_i            (~rst_n),
    .clk_i              (clk),
    .wr_en_i            (m1_wr_en),
    .rd_en_i            (rd_check_en),
    .wdata              (m1_wdata_int),
    .full_o             (),
    .empty_o            (read_done_1),
    .almost_empty_o     (),
    .rd_valid_o         (m_rvalid[1]),
    .rdata              (m_rdata[15:8]),
    .rst_busy           (rst_busy_1)
);

endmodule
