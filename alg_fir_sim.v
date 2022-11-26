`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/16 13:33:44
// Design Name: 
// Module Name: alg_fir_sim
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alg_fir_sim(

    );
            reg          clk            =0;    
           reg          rst_n          =0;    
           reg          dat_clk=0;
           
         wire [15:0]  ref_dat;
         reg          ref_dat_valid=0;
           
          wire [15:0]  pem_dat;
          reg          pem_dat_valid=0;   
           
           reg  [9:0]   rom_rd_addr=0;
           reg          rom_rd_en=0;
//           wire  [15:0] pem_ave;
           reg   dat_rst_n=0;
           reg   init_phase_found=0;
           reg [9:0]  rom_rd_cnt;
      wire [15:0]   ref_sync_pem_dat      ; 
      wire    ref_sync_pem_dat_valid; 
      wire  pem_posedge;
      wire         trig_search_cdc;   
      wire  [8:0]  cap_data_number;  
     wire   [15:0] ram_dat      ;
     wire   [8:0]  ram_addr     ;
     wire           ram_wr_valid;
      wire  cap_data_number_valid;
      wire   wave_dat_req;
  wire  [8:0]  wave_addr;
  
  
  wire  [63:0]  sine;
    
  wire  [63:0]  cosine;
    alg_top_fir alg_top_fir_0(
      .alg_clk               (     clk                                  ),                                                                                 //input          alg_clk,
      .alg_rst_n             (    rst_n                                 ),                                                                               //input          alg_rst_n,
      .dat_clk               ( dat_clk                          ),                                                                                 //input          dat_clk,
      .init_phase_found      (  init_phase_found              ),                                                                        //input          init_phase_found,   
      .ref_dat               (   ref_dat               ),                                                                                 //input  [15:0]  ref_dat,
      .ref_dat_valid         (   ref_dat_valid         ),                                                                           //input          ref_dat_valid,
      .pem_dat               (   pem_dat               ),                                                                                 //input  [15:0]  pem_dat,
      .pem_dat_valid         (   pem_dat_valid         ),                                                                           //input          pem_dat_valid,
      .pem_dat_average       (             16'h2012                ),                                                                         //input  [15:0]  pem_dat_average,
      .pem_posedge           (    pem_posedge                      ),                                                                             //output         pem_posedge,
      .wave_dat_sine         (    sine[47:0]                             ),                                                                           //input  [47:0]  wave_dat_sine,
      .wave_dat_cosine       (     cosine[47:0]                           ),                                                                         //input  [47:0]  wave_dat_cosine,
      .wave_dat_req          (  wave_dat_req                     ),                                                                            //output         wave_dat_req,
      .wave_addr             ( wave_addr                         ),                                                                               //output  [8:0]  wave_addr,
      .phase_out             (                                    ),                                                                               //output [31:0]  phase_out,
      .phase_out_valid       (                                    ),                                                                         //output [31:0]  phase_out_valid,
      .ref_sync_pem_dat      (  ref_sync_pem_dat              ),                                                                        //output  [15:0] ref_sync_pem_dat,
      .ref_sync_pem_dat_valid(  ref_sync_pem_dat_valid        )                           //output         ref_sync_pem_dat_valid
    
    );
    cos_gen_1 cos_gen_1_0(
        .clka  (   clk    ),//: IN STD_LOGIC;
        .ena   (wave_dat_req   ),//: IN STD_LOGIC;
        .addra (wave_addr[6:0]    ),//: IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        .douta (  cosine   ) //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
      );
    
    sine_dat_1  sine_dat_1_0(
            .clka  (   clk     ),//: IN STD_LOGIC;
            .ena   ( wave_dat_req  ),//: IN STD_LOGIC;
            .addra (wave_addr[6:0]     ),//: IN STD_LOGIC_VECTOR(6 DOWNTO 0);
            .douta (   sine) //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
          );  
    
    
    
    
    
//     average average_0(
//      . clk      (   dat_clk         ),
//      . rst_n    (  rst_n         ),
//      . din      (   pem_dat       ),
//      . din_valid( pem_dat_valid     ),
//      . dout     (   pem_ave      )
//   );
    
     raw_pem_rom raw_pem_rom_0 (
      .clka (   dat_clk       ), //: IN STD_LOGIC;
      .ena  ( rom_rd_en           ), //: IN STD_LOGIC;
      .addra(  rom_rd_addr-1'b1        ), //: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
      .douta(  pem_dat       )  //: OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
    
         ref_dat_rom ref_dat_rom_0 (
     .clka (   dat_clk        ), //: IN STD_LOGIC;
     .ena  (  rom_rd_en           ), //: IN STD_LOGIC;
     .addra( rom_rd_addr-1'b1        ), //: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
     .douta(   ref_dat         )  //: OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
   );
   
 
   
   
   
   
   
   
   
   
   
   always#4 clk=~clk;
   always#25 dat_clk=~dat_clk;
   
   
   
    initial  begin
    #75
    rst_n=1;
    #750
    dat_rst_n=1;
    #10000
    init_phase_found=1;
    
    
   end
    
    always@(posedge dat_clk)
    begin
    ref_dat_valid<=rom_rd_en;
    pem_dat_valid<=rom_rd_en;
    end
    
    
    always@(posedge dat_clk or negedge dat_rst_n)
    if(!dat_rst_n)
    begin
     rom_rd_addr<=0;
     rom_rd_en<=0;  
    end
       else if((rom_rd_addr==10'd1008)&&(rom_rd_cnt==19))
     begin
          rom_rd_addr<=10'd1 ;
          rom_rd_en<=1;  
         end
    
    
    
    
    else if(rom_rd_cnt==19)
    begin
         rom_rd_addr<=(rom_rd_addr+1);
         rom_rd_en<=1;  
        end
    else 
    begin
        rom_rd_addr<=rom_rd_addr;
          rom_rd_en<=0;     
       end 
   always@(posedge dat_clk or negedge dat_rst_n)
           if(!dat_rst_n)      
        
   rom_rd_cnt <=0;
   else if(rom_rd_cnt==19)
    rom_rd_cnt <=0;
   else
    rom_rd_cnt <=rom_rd_cnt+1'b1; 
    
    
    
endmodule
