module efx_custom_axist_master_model # (
    parameter                     T_DEST         = 0,
    parameter                     TDEST_WIDTH    = 0,
    parameter                     DWIDTH         = 8,
    parameter                     DBURST_LEN     = 7,
    parameter                     TLAST_EN       = 1,
    parameter                     MAX_XFER_BYTE  = 1024,
    parameter                     MAX_TVALID_LOW = 1024,
    parameter                     CNT_WIDTH      = TLAST_EN ? DBURST_LEN : 10
)(
    input  wire                   clk,
    input  wire                   rst_n,
    input  wire                   sys_ready,
    input  wire                   tready,
    output wire                   tvalid,
    output wire [DWIDTH-1:0]      tdata,
    output wire                   tlast,
    output wire [TDEST_WIDTH-1:0] tdest,
    output wire                   verify_en
);

localparam IDLE          = 0,
           PRE_SEND_DATA = 1,
           SEND_DATA     = 2,
           ROUND_CHECK   = 3,
           DONE          = 4;

reg [3:0]            state;
reg [3:0]            next_state;
reg [31:0]           data_reg;
reg                  opdone;
reg [CNT_WIDTH-1:0]  dcnt;
reg [3:0]            round_cnt;
reg                  tvalid_int;
reg [10:0]           tvalid_low_cnt;

wire [31:0]          crc_data;
wire                 halt;
wire                 force_low;

assign tdest     = T_DEST;
assign tdata     = crc_data[((T_DEST+1)*DWIDTH)-1:T_DEST*DWIDTH];
assign tlast     = TLAST_EN & (&dcnt);
assign verify_en = opdone;
assign halt      = TLAST_EN ? tlast : (MAX_TVALID_LOW > 0) ? (tvalid_low_cnt == MAX_TVALID_LOW-1) : (dcnt == MAX_XFER_BYTE);
assign force_low = (MAX_TVALID_LOW > 0) & (dcnt >= MAX_XFER_BYTE/2-1);
assign tvalid    = tvalid_int & ~force_low;

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        state <= IDLE;
    end
    else begin
        state <= next_state;
    end
end

always @ (*) begin
    case (state)
        IDLE          : begin if (sys_ready)    next_state = PRE_SEND_DATA; else next_state = IDLE;          end
        PRE_SEND_DATA : begin if (tready)       next_state = SEND_DATA;     else next_state = PRE_SEND_DATA; end
        SEND_DATA     : begin if (halt)         next_state = ROUND_CHECK;   else next_state = SEND_DATA;     end
        ROUND_CHECK   : begin if (round_cnt[3]) next_state = DONE;          else next_state = PRE_SEND_DATA; end
        DONE          : begin                   next_state = DONE;                                           end
        default       : begin                   next_state = IDLE;                                           end
    endcase
end

always @ (*) begin
    tvalid_int = 1'b0;
    opdone     = 1'b0;
    case (state)
        PRE_SEND_DATA : begin tvalid_int = 1'b1; end
        SEND_DATA     : begin tvalid_int = 1'b1; end
        ROUND_CHECK   : begin end
        DONE          : begin opdone = 1'b1;     end
        default       : begin end
    endcase
end

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        data_reg <= 'd0;
    end
    else if (opdone) begin
        data_reg  <= 'd0;
    end
    else if (tready && tvalid_int) begin
        data_reg <= data_reg + 1'd1;
    end
end

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        dcnt     <= 'd1;
    end
    else if (halt) begin
        dcnt      <= 'd1;
    end
    else if (tready && tvalid_int) begin
        dcnt     <= dcnt + 1'd1;
    end
end

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        round_cnt <= 'd0;
    end
    else if (opdone) begin
        round_cnt <= 'd0;
    end
    else if (halt) begin
        round_cnt <= round_cnt + 1'd1;
    end
end

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        tvalid_low_cnt <= 'd0;
    end
    else if (halt) begin
        tvalid_low_cnt <= 'd0;
    end
    else if (MAX_TVALID_LOW > 0 && force_low && tready) begin
        tvalid_low_cnt <= tvalid_low_cnt + 1'd1;
    end
end

efx_crc32 crc32_inst(
    .clk     (clk),
    .reset_n (rst_n),
    .clear   (opdone),
    .crc_en  (tready & tvalid_int),
    .data_in (data_reg),
    .crc_out (crc_data)
);

endmodule
