//`include "uart_tx.sv"
//`include "sha_256_fsm_v1.sv"


module sha_uart (
    input wire clk,
    input wire rst,
    output reg o_uart_tx,
    output reg done
);

    logic [511:0] w_idata = 512'b01101000011001010110110001101100011011110010000001110111011011110111001001101100011001001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001011000;
    logic [255:0] signature;
    logic [7:0] data_chunk = '0;
    logic hashdone;
    logic tx_done;
    logic tx_valid = '0;
    logic o_Tx_active;
    logic [5:0] chunk_index = '0;
    logic [1:0] state;

    localparam IDLE = 2'b00;
    localparam LOAD = 2'b01;
    localparam SEND = 2'b10;
    localparam DONE = 2'b11;

    sha_256_fsm_3cyc useone (
        .i_data(w_idata),
        .signature(signature),
        .clk(clk),
        .rst(rst),
        .hash_done(hashdone)
    );

    uart_tx useuart (
        .i_Clock(clk),
        .i_Tx_DV(tx_valid),
        .i_Tx_Byte(data_chunk),
        .o_Tx_Active(o_Tx_active),
        .o_Tx_Serial(o_uart_tx),
        .o_Tx_Done(tx_done)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_chunk <= '0;
            done <= '0;
            tx_valid <= '0;
            chunk_index <= '0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if (hashdone && ~rst) begin
                        state <= LOAD;
                    end
                    else if (rst) begin
                        state <= IDLE;
                    end
                end
                LOAD: begin
                    if (!o_Tx_active) begin
                        data_chunk <= signature[chunk_index*8 +: 8];
                        chunk_index <= chunk_index + 1'b1;
                        tx_valid <= 1;
                        state <= SEND;
                    end
                end
                SEND: begin
                    if (o_Tx_active) begin
                        tx_valid <= 0;
                        if (chunk_index == 32) begin
                            state <= DONE;
                        end else begin
                            state <= LOAD;
                        end
                    end
                end
                DONE: begin
                    done <= 1'b1;
                end
            endcase
        end
    end

endmodule

/*module sha_uart ( input clk,rst,
                 output reg o_uart_tx,done);
  
  
  logic [511:0] w_idata = 512'b01101000011001010110110001101100011011110010000001110111011011110111001001101100011001001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001011000;   //;// 512bit date here for processing ;
  
  logic [255:0] signature ;
  
  
  logic [7:0] data_chunk= '0;
  
  logic hashdone  ; //= '0;
  
  logic  tx_done ,//= '0,
      	 tx_valid = '0,
      	 o_Tx_active ;//='0;
  
  logic [5:0] chunk_index= '0;

  
  
  
  sha_256_fsm_v1  useone ( 
    .i_data (w_idata),
    .signature(signature),
    .clk(clk),
    .rst(rst),
    .hash_done(hashdone) );
  
  
  o_uart_tx useuart (
    
    .i_Clock(clk),
    .i_Tx_DV(tx_valid),
    .i_Tx_Byte(data_chunk),
    .o_Tx_Active(o_Tx_active),
    .o_Tx_Serial(o_uart_tx),
    .o_Tx_Done(tx_done) );
  
  
  always @(posedge clk) begin 
    if (rst) begin
      data_chunk <= '0;
      done <='0;
      tx_valid = '0;
      
    end 
    
    else if ( hashdone) begin 
      
      if ( chunk_index < 32 && ! o_Tx_active) begin 
        tx_valid <= 1;
        data_chunk <= signature [chunk_index*8 +:8];
        //tx_valid <= 1;
        chunk_index <= chunk_index + 1'b1;
        
      end
      
      else if (chunk_index ==32) begin 
        done = 1'b1;
        
      
      
    end 
  end 
  end

    
    endmodule*/
    