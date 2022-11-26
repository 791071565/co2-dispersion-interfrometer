`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/16 11:53:05
// Design Name: 
// Module Name: mix_max_search
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


module mix_max_search(
 input          alg_clk,
   input          alg_rst_n,

   input          research, 
   
   input          sine_valid,
   input [47:0]   sine_wave,
   input [8:0]    sine_addr,
   
   input          cosine_valid,
   input [47:0]   cosine_wave,
   input [8:0]    cosine_addr, 

   output             search_req,
   output  reg [8:0]  search_addr,
   input       [15:0] capture_raw_dat,
   
   // output [11:0]      init_phase,
   // output  reg        init_phase_found,
   //output  reg         stroe_wave,

  
   output  reg [47:0]   sine_wave_r,
   output  reg [47:0]   cosine_wave_r,
   output  reg [8:0]    sine_addr_r,
   output  reg [8:0]    cosine_addr_r,
   output  reg          sine_valid_r,
   output  reg          cosine_valid_r,
   
   
   
 (*mark_debug = "true"*)   output reg  [11:0]   average_1_position_max,
 (*mark_debug = "true"*)   output reg  [11:0]   average_1_position_min,

 (*mark_debug = "true"*)   output reg   [11:0]   average_2_position_max,
 (*mark_debug = "true"*)   output reg   [11:0]   average_2_position_min, 
   
 (*mark_debug = "true"*)   output   wire      init_phase_found_posedge, 
   input              mem_copy_end_1,
   output reg         mem_copy_1,

   input              mem_copy_end_2,
   output reg         mem_copy_2,

   input              mem_copy_end_3,
   output reg         mem_copy_3,

   input              mem_copy_end_4,
   output reg         mem_copy_4,

   output             fft_end//search degree
 );
 
  localparam   IDLE      =8'd0;
  localparam   MIX       =8'd1;
  localparam   MIX_END   =8'd2;
  localparam   CMP_1     =8'd3;
  localparam   MEM_COPY_1=8'd4;
  localparam   CMP_2     =8'd5;
  localparam   MEM_COPY_2=8'd6;
  localparam   FFT_END   =8'd7;
  localparam   WAIT_SYNC =8'd8;
  
 (*mark_debug = "true"*)  reg  [7:0]   state;
 (*mark_debug = "true"*)  reg  [7:0]   state_1;
  reg [63:0]   mix_sine;
  reg [63:0]   mix_cosine;
   
  
  wire          sine_valid_pos;
  wire          sine_valid_neg;
  wire          mix_dat_valid_neg;
//  reg           sine_valid_r;
  reg           mix_dat_valid;
  reg           mix_dat_valid_r;
 
  
  reg           first_sig_1;
  reg           first_sig_2;
  
  reg  [63:0]   average_1_cmp    ;
  reg  [63:0]   average_1_cmp_min;
//  reg  [11:0]   average_1_position_max;
//  reg  [11:0]   average_1_position_min;
//wire          average_1_valid;
  
  reg  [63:0]   average_2_cmp    ;
  reg  [63:0]   average_2_cmp_min;
//  reg  [11:0]   average_2_position_max;
//  reg  [11:0]   average_2_position_min; 
  reg           smaller_1_temp;
  reg           smaller_2_temp;         
//wire          average_2_valid;
  
  reg [11:0]  init_phase_temp;
  reg         init_phase_found;
  reg         init_phase_found_r;
    reg  sync_1;
    reg  sync_2;
    reg  sync_sig;
           
  
  wire  [63:0]  average_1      ;
  wire          average_1_valid;
  
  wire  [63:0]  average_2      ;
  wire          average_2_valid;
  
//  wire   init_phase_found_posedge;       
  
  wire           larger_1 ;
  wire           smaller_1;
  
  wire           larger_2 ;
  wire           smaller_2;
  
  
  wire          cmp_result_valid_0;
  wire          cmp_result_valid_1;
  wire          cmp_result_valid_2;
  wire          cmp_result_valid_3;
  
  wire          cmp_result_0;
  wire          cmp_result_1;
  wire          cmp_result_2;
  wire          cmp_result_3;
  
  
  wire          mix_dat_sof    ;
  wire          mix_dat_eof    ;
  assign        sine_valid_pos   =sine_valid&&(!sine_valid_r);
  assign        search_req       =sine_valid;
  assign        mix_dat_valid_neg=(!mix_dat_valid)&&mix_dat_valid_r;
  assign        mix_dat_sof      = mix_dat_valid&&(!mix_dat_valid_r)  ;
  assign        mix_dat_eof      =  (!sine_valid_r)&&mix_dat_valid ;
  assign        sine_valid_neg   =  (!mix_dat_valid)&& mix_dat_valid_r  ;
  assign        larger_1         =cmp_result_valid_0&&cmp_result_0;
  assign        smaller_1        =cmp_result_valid_1&&(!cmp_result_1);
  
  assign        larger_2         =cmp_result_valid_2&&cmp_result_2;
  assign        smaller_2        =cmp_result_valid_3&&(!cmp_result_3);
  
  assign        fft_end          =(state==FFT_END);
  assign        init_phase_found_posedge=(!init_phase_found_r)&&init_phase_found;
  always@(posedge alg_clk)
   begin
   sine_valid_r  <= sine_valid   ;
   cosine_valid_r<= cosine_valid ;
   mix_dat_valid <= sine_valid_r ;
   mix_dat_valid_r<=mix_dat_valid;
   sine_wave_r   <= sine_wave    ;
   cosine_wave_r <= cosine_wave  ;
//   sine_wave_rr  <= sine_wave_r  ;
//   cosine_wave_rr<= cosine_wave_r;
   sine_addr_r   <= sine_addr    ;
   cosine_addr_r <= cosine_addr  ;
  end
  
 always@(posedge alg_clk or negedge alg_rst_n)
  if(!alg_rst_n)
   search_addr<=0;
  else if(search_req)
   search_addr<=search_addr+1'b1;
  else
   search_addr<=0;

 always@(posedge alg_clk or negedge alg_rst_n)
  if(!alg_rst_n)
   state<=IDLE;
  else begin
   case(state)
   IDLE:
    state<=(sine_valid_pos)?MIX:IDLE;
   MIX :
 //   state<=(mix_dat_valid_neg)?MIX_END:MIX;
    state<=(average_1_valid)?MIX_END:MIX;
   MIX_END:
    state<= CMP_1;
   CMP_1: 
    state<=((cmp_result_valid_0&&larger_1)||(cmp_result_valid_0&&(!first_sig_1)))?MEM_COPY_1:CMP_2;
   MEM_COPY_1:
    state<=(mem_copy_end_1)?CMP_2:MEM_COPY_1;
   CMP_2:
    state<=(smaller_1_temp||(!first_sig_1))?MEM_COPY_2:WAIT_SYNC;
   MEM_COPY_2:
    state<=(mem_copy_end_2)?WAIT_SYNC:MEM_COPY_2;
    
   WAIT_SYNC:
    state<=(sync_sig)?FFT_END:WAIT_SYNC;     
    
   FFT_END: 
    state<= IDLE; 
    
  default:;
  endcase
  end


 always@(posedge alg_clk or negedge alg_rst_n)
  if(!alg_rst_n)
   state_1<=IDLE;
  else begin
   case(state_1)
   IDLE:
    state_1<=(sine_valid_pos)?MIX:IDLE;
   MIX :
 //   state_1<=(mix_dat_valid_neg)?MIX_END:MIX;
    state_1<=(average_2_valid)?MIX_END:MIX;
   MIX_END:
    state_1<= CMP_1;
   CMP_1: 
    state_1<=((cmp_result_valid_2&&larger_2)||(cmp_result_valid_2&&(!first_sig_2)))?MEM_COPY_1:CMP_2;
   MEM_COPY_1:
    state_1<=(mem_copy_end_3)?CMP_2:MEM_COPY_1;
   CMP_2:
    state_1<=(smaller_2_temp||(!first_sig_2))?MEM_COPY_2:WAIT_SYNC;
   MEM_COPY_2:
    state_1<=(mem_copy_end_4)?WAIT_SYNC:MEM_COPY_2;
   WAIT_SYNC:
    state_1<=(sync_sig)?FFT_END:WAIT_SYNC;  
   
   FFT_END: 
    state_1<= IDLE; 
    
  default:;
  endcase
  end


always@(posedge alg_clk or negedge alg_rst_n)
  if(!alg_rst_n)
    begin
     mix_sine  <=64'b0;
     mix_cosine<=64'b0;
    end
  else  if(sine_valid_r) 
    begin
      mix_sine  <=$signed( capture_raw_dat )*$signed(sine_wave_r);
      mix_cosine<=$signed( capture_raw_dat )*$signed(cosine_wave_r);
    end

 always@(posedge alg_clk or negedge alg_rst_n)
  if(!alg_rst_n)
    first_sig_1<=0;
  else if((!first_sig_1)&&(state==CMP_2))
    first_sig_1<=1;
  else if(init_phase_found_posedge ) 
    first_sig_1<=0;
    
    
 always@(posedge alg_clk or negedge alg_rst_n)
  if(!alg_rst_n)
    first_sig_2<=0;
  else if((!first_sig_2)&&(state_1==CMP_2))
    first_sig_2<=1;
  else if(init_phase_found_posedge ) 
    first_sig_2<=0; 
    
    
 always@(posedge alg_clk or negedge alg_rst_n)
  if(!alg_rst_n)
  begin
   init_phase_temp<=0;
   
  end
  else if(sine_valid_neg&&(init_phase_temp==12'd3599))
// else if(sine_valid_neg&&(init_phase_temp==12'd359))
  init_phase_temp<=0;
  
  else if(sine_valid_neg)
   begin
    init_phase_temp<=init_phase_temp+1;
  
   end

 always@(posedge alg_clk or negedge alg_rst_n)
  if(!alg_rst_n)
  init_phase_found<=1'b0;
  //else if(sine_valid_neg&&(init_phase_temp==12'd3599))
  //else if((state_1==FFT_END)&&(init_phase_temp==12'd3599))
  else if((state_1==FFT_END)&&(init_phase_temp==12'd0))
    
  init_phase_found<=1'b1;
  else if( research )
  init_phase_found<=1'b0;

 always@(posedge alg_clk)
   init_phase_found_r<=init_phase_found;
    
    
 always@(posedge alg_clk or negedge alg_rst_n)
  if(!alg_rst_n) 
    average_1_cmp <=0 ;
  else if(cmp_result_valid_0&&(!first_sig_1))
    average_1_cmp <=average_1;
  else if(cmp_result_valid_0&&(first_sig_1)&&larger_1)
    average_1_cmp <=average_1; 
    
    
    
    
 always@(posedge alg_clk or negedge alg_rst_n)
  if(!alg_rst_n) 
    average_1_cmp_min <=0 ;
  else if(cmp_result_valid_0&&(!first_sig_1))
    average_1_cmp_min <=average_1;
  else if(cmp_result_valid_0&&(first_sig_1)&&smaller_1)
    average_1_cmp_min <=average_1;  
    
  /* reg  [11:0]   average_1_position_max;
  reg  [11:0]   average_1_position_min;  */
    
  always@(posedge alg_clk or negedge alg_rst_n)
  if(!alg_rst_n) 
    average_1_position_max <=0 ;
  else if(cmp_result_valid_0&&(!first_sig_1))
    average_1_position_max <=init_phase_temp;
  else if(cmp_result_valid_0&&(first_sig_1)&&larger_1)
    average_1_position_max <=init_phase_temp;  
    
  always@(posedge alg_clk or negedge alg_rst_n)
  if(!alg_rst_n) 
    average_1_position_min <=0 ;
  else if(cmp_result_valid_0&&(!first_sig_1))
    average_1_position_min <=init_phase_temp;
  else if(cmp_result_valid_0&&(first_sig_1)&&smaller_1)
    average_1_position_min <=init_phase_temp;   
   
   
   
   
   
   
   
   
    
 always@(posedge alg_clk or negedge alg_rst_n)
  if(!alg_rst_n) 
    average_2_cmp <=0 ;
  else if( cmp_result_valid_2&&(!first_sig_2) )
    average_2_cmp <=average_2;
  else if(cmp_result_valid_2&&(first_sig_2)&&larger_2)
    average_2_cmp <=average_2; 
    
    
    
    
 always@(posedge alg_clk or negedge alg_rst_n)
  if(!alg_rst_n) 
    average_2_cmp_min <=0 ;
  else if( cmp_result_valid_2&&(!first_sig_2) )
    average_2_cmp_min <=average_2;
  else if(cmp_result_valid_2&&(first_sig_2)&&smaller_2)
    average_2_cmp_min <=average_2;  
    
  /* reg  [11:0]   average_1_position_max;
  reg  [11:0]   average_1_position_min;  */
    
  always@(posedge alg_clk or negedge alg_rst_n)
  if(!alg_rst_n) 
    average_2_position_max <=0 ;
  else if(cmp_result_valid_2&&(!first_sig_2))
    average_2_position_max <=init_phase_temp;
  else if(cmp_result_valid_2&&(first_sig_2)&&larger_2)
    average_2_position_max <=init_phase_temp;  
    
  always@(posedge alg_clk or negedge alg_rst_n)
  if(!alg_rst_n) 
    average_2_position_min <=0 ;
  else if(cmp_result_valid_2&&(!first_sig_2))
    average_2_position_min <=init_phase_temp;
  else if(cmp_result_valid_2&&(first_sig_2)&&smaller_2)
    average_2_position_min <=init_phase_temp;   
    
 always@(posedge alg_clk or negedge alg_rst_n)
  if(!alg_rst_n) 
    smaller_1_temp<=0;
  else if(cmp_result_valid_0&&smaller_1)
    smaller_1_temp<=1; 
  else if( state==FFT_END ) 
    smaller_1_temp<=0;
    
     
 always@(posedge alg_clk or negedge alg_rst_n)
  if(!alg_rst_n) 
    smaller_2_temp<=0;
  else if(cmp_result_valid_2&&smaller_2)
    smaller_2_temp<=1; 
  else if( state_1==FFT_END ) 
    smaller_2_temp<=0; 
    
 always@(posedge alg_clk or negedge alg_rst_n)
  if(!alg_rst_n)  
    mem_copy_1<=0;
   else  
    mem_copy_1<=(((state==CMP_1)&&cmp_result_valid_0&&larger_1)||((state==CMP_1)&&cmp_result_valid_0&&(!first_sig_1)));
 always@(posedge alg_clk or negedge alg_rst_n)
  if(!alg_rst_n)  
    mem_copy_2<=0;
  else
    mem_copy_2<=((smaller_1_temp&&(state==CMP_2))||((!first_sig_1)&&(state==CMP_2))); 
    
 always@(posedge alg_clk or negedge alg_rst_n)
  if(!alg_rst_n)  
    mem_copy_3<=0; 
  else  
    mem_copy_3<=(((state_1==CMP_1)&&cmp_result_valid_2&&larger_2 )||((state_1==CMP_1)&&cmp_result_valid_2&&(!first_sig_2)));
    
 always@(posedge alg_clk or negedge alg_rst_n)
  if(!alg_rst_n)  
    mem_copy_4<=0;
  else
    mem_copy_4<=((smaller_2_temp&&(state_1==CMP_2))||((!first_sig_2)&&(state_1==CMP_2)));  

  
   always@(posedge alg_clk or negedge alg_rst_n)
  if(!alg_rst_n)  
    
    sync_1<=0;
    
      else if(state==FFT_END)
      sync_1<=0;
    
    else if( state==WAIT_SYNC )
    sync_1<=1;
  
    
    always@(posedge alg_clk or negedge alg_rst_n)
  if(!alg_rst_n)  
    
    sync_2<=0;
    
   else if(state_1==FFT_END)
    sync_2<=0;
    
    
   else if(state_1==WAIT_SYNC )
    sync_2<=1;

    always@(posedge alg_clk or negedge alg_rst_n)
     if(!alg_rst_n) 
    sync_sig<=0;
      else if((!sync_1)&&(!sync_2))
     sync_sig<=0;
   
   
    else if((sync_1&&sync_2))
    sync_sig<=1;

    
// #(
  // parameter max_average_count = 10'd1001,
  // parameter C_DATA_WIDTH = 54
// )

 average_calcu_float#(
    . max_average_count ( 10'd1001),
    . C_DATA_WIDTH      ( 54      ) //1bit sign 17 bit int 36 bit int
  )
 average_calcu_float_0 (
     .clk            (  alg_clk                            ),                                            //input                       clk,
     .rst_n          (  alg_rst_n                          ),                                          //input                       rst_n,
     .DATA_in        (  mix_sine[63:10]                    ),                                  //input [C_DATA_WIDTH-1:0]    DATA_in      ,
     .DATA_sof       (  mix_dat_sof      ),                                  //input                       DATA_sof     ,
     .DATA_eof       (  mix_dat_eof   ),                                  //input                       DATA_eof     ,
     .DATA_in_valid  (   mix_dat_valid   ),                                  //input                       DATA_in_valid,                 
     .DATA_in_ready  (                                     ),                                  //output                      DATA_in_ready,                           
     .data_out       (  average_1                 ),                                //output[63:0]                data_out       , 
     .data_out_valid (  average_1_valid           )                                 //output                      data_out_valid    
     
  );

 average_calcu_float#(
    . max_average_count ( 10'd1001),
    . C_DATA_WIDTH      ( 54      ) //1bit sign 17 bit int 36 bit int
  )
 average_calcu_float_1 (
     .clk            (  alg_clk                            ),                                            //input                       clk,
     .rst_n          (  alg_rst_n                          ),                                          //input                       rst_n,
     .DATA_in        (   mix_cosine[63:10]                    ),                                  //input [C_DATA_WIDTH-1:0]    DATA_in      ,
     .DATA_sof       (   mix_dat_sof        ),                                  //input                       DATA_sof     ,
     .DATA_eof       (   mix_dat_eof      ),                                  //input                       DATA_eof     ,
     .DATA_in_valid  (   mix_dat_valid   ),                                  //input                       DATA_in_valid,                 
     .DATA_in_ready  (                                     ),                                  //output                      DATA_in_ready,                           
     .data_out       (   average_2                ),                                //output[63:0]                data_out       , 
     .data_out_valid (   average_2_valid          )                                 //output                      data_out_valid    
     
  );
wire [6:0]  reserve_0;
wire [6:0]  reserve_1;
wire [6:0]  reserve_2;
wire [6:0]  reserve_3;
 fp_double_cmp_greater fp_double_cmp_greater_0(
   .aclk                 (   alg_clk                     ),//: IN STD_LOGIC;
   .s_axis_a_tvalid      (    average_1_valid                ),//: IN STD_LOGIC;
   .s_axis_a_tdata       (    average_1                  ),//: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
   .s_axis_b_tvalid      (    average_1_valid             ),//: IN STD_LOGIC;
   .s_axis_b_tdata       (    average_1_cmp               ),//: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
   .m_axis_result_tvalid (  cmp_result_valid_0            ),//: OUT STD_LOGIC;
   .m_axis_result_tdata  (    {reserve_0,cmp_result_0}                           )  //: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );

 fp_double_cmp_greater fp_double_cmp_greater_1(
   .aclk                 (   alg_clk                    ),//: IN STD_LOGIC;
   .s_axis_a_tvalid      (   average_1_valid            ),//: IN STD_LOGIC;
   .s_axis_a_tdata       (   average_1                  ),//: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
   .s_axis_b_tvalid      (   average_1_valid               ),//: IN STD_LOGIC;
   .s_axis_b_tdata       (   average_1_cmp_min              ),//: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
   .m_axis_result_tvalid (  cmp_result_valid_1          ),//: OUT STD_LOGIC;
   .m_axis_result_tdata  (     {reserve_1,cmp_result_1}          )  //: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );

 fp_double_cmp_greater fp_double_cmp_greater_2(
   .aclk                 (  alg_clk                      ),//: IN STD_LOGIC;
   .s_axis_a_tvalid      (  average_2_valid             ),//: IN STD_LOGIC;
   .s_axis_a_tdata       (  average_2                   ),//: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
   .s_axis_b_tvalid      (  average_2_valid              ),//: IN STD_LOGIC;
   .s_axis_b_tdata       (  average_2_cmp                ),//: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
   .m_axis_result_tvalid ( cmp_result_valid_2           ),//: OUT STD_LOGIC;
   .m_axis_result_tdata  (   {reserve_2,cmp_result_2}           )  //: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );

 fp_double_cmp_greater fp_double_cmp_greater_3(
   .aclk                 (  alg_clk                    ),//: IN STD_LOGIC;
   .s_axis_a_tvalid      (  average_2_valid               ),//: IN STD_LOGIC;
   .s_axis_a_tdata       (  average_2                     ),//: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
   .s_axis_b_tvalid      (  average_2_valid              ),//: IN STD_LOGIC;
   .s_axis_b_tdata       (  average_2_cmp_min            ),//: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
   .m_axis_result_tvalid (  cmp_result_valid_3          ),//: OUT STD_LOGIC;
   .m_axis_result_tdata  (  {reserve_3,cmp_result_3}             )  //: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );








 


  
endmodule