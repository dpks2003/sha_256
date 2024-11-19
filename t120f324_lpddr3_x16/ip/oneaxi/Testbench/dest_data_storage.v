module dest_data_storage #(
    parameter                        M_PORTS       = 1,
    parameter                        DEPTH         = 1024,
    parameter                        DWIDTH        = 8,
    parameter                        TREADY_CTRL_0 = 0,
    parameter                        TREADY_CTRL_1 = 0
)(
    input  wire                      clk,
    input  wire                      rst_n,
    input  wire                      rd_check_en,
    input  wire [M_PORTS-1:0]        s_valid,
    input  wire [M_PORTS*DWIDTH-1:0] s_wdata,
    output wire [M_PORTS-1:0]        m_wready,
    output wire [M_PORTS-1:0]        m_rvalid,
    output wire [M_PORTS*DWIDTH-1:0] m_rdata,
    output wire                      storage_ready,
    output wire                      read_done
);

reg [TREADY_CTRL_0-1:0] ready_cnt0;
reg [TREADY_CTRL_1-1:0] ready_cnt1;

wire rst_busy_0;
wire rst_busy_1;
wire read_done_0;
wire read_done_1;

assign storage_ready = ~(rst_busy_0 | rst_busy_1);
assign read_done     = read_done_0 | read_done_1;

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
    .wr_en_i            (s_valid[0] & m_wready[0]),
    .rd_en_i            (rd_check_en),
    .wdata              (s_wdata[0+:DWIDTH]),
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
    .wr_en_i            (s_valid[1] & m_wready[1]),
    .rd_en_i            (rd_check_en),
    .wdata              (s_wdata[DWIDTH+:DWIDTH]),
    .full_o             (),
    .empty_o            (read_done_1),
    .almost_empty_o     (),
    .rd_valid_o         (m_rvalid[1]),
    .rdata              (m_rdata[15:8]),
    .rst_busy           (rst_busy_1)
);

assign m_wready[0] = (TREADY_CTRL_0 == 0) ? 1'b1 : ready_cnt0[TREADY_CTRL_0-1];
assign m_wready[1] = (TREADY_CTRL_1 == 0) ? 1'b1 : ready_cnt1[TREADY_CTRL_1-1];

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        ready_cnt0 <= 'd0;
    end
    else begin
        ready_cnt0 <= ready_cnt0 + 1'd1;
    end
end

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        ready_cnt1 <= 'd0;
    end
    else begin
        ready_cnt1 <= ready_cnt1 + 1'd1;
    end
end

endmodule
