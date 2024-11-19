//`include "idh.sv"
//`include "odh.sv"

module sha_uart_top (
        input rst,clk,
        input  i_uart_rx,
        output o_uart_tx,
        output o_done);
  
  
  
  logic [511:0] data_512;
  logic         w_idh_dv;
  
  
  input_data_handler uutidh (
    .uart_rx(i_uart_rx),
    .clk(clk), 
    .rst(rst),
    .d_out(data_512),
    .idh_dv(w_idh_dv) );

	output_data_handler uutodh (
      .w_idata(data_512),
      .clk(clk),
      .rst(rst),
      .o_uart_tx(o_uart_tx),
      .done(o_done),
      .sha_start(w_idh_dv)
			);
    
endmodule 
    
  
  