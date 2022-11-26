`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/07 14:33:38
// Design Name: 
// Module Name: phase_calcu
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


module phase_calcu(
 input          alg_clk,
  input          alg_rst_n,                
  input          rst_n,
  input  [15:0]  ref_sync_with_pem_dat      ,//1 bit sign 15 bit int
  input          ref_sync_with_pem_dat_valid,
  input          pem_posedge    ,
  input          search_end     ,
 (*mark_debug = "true"*)  input   [47:0] wave_dat_sine  ,//1 bit sign 1 bit int 46 bit
 (*mark_debug = "true"*)  input   [47:0] wave_dat_cosine,
  input   [31:0] atan_coef,
  
  
 (*mark_debug = "true"*)  output         wave_dat_req   ,
 (*mark_debug = "true"*)  output   [8:0] wave_addr      ,  
  output [31:0]  phase_out      ,
  output         phase_out_valid ,
  
  output        buf_refresh    ,
  
    output [127:0]  phase_out_shift       ,
  output            phase_out_shift_valid 
      
  );
  
   reg [8:0]   wave_addr_r            ;
   reg [63:0]  mix_sine               ;//1bit sign 17 bit int 46 bit fraction
   reg [63:0]  mix_cosine             ;//1bit sign 17 bit int 46 bit fraction
   reg         start_mix              ;
   reg         wave_dat_req_r         ;
   reg         wave_dat_req_rr        ;
   reg         pem_posedge_r          ;
   reg         pem_posedge_rr         ;
   reg         pem_posedge_rrr        ;
   reg  [15:0] ref_sync_with_pem_dat_r;
   reg         ping_pong_sig          ;      
   reg         sync_pem               ;
   reg [95:0]  wave_dat_sine_r        ;//1 bit sign 3bit int 92 bit fraction  
   reg [95:0]  wave_dat_cosine_r      ;
   reg         div_ping_pong_sig      ;
    reg  [7:0] pem_posedge_cnt;
   
   wire [63:0]  mean_mix_sine_ping      ;  //1bit sign 17 bit int 46 bit fraction
   wire         mean_mix_sine_ping_valid;
  
   wire [63:0]  mean_mix_sine_pong      ;  //
   wire         mean_mix_sine_pong_valid;
  
   wire [63:0]  mean_mix_cosine_ping      ;//
   wire         mean_mix_cosine_ping_valid;
  
   wire [63:0]  mean_mix_cosine_pong      ;//
   wire         mean_mix_cosine_pong_valid;
  
   wire [63:0]  mean_sine_ping      ;//
   wire         mean_sine_ping_valid;
  
   wire [63:0]  mean_sine_pong      ;//
   wire         mean_sine_pong_valid;
  
   wire [63:0]  mean_cosine_ping      ;//
   wire         mean_cosine_ping_valid;
  
   wire [63:0]  mean_cosine_pong      ;//
   wire         mean_cosine_pong_valid;
  
  
localparam PI_fix=32'b01100100100000000000000000000000; //0 sign 11 interger 0010010000000 fraction 29
localparam PI_inv_fix=  {~PI_fix[31],~PI_fix[30:0]+1'b1}; 
  localparam PI_fix_ex=33'b001100100100000000000000000000000;
  assign  wave_dat_req=((sync_pem&&ref_sync_with_pem_dat_valid)||(pem_posedge&&start_mix&&(!sync_pem)));
  assign   wave_addr =(wave_dat_req&&pem_posedge&&(pem_posedge_cnt==8'd4))?9'd0:wave_addr_r;
  
   always@(posedge alg_clk or negedge rst_n)
    if(!rst_n)
    start_mix<=0;
   else if(search_end)
    start_mix<=1'b1;
  
   always@(posedge alg_clk or negedge alg_rst_n)
    if(!alg_rst_n)
    sync_pem<=0;
    else if(start_mix&&pem_posedge)
    sync_pem<=1;
  
 
  
   always@(posedge alg_clk or negedge alg_rst_n)
     if(!alg_rst_n)
  pem_posedge_cnt<=0;
  else if( pem_posedge&&(pem_posedge_cnt==8'd4)  )
   pem_posedge_cnt<=0;
  else if(pem_posedge&&sync_pem)
    pem_posedge_cnt<=pem_posedge_cnt+1'b1; 
  
  
  always@(posedge alg_clk or negedge alg_rst_n)
    if(!alg_rst_n)
    wave_addr_r<=0;
    else if(wave_dat_req&&pem_posedge&&(pem_posedge_cnt==8'd4))
    wave_addr_r<=1'b1;
    else if(wave_dat_req)
    wave_addr_r<=wave_addr_r+1;
  
  reg   sync_pem_posedge_rr;
  
   always@(posedge alg_clk)
    begin
     ref_sync_with_pem_dat_r<=ref_sync_with_pem_dat;
     wave_dat_req_r         <=wave_dat_req;
     wave_dat_req_rr        <=wave_dat_req_r;
     pem_posedge_r          <=(pem_posedge&&sync_pem)||(pem_posedge&&start_mix&&(!sync_pem));
     sync_pem_posedge_rr    <=pem_posedge&&sync_pem&&(pem_posedge_cnt==8'd4);
     pem_posedge_rr         <=pem_posedge_r;
     pem_posedge_rrr        <=pem_posedge_rr;
    end
  
  
   always@(posedge alg_clk or negedge alg_rst_n)
     if(!alg_rst_n)
     begin
      mix_sine  <=0;
      mix_cosine<=0;      
     end
     else if(wave_dat_req_r)//
     begin
      mix_sine  <=$signed(wave_dat_sine  )*$signed(ref_sync_with_pem_dat_r);
      mix_cosine<=$signed(wave_dat_cosine)*$signed(ref_sync_with_pem_dat_r);
     end
     
    always@(posedge alg_clk or negedge alg_rst_n)
     if(!alg_rst_n) 
      ping_pong_sig<=0;
     else if(sync_pem_posedge_rr)//end of a frame
      ping_pong_sig<=~ping_pong_sig;
      
   always@(posedge alg_clk or negedge alg_rst_n)
     if(!alg_rst_n)
       begin
       wave_dat_sine_r  <=0;
       wave_dat_cosine_r<=0;
       end
      else 
       begin
       wave_dat_sine_r  <=$signed(wave_dat_sine)*$signed(wave_dat_sine)  ;
       wave_dat_cosine_r<=$signed(wave_dat_cosine)*$signed(wave_dat_cosine) ;        
       end
  
   always@(posedge alg_clk or negedge alg_rst_n)
     if(!alg_rst_n)
      div_ping_pong_sig<=0;   
     else if(mean_mix_sine_ping_valid||mean_mix_sine_pong_valid)
      div_ping_pong_sig<=~div_ping_pong_sig;
  
  
  
  //output  1bit sign   63 bit int   15 bit fraction
  //mean_mix_sine_ping[77:0]  64 bit     54 10
  //we select  {mean_mix_sine_ping[77],mean_mix_sine_ping[68:15],mean_mix_sine_ping[14:5]}
   
   
   average_calcu_float#(
    . max_average_count ( 10'd1001),
    . C_DATA_WIDTH      ( 54      ) //1bit sign 17 bit int 36 bit int
  )
 average_calcu_float_0 (
     .clk            (  alg_clk                            ),                                            //input                       clk,
     .rst_n          (  alg_rst_n                          ),                                          //input                       rst_n,
     .DATA_in        (  mix_sine[63:10]                    ),                                  //input [C_DATA_WIDTH-1:0]    DATA_in      ,
     .DATA_sof       (  pem_posedge_rr&&(!ping_pong_sig)&&(pem_posedge_cnt==8'd0)   ),                                  //input                       DATA_sof     ,
     .DATA_eof       (  pem_posedge&&(!ping_pong_sig)&&(pem_posedge_cnt==8'd4)   ),                                  //input                       DATA_eof     ,
     .DATA_in_valid  (  wave_dat_req_rr&&(!ping_pong_sig)  ),                                  //input                       DATA_in_valid,                 
     .DATA_in_ready  (                                     ),                                  //output                      DATA_in_ready,                           
     .data_out       (  mean_mix_sine_ping                 ),                                //output[63:0]                data_out       , 
     .data_out_valid (  mean_mix_sine_ping_valid           )                                 //output                      data_out_valid    
     
  );
   
   
     average_calcu_float#(
    . max_average_count ( 10'd1001),
    . C_DATA_WIDTH      ( 54      ) //1bit sign 17 bit int 36 bit int
  )
 average_calcu_float_1 (
     .clk            (  alg_clk                             ),                                            //input                       clk,
     .rst_n          (  alg_rst_n                           ),                                          //input                       rst_n,
     .DATA_in        (  mix_sine[63:10]                     ),                                  //input [C_DATA_WIDTH-1:0]    DATA_in      ,
     .DATA_sof       (  pem_posedge_rr&&(ping_pong_sig)&&(pem_posedge_cnt==8'd0)     ),                                  //input                       DATA_sof     ,
     .DATA_eof       (  pem_posedge&&(ping_pong_sig)&&(pem_posedge_cnt==8'd4)     ),                                  //input                       DATA_eof     ,
     .DATA_in_valid  (  wave_dat_req_rr&&(ping_pong_sig)    ),                                  //input                       DATA_in_valid,                 
     .DATA_in_ready  (                                      ),                                  //output                      DATA_in_ready,                           
     .data_out       (  mean_mix_sine_pong                  ),                                //output[63:0]                data_out       , 
     .data_out_valid (  mean_mix_sine_pong_valid            )                                 //output                      data_out_valid    
     
  );
   
  average_calcu_float#(
  . max_average_count ( 10'd1001),
  . C_DATA_WIDTH      ( 54      ) //1bit sign 17 bit int 36 bit int
)
average_calcu_float_2 (
   .clk            (  alg_clk                             ),                                            //input                       clk,
   .rst_n          (  alg_rst_n                           ),                                          //input                       rst_n,
   .DATA_in        ({ wave_dat_sine_r[95],((wave_dat_sine_r[95])?16'hFFFF:16'h0000),wave_dat_sine_r[92:56]}),                                  //input [C_DATA_WIDTH-1:0]    DATA_in      ,
   .DATA_sof       (  pem_posedge_rr&&(!ping_pong_sig)&&(pem_posedge_cnt==8'd0)    ),                                  //input                       DATA_sof     ,
   .DATA_eof       (  pem_posedge&&(!ping_pong_sig)&&(pem_posedge_cnt==8'd4)    ),                                  //input                       DATA_eof     ,
   .DATA_in_valid  (  wave_dat_req_rr&&(!ping_pong_sig)   ),                                  //input                       DATA_in_valid,                 
   .DATA_in_ready  (                                      ),                                  //output                      DATA_in_ready,                           
   .data_out       (   mean_sine_ping                     ),                                //output[63:0]                data_out       , 
   .data_out_valid (   mean_sine_ping_valid               )                                 //output                      data_out_valid    
   
); 
   
   
   
    average_calcu_float#(
 . max_average_count ( 10'd1001),
 . C_DATA_WIDTH      ( 54      ) //1bit sign 17 bit int 36 bit int
)
average_calcu_float_3 (
  .clk            (  alg_clk                             ),                                            //input                       clk,
  .rst_n          (  alg_rst_n                           ),                                          //input                       rst_n,
  .DATA_in        ({ wave_dat_sine_r[95],((wave_dat_sine_r[95])?16'hFFFF:16'h0000),wave_dat_sine_r[92:56]}),                                  //input [C_DATA_WIDTH-1:0]    DATA_in      ,
  .DATA_sof       (  pem_posedge_rr&&(ping_pong_sig)&&(pem_posedge_cnt==8'd0)   ),                                  //input                       DATA_sof     ,
  .DATA_eof       (  pem_posedge&&(ping_pong_sig)&&(pem_posedge_cnt==8'd4)    ),                                  //input                       DATA_eof     ,
  .DATA_in_valid  (  wave_dat_req_rr&&(ping_pong_sig)  ),                                  //input                       DATA_in_valid,                 
  .DATA_in_ready  (                                    ),                                  //output                      DATA_in_ready,                           
  .data_out       (  mean_sine_pong                    ),                                //output[63:0]                data_out       , 
  .data_out_valid (  mean_sine_pong_valid              )                                 //output                      data_out_valid    
  
); 
  
  
   average_calcu_float#(
. max_average_count ( 10'd1001),
. C_DATA_WIDTH      ( 54      ) //1bit sign 17 bit int 36 bit int
)
average_calcu_float_4 (
.clk            (  alg_clk                             ),                                            //input                       clk,
.rst_n          (  alg_rst_n                           ),                                          //input                       rst_n,
.DATA_in        ( mix_cosine[63:10]  ),                                  //input [C_DATA_WIDTH-1:0]    DATA_in      ,
.DATA_sof       ( pem_posedge_rr&&(!ping_pong_sig)&&(pem_posedge_cnt==8'd0)  ),                                  //input                       DATA_sof     ,
.DATA_eof       ( pem_posedge&&(!ping_pong_sig)&&(pem_posedge_cnt==8'd4)   ),                                  //input                       DATA_eof     ,
.DATA_in_valid  ( wave_dat_req_rr&&(!ping_pong_sig) ),                                  //input                       DATA_in_valid,                 
.DATA_in_ready  (                                    ),                                  //output                      DATA_in_ready,                           
.data_out       ( mean_mix_cosine_ping          ),                                //output[63:0]                data_out       , 
.data_out_valid ( mean_mix_cosine_ping_valid    )                                 //output                      data_out_valid    

);   
   
    average_calcu_float#(
. max_average_count ( 10'd1001),
. C_DATA_WIDTH      ( 54      ) //1bit sign 17 bit int 36 bit int
)
average_calcu_float_5 (
.clk            (  alg_clk                             ),                                            //input                       clk,
.rst_n          (  alg_rst_n                           ),                                          //input                       rst_n,
.DATA_in        ( mix_cosine[63:10]  ),                                  //input [C_DATA_WIDTH-1:0]    DATA_in      ,
.DATA_sof       ( pem_posedge_rr&&(ping_pong_sig)&&(pem_posedge_cnt==8'd0) ),                                  //input                       DATA_sof     ,
.DATA_eof       ( pem_posedge&&(ping_pong_sig)&&(pem_posedge_cnt==8'd4)  ),                                  //input                       DATA_eof     ,
.DATA_in_valid  ( wave_dat_req_rr&&(ping_pong_sig)),                                  //input                       DATA_in_valid,                 
.DATA_in_ready  (                                    ),                                  //output                      DATA_in_ready,                           
.data_out       ( mean_mix_cosine_pong        ),                                //output[63:0]                data_out       , 
.data_out_valid ( mean_mix_cosine_pong_valid  )                                 //output                      data_out_valid    

);
   
   
     average_calcu_float#(
. max_average_count ( 10'd1001),
. C_DATA_WIDTH      ( 54      ) //1bit sign 17 bit int 36 bit int
)
average_calcu_float_6 (
.clk            (  alg_clk                             ),                                            //input                       clk,
.rst_n          (  alg_rst_n                           ),                                          //input                       rst_n,
.DATA_in        ({ wave_dat_cosine_r[95],((wave_dat_cosine_r[95])?16'hFFFF:16'h0000),wave_dat_cosine_r[92:56]}),                                  //input [C_DATA_WIDTH-1:0]    DATA_in      ,
.DATA_sof       ( pem_posedge_rr&&(!ping_pong_sig)&&(pem_posedge_cnt==8'd0) ),                                  //input                       DATA_sof     ,
.DATA_eof       ( pem_posedge&&(!ping_pong_sig)&&(pem_posedge_cnt==8'd4) ),                                  //input                       DATA_eof     ,
.DATA_in_valid  ( wave_dat_req_rr&&(!ping_pong_sig)),                                  //input                       DATA_in_valid,                 
.DATA_in_ready  (                                     ),                                  //output                      DATA_in_ready,                           
.data_out       ( mean_cosine_ping                   ),                                //output[63:0]                data_out       , 
.data_out_valid ( mean_cosine_ping_valid             )                                 //output                      data_out_valid    

);  
   
   
   average_calcu_float#(
. max_average_count ( 10'd1001),
. C_DATA_WIDTH      ( 54      ) //1bit sign 17 bit int 36 bit int
)
average_calcu_float_7 (
.clk            (  alg_clk                             ),                                            //input                       clk,
.rst_n          (  alg_rst_n                           ),                                          //input                       rst_n,
.DATA_in        ({ wave_dat_cosine_r[95],((wave_dat_cosine_r[95])?16'hFFFF:16'h0000),wave_dat_cosine_r[92:56]}),                                  //input [C_DATA_WIDTH-1:0]    DATA_in      ,
.DATA_sof       ( pem_posedge_rr&&(ping_pong_sig)&&(pem_posedge_cnt==8'd0) ),                                  //input                       DATA_sof     ,
.DATA_eof       ( pem_posedge&&(ping_pong_sig)&&(pem_posedge_cnt==8'd4)  ),                                  //input                       DATA_eof     ,
.DATA_in_valid  ( wave_dat_req_rr&&(ping_pong_sig)),                                  //input                       DATA_in_valid,                 
.DATA_in_ready  (                                    ),                                  //output                      DATA_in_ready,                           
.data_out       ( mean_cosine_pong                  ),                                //output[63:0]                data_out       , 
.data_out_valid ( mean_cosine_pong_valid            )                                 //output                      data_out_valid    

);   
   
   
   wire [63:0] w1_fp_double      ;
   wire        w1_fp_double_valid;  
   
    wire [63:0] w2_fp_double      ;
    wire        w2_fp_double_valid;  
   
  wire [63:0]  mean_mix_sine       ;         
  wire         mean_mix_sine_valid ;  
   
   wire [63:0]  mean_sine ;         
   wire   mean_sine_valid ;   
   
    wire [63:0]  mean_mix_cosine ;         
    wire   mean_mix_cosine_valid ;  
     
     wire [63:0]  mean_cosine ;         
     wire   mean_cosine_valid ;  
   
    assign   mean_mix_sine        =(!div_ping_pong_sig)? mean_mix_sine_ping :mean_mix_sine_pong  ;         
    assign   mean_mix_sine_valid  =(!div_ping_pong_sig)? mean_mix_sine_ping_valid  : mean_mix_sine_pong_valid      ;        
    assign   mean_sine            =(!div_ping_pong_sig)? mean_sine_ping       :  mean_sine_pong     ;         
    assign   mean_sine_valid      =(!div_ping_pong_sig)? mean_sine_ping_valid       : mean_sine_pong_valid      ;       
    assign   mean_mix_cosine      =(!div_ping_pong_sig)?  mean_mix_cosine_ping      : mean_mix_cosine_pong      ;         
    assign   mean_mix_cosine_valid=(!div_ping_pong_sig)? mean_mix_cosine_ping_valid : mean_mix_cosine_pong_valid ;          
    assign   mean_cosine          =(!div_ping_pong_sig)? mean_cosine_ping       : mean_cosine_pong  ;         
    assign   mean_cosine_valid    =(!div_ping_pong_sig)?mean_cosine_ping_valid   :mean_cosine_pong_valid ;  
                                                                
   
   
    fp_double_divider fp_double_divider_0 (
  .aclk                 (    alg_clk                ),//: IN STD_LOGIC;
  .s_axis_a_tvalid      ( mean_mix_sine_valid             ),//: IN STD_LOGIC;
  .s_axis_a_tdata       (  mean_mix_sine           ),//: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
  .s_axis_b_tvalid      (mean_sine_valid            ),//: IN STD_LOGIC;
  .s_axis_b_tdata       (  mean_sine              ),//: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
  .m_axis_result_tvalid ( w1_fp_double_valid               ),//: OUT STD_LOGIC;
  .m_axis_result_tdata  ( w1_fp_double         ) //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
 );
   
   
 
 fp_double_divider fp_double_divider_1 (
  .aclk                 (    alg_clk                ),//: IN STD_LOGIC;
  .s_axis_a_tvalid      (  mean_mix_cosine_valid        ),//: IN STD_LOGIC;
  .s_axis_a_tdata       (   mean_mix_cosine           ),//: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
  .s_axis_b_tvalid      ( mean_cosine_valid         ),//: IN STD_LOGIC;
  .s_axis_b_tdata       (   mean_cosine           ),//: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
  .m_axis_result_tvalid (  w2_fp_double_valid              ),//: OUT STD_LOGIC;
  .m_axis_result_tdata  (  w2_fp_double        ) //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
 );
   
  wire [31:0]  w1_single       ;
  wire         w1_single_valid ;
  wire [31:0]  w2_single       ;           
  wire         w2_single_valid ;     
  
  
  
  fp_double_2_single fp_double_2_single_0 (
    .aclk                (    alg_clk          ),//: IN STD_LOGIC;
    .s_axis_a_tvalid     (  w1_fp_double_valid     ),//: IN STD_LOGIC;
    .s_axis_a_tdata      (  w1_fp_double         ),//: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    .m_axis_result_tvalid(   w1_single_valid        ),//: OUT STD_LOGIC;
    .m_axis_result_tdata (  w1_single        ) //: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
   );
  
  

     fp_double_2_single fp_double_2_single_1 (
    .aclk                (     alg_clk          ),//: IN STD_LOGIC;
    .s_axis_a_tvalid     (   w2_fp_double_valid ),//: IN STD_LOGIC;
    .s_axis_a_tdata      (   w2_fp_double       ),//: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    .m_axis_result_tvalid(  w2_single_valid      ),//: OUT STD_LOGIC;
    .m_axis_result_tdata (   w2_single        ) //: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
   ); 
   
   wire   [31:0]   fp_w1_mul_coef;
   wire   fp_w1_mul_coef_valid;
   
  wire    [31:0]   fp_w2_delay      ;
  wire             fp_w2_delay_valid;
  fp_single_multiple fp_single_multiple_0 (
      .aclk                (   alg_clk            ),//: IN STD_LOGIC;
      .s_axis_a_tvalid     (  w1_single_valid        ),//: IN STD_LOGIC;
      .s_axis_a_tdata      (  w1_single            ),//: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      .s_axis_b_tvalid     (  w1_single_valid       ),//: IN STD_LOGIC;
      .s_axis_b_tdata      (  atan_coef            ),//: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      .m_axis_result_tvalid(fp_w1_mul_coef_valid       ),//: OUT STD_LOGIC;
      .m_axis_result_tdata (  fp_w1_mul_coef       ) //: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
     ); 
   
   
   shift_delay#(
      .delay_pace(8   )  ,
      .D_WIDTH   (32  )
     )
    shift_delay_0 (
        . clk           (    alg_clk                         ) ,
        . rst_n         (   alg_rst_n                        ) ,                
        . data_in       (  w2_single                         ) ,
        . data_in_valid (    w2_single_valid                 ) ,
        . data_out      (fp_w2_delay                         ) ,
        . data_out_valid( fp_w2_delay_valid                  )
     
        );
   
   wire  [31:0]  w1_renormalized      ;
   wire  [31:0]  w2_renormalized      ;
   wire          w1_renormalized_valid;
   wire          w2_renormalized_valid;
   
   
normalization  normalization_0(
 .clk                     (    alg_clk              )  ,                        // input            clk,         
 .rst_n                   (    alg_rst_n            )  ,                      // input            rst_n,
 .A_C_B_D_re              (   fp_w1_mul_coef               )  ,                 // input [31:0]     A_C_B_D_re,
 .A_C_B_D_re_en           (  fp_w1_mul_coef_valid             )  ,              // input            A_C_B_D_re_en,   
 .A_D_B_C_im              (  fp_w2_delay              )  ,                 // input [31:0]     A_D_B_C_im,
 .A_D_B_C_im_en           (   fp_w2_delay_valid            )  ,              // input            A_D_B_C_im_en,    
 .A_C_B_D_re_normalized   (  w1_renormalized              ) ,  // output [31:0]    A_C_B_D_re_normalized      ,//fixed point 31_29
 .A_C_B_D_re_normalized_en(  w1_renormalized_valid    ) ,  // output           A_C_B_D_re_normalized_en   ,//fixed point 31_29    
 .A_D_B_C_im_normalized   (  w2_renormalized          ) ,  // output  [31:0]   A_D_B_C_im_normalized      ,//fixed point 31_29
 .A_D_B_C_im_normalized_en(  w2_renormalized_valid    )    // output           A_D_B_C_im_normalized_en    //fixed point 31_29
     );




(*mark_debug = "true"*) wire [31:0]     phase_out_raw;
 
(*mark_debug = "true"*) wire     phase_out_raw_valid;     
 
 //atan2  
   cordic_0 cordic_0_0(
        . aclk                   (   alg_clk                        ), // : IN STD_LOGIC;
        . s_axis_cartesian_tvalid(   w1_renormalized_valid          ), // : IN STD_LOGIC;
        . s_axis_cartesian_tdata ( {w1_renormalized,w2_renormalized}), // : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
        . m_axis_dout_tvalid     ( phase_out_raw_valid              ), // : OUT STD_LOGIC;
        . m_axis_dout_tdata      ( phase_out_raw                    ) // : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
       );
   wire   w2_signal_flag;
   wire   w1_signal_flag;      
     flag_fifo flag_fifo_0 (
         .clk   (   alg_clk    ),//: IN STD_LOGIC;
         .srst  (  ~alg_rst_n   ),//: IN STD_LOGIC;
         .din   (  {w1_renormalized[31],w2_renormalized[31]}   ),//: IN STD_LOGIC_VECTOR(0 DOWNTO 0);
         .wr_en ( w2_renormalized_valid  ),//: IN STD_LOGIC;
         .rd_en (  phase_out_raw_valid   ),//: IN STD_LOGIC;
         .dout  ( {w1_signal_flag ,w2_signal_flag } ),//: OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         .full  (                ),//: OUT STD_LOGIC;
         .empty (                ) //: OUT STD_LOGIC
        );   
       //atan2 2 atan
 (*mark_debug = "true"*)  reg [31:0]     phase_out_raw_r; 
 (*mark_debug = "true"*)  reg            phase_out_raw_valid_r;
(*mark_debug = "true"*)   reg [31:0]   phase_out_convert      ;
(*mark_debug = "true"*)   reg          phase_out_convert_valid;   
  reg          w2_signal_flag_r;
     always@(posedge alg_clk)
  w2_signal_flag_r<= w2_signal_flag;
  
  
   always@(posedge alg_clk)
   begin
    phase_out_raw_valid_r<=phase_out_raw_valid;
    phase_out_raw_r<= phase_out_raw;
     
    end
  always@(posedge alg_clk or negedge   alg_rst_n)
   if(!alg_rst_n)
     begin
     phase_out_convert      <=0;  
     phase_out_convert_valid<=0;  
     end
   else   if(phase_out_raw_valid_r)
    begin
    case ( {w1_signal_flag ,w2_signal_flag })
    2'b00:
    begin
    phase_out_convert_valid<=1;  
    phase_out_convert<=phase_out_raw_r;
    end
    2'b01:
    begin
    phase_out_convert_valid<=1;  
    phase_out_convert<=phase_out_raw_r+PI_inv_fix;
    end
    2'b10:
    begin
    phase_out_convert_valid<=1; 
      phase_out_convert<=phase_out_raw_r;
    end 
    2'b11:
    begin
    
    phase_out_convert_valid<=1;  
       phase_out_convert<=phase_out_raw_r+PI_fix;
    end
    default:;
     // phase_out_add_pi      <=(w2_signal_flag)?phase_out_raw_r+pi:phase_out_raw_r;  
        endcase
        end

  else 
  begin
   phase_out_convert_valid<=0;  
  end
  
//    reg [32:0]   phase_before_rpjp      ;
//    reg          phase_before_rpjp_valid;   
//    always@(posedge alg_clk or negedge   alg_rst_n)
//      if(!alg_rst_n)
//         begin
//         phase_before_rpjp      <=0;  
//         phase_before_rpjp_valid<=0;  
//         end
//      else if(phase_out_convert_valid )
//      begin
//              phase_before_rpjp      <=(w2_signal_flag_r )?(phase_out_convert+PI_fix_ex):phase_out_convert           ;  
//              phase_before_rpjp_valid<=1;  
//              end
//  else
//   phase_before_rpjp_valid<=0;  
    (*mark_debug = "true"*)   wire [15:0] phase_out_fix   ; 
    (*mark_debug = "true"*)   wire        phase_out_fix_en;
  
  
  RPJP_processing_unit_v2 RPJP_processing_unit_v2_0(
    .clk           (       alg_clk                                 ),         // input        wire           clk,
    .rst_n         (       alg_rst_n                               ),        //input        wire           rst_n,
    .PHASE_IN      (     phase_out_convert                          ),     //input        wire[31:0]     PHASE_IN,
    .PHASE_IN_en   (     phase_out_convert_valid                    ),  //input        wire           PHASE_IN_en,
    .PHASE_out     (     phase_out                                 ),//floating_point                                                       //output       wire[31:0]     PHASE_out,//floating_point
    .PHASE_out_EN  (     phase_out_valid                           ) , //output       wire           PHASE_out_EN
    .phase_out_fix                    ( phase_out_fix                               ) ,     
    .phase_out_fix_en                 ( phase_out_fix_en                            ) ,
    .PHASE_out_complement_binary_en_r (                             ) ,
    .phase_result_degree              (                             )  //1bit sign   27bit interger   48 bit fraction   
    
    
    
    
    );
  
  
  assign buf_refresh= pem_posedge&&(pem_posedge_cnt==8'd4) ;
  
  
  shift_reg#(
   .shift_ele_width(16),
   .shift_stage    (8 )
   )
  shift_reg_0(
    .clk         (   alg_clk            )  ,                                      //input                                        clk,
    .rst_n       (   alg_rst_n          )  ,                                      //input                                        rst_n,
    .data_in     ( phase_out_fix    )  ,                                      //input  [shift_ele_width-1:0]                 data_in,
    .data_in_vld ( phase_out_fix_en )  ,                                      //input                                        data_in_vld,
    .data_out    ( phase_out_shift      )  ,                                       //output     [shift_ele_width*shift_stage-1:0] data_out, 
    .data_out_vld( phase_out_shift_valid)                                         //output                                       data_out_vld  
  );
  
  
  
  
  
  endmodule

