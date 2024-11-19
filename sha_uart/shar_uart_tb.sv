`timescale 1ns/1ns
`include "top.sv"
`include "uart_tx.sv"
module tb_sha_uart; 
  
  logic rst, clk, o_uart_tx, done;
   

  
 
  sha_uart uut (
    .clk(clk),
    .rst(rst),
    .o_uart_tx(o_uart_tx),
    .done(done) ) ;
  
	
  
  initial clk = 0;
  always #50clk= !clk;
  
  
  initial begin
    
    $dumpfile("tb_sha_256.vcd");
    $dumpvars(0,uut);
    
    rst = '1;
   // uart_tx = 1;
    
    #20;
    rst = '0;

  
 		

   
    #100000000;

   
    $display("Signatu values:");
   
    $display("Signature value: %h", o_uart_tx);
    

    $finish;
    
  end
    
endmodule
