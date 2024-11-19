module sha_256_fsm_3cyc (
  input [0:511] i_data,
    output reg [0:255] signature,
    input          clk,
    input          rst,
    input          sha_start,
    output reg     hash_done
 );
    // for fsm 
  logic [3:0] state,next;

    logic[3:0] scheuleing  = 4'b0000,
               compressing = 4'b0001,
               done        = 4'b0010,
               ideal       = 4'b0100;
    
    integer i;
    // for schedular
    logic [31:0] w[63:0];
  logic [31:0] s0 ='0 ,
  				s1='0;


    // internal flags
    logic sch_done  = '0;
    logic comp_done = '0;
         // hash_done = '0;

    // constant for the compression 
    logic [2047:0] k = {
	    32'h428a2f98, 32'h71374491, 32'hb5c0fbcf, 32'he9b5dba5,
		32'h3956c25b, 32'h59f111f1, 32'h923f82a4, 32'hab1c5ed5,
		32'hd807aa98, 32'h12835b01, 32'h243185be, 32'h550c7dc3,
		32'h72be5d74, 32'h80deb1fe, 32'h9bdc06a7, 32'hc19bf174,
		32'he49b69c1, 32'hefbe4786, 32'h0fc19dc6, 32'h240ca1cc,
		32'h2de92c6f, 32'h4a7484aa, 32'h5cb0a9dc, 32'h76f988da,
		32'h983e5152, 32'ha831c66d, 32'hb00327c8, 32'hbf597fc7,
		32'hc6e00bf3, 32'hd5a79147, 32'h06ca6351, 32'h14292967,
		32'h27b70a85, 32'h2e1b2138, 32'h4d2c6dfc, 32'h53380d13,
		32'h650a7354, 32'h766a0abb, 32'h81c2c92e, 32'h92722c85,
		32'ha2bfe8a1, 32'ha81a664b, 32'hc24b8b70, 32'hc76c51a3,
		32'hd192e819, 32'hd6990624, 32'hf40e3585, 32'h106aa070,
		32'h19a4c116, 32'h1e376c08, 32'h2748774c, 32'h34b0bcb5,
		32'h391c0cb3, 32'h4ed8aa4a, 32'h5b9cca4f, 32'h682e6ff3,
		32'h748f82ee, 32'h78a5636f, 32'h84c87814, 32'h8cc70208,
		32'h90befffa, 32'ha4506ceb, 32'hbef9a3f7, 32'hc67178f2};

    logic [31:0] H0=32'h6a09e667,
	        H1=32'hbb67ae85,
	        H2=32'h3c6ef372,
	        H3=32'ha54ff53a,
	        H4=32'h510e527f,
	        H5=32'h9b05688c,
	        H6=32'h1f83d9ab,
	        H7=32'h5be0cd19;

  	logic [31:0] a=32'h6a09e667,
	        b=32'hbb67ae85,
	        c=32'h3c6ef372,
	        d=32'ha54ff53a,
	        e=32'h510e527f,
	        f=32'h9b05688c,
	        g=32'h1f83d9ab,
	        h=32'h5be0cd19;
  
  logic [31:0] temp_a='0,
	         temp_b='0,
	         temp_c='0,
	         temp_d='0,
	         temp_e='0,
	         temp_f='0,
	         temp_g='0,
	         temp_h='0;

    logic [31:0] temp_H0= '0,
	        temp_H1='0,
	        temp_H2='0,
	        temp_H3='0,
	        temp_H4='0,
	        temp_H5='0,
	        temp_H6='0,
	        temp_H7='0;




    // for compressing 

  logic [31:0] S0='0,
  				S1='0,
  				ch='0,
  				tmp1='0,
  				maj='0,
    			tmp2='0;
	




    // fsm 
  
  always@(posedge clk)begin
     
        case (state)
            ideal: begin
                if (rst)begin
                    signature = '0;
                  state <= ideal;
                  hash_done <=0;
                end

              else if (~hash_done && sha_start) begin
                   state <= scheuleing; 
                end
                
            end 

            scheuleing : begin

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
             // i <= 0;
                sch_done  = '1;
                state <= compressing;
               
              
                
            end

            compressing : begin
              
          //if(sch_done) begin 
              for (i=0; i<64; i= i + 1) begin
                    S1 = {e[5:0],e[31:6]} ^ {e[10:0],e[31:11]} ^ {e[24:0],e[31:25]} ;
                    ch = (e & f) ^ (~e & g);
                    tmp1 = h + S1 + ch + k[2047-i*32 -: 32] + w[i];
			        S0 = {a[1:0],a[31:2]} ^ {a[12:0],a[31:13]} ^ {a[21:0],a[31:22]} ;
                    maj = (a & b) ^ (a & c) ^ (b & c);
			        tmp2 = S0 + maj;
                     
        	        
                	
                	temp_h = g;
        	        temp_g = f;
        	        temp_f = e;
        	        temp_e = d + tmp1;
        	        temp_d = c;
        	        temp_c = b;
        	        temp_b = a;
        	        temp_a = tmp1+ tmp2;
               
                
                	a = temp_a;
					b = temp_b;
					c = temp_c;
					d = temp_d; 
					e = temp_e;
					f = temp_f;
					g = temp_g;
	 				h = temp_h;
   
    	        end

    	        temp_H0 <= H0 + a;
    	        temp_H1 <= H1 + b;
    	        temp_H2 <= H2 + c;
    	        temp_H3 <= H3 + d;
    	        temp_H4 <= H4 + e;
    	        temp_H5 <= H5 + f;
    	        temp_H6 <= H6 + g;
                temp_H7 <= H7 + h;
              
              

                state <= done;
                comp_done <= '1; 
              
             

              //d
                
            end

            done : begin
                signature <= {temp_H0,temp_H1,temp_H2,temp_H3,temp_H4,temp_H5,temp_H6,temp_H7};
                hash_done <='1;
                state <= ideal;
                
            end
            default: begin
             state <= ideal;
            end
        endcase
    end
    
    
endmodule 