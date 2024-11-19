
module sha_256_schedular (
  input [0:511] i_data,  
  output wire [31:0] w_out [63:0],
  output reg sch_done 
);

  reg [31:0] w[63:0];
 // reg [31:0] u[0:63];
  reg [31:0] s0, s1;
 // reg sch_done = 1'b0; 
  integer i;

 // converting the input 512 bit to 64 words of 32 bit each 
  always @(*) begin
    for (i = 0; i < 64; i = i + 1) begin  
      if (i < 16) begin
        w[i] = i_data[(i * 32) +: 32];
      end
  
 // to create the 64 32 bit words scheduler W for hashing 
      else begin
     
        s0 = ({w[i-15][6:0], w[i-15][31:7]} ^  {w[i-15][17:0], w[i-15][31:18]} ^ (w[i-15] >> 3));
        s1 = ({w[i-2][16:0], w[i-2][31:17]} ^ {w[i-2][18:0], w[i-2][31:19]} ^  (w[i-2] >> 10));                 
        w[i] = w[i-16] + s0 + w[i-7] + s1;
      end 
    end
    sch_done = 1'b1;
  end 

  // Creating the message schedule 
  assign w_out = w;
  
endmodule