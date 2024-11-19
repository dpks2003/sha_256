module top (
    input  wire pll_clkout,
    input  wire rst_n,
    output wire pll_inst1_RSTN,
    output reg  test_fail,
    output wire test_pass,
    output wire test_done
);

`include "oneaxi_define.vh"
`include "axi_stream_switch.vh"

localparam DWIDTH      = DATA_BYTE * 8;

wire [S_PORTS-1:0]            s_axis_tvalid;
wire [S_PORTS-1:0]            s_axis_tready;
wire [S_PORTS*DWIDTH-1:0]     s_axis_tdata;
wire [S_PORTS-1:0]            s_axis_tlast;
wire [S_PORTS*DEST_WIDTH-1:0] s_axis_tdest;
wire [S_PORTS*DATA_BYTE-1:0]  s_axis_tstrb;
wire [S_PORTS*DATA_BYTE-1:0]  s_axis_tkeep;
wire [S_PORTS*USER_WIDTH-1:0] s_axis_tuser;
wire [S_PORTS*ID_WIDTH-1:0]   s_axis_tid;
wire [M_PORTS-1:0]            m_axis_tvalid;
wire [M_PORTS-1:0]            m_axis_tready;
wire [M_PORTS*DWIDTH-1:0]     m_axis_tdata;
wire [S_PORTS-1:0]            master_done;
wire [M_PORTS*DWIDTH-1:0]     golden_rdata;
wire [M_PORTS-1:0]            golden_rvalid;
wire [M_PORTS*DWIDTH-1:0]     dest_rdata;
wire [M_PORTS-1:0]            dest_rvalid;
wire                          sys_ready_1;
wire                          sys_ready_2;
wire                          rd_check_en;
wire                          cmp_fail;
wire                          golden_read_done;
wire                          dest_read_done;

assign rd_check_en    = &master_done;
assign pll_inst1_RSTN = 1'b1;

oneaxi efx_axi_stream_switch_DUT (
    .aclk           (pll_clkout),
    .aresetn        (rst_n),
    .s_axis_tvalid  (s_axis_tvalid),
    .s_axis_tready  (s_axis_tready),
    .s_axis_tdata   (s_axis_tdata),
    .s_axis_tlast   (s_axis_tlast),
    .s_axis_tdest   (s_axis_tdest),
    //.s_axis_tstrb (s_axis_tstrb),
    //.s_axis_tkeep (s_axis_tkeep),
    //.s_axis_tuser (s_axis_tuser),
    //.s_axis_tid   (s_axis_tid),
    .m_axis_tvalid  (m_axis_tvalid),
    .m_axis_tready  (m_axis_tready),
    .m_axis_tdata   (m_axis_tdata),
    .m_axis_tlast   (),
    .m_axis_tdest   ()
);

genvar i;
generate
    for (i=0;i<S_PORTS;i=i+1) begin
        efx_custom_axist_master_model # (
            .T_DEST         (S_PORTS-1-i),
            .TDEST_WIDTH    (DEST_WIDTH),
            .DWIDTH         (DWIDTH),
            .DBURST_LEN     (7),
            .TLAST_EN       (TLAST_EN),
            .MAX_XFER_BYTE  (MAX_XFER_BYTE),
            .MAX_TVALID_LOW (MAX_TVALID_LOW)
        ) efx_custom_axist_master_model_inst (
            .clk            (pll_clkout),
            .rst_n          (rst_n),
            .sys_ready      (sys_ready_1 & sys_ready_2),
            .tready         (s_axis_tready[i]),
            .tvalid         (s_axis_tvalid[i]),
            .tdata          (s_axis_tdata[i*DWIDTH+:DWIDTH]),
            .tlast          (s_axis_tlast[i]),
            .tdest          (s_axis_tdest[i*DEST_WIDTH+:DEST_WIDTH]),
            .verify_en      (master_done[i])
        );
    end
endgenerate

golden_data_storage #(
    .S_PORTS       (S_PORTS),
    .M_PORTS       (M_PORTS),
    .DEPTH         (8192),
    .DWIDTH        (DWIDTH)
) golden_data (
    .clk           (pll_clkout),
    .rst_n         (rst_n),
    .rd_check_en   (rd_check_en),
    .s_ready       (s_axis_tready),
    .s_valid       (s_axis_tvalid),
    .s_wdata       (s_axis_tdata),
    .m_rvalid      (golden_rvalid),
    .m_rdata       (golden_rdata),
    .storage_ready (sys_ready_1),
    .read_done     (golden_read_done)
);

dest_data_storage #(
    .M_PORTS       (M_PORTS),
    .DEPTH         (8192),
    .DWIDTH        (DWIDTH)
) dest_data (
    .clk           (pll_clkout),
    .rst_n         (rst_n),
    .rd_check_en   (rd_check_en),
    .s_valid       (m_axis_tvalid),
    .s_wdata       (m_axis_tdata),
    .m_rvalid      (dest_rvalid),
    .m_rdata       (dest_rdata),
    .m_wready      (m_axis_tready),
    .storage_ready (sys_ready_2),
    .read_done     (dest_read_done)
);

assign cmp_fail  = |((golden_rdata & {DWIDTH{golden_rvalid}}) ^ (dest_rdata & {DWIDTH{dest_rvalid}}));
assign test_done = rd_check_en & golden_read_done & dest_read_done;
assign test_pass = test_done & ~test_fail;

always @ (posedge pll_clkout or negedge rst_n) begin
    if (!rst_n) begin
        test_fail <= 1'b0;
    end
    else if (cmp_fail) begin
        test_fail <= 1'b1;
    end
end

endmodule
