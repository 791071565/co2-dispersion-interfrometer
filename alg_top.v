`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/31 13:03:45
// Design Name: 
// Module Name: alg_top
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


module alg_top(
input  alg_clk,
input  rst_n,
input  FFT_rst_n,
input         adc_clk,
(*mark_debug = "true"*)input  [15:0] ADC_data_in_A_channel   ,//2's complement
(*mark_debug = "true"*)input         ADC_data_in_A_channel_en,
(*mark_debug = "true"*)input [15:0]  ADC_data_in_B_channel   ,
(*mark_debug = "true"*)input         ADC_data_in_B_channel_en,

//config ports
input  start,
input  PCIE_dma_engine_clk,       
input   RAM_wr_en  ,               
input  [31:0]   RAM_wr_data ,       
input  [7:0]    RAM_wr_addr ,      
input    RAM_SEL          ,  
input   ROM_SEL           , 
  


 input [7:0]  narrow_band_width  ,//        (        'd0                                ),             //input  [7:0]          narrow_band_width           ,
input      narrow_band_width_en   ,//    (        'd0                                ),             //input                 narrow_band_width_en        ,  
input  [1:0] filter_mode       , //           (        'd0                             ),             //input  [1:0]          filter_mode                 ,
input   filter_mode_en         , // (        'd0                             ),             //input                 filter_mode_en              ,  
input [7:0]  start_cmp_position , //     (         'd0                             ),            //input  [7:0]          start_cmp_position           ,
input start_cmp_position_en   , // (         'd0                             ),            //input                 start_cmp_position_en     

output  wire [127:0] PHASE_out_to_PCIE   ,
output  wire         PHASE_out_to_PCIE_en,

(*mark_debug = "true"*)output  wire [127:0] raw_phase_to_pcie_frequency1,
(*mark_debug = "true"*)output  wire         raw_phase_to_pcie_frequency1_valid,


output  wire [127:0] raw_phase_to_pcie_frequency2,
output  wire         raw_phase_to_pcie_frequency2_valid,

output  wire [127:0] raw_phase_to_pcie_frequency3,
output  wire         raw_phase_to_pcie_frequency3_valid 



);


    (*mark_debug = "true"*)   wire  [15:0] data_in_A_channel;    
    (*mark_debug = "true"*)  wire      data_in_A_channel_en; 
    (*mark_debug = "true"*)  wire  [15:0] data_in_B_channel;    
    (*mark_debug = "true"*)  wire      data_in_B_channel_en;


  ADC_data_cross_clock_domian ADC_data_cross_clock_domian_0(
     .adc_clk                   (adc_clk                    )  ,                              // input         adc_clk,
     .ADC_data_in_A_channel     (ADC_data_in_A_channel      )  ,                // input  [15:0] ADC_data_in_A_channel,
     .ADC_data_in_A_channel_en  (ADC_data_in_A_channel_en   )  ,             // input         ADC_data_in_A_channel_en,
     .ADC_data_in_B_channel     (ADC_data_in_B_channel      )  ,                // input  [15:0] ADC_data_in_B_channel,
     .ADC_data_in_B_channel_en  (ADC_data_in_B_channel_en   )  ,             // input         ADC_data_in_B_channel_en,
                                                                        // 
     .alg_clk                 (     alg_clk                       )    ,                             // input          alg_clk,
     .alg_rst_n               (      rst_n                            )    ,                           // input          alg_rst_n,
     .data_in_A_channel       (  data_in_A_channel             )    ,                   // output  [15:0] data_in_A_channel,
     .data_in_A_channel_en    (  data_in_A_channel_en          )    ,                   // output   reg   data_in_A_channel_en,
     .data_in_B_channel       (  data_in_B_channel             )    ,                   // output  [15:0] data_in_B_channel,
     .data_in_B_channel_en    (  data_in_B_channel_en          )        );               // output   reg   data_in_B_channel_en);
  


(*mark_debug = "true"*)wire    [31:0]     data_to_CHA_FFT    ;
                   
(*mark_debug = "true"*)wire               data_to_CHA_FFT_en ;
                   
wire               stream_last_CHA    ;
                   
(*mark_debug = "true"*)wire    [31:0]     data_to_CHB_FFT    ;
                   
(*mark_debug = "true"*)wire               data_to_CHB_FFT_en ;
                   
wire               stream_last_CHB    ;

wire    [31:0]     data_to_CHA_FFT_1    ;
                   
wire               data_to_CHA_FFT_en_1 ;
                   
wire               stream_last_CHA_1    ;
                   
wire    [31:0]     data_to_CHB_FFT_1    ;
                   
wire               data_to_CHB_FFT_en_1 ;
                   
wire               stream_last_CHB_1    ;


 ping_pong_storage_top ping_pong_storage_top_0(
    .clk   (   alg_clk              ) ,                             //input          clk,      
    .rst_n (   rst_n                 ) ,                           //input          rst_n,     
    .start (   start                ) ,                           //input          start,
                                         //
    .data_in_A_channel   (    data_in_A_channel       ) ,                    //input   [15:0] data_in_A_channel,
    .data_in_A_channel_en(   data_in_A_channel_en     ) ,                 //input          data_in_A_channel_en,
                                         //
    .data_in_B_channel   (data_in_B_channel           ),       //input   [15:0] data_in_B_channel,
    .data_in_B_channel_en(data_in_B_channel_en        ),    //input          data_in_B_channel_en,
                                         //
     .PCIE_dma_engine_clk (PCIE_dma_engine_clk        ) ,       //input          PCIE_dma_engine_clk,
     .RAM_wr_en           (RAM_wr_en                  ) ,                 //input          RAM_wr_en,
     .RAM_wr_data         (RAM_wr_data                ) ,               //input [31:0]   RAM_wr_data,
     .RAM_wr_addr         (RAM_wr_addr                ) ,               //input [7:0]    RAM_wr_addr,
     .RAM_SEL             (RAM_SEL                    ) ,                   //input          RAM_SEL,
     .ROM_SEL             (ROM_SEL                    ) ,                  //input          ROM_SEL,
    
     .data_to_CHA_FFT     ( data_to_CHA_FFT_1     )     ,                                //output [31:0]  data_to_CHA_FFT,   //floating point
                                                                                            //
     .data_to_CHA_FFT_en  ( data_to_CHA_FFT_en_1    )     ,                                                               //output         data_to_CHA_FFT_en,
                                                                                             //
     .stream_last_CHA     ( stream_last_CHA_1       )       ,                               //output          stream_last_CHA,     
                                                                                              //
     .data_to_CHB_FFT    (  data_to_CHB_FFT_1            )    ,                                //output [31:0]  data_to_CHB_FFT,   //floating point
                                                                                                     //
     .data_to_CHB_FFT_en(   data_to_CHB_FFT_en_1       )  ,                          //output         data_to_CHB_FFT_en,   
                                                                                                    //
     .stream_last_CHB    (  stream_last_CHB_1             )                         //output         stream_last_CHB 
   
    );





 ping_pong_storage_double ping_pong_storage_double_0(
  .clk                  (  alg_clk                             ) ,	                        //input               clk,	  
  .rst_n                (  rst_n                               ) ,                       //input               rst_n,     
  .start                (  start                               ) ,                       //input               start,
  .data_in_A_channel    ( data_in_A_channel                   ) ,           //input   [15:0]      data_in_A_channel,
  .data_in_A_channel_en ( data_in_A_channel_en                ) ,        //input               data_in_A_channel_en,
  .data_in_B_channel    ( data_in_B_channel                   ) ,           //input   [15:0]      data_in_B_channel,
  .data_in_B_channel_en ( data_in_B_channel_en                ) ,        //input               data_in_B_channel_en,
  .PCIE_dma_engine_clk  ( PCIE_dma_engine_clk                  ) ,         //input               PCIE_dma_engine_clk,
  .RAM_wr_en            ( RAM_wr_en                            ) ,                   //input               RAM_wr_en,
  .RAM_wr_data          ( {32'b0,RAM_wr_data}                  ) ,                 //input [63:0]        RAM_wr_data,
  .RAM_wr_addr          ( RAM_wr_addr                          ) ,                 //input [7:0]         RAM_wr_addr,
  .RAM_SEL              ( RAM_SEL                              ) ,                     //input               RAM_SEL,
  .ROM_SEL              ( ROM_SEL                              ) ,                     //input               ROM_SEL,
  .data_to_CHA_FFT      ( data_to_CHA_FFT                    ) ,          //output [31:0]       data_to_CHA_FFT   ,           //floating point
  .data_to_CHA_FFT_en   (data_to_CHA_FFT_en                 ) ,          //output              data_to_CHA_FFT_en,
  .stream_last_CHA      (stream_last_CHA                      ) ,             //output    reg       stream_last_CHA,     
  .data_to_CHB_FFT      ( data_to_CHB_FFT                     ) ,          //output [31:0]       data_to_CHB_FFT   ,            //floating point  
  .data_to_CHB_FFT_en   (data_to_CHB_FFT_en                   ) ,          //output              data_to_CHB_FFT_en,   
  .stream_last_CHB      ( stream_last_CHB                       )            //output    reg       stream_last_CHB    
 );































   (*mark_debug = "true"*)wire [31:0] ffted_data_CHA_RE   ;
   (*mark_debug = "true"*) wire [31:0] ffted_data_CHA_IM   ;
   (*mark_debug = "true"*) wire        ffted_data_CHA_en   ; 
 wire        ffted_data_CHA_last ;
    
    fft_module fft_module_0(
    .aclk         (   alg_clk                      ) ,                              //input         aclk,
    .rst_n        (    FFT_rst_n                       ) ,                             //input         rst_n,
    .data_in_re   ( data_to_CHA_FFT                 ) ,                        //input  [31:0] data_in_re,
    .data_in_im   (    32'b0                        ) ,                        //input  [31:0] data_in_im,
    .data_in_en   (data_to_CHA_FFT_en            ) ,                        //input         data_in_en,
    .data_in_last (stream_last_CHA              ) ,                      //input         data_in_last,
    .FFT_mode     (           1'b1              )    ,                     //1:FFT  0:IFFT
    .data_out_re  ( ffted_data_CHA_RE           ) ,                       //output [31:0] data_out_re,
    .data_out_im  ( ffted_data_CHA_IM           ) ,                       //output [31:0] data_out_im,
    .data_out_en  ( ffted_data_CHA_en           ) ,                       //output        data_out_en,
    .data_out_last( ffted_data_CHA_last         )                             //output        data_out_last
        );
  (*mark_debug = "true"*) wire [31:0] ffted_data_CHB_RE   ;
  (*mark_debug = "true"*) wire [31:0] ffted_data_CHB_IM   ;
  (*mark_debug = "true"*) wire        ffted_data_CHB_en   ; 
   wire        ffted_data_CHB_last ;
    
  fft_module fft_module_1(
           .aclk         (   alg_clk                      ) ,                              //input         aclk,
           .rst_n        (    FFT_rst_n                       ) ,                             //input         rst_n,
           .data_in_re   ( data_to_CHB_FFT                 ) ,                        //input  [31:0] data_in_re,
           .data_in_im   (    32'b0                        ) ,                        //input  [31:0] data_in_im,
           .data_in_en   (data_to_CHB_FFT_en            ) ,                        //input         data_in_en,
           .data_in_last (stream_last_CHB              ) ,                      //input         data_in_last,
           .FFT_mode     (           1'b1              )    ,                     //1:FFT  0:IFFT
           .data_out_re  ( ffted_data_CHB_RE           ) ,                       //output [31:0] data_out_re,
           .data_out_im  ( ffted_data_CHB_IM           ) ,                       //output [31:0] data_out_im,
           .data_out_en  ( ffted_data_CHB_en           ) ,                       //output        data_out_en,
           .data_out_last( ffted_data_CHB_last         )                             //output        data_out_last
               );

  (*mark_debug = "true"*)wire          CHA_RE_IM_DATA_valid_f1   ;   
  wire  [63:0]  CHA_RE_IM_DATA_filtered_f1;
 wire          CHA_RE_IM_DATA_last_f1    ;  
 (*mark_debug = "true"*)wire          CHB_RE_IM_DATA_valid_f1   ;   
wire  [63:0]  CHB_RE_IM_DATA_filtered_f1;
  (*mark_debug = "true"*)wire [31:0] CHA_RE_DATA_filtered_f1;
 (*mark_debug = "true"*) wire [31:0] CHA_IM_DATA_filtered_f1; 
   (*mark_debug = "true"*)wire [31:0] CHB_RE_DATA_filtered_f1;
  (*mark_debug = "true"*) wire [31:0] CHB_IM_DATA_filtered_f1; 
 
 assign  CHA_RE_DATA_filtered_f1= CHA_RE_IM_DATA_filtered_f1[63:32];
 assign  CHA_IM_DATA_filtered_f1= CHA_RE_IM_DATA_filtered_f1[31:0];
 
 assign  CHB_RE_DATA_filtered_f1= CHB_RE_IM_DATA_filtered_f1[63:32];            
 assign  CHB_IM_DATA_filtered_f1= CHB_RE_IM_DATA_filtered_f1[31:0];             
 
 
 wire          CHB_RE_IM_DATA_last_f1    ;  
 wire  [63:0]  CHA_RE_IM_DATA_filtered_f2;
 wire          CHA_RE_IM_DATA_valid_f2   ;  
 wire          CHA_RE_IM_DATA_last_f2    ;   
 wire  [63:0]  CHB_RE_IM_DATA_filtered_f2;
 wire          CHB_RE_IM_DATA_last_f2    ;   
 wire          CHB_RE_IM_DATA_valid_f2   ;  
 wire          CHA_RE_IM_DATA_valid_f3   ;   
 wire  [63:0]  CHA_RE_IM_DATA_filtered_f3;
 wire          CHA_RE_IM_DATA_last_f3    ;  
 wire          CHB_RE_IM_DATA_valid_f3   ;   
 wire  [63:0]  CHB_RE_IM_DATA_filtered_f3;
 wire          CHB_RE_IM_DATA_last_f3    ;		   
			    
			   
			   

narrow_band_filter_top narrow_band_filter_top_0(
    .rst_n                (         rst_n                                )  ,                           //input          rst_n  ,
    .clk                  (        alg_clk                              )  ,                           //input          clk    ,
    .ffted_data_CHA_RE    (    ffted_data_CHA_RE                             )  ,               //input [31:0]   ffted_data_CHA_RE  ,
    .ffted_data_CHA_IM    (    ffted_data_CHA_IM                             )  ,               //input [31:0]   ffted_data_CHA_IM  ,
    .ffted_data_CHA_en    (    ffted_data_CHA_en                             )  ,               //input          ffted_data_CHA_en  , 
    .ffted_data_CHA_last  (    ffted_data_CHA_last                           )  ,               //input          ffted_data_CHA_last,  
    .ffted_data_CHB_RE    (   ffted_data_CHB_RE                          )  ,               //input [31:0]   ffted_data_CHB_RE  ,  //reference channel
    .ffted_data_CHB_IM    (   ffted_data_CHB_IM                          )  ,               //input [31:0]   ffted_data_CHB_IM  ,  //reference channel
    .ffted_data_CHB_en    (   ffted_data_CHB_en                          )  ,               //input          ffted_data_CHB_en  ,  //reference channel
    .ffted_data_CHB_last  (   ffted_data_CHB_last                        )  ,               //input          ffted_data_CHB_last,  //reference channel
    .PCIE_dma_engine_clk  (   PCIE_dma_engine_clk                )  ,               //input          PCIE_dma_engine_clk,
                                                                                            //
                                                                                            //
    .narrow_band_width          (  narrow_band_width               ),             //input  [7:0]          narrow_band_width           ,
    .narrow_band_width_en       (  narrow_band_width_en            ),             //input                 narrow_band_width_en        ,  
    .filter_mode                (  filter_mode                  ),             //input  [1:0]          filter_mode                 ,
    .filter_mode_en             (  filter_mode_en               ),             //input                 filter_mode_en              ,  
    .start_cmp_position         (  start_cmp_position            ),            //input  [7:0]          start_cmp_position           ,
    .start_cmp_position_en      (  start_cmp_position_en         ),            //input                 start_cmp_position_en        ,
    .CHA_RE_IM_DATA_valid_f1    (CHA_RE_IM_DATA_valid_f1    ) ,              //output    wire          CHA_RE_IM_DATA_valid_f1,
    .CHA_RE_IM_DATA_filtered_f1 (CHA_RE_IM_DATA_filtered_f1 ) ,              //output    wire  [63:0]  CHA_RE_IM_DATA_filtered_f1, 
    .CHA_RE_IM_DATA_last_f1     (CHA_RE_IM_DATA_last_f1     ) ,              //output    wire          CHA_RE_IM_DATA_last_f1  , 
    .CHB_RE_IM_DATA_valid_f1    (CHB_RE_IM_DATA_valid_f1    ) ,              //output    wire          CHB_RE_IM_DATA_valid_f1,
    .CHB_RE_IM_DATA_filtered_f1 (CHB_RE_IM_DATA_filtered_f1 ) ,              //output    wire  [63:0]  CHB_RE_IM_DATA_filtered_f1,
    .CHB_RE_IM_DATA_last_f1     (CHB_RE_IM_DATA_last_f1     ) ,              //output    wire          CHB_RE_IM_DATA_last_f1  , 
    .CHA_RE_IM_DATA_filtered_f2 (CHA_RE_IM_DATA_filtered_f2 ) ,              //output    wire  [63:0]  CHA_RE_IM_DATA_filtered_f2, 
    .CHA_RE_IM_DATA_valid_f2    (CHA_RE_IM_DATA_valid_f2    ) ,              //output    wire          CHA_RE_IM_DATA_valid_f2 ,
    .CHA_RE_IM_DATA_last_f2     (CHA_RE_IM_DATA_last_f2     ) ,              //output    wire          CHA_RE_IM_DATA_last_f2 ,
    .CHB_RE_IM_DATA_filtered_f2 (CHB_RE_IM_DATA_filtered_f2 ) ,              //output    wire  [63:0]  CHB_RE_IM_DATA_filtered_f2,
    .CHB_RE_IM_DATA_last_f2     (CHB_RE_IM_DATA_last_f2     )  ,             //output    wire          CHB_RE_IM_DATA_last_f2 ,
    .CHB_RE_IM_DATA_valid_f2    (CHB_RE_IM_DATA_valid_f2    )  ,             //output    wire          CHB_RE_IM_DATA_valid_f2 ,
    .CHA_RE_IM_DATA_valid_f3    (CHA_RE_IM_DATA_valid_f3    )  ,             //output    wire          CHA_RE_IM_DATA_valid_f3,
    .CHA_RE_IM_DATA_filtered_f3 (CHA_RE_IM_DATA_filtered_f3 )  ,             //output    wire  [63:0]  CHA_RE_IM_DATA_filtered_f3, 
    .CHA_RE_IM_DATA_last_f3     (CHA_RE_IM_DATA_last_f3     )   ,            //output    wire          CHA_RE_IM_DATA_last_f3  , 
    .CHB_RE_IM_DATA_valid_f3    (CHB_RE_IM_DATA_valid_f3    )   ,            //output    wire          CHB_RE_IM_DATA_valid_f3,
    .CHB_RE_IM_DATA_filtered_f3 (CHB_RE_IM_DATA_filtered_f3 )  ,             //output    wire  [63:0]  CHB_RE_IM_DATA_filtered_f3,
    .CHB_RE_IM_DATA_last_f3     (CHB_RE_IM_DATA_last_f3     )                //output    wire          CHB_RE_IM_DATA_last_f3   

);

(*mark_debug = "true"*)wire  [31:0] iffted_data_CHA_RE_f1   ;
(*mark_debug = "true"*)wire  [31:0] iffted_data_CHA_IM_f1   ;
(*mark_debug = "true"*)wire         iffted_data_CHA_en_f1   ;
wire         iffted_data_CHA_last_f1 ;
reg          iffted_data_CHA_en_f1_r;
reg           iffted_data_CHA_last_f1_r;
reg  [31:0] iffted_data_CHA_RE_f1_r='d0;
reg  [31:0] iffted_data_CHA_IM_f1_r='d0;

always@(posedge  alg_clk)
begin
iffted_data_CHA_en_f1_r<=iffted_data_CHA_en_f1;
iffted_data_CHA_last_f1_r<=iffted_data_CHA_last_f1;
end
always@(posedge alg_clk or negedge rst_n)
 if(!rst_n)
 begin
 iffted_data_CHA_RE_f1_r<='d0;
 iffted_data_CHA_IM_f1_r<='d0;
  end
 else if(iffted_data_CHA_en_f1)
 begin
 iffted_data_CHA_RE_f1_r<=iffted_data_CHA_RE_f1;  
 iffted_data_CHA_IM_f1_r<=iffted_data_CHA_IM_f1;  
end
   fft_module fft_module_2(
    .aclk         (   alg_clk                      ) ,                              //input         aclk,
    .rst_n        (    FFT_rst_n                       ) ,                             //input         rst_n,
    .data_in_re   ( CHA_RE_IM_DATA_filtered_f1[63:32]                 ) ,                        //input  [31:0] data_in_re,
    .data_in_im   (  CHA_RE_IM_DATA_filtered_f1[31:0]       ) ,                        //input  [31:0] data_in_im,
    .data_in_en   (CHA_RE_IM_DATA_valid_f1            ) ,                        //input         data_in_en,
    .data_in_last (CHA_RE_IM_DATA_last_f1              ) ,                      //input         data_in_last,
    .FFT_mode     (           1'b0              )    ,                     //1:FFT  0:IFFT
    .data_out_re  ( iffted_data_CHA_RE_f1           ) ,                       //output [31:0] data_out_re,
    .data_out_im  ( iffted_data_CHA_IM_f1           ) ,                       //output [31:0] data_out_im,
    .data_out_en  ( iffted_data_CHA_en_f1           ) ,                       //output        data_out_en,
    .data_out_last( iffted_data_CHA_last_f1         )                         //output        data_out_last
        );

		
wire  [31:0] iffted_data_CHB_RE_f1   ;
wire  [31:0] iffted_data_CHB_IM_f1   ;
wire         iffted_data_CHB_en_f1   ;
wire         iffted_data_CHB_last_f1 ;		
reg          iffted_data_CHB_en_f1_r;
reg           iffted_data_CHB_last_f1_r;
reg  [31:0] iffted_data_CHB_RE_f1_r='d0;
reg  [31:0] iffted_data_CHB_IM_f1_r='d0;

always@(posedge  alg_clk)
begin
iffted_data_CHB_en_f1_r<=iffted_data_CHB_en_f1;
iffted_data_CHB_last_f1_r<=iffted_data_CHB_last_f1;
end
always@(posedge alg_clk or negedge rst_n)
 if(!rst_n)
 begin
 iffted_data_CHB_RE_f1_r<='d0;
 iffted_data_CHB_IM_f1_r<='d0;
  end
 else if(iffted_data_CHB_en_f1)
 begin
 iffted_data_CHB_RE_f1_r<=iffted_data_CHB_RE_f1;  
 iffted_data_CHB_IM_f1_r<=iffted_data_CHB_IM_f1;  
end		
		
		
 fft_module fft_module_3(
    .aclk         (   alg_clk                      ) ,                              //input         aclk,
    .rst_n        (    FFT_rst_n                       ) ,                             //input         rst_n,
    .data_in_re   (  CHB_RE_IM_DATA_filtered_f1[63:32]                 ) ,                        //input  [31:0] data_in_re,
    .data_in_im   (  CHB_RE_IM_DATA_filtered_f1[31:0]       ) ,                        //input  [31:0] data_in_im,
    .data_in_en   (CHB_RE_IM_DATA_valid_f1            ) ,                        //input         data_in_en,
    .data_in_last (CHB_RE_IM_DATA_last_f1              ) ,                      //input         data_in_last,
    .FFT_mode     (           1'b0              )    ,                     //1:FFT  0:IFFT
    .data_out_re  ( iffted_data_CHB_RE_f1           ) ,                       //output [31:0] data_out_re,
    .data_out_im  ( iffted_data_CHB_IM_f1           ) ,                       //output [31:0] data_out_im,
    .data_out_en  ( iffted_data_CHB_en_f1           ) ,                       //output        data_out_en,
    .data_out_last( iffted_data_CHB_last_f1         )                         //output        data_out_last
        );
wire  [31:0] iffted_data_CHA_RE_f2  ;
wire  [31:0] iffted_data_CHA_IM_f2  ;
wire         iffted_data_CHA_en_f2  ;
wire         iffted_data_CHA_last_f2 ;
reg          iffted_data_CHA_en_f2_r;
reg           iffted_data_CHA_last_f2_r;
reg  [31:0] iffted_data_CHA_RE_f2_r='d0;
reg  [31:0] iffted_data_CHA_IM_f2_r='d0;

always@(posedge  alg_clk)
begin
iffted_data_CHA_en_f2_r<=iffted_data_CHA_en_f2;
iffted_data_CHA_last_f2_r<=iffted_data_CHA_last_f2;
end
always@(posedge alg_clk or negedge rst_n)
 if(!rst_n)
 begin
 iffted_data_CHA_RE_f2_r<='d0;
 iffted_data_CHA_IM_f2_r<='d0;
  end
 else if(iffted_data_CHA_en_f1)
 begin
 iffted_data_CHA_RE_f2_r<=iffted_data_CHA_RE_f2;  
 iffted_data_CHA_IM_f2_r<=iffted_data_CHA_IM_f2;  
end

	 fft_module fft_module_4(
    .aclk         (   alg_clk                      ) ,                              //input         aclk,
    .rst_n        (    FFT_rst_n                       ) ,                             //input         rst_n,
    .data_in_re   ( CHA_RE_IM_DATA_filtered_f2[63:32]                 ) ,                        //input  [31:0] data_in_re,
    .data_in_im   (  CHA_RE_IM_DATA_filtered_f2[31:0]       ) ,                        //input  [31:0] data_in_im,
    .data_in_en   (CHA_RE_IM_DATA_valid_f2            ) ,                        //input         data_in_en,
    .data_in_last (CHA_RE_IM_DATA_last_f2              ) ,                      //input         data_in_last,
    .FFT_mode     (           1'b0              )    ,                     //1:FFT  0:IFFT
    .data_out_re  ( iffted_data_CHA_RE_f2           ) ,                       //output [31:0] data_out_re,
    .data_out_im  ( iffted_data_CHA_IM_f2           ) ,                       //output [31:0] data_out_im,
    .data_out_en  ( iffted_data_CHA_en_f2           ) ,                       //output        data_out_en,
    .data_out_last( iffted_data_CHA_last_f2         )                         //output        data_out_last
        );	
		
wire  [31:0] iffted_data_CHB_RE_f2  ;
wire  [31:0] iffted_data_CHB_IM_f2  ;
wire         iffted_data_CHB_en_f2  ;
wire         iffted_data_CHB_last_f2 ;
reg          iffted_data_CHB_en_f2_r;
reg           iffted_data_CHB_last_f2_r;
reg  [31:0] iffted_data_CHB_RE_f2_r='d0;
reg  [31:0] iffted_data_CHB_IM_f2_r='d0;

always@(posedge  alg_clk)
begin
iffted_data_CHB_en_f2_r<=iffted_data_CHB_en_f2;
iffted_data_CHB_last_f2_r<=iffted_data_CHB_last_f2;
end
always@(posedge alg_clk or negedge rst_n)
 if(!rst_n)
 begin
 iffted_data_CHB_RE_f2_r<='d0;
 iffted_data_CHB_IM_f2_r<='d0;
  end
 else if(iffted_data_CHB_en_f2)
 begin
 iffted_data_CHB_RE_f2_r<=iffted_data_CHB_RE_f2;  
 iffted_data_CHB_IM_f2_r<=iffted_data_CHB_IM_f2;  
end


	 fft_module fft_module_5(
    .aclk         (   alg_clk                      ) ,                              //input         aclk,
    .rst_n        (    FFT_rst_n                       ) ,                             //input         rst_n,
    .data_in_re   ( CHB_RE_IM_DATA_filtered_f2[63:32]                 ) ,                        //input  [31:0] data_in_re,
    .data_in_im   ( CHB_RE_IM_DATA_filtered_f2[31:0]       ) ,                        //input  [31:0] data_in_im,
    .data_in_en   ( CHB_RE_IM_DATA_valid_f2            ) ,                        //input         data_in_en,
    .data_in_last ( CHB_RE_IM_DATA_last_f2              ) ,                      //input         data_in_last,
    .FFT_mode     (           1'b0              )    ,                     //1:FFT  0:IFFT
    .data_out_re  ( iffted_data_CHB_RE_f2           ) ,                       //output [31:0] data_out_re,
    .data_out_im  ( iffted_data_CHB_IM_f2           ) ,                       //output [31:0] data_out_im,
    .data_out_en  ( iffted_data_CHB_en_f2           ) ,                       //output        data_out_en,
    .data_out_last( iffted_data_CHB_last_f2         )                         //output        data_out_last
        );	
		
wire  [31:0] iffted_data_CHA_RE_f3  ;
wire  [31:0] iffted_data_CHA_IM_f3  ;
wire         iffted_data_CHA_en_f3  ;
wire         iffted_data_CHA_last_f3 ;		
	
reg          iffted_data_CHA_en_f3_r;
reg           iffted_data_CHA_last_f3_r;
reg  [31:0] iffted_data_CHA_RE_f3_r='d0;
reg  [31:0] iffted_data_CHA_IM_f3_r='d0;

always@(posedge  alg_clk)
begin
iffted_data_CHA_en_f3_r<=iffted_data_CHA_en_f3;
iffted_data_CHA_last_f3_r<=iffted_data_CHA_last_f3;
end
always@(posedge alg_clk or negedge rst_n)
 if(!rst_n)
 begin
 iffted_data_CHA_RE_f3_r<='d0;
 iffted_data_CHA_IM_f3_r<='d0;
  end
 else if(iffted_data_CHA_en_f3)
 begin
 iffted_data_CHA_RE_f3_r<=iffted_data_CHA_RE_f3;  
 iffted_data_CHA_IM_f3_r<=iffted_data_CHA_IM_f3;  
end	
		
	 fft_module fft_module_6(
    .aclk         (   alg_clk                      ) ,                              //input         aclk,
    .rst_n        (    FFT_rst_n                       ) ,                             //input         rst_n,
    .data_in_re   ( CHA_RE_IM_DATA_filtered_f3[63:32]                 ) ,                        //input  [31:0] data_in_re,
    .data_in_im   ( CHA_RE_IM_DATA_filtered_f3[31:0]       ) ,                        //input  [31:0] data_in_im,
    .data_in_en   ( CHA_RE_IM_DATA_valid_f3            ) ,                        //input         data_in_en,
    .data_in_last ( CHA_RE_IM_DATA_last_f3              ) ,                      //input         data_in_last,
    .FFT_mode     (           1'b0              )    ,                     //1:FFT  0:IFFT
    .data_out_re  ( iffted_data_CHA_RE_f3           ) ,                       //output [31:0] data_out_re,
    .data_out_im  ( iffted_data_CHA_IM_f3           ) ,                       //output [31:0] data_out_im,
    .data_out_en  ( iffted_data_CHA_en_f3           ) ,                       //output        data_out_en,
    .data_out_last( iffted_data_CHA_last_f3         )                         //output        data_out_last
        );	
		
wire  [31:0] iffted_data_CHB_RE_f3  ;
wire  [31:0] iffted_data_CHB_IM_f3  ;
wire         iffted_data_CHB_en_f3  ;
wire         iffted_data_CHB_last_f3 ;			
reg          iffted_data_CHB_en_f3_r;
reg           iffted_data_CHB_last_f3_r;
reg  [31:0] iffted_data_CHB_RE_f3_r='d0;
reg  [31:0] iffted_data_CHB_IM_f3_r='d0;

always@(posedge  alg_clk)
begin
iffted_data_CHB_en_f3_r<=iffted_data_CHB_en_f3;
iffted_data_CHB_last_f3_r<=iffted_data_CHB_last_f3;
end
always@(posedge alg_clk or negedge rst_n)
 if(!rst_n)
 begin
 iffted_data_CHB_RE_f3_r<='d0;
 iffted_data_CHB_IM_f3_r<='d0;
  end
 else if(iffted_data_CHB_en_f3)
 begin
 iffted_data_CHB_RE_f3_r<=iffted_data_CHB_RE_f3;  
 iffted_data_CHB_IM_f3_r<=iffted_data_CHB_IM_f3;  
end		
		
		
		
	 fft_module fft_module_7(
    .aclk         (   alg_clk                      ) ,                              //input         aclk,
    .rst_n        (    FFT_rst_n                       ) ,                             //input         rst_n,
    .data_in_re   ( CHB_RE_IM_DATA_filtered_f3[63:32]                 ) ,                        //input  [31:0] data_in_re,
    .data_in_im   ( CHB_RE_IM_DATA_filtered_f3[31:0]       ) ,                        //input  [31:0] data_in_im,
    .data_in_en   ( CHB_RE_IM_DATA_valid_f3            ) ,                        //input         data_in_en,
    .data_in_last ( CHB_RE_IM_DATA_last_f3              ) ,                      //input         data_in_last,
    .FFT_mode     (           1'b0              )    ,                     //1:FFT  0:IFFT
    .data_out_re  ( iffted_data_CHB_RE_f3           ) ,                       //output [31:0] data_out_re,
    .data_out_im  ( iffted_data_CHB_IM_f3           ) ,                       //output [31:0] data_out_im,
    .data_out_en  ( iffted_data_CHB_en_f3           ) ,                       //output        data_out_en,
    .data_out_last( iffted_data_CHB_last_f3         )                         //output        data_out_last
        );	
		
	
wire  [31:0] iffted_data_CHA_RE_f1_divide_256  ;
wire  [31:0] iffted_data_CHA_IM_f1_divide_256  ;

	
	//wire  sign_CHA_re;
	//wire  sign_CHA_im;
	//	assign  sign_CHA_re=iffted_data_CHA_RE_f1[31];
	//	assign  sign_CHA_im=iffted_data_CHA_IM_f1[31];
	
		
//assign   iffted_data_CHA_RE_f1_divide_256={iffted_data_CHA_RE_f1[31],((|iffted_data_CHA_RE_f1)?(iffted_data_CHA_RE_f1[30:23]-'d8):8'b0),iffted_data_CHA_RE_f1[22:0]};
//assign   iffted_data_CHA_IM_f1_divide_256={iffted_data_CHA_IM_f1[31],((|iffted_data_CHA_IM_f1)?(iffted_data_CHA_IM_f1[30:23]-'d8):8'b0),iffted_data_CHA_IM_f1[22:0]};
assign   iffted_data_CHA_RE_f1_divide_256={iffted_data_CHA_RE_f1_r[31], ((iffted_data_CHA_RE_f1_r[30:23]>8'd8)?(iffted_data_CHA_RE_f1_r[30:23]-8'd8):8'b0),iffted_data_CHA_RE_f1_r[22:0]};       
assign   iffted_data_CHA_IM_f1_divide_256={iffted_data_CHA_IM_f1_r[31], ((iffted_data_CHA_IM_f1_r[30:23]>8'd8)?(iffted_data_CHA_IM_f1_r[30:23]-8'd8):8'b0),iffted_data_CHA_IM_f1_r[22:0]};  
     
//    wire [31:0] iffted_data_CHA_RE_f1_divide_256_1; 
//    wire [31:0] iffted_data_CHA_IM_f1_divide_256_1; 
//     
//     
//assign   iffted_data_CHA_RE_f1_divide_256_1={sign_CHA_re, ((iffted_data_CHA_RE_f1[30:23]>'d8)?(iffted_data_CHA_RE_f1[30:23]-'d8):8'b0),iffted_data_CHA_RE_f1[22:0]};       
//assign   iffted_data_CHA_IM_f1_divide_256_1={sign_CHA_im, ((iffted_data_CHA_IM_f1[30:23]>'d8)?(iffted_data_CHA_IM_f1[30:23]-'d8):8'b0),iffted_data_CHA_IM_f1[22:0]};      
     
     
     
wire  [31:0] iffted_data_CHB_RE_f1_divide_256   ;
wire  [31:0] iffted_data_CHB_IM_f1_divide_256   ;
	
//wire  sign_CHB_re;
//wire  sign_CHB_im;
//    assign  sign_CHB_re=iffted_data_CHB_RE_f1[31];
//    assign  sign_CHB_im=iffted_data_CHB_IM_f1[31];
//
//  wire [31:0] iffted_data_CHB_RE_f1_divide_256_1;   
//  wire [31:0] iffted_data_CHB_IM_f1_divide_256_1;   
                                                    
//assign   iffted_data_CHB_RE_f1_divide_256={iffted_data_CHB_RE_f1[31],((|iffted_data_CHB_RE_f1)?(iffted_data_CHB_RE_f1[30:23]-'d8):8'b0),iffted_data_CHB_RE_f1[22:0]};
//assign   iffted_data_CHB_IM_f1_divide_256={iffted_data_CHB_IM_f1[31],((|iffted_data_CHB_IM_f1)?(iffted_data_CHB_IM_f1[30:23]-'d8):8'b0),iffted_data_CHB_IM_f1[22:0]};

assign   iffted_data_CHB_RE_f1_divide_256={iffted_data_CHB_RE_f1_r[31], ((iffted_data_CHB_RE_f1_r[30:23]>8'd8)?(iffted_data_CHB_RE_f1_r[30:23]-8'd8):8'b0),iffted_data_CHB_RE_f1_r[22:0]};        
assign   iffted_data_CHB_IM_f1_divide_256={iffted_data_CHB_IM_f1_r[31], ((iffted_data_CHB_IM_f1_r[30:23]>8'd8)?(iffted_data_CHB_IM_f1_r[30:23]-8'd8):8'b0),iffted_data_CHB_IM_f1_r[22:0]};    


//assign   iffted_data_CHB_RE_f1_divide_256_1={sign_CHB_re, ((iffted_data_CHB_RE_f1[30:23]>'d8)?(iffted_data_CHB_RE_f1[30:23]-'d8):8'b0),iffted_data_CHB_RE_f1[22:0]};                         
//assign   iffted_data_CHB_IM_f1_divide_256_1={sign_CHB_im, ((iffted_data_CHB_IM_f1[30:23]>'d8)?(iffted_data_CHB_IM_f1[30:23]-'d8):8'b0),iffted_data_CHB_IM_f1[22:0]};                         






    
wire  [31:0] iffted_data_CHA_RE_f2_divide_256   ;
wire  [31:0] iffted_data_CHA_IM_f2_divide_256   ;
		
//assign   iffted_data_CHA_RE_f2_divide_256={iffted_data_CHA_RE_f2[31],((|iffted_data_CHA_RE_f2)?(iffted_data_CHA_RE_f2[30:23]-'d8):8'b0),iffted_data_CHA_RE_f2[22:0]};
//assign   iffted_data_CHA_IM_f2_divide_256={iffted_data_CHA_IM_f2[31],((|iffted_data_CHA_IM_f2)?(iffted_data_CHA_IM_f2[30:23]-'d8):8'b0),iffted_data_CHA_IM_f2[22:0]};

assign   iffted_data_CHA_RE_f2_divide_256={iffted_data_CHA_RE_f2_r[31], ((iffted_data_CHA_RE_f2_r[30:23]>8'd8)?(iffted_data_CHA_RE_f2_r[30:23]-8'd8):8'b0),iffted_data_CHA_RE_f2_r[22:0]};               
assign   iffted_data_CHA_IM_f2_divide_256={iffted_data_CHA_IM_f2_r[31], ((iffted_data_CHA_IM_f2_r[30:23]>8'd8)?(iffted_data_CHA_IM_f2_r[30:23]-8'd8):8'b0),iffted_data_CHA_IM_f2_r[22:0]};               

wire  [31:0] iffted_data_CHB_RE_f2_divide_256   ;
wire  [31:0] iffted_data_CHB_IM_f2_divide_256   ;
		
//assign   iffted_data_CHB_RE_f2_divide_256={iffted_data_CHB_RE_f2[31],((|iffted_data_CHB_RE_f2)?(iffted_data_CHB_RE_f2[30:23]-'d8):8'b0),iffted_data_CHB_RE_f2[22:0]};
//assign   iffted_data_CHB_IM_f2_divide_256={iffted_data_CHB_IM_f2[31],((|iffted_data_CHB_IM_f2)?(iffted_data_CHB_IM_f2[30:23]-'d8):8'b0),iffted_data_CHB_IM_f2[22:0]};

assign   iffted_data_CHB_RE_f2_divide_256={iffted_data_CHB_RE_f2_r[31], ((iffted_data_CHB_RE_f2_r[30:23]>8'd8)?(iffted_data_CHB_RE_f2_r[30:23]-8'd8):8'b0),iffted_data_CHB_RE_f2_r[22:0]};       
assign   iffted_data_CHB_IM_f2_divide_256={iffted_data_CHB_IM_f2_r[31], ((iffted_data_CHB_IM_f2_r[30:23]>8'd8)?(iffted_data_CHB_IM_f2_r[30:23]-8'd8):8'b0),iffted_data_CHB_IM_f2_r[22:0]};       

wire  [31:0] iffted_data_CHA_RE_f3_divide_256   ;
wire  [31:0] iffted_data_CHA_IM_f3_divide_256   ;

//assign   iffted_data_CHA_RE_f3_divide_256={iffted_data_CHA_RE_f3[31],((|iffted_data_CHA_RE_f3)?(iffted_data_CHA_RE_f3[30:23]-'d8):8'b0),iffted_data_CHA_RE_f3[22:0]};
//assign   iffted_data_CHA_IM_f3_divide_256={iffted_data_CHA_IM_f3[31],((|iffted_data_CHA_IM_f3)?(iffted_data_CHA_IM_f3[30:23]-'d8):8'b0),iffted_data_CHA_IM_f3[22:0]};

assign   iffted_data_CHA_RE_f3_divide_256={iffted_data_CHA_RE_f3_r[31], ((iffted_data_CHA_RE_f3_r[30:23]>8'd8)?(iffted_data_CHA_RE_f3_r[30:23]-8'd8):8'b0),iffted_data_CHA_RE_f3_r[22:0]};                   
assign   iffted_data_CHA_IM_f3_divide_256={iffted_data_CHA_IM_f3_r[31], ((iffted_data_CHA_IM_f3_r[30:23]>8'd8)?(iffted_data_CHA_IM_f3_r[30:23]-8'd8):8'b0),iffted_data_CHA_IM_f3_r[22:0]};                   




wire  [31:0] iffted_data_CHB_RE_f3_divide_256   ;
wire  [31:0] iffted_data_CHB_IM_f3_divide_256   ;

//assign   iffted_data_CHB_RE_f3_divide_256={iffted_data_CHB_RE_f3[31],((|iffted_data_CHB_RE_f3)?(iffted_data_CHB_RE_f3[30:23]-'d8):8'b0),iffted_data_CHB_RE_f3[22:0]};
//assign   iffted_data_CHB_IM_f3_divide_256={iffted_data_CHB_IM_f3[31],((|iffted_data_CHB_IM_f3)?(iffted_data_CHB_IM_f3[30:23]-'d8):8'b0),iffted_data_CHB_IM_f3[22:0]};

assign   iffted_data_CHB_RE_f3_divide_256={iffted_data_CHB_RE_f3_r[31], ((iffted_data_CHB_RE_f3_r[30:23]>8'd8)?(iffted_data_CHB_RE_f3_r[30:23]-8'd8):8'b0),iffted_data_CHB_RE_f3_r[22:0]};              
assign   iffted_data_CHB_IM_f3_divide_256={iffted_data_CHB_IM_f3_r[31], ((iffted_data_CHB_IM_f3_r[30:23]>8'd8)?(iffted_data_CHB_IM_f3_r[30:23]-8'd8):8'b0),iffted_data_CHB_IM_f3_r[22:0]};              




(*mark_debug = "true"*) wire  [31:0]  CHB_A_C_B_D_re_f1    ;//floating point 
(*mark_debug = "true"*) wire          CHB_A_C_B_D_re_en_f1 ;
(*mark_debug = "true"*) wire  [31:0]  CHB_A_D_B_C_im_f1    ;//floating point 
(*mark_debug = "true"*) wire          CHB_A_D_B_C_im_en_f1 ;

floating_point_complex_multiplier floating_point_complex_multiplier_0(
    .rst_n         (             rst_n                            ) ,       //input           rst_n  ,
    .clk           (          alg_clk                          ) ,       //input           clk    ,
    .A_re          (  iffted_data_CHA_RE_f1_divide_256          ) ,        //input   [31:0]  A_re,
    .A_re_en       (      iffted_data_CHA_en_f1_r                      ) ,      //input           A_re_en,
    .B_im          ( { (~iffted_data_CHA_IM_f1_divide_256[31]),iffted_data_CHA_IM_f1_divide_256[30:0]}            ),       //input   [31:0]  B_im,
    .B_im_en       (      iffted_data_CHA_en_f1_r                   )  ,  //input           B_im_en,
    .C_re          (   iffted_data_CHB_RE_f1_divide_256           ),    //input   [31:0]  C_re,
    .C_re_en       (       iffted_data_CHB_en_f1_r                   ),   //input           C_re_en,
    .D_im          (   iffted_data_CHB_IM_f1_divide_256           ),  //input   [31:0]  D_im,
    .D_im_en       (       iffted_data_CHB_en_f1_r                   ) , //input           D_im_en,                    
    .A_C_B_D_re    (   CHB_A_C_B_D_re_f1                       ) ,  //output [31:0]   A_C_B_D_re,
    .A_C_B_D_re_en (   CHB_A_C_B_D_re_en_f1                    ) ,  //output          A_C_B_D_re_en,
    .A_D_B_C_im    (   CHB_A_D_B_C_im_f1                       ) ,  //output [31:0]   A_D_B_C_im,
    .A_D_B_C_im_en (   CHB_A_D_B_C_im_en_f1                    )          //output          A_D_B_C_im_en

);


wire  [31:0]  CHB_A_C_B_D_re_f2    ;//floating point 
wire          CHB_A_C_B_D_re_en_f2 ;
wire  [31:0]  CHB_A_D_B_C_im_f2    ;//floating point 
wire          CHB_A_D_B_C_im_en_f2 ;

floating_point_complex_multiplier floating_point_complex_multiplier_1(
    .rst_n         (            rst_n                          ) ,       //input           rst_n  ,
    .clk           (          alg_clk                          ) ,       //input           clk    ,
    .A_re          (  iffted_data_CHA_RE_f2_divide_256            ) ,        //input   [31:0]  A_re,
    .A_re_en       (     iffted_data_CHA_en_f2_r                       ) ,      //input           A_re_en,
    .B_im          (  {~iffted_data_CHA_IM_f2_divide_256[31],iffted_data_CHA_IM_f2_divide_256[30:0]}            ),       //input   [31:0]  B_im,
    .B_im_en       (      iffted_data_CHA_en_f2_r                    )  ,  //input           B_im_en,
    .C_re          (   iffted_data_CHB_RE_f2_divide_256           ),    //input   [31:0]  C_re,
    .C_re_en       (       iffted_data_CHB_en_f2_r                   ),   //input           C_re_en,
    .D_im          (   iffted_data_CHB_IM_f2_divide_256           ),  //input   [31:0]  D_im,
    .D_im_en       (       iffted_data_CHB_en_f2_r                   ) , //input           D_im_en,                    
    .A_C_B_D_re    (   CHB_A_C_B_D_re_f2                       ) ,  //output [31:0]   A_C_B_D_re,
    .A_C_B_D_re_en (   CHB_A_C_B_D_re_en_f2                    ) ,  //output          A_C_B_D_re_en,
    .A_D_B_C_im    (   CHB_A_D_B_C_im_f2                       ) ,  //output [31:0]   A_D_B_C_im,
    .A_D_B_C_im_en (   CHB_A_D_B_C_im_en_f2                    )          //output          A_D_B_C_im_en

);


wire  [31:0]  CHB_A_C_B_D_re_f3    ;//floating point 
wire          CHB_A_C_B_D_re_en_f3 ;
wire  [31:0]  CHB_A_D_B_C_im_f3    ;//floating point 
wire          CHB_A_D_B_C_im_en_f3 ;

floating_point_complex_multiplier floating_point_complex_multiplier_2(
    .rst_n         (            rst_n                           ) ,       //input           rst_n  ,
    .clk           (          alg_clk                          ) ,       //input           clk    ,
    .A_re          (  iffted_data_CHA_RE_f3_divide_256            ) ,        //input   [31:0]  A_re,
    .A_re_en       (      iffted_data_CHA_en_f3_r                      ) ,      //input           A_re_en,
    .B_im          ({(~iffted_data_CHA_IM_f3_divide_256[31]),iffted_data_CHA_IM_f3_divide_256[30:0]}           ),       //input   [31:0]  B_im,
    .B_im_en       (      iffted_data_CHA_en_f3_r                    )  ,  //input           B_im_en,
    .C_re          (   iffted_data_CHB_RE_f3_divide_256           ),    //input   [31:0]  C_re,
    .C_re_en       (       iffted_data_CHB_en_f3_r                   ),   //input           C_re_en,
    .D_im          (   iffted_data_CHB_IM_f3_divide_256           ),  //input   [31:0]  D_im,
    .D_im_en       (       iffted_data_CHB_en_f3_r                   ) , //input           D_im_en,                    
    .A_C_B_D_re    (   CHB_A_C_B_D_re_f3                       ) ,  //output [31:0]   A_C_B_D_re,
    .A_C_B_D_re_en (   CHB_A_C_B_D_re_en_f3                    ) ,  //output          A_C_B_D_re_en,
    .A_D_B_C_im    (   CHB_A_D_B_C_im_f3                       ) ,  //output [31:0]   A_D_B_C_im,
    .A_D_B_C_im_en (   CHB_A_D_B_C_im_en_f3                    )          //output          A_D_B_C_im_en

);

(*mark_debug = "true"*) wire [31:0]    A_C_B_D_re_normalized_f1   ;     //fixed point 31_29
(*mark_debug = "true"*) wire           A_C_B_D_re_normalized_en_f1;     //fixed point 31_29
(*mark_debug = "true"*) wire  [31:0]   A_D_B_C_im_normalized_f1   ;     //fixed point 31_29
(*mark_debug = "true"*) wire           A_D_B_C_im_normalized_en_f1;      //fixed point 31_29



 normalization  normalization_0(
   .clk                     (     alg_clk                       ) ,                         //input            clk,         
   .rst_n                   (     rst_n                           ) ,                       //input            rst_n,
   .A_C_B_D_re              ( CHB_A_C_B_D_re_f1               ) ,                  //input [31:0]     A_C_B_D_re,
   .A_C_B_D_re_en           ( CHB_A_C_B_D_re_en_f1            ) ,               //input            A_C_B_D_re_en,
   .A_D_B_C_im              ( CHB_A_D_B_C_im_f1               ) ,                  //input [31:0]     A_D_B_C_im,
   .A_D_B_C_im_en           ( CHB_A_D_B_C_im_en_f1            ) ,               //input            A_D_B_C_im_en,
   .A_C_B_D_re_normalized   ( A_C_B_D_re_normalized_f1         ) ,    //output [31:0]    A_C_B_D_re_normalized   ,      //fixed point 31_29
   .A_C_B_D_re_normalized_en( A_C_B_D_re_normalized_en_f1      ) ,    //output           A_C_B_D_re_normalized_en,      //fixed point 31_29
   .A_D_B_C_im_normalized   ( A_D_B_C_im_normalized_f1         ) ,    //output  [31:0]   A_D_B_C_im_normalized   ,      //fixed point 31_29
   .A_D_B_C_im_normalized_en( A_D_B_C_im_normalized_en_f1      )      //output           A_D_B_C_im_normalized_en       //fixed point 31_29
  );

wire [31:0]    A_C_B_D_re_normalized_f2   ;     //fixed point 31_29
wire           A_C_B_D_re_normalized_en_f2;     //fixed point 31_29
wire  [31:0]   A_D_B_C_im_normalized_f2   ;     //fixed point 31_29
wire           A_D_B_C_im_normalized_en_f2;      //fixed point 31_29
  

 normalization  normalization_1(
   .clk                     (     alg_clk                       ) ,                         //input            clk,         
   .rst_n                   (     rst_n                            ) ,                       //input            rst_n,
   .A_C_B_D_re              ( CHB_A_C_B_D_re_f2               ) ,                  //input [31:0]     A_C_B_D_re,
   .A_C_B_D_re_en           ( CHB_A_C_B_D_re_en_f2            ) ,               //input            A_C_B_D_re_en,
   .A_D_B_C_im              ( CHB_A_D_B_C_im_f2               ) ,                  //input [31:0]     A_D_B_C_im,
   .A_D_B_C_im_en           ( CHB_A_D_B_C_im_en_f2            ) ,               //input            A_D_B_C_im_en,
   .A_C_B_D_re_normalized   ( A_C_B_D_re_normalized_f2         ) ,    //output [31:0]    A_C_B_D_re_normalized   ,      //fixed point 31_29
   .A_C_B_D_re_normalized_en( A_C_B_D_re_normalized_en_f2      ) ,    //output           A_C_B_D_re_normalized_en,      //fixed point 31_29
   .A_D_B_C_im_normalized   ( A_D_B_C_im_normalized_f2         ) ,    //output  [31:0]   A_D_B_C_im_normalized   ,      //fixed point 31_29
   .A_D_B_C_im_normalized_en( A_D_B_C_im_normalized_en_f2      )      //output           A_D_B_C_im_normalized_en       //fixed point 31_29
  );

wire [31:0]    A_C_B_D_re_normalized_f3   ;     //fixed point 31_29
wire           A_C_B_D_re_normalized_en_f3;     //fixed point 31_29
wire  [31:0]   A_D_B_C_im_normalized_f3   ;     //fixed point 31_29
wire           A_D_B_C_im_normalized_en_f3;      //fixed point 31_29


 normalization  normalization_2(
   .clk                     (     alg_clk                       ) ,                         //input            clk,         
   .rst_n                   (    rst_n                            ) ,                       //input            rst_n,
   .A_C_B_D_re              ( CHB_A_C_B_D_re_f3               ) ,                  //input [31:0]     A_C_B_D_re,
   .A_C_B_D_re_en           ( CHB_A_C_B_D_re_en_f3            ) ,               //input            A_C_B_D_re_en,
   .A_D_B_C_im              ( CHB_A_D_B_C_im_f3               ) ,                  //input [31:0]     A_D_B_C_im,
   .A_D_B_C_im_en           ( CHB_A_D_B_C_im_en_f3            ) ,               //input            A_D_B_C_im_en,
   .A_C_B_D_re_normalized   ( A_C_B_D_re_normalized_f3         ) ,    //output [31:0]    A_C_B_D_re_normalized   ,      //fixed point 31_29
   .A_C_B_D_re_normalized_en( A_C_B_D_re_normalized_en_f3      ) ,    //output           A_C_B_D_re_normalized_en,      //fixed point 31_29
   .A_D_B_C_im_normalized   ( A_D_B_C_im_normalized_f3         ) ,    //output  [31:0]   A_D_B_C_im_normalized   ,      //fixed point 31_29
   .A_D_B_C_im_normalized_en( A_D_B_C_im_normalized_en_f3      )      //output           A_D_B_C_im_normalized_en       //fixed point 31_29
  );


  (*mark_debug = "true"*)  wire [31:0] phase_before_rpjp_f1;
  (*mark_debug = "true"*)  wire        phase_before_rpjp_en_f1;


cordic_0 cordic_0_0(
   . aclk                   (   alg_clk           ), // : IN STD_LOGIC;
   . s_axis_cartesian_tvalid(   A_C_B_D_re_normalized_en_f1      ), // : IN STD_LOGIC;
   . s_axis_cartesian_tdata ( {A_D_B_C_im_normalized_f1,A_C_B_D_re_normalized_f1}), // : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
   . m_axis_dout_tvalid     (    phase_before_rpjp_en_f1                   ), // : OUT STD_LOGIC;
   . m_axis_dout_tdata      (  phase_before_rpjp_f1                     ) // : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );

wire  [31:0]  phase_selected_before_rpjp_f1;
wire          phase_selected_before_rpjp_en_f1;

data_select#(
 . select_cnt  (26 ),
 . frame_width (256), 
 . data_width  (32 )
)
data_select_0(
  .clk            (  alg_clk        ),
  .rst_n          (  rst_n          ),
  .data_in        (   phase_before_rpjp_f1       ),
  .data_in_valid  (   phase_before_rpjp_en_f1  ), 
  .data_out       (   phase_selected_before_rpjp_f1   ), 
  .data_out_valid (   phase_selected_before_rpjp_en_f1 )
);

reg [31:0] phase_selected_before_rpjp_f1_r   =32'd0;
reg        phase_selected_before_rpjp_en_f1_r=1'd0;

always@(posedge  alg_clk or negedge rst_n)
 if(!rst_n)
phase_selected_before_rpjp_en_f1_r<=1'b0;
else
phase_selected_before_rpjp_en_f1_r<=phase_selected_before_rpjp_en_f1;

always@(posedge  alg_clk or negedge rst_n)
 if(!rst_n)
phase_selected_before_rpjp_f1_r<=1'b0;
else if(phase_selected_before_rpjp_en_f1)
phase_selected_before_rpjp_f1_r<=phase_selected_before_rpjp_f1;





 (*mark_debug = "true"*) wire [31:0] fp_result_before_rpjp_f1   ;
 (*mark_debug = "true"*) wire        fp_result_before_rpjp_en_f1;
  wire [31:0] fp_result_before_rpjp_f2   ;
  wire        fp_result_before_rpjp_en_f2;
  wire [31:0] fp_result_before_rpjp_f3   ;
  wire        fp_result_before_rpjp_en_f3;

fix_32_29_to_fp32 fix_32_29_to_fp32_0(
   .aclk                 (    alg_clk        ),
   .s_axis_a_tvalid      ( phase_selected_before_rpjp_en_f1    ),
   .s_axis_a_tdata       ( phase_selected_before_rpjp_f1       ),
   .m_axis_result_tvalid ( fp_result_before_rpjp_en_f1                   ), 
   .m_axis_result_tdata  ( fp_result_before_rpjp_f1                   )  
  );

(*mark_debug = "true"*)  wire [31:0] PHASE_out_f1;
 (*mark_debug = "true"*)  wire        PHASE_out_EN_f1;


 shift_reg#(
  .shift_ele_width(32 ),
  .shift_stage    (4  )
)
shift_reg_0(
  .clk         (    alg_clk              ),
  .rst_n       (       rst_n                    ),
  .data_in     (  PHASE_out_f1    ),
  .data_in_vld (  PHASE_out_EN_f1       ),
  .data_out    (   raw_phase_to_pcie_frequency1     ), 
  .data_out_vld(  raw_phase_to_pcie_frequency1_valid   )
);






wire [31:0] phase_before_rpjp_f2;
wire        phase_before_rpjp_en_f2;


cordic_0 cordic_0_1(
   . aclk                   (   alg_clk           ), // : IN STD_LOGIC;
   . s_axis_cartesian_tvalid(   A_C_B_D_re_normalized_en_f2      ), // : IN STD_LOGIC;
   . s_axis_cartesian_tdata ( {A_D_B_C_im_normalized_f2,A_C_B_D_re_normalized_f2}), // : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
   . m_axis_dout_tvalid     (    phase_before_rpjp_en_f2                   ), // : OUT STD_LOGIC;
   . m_axis_dout_tdata      (  phase_before_rpjp_f2                     ) // : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );






fix_32_29_to_fp32 fix_32_29_to_fp32_1(
   .aclk                 (    alg_clk        ),
   .s_axis_a_tvalid      ( phase_before_rpjp_en_f2    ),
   .s_axis_a_tdata       ( phase_before_rpjp_f2       ),
   .m_axis_result_tvalid ( fp_result_before_rpjp_en_f2                   ), 
   .m_axis_result_tdata  ( fp_result_before_rpjp_f2                   )  
  );

 shift_reg#(
  .shift_ele_width(32 ),
  .shift_stage    (4  )
)
shift_reg_1(
  .clk         (    alg_clk              ),
  .rst_n       (      rst_n                     ),
  .data_in     (  fp_result_before_rpjp_f2    ),
  .data_in_vld (  fp_result_before_rpjp_en_f2       ),
  .data_out    (   raw_phase_to_pcie_frequency2     ), 
  .data_out_vld(  raw_phase_to_pcie_frequency2_valid   )
);


wire [31:0] phase_before_rpjp_f3;
wire        phase_before_rpjp_en_f3;


cordic_0 cordic_0_2(
   . aclk                   (   alg_clk           ), // : IN STD_LOGIC;
   . s_axis_cartesian_tvalid(   A_C_B_D_re_normalized_en_f3      ), // : IN STD_LOGIC;
   . s_axis_cartesian_tdata ( {A_D_B_C_im_normalized_f3,A_C_B_D_re_normalized_f3}), // : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
   . m_axis_dout_tvalid     (    phase_before_rpjp_en_f3                   ), // : OUT STD_LOGIC;
   . m_axis_dout_tdata      (  phase_before_rpjp_f3                     ) // : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );

fix_32_29_to_fp32 fix_32_29_to_fp32_2(
   .aclk                 (    alg_clk        ),
   .s_axis_a_tvalid      ( phase_before_rpjp_f3    ),
   .s_axis_a_tdata       ( phase_before_rpjp_en_f3       ),
   .m_axis_result_tvalid ( fp_result_before_rpjp_en_f3                   ), 
   .m_axis_result_tdata  ( fp_result_before_rpjp_f3                   )  
  );

 shift_reg#(
  .shift_ele_width(32 ),
  .shift_stage    (4  )
)
shift_reg_2(
  .clk         (    alg_clk              ),
  .rst_n       (      rst_n                ),
  .data_in     (  fp_result_before_rpjp_en_f3    ),
  .data_in_vld (  fp_result_before_rpjp_f3       ),
  .data_out    (   raw_phase_to_pcie_frequency3     ), 
  .data_out_vld(  raw_phase_to_pcie_frequency3_valid   )
);




















 

RPJP_processing_unit_v2 RPJP_processing_unit_v2_0(
        .clk          (     alg_clk                   ),                                   //input		   wire		      clk,
        .rst_n        (     rst_n                    ),                           //input        wire           rst_n,
        .PHASE_IN     (phase_selected_before_rpjp_f1_r       ),                        //input        wire[31:0]     PHASE_IN,
        .PHASE_IN_en  (phase_selected_before_rpjp_en_f1_r  ),                     //input        wire           PHASE_IN_en,
        .PHASE_out    (   PHASE_out_f1                ),//floating_point       //output       wire[31:0]     PHASE_out,//floating_point
        .PHASE_out_EN (   PHASE_out_EN_f1             )                      //output       wire           PHASE_out_EN
 );


wire [31:0] PHASE_out_f2;
wire        PHASE_out_EN_f2;

RPJP_processing_unit_v2 RPJP_processing_unit_v2_1(
        .clk          (     alg_clk                   ),                                   //input		   wire		      clk,
        .rst_n        (     rst_n                    ),                           //input        wire           rst_n,
        .PHASE_IN     (   phase_before_rpjp_f2        ),                        //input        wire[31:0]     PHASE_IN,
        .PHASE_IN_en  (     phase_before_rpjp_en_f2   ),                     //input        wire           PHASE_IN_en,
        .PHASE_out    (   PHASE_out_f2                ),//floating_point       //output       wire[31:0]     PHASE_out,//floating_point
        .PHASE_out_EN (   PHASE_out_EN_f2             )                      //output       wire           PHASE_out_EN
 );



wire [31:0] PHASE_out_f3;
wire        PHASE_out_EN_f3;

RPJP_processing_unit_v2 RPJP_processing_unit_v2_2(
        .clk          (     alg_clk                   ),                                   //input		   wire		      clk,
        .rst_n        (     rst_n                    ),                           //input        wire           rst_n,
        .PHASE_IN     (   phase_before_rpjp_f3        ),                        //input        wire[31:0]     PHASE_IN,
        .PHASE_IN_en  (     phase_before_rpjp_en_f3   ),                     //input        wire           PHASE_IN_en,
        .PHASE_out    (   PHASE_out_f3                ),//floating_point       //output       wire[31:0]     PHASE_out,//floating_point
        .PHASE_out_EN (   PHASE_out_EN_f3             )                      //output       wire           PHASE_out_EN
 );

reg [2:0] frequency_mode='d00;
always@(posedge alg_clk or negedge rst_n) 
if(!rst_n)
frequency_mode<='d00;
else if(filter_mode_en)
frequency_mode<=filter_mode;
 data_select_and_arbier data_select_and_arbier_0(
         . clk                 (     alg_clk                            ),                                                       //input		   wire		      clk,
         . rst_n               (     rst_n                              ),                                            //input           wire           rst_n,
         . ferquency_mode      (     frequency_mode                     ),                                   //input        [2:0]             ferquency_mode,
         . PHASE_out_f1        (    PHASE_out_f1                        ),                                     //input        wire[31:0]        PHASE_out_f1,
         . PHASE_out_EN_f1     (    PHASE_out_EN_f1                     ),                                  //input        wire              PHASE_out_EN_f1,
         . PHASE_out_f2        (    PHASE_out_f2                        ),                                     //input        wire[31:0]        PHASE_out_f2,
         . PHASE_out_EN_f2     (    PHASE_out_EN_f2                     ),                                  //input        wire              PHASE_out_EN_f2,
         . PHASE_out_f3        (     PHASE_out_f3                       ),                                     //input        wire[31:0]        PHASE_out_f3,
         . PHASE_out_EN_f3     (     PHASE_out_EN_f3                    ),                                  //input        wire              PHASE_out_EN_f3, 
         . PHASE_out_to_PCIE   (  PHASE_out_to_PCIE                     ),                              //output       reg [127:0]       PHASE_out_to_PCIE=0,
         . PHASE_out_to_PCIE_en(  PHASE_out_to_PCIE_en                  )                                     //output       reg               PHASE_out_to_PCIE_en=0
);


endmodule
