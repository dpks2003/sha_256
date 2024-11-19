//`include "uart_rx.sv"
module input_data_handler ( input uart_rx,
                          // input  uart_dv,
                           input clk, rst,
                           output reg [511:0] d_out,
                           output reg idh_dv);
  
  
  
  
    logic receive_done = '0;
    logic [7:0] rx_word_count = '0;
    logic [1:0] state ;
  	logic [7:0] o_Rx_Byte;
  	logic uart_dv;
  
    
    
    localparam IDLE = 2'b00;
    localparam LOAD = 2'b01;
    localparam SEND = 2'b10;
    localparam DONE = 2'b11;
  
  uart_rx userx (
    .i_Clock(clk),
    .i_Rx_Serial(uart_rx),
    .o_Rx_DV(uart_dv),
    .o_Rx_Byte(o_Rx_Byte)
  );
  
  always @ (posedge clk) begin 
    if (rst) begin 
      d_out <= '0;
      receive_done <= '0;
      idh_dv<= '0;
      state <= IDLE;
      
    end else begin 
      case (state) 
        
        
        IDLE: begin 
          if (rst) begin 
            state <= IDLE;
            idh_dv<='0;
            d_out <= '0;
          end 
          else begin 
           // rx_word_count <=0;
           // idh_dv <= 0;
            state<= LOAD;
          end 
        end
          
        LOAD :begin
          if (uart_dv && rx_word_count < 64) begin
            d_out[511-(rx_word_count*8) -: 8] <= o_Rx_Byte;
            rx_word_count <= rx_word_count + 1 ;
            state <= SEND;
            
          end
          
          else begin 
            state <= LOAD;
          end
          
        end 
        
        SEND : begin 
          
          if ( rx_word_count == 64) begin 
            state <= DONE;
          end
          
          else begin 
            state <= LOAD;
          end 
          
        end 
        
        DONE : begin 
          idh_dv <= 1;
          state<= IDLE;
          rx_word_count <='0;
          
        end 
        
        default : begin 
          state <= IDLE;
        end 
      endcase 
        end 
    
    end
endmodule