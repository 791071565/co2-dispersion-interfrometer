`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/16 12:55:09
// Design Name: 
// Module Name: hl2m_algorithm_top
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


module hl2m_algorithm_top(//pem sync the data should larger than zero
     input          alg_clk,
     input          alg_rst_n,
     input          dat_clk,
     input  [15:0]  ref_dat,
     input          ref_dat_valid,
     input  [15:0]  pem_dat,
     input          pem_dat_valid,
     input  [15:0]  pem_dat_average,

     //input    frequency_valid,
   //  input   refresh_align,
  //   output   trig_search_cdc,
     output [31:0]  phase_out,   
     output   phase_out_valid,

output  [127:0]    phase_to_pcie    , 
output    phase_to_pcie_valid ,

 output [127:0]   phase_out_shift ,       
output   phase_out_shift_valid   
        


);

  wire   refresh_align;




wire    init_phase_found;


//wire  [47:0] wave_dat_sine;
//wire  [47:0] wave_dat_cosine;
//wire         wave_dat_req; 
//wire  [8:0]  wave_addr;   
wire         pem_posedge;
wire  [47:0] angle_out_0      ;
wire         angle_out_valid_0; 
wire  [47:0] angle_out_1      ;
wire         angle_out_valid_1; 
wire         sine_valid;
wire         sine_valid_r;
wire         sine_valid_neg;
wire         sine_valid_pos;
wire  [47:0] sine_wave;
wire         cosine_valid;
wire  [47:0] cosine_wave;
wire  [47:0] reserve1;
wire  [47:0] reserve2;
wire  [15:0]  ref_sync_pem_dat      ;
wire          ref_sync_pem_dat_valid;

wire  [15:0]  ram_dat     ;
wire  [8:0]   ram_addr    ;
wire          ram_wr_valid;
(*mark_debug = "true"*) wire  trig_search_cdc;
wire [8:0] cap_data_number;
wire  serach_req;
wire  [15:0] capture_raw_dat;



//wire        stroe_wave; 
//wire        sine_valid_rrrr;
//wire [47:0] sine_wave_rrrr;
//wire [8:0]  sine_addr_rrrr;   
//wire        cosine_valid_rrrr;
//wire [47:0] cosine_wave_rrrr;
//wire [8:0]  cosine_addr_rrrr; 


   wire [47:0]   sine_wave_r   ;
   wire [47:0]   cosine_wave_r ;
   wire [8:0]    sine_addr_r   ;
   wire [8:0]    cosine_addr_r ;
 // wire          sine_valid_r  ;
   wire          cosine_valid_r; 


   wire    mem_copy_end_1  ;
   wire    mem_copy_1      ;
   wire    mem_copy_end_2  ;
   wire    mem_copy_2      ;
   wire    mem_copy_end_3  ;
   wire    mem_copy_3      ;
   wire    mem_copy_end_4  ;
   wire    mem_copy_4      ;








reg [8:0] sine_addr ;
reg [8:0] cosine_addr ;

wire  fft_end;
//wire  sine_valid_rrrr_neg;
//reg  sine_valid_rrrr_d1;
//always@(posedge alg_clk)
//sine_valid_rrrr_d1<=sine_valid_rrrr;
//assign sine_valid_rrrr_neg=(!sine_valid_rrrr)&&sine_valid_rrrr_d1;



assign sine_valid_neg= (!sine_valid)&&sine_valid_r;
assign sine_valid_pos= (sine_valid)&&(!sine_valid_r);
//always@(posedge alg_clk)
//sine_valid_r<=sine_valid;

alg_top_fir alg_top_fir_0(
  .alg_clk                (alg_clk               ),      //input          alg_clk,
  .alg_rst_n              (alg_rst_n             ),      //input          alg_rst_n,
  .dat_clk                (dat_clk               ),      //input          dat_clk,
  .ref_dat                (ref_dat               ),      //input  [15:0]  ref_dat,
  .ref_dat_valid          (ref_dat_valid         ),      //input          ref_dat_valid,
  .pem_dat                (pem_dat               ),      //input  [15:0]  pem_dat,
  .pem_dat_valid          (pem_dat_valid         ),      //input          pem_dat_valid,
  .pem_dat_average        (pem_dat_average       ),      //input  [15:0]  pem_dat_average,
//  .wave_dat_sine          (wave_dat_sine         ),      //input  [47:0]  wave_dat_sine,
//  .wave_dat_cosine        (wave_dat_cosine       ),      //input  [47:0]  wave_dat_cosine,
//  .wave_dat_req           (wave_dat_req          ),      //output         wave_dat_req,
//  .wave_addr              (wave_addr             ),      //output  [8:0]  wave_addr,
//  .phase_out              (phase_out             ),     //output [31:0]  phase_out,
//  .phase_out_valid        (phase_out_valid       ),
  .pem_posedge            (pem_posedge           ),  //output [31:0]  phase_out_valid
  .ref_sync_pem_dat       (ref_sync_pem_dat      )   ,
  .ref_sync_pem_dat_valid (ref_sync_pem_dat_valid) 
//  .init_phase_found       (init_phase_found) 
// .   phase_to_pcie       (   phase_to_pcie       ),
// . phase_to_pcie_valid   ( phase_to_pcie_valid   )

  
);


//data_cap_ture data_cap_ture_0(
//    .alg_clk               ( alg_clk            ) ,   //input          alg_clk,
//    .alg_rst_n             ( alg_rst_n          ) ,   //input          alg_rst_n,
//	.ref_sync_pem_dat      ( ref_sync_pem_dat        ) ,   //input   [15:0] ref_sync_pem_dat,
//    .ref_sync_pem_dat_valid( ref_sync_pem_dat_valid  ) ,   //input          ref_sync_pem_dat_valid,
//	.pem_posedge           ( pem_posedge       ) ,   //input          pem_posedge,
//	.ram_dat               ( ram_dat             ) ,   //output  [15:0] ram_dat,
//	.ram_addr              ( ram_addr            ) ,   //output  [8:0]  ram_addr,
//	.ram_wr_valid          ( ram_wr_valid        ) ,   //output         ram_wr_valid,
//	.trig_search_cdc       (  trig_search_cdc      ) ,   //output         trig_search_cdc,
//	.cap_data_number       (  cap_data_number       ) ,   //output  [8:0]  cap_data_number,
//	.cap_data_number_valid (                       )   //output         cap_data_number_valid
//  );
(*mark_debug = "true"*) wire  frequency_valid;
(*mark_debug = "true"*) wire  filtered_pem_posedge;
 wire [18:0]   coef       ;
 (*mark_debug = "true"*) wire    coef_valid ;
frequency_detect#(
    .frequency_detect_count(20'd1000000)
)
frequency_detect_0(
	.clk                  ( alg_clk            ) ,                              //input           clk,
	.rst_n                ( alg_rst_n          ) ,                            //input           rst_n,
	.data_valid           (ref_sync_pem_dat_valid     ) ,                       //input           data_valid,
	.PEM_posedge          (pem_posedge           ) ,						                //input           PEM_posedge,						 
	.frequency            (                      ) ,                        //output [19:0]   frequency,
    .frequency_valid      (frequency_valid       ),             //output          frequency_valid ,
	.frequency_detected_w (                      ) ,             //output          frequency_detected_w,
	.PEM_posedge_filtered (filtered_pem_posedge  ) ,             //output          PEM_posedge_filtered,
	.filter_sig           (                      )  ,             //output          filter_sig
	.  coef       (  coef                 ) ,
    .  coef_valid (   coef_valid        )
	
	
);
wire  fft_end_delay;
dat_gen dat_gen_0(
  .clk             (  alg_clk       ),                                               // input          clk,
  .rst_n           (  alg_rst_n     ),                                             // input          rst_n,
  .valid_coef      ( coef                  ),                                        // input [18:0]   valid_coef,         //19 bit fractional
  .coef_valid      (    coef_valid        ),                                        // input          coef_valid, 
  .trig_search_cdc (  trig_search_cdc    ),                                   // input          trig_search_cdc,
  .cap_data_number (      8'd101             ),                                   // input   [8:0]  cap_data_number,
  .fft_end         (   fft_end_delay          ),                                           // input          fft_end,
  .angle_out       ( angle_out_0    ),                                         // output  [47:0] angle_out,
  .angle_out_valid ( angle_out_valid_0    ),                                  // output         angle_out_valid ,
  .angle_out_temp  (                   )                                    // output [55:0] angle_out_temp 
);


dat_gen_two dat_gen_two_0(
 .clk            ( alg_clk           ),              //input          clk,
 .rst_n          ( alg_rst_n         ),            //input          rst_n,
 .valid_coef     (coef               ),       //input [18:0]   valid_coef,
 .coef_valid     (   coef_valid      ),       //input          coef_valid, 
 .trig_search_cdc(   trig_search_cdc            ),  //input          trig_search_cdc,
 .cap_data_number(     8'd101              ),  //input   [8:0]  cap_data_number, 
 .fft_end        (    fft_end_delay          ),          //input          fft_end,
 .angle_out      (   angle_out_1         ),        //output  [47:0] angle_out,
 .angle_out_temp (                      ),   //output [55:0]  angle_out_temp,
 .angle_out_valid(angle_out_valid_1   )   //output         angle_out_valid 
);

  sin_cos_generator sin_cos_generator_0 (    
        .aclk                (    alg_clk               ),    
        .s_axis_phase_tvalid (  angle_out_valid_0    ),    
        .s_axis_phase_tdata  (  angle_out_0            ),    
        .m_axis_dout_tvalid  ( sine_valid    ),    
        .m_axis_dout_tdata   (     { sine_wave,reserve1}    )     
       );  
 
 
  sin_cos_generator sin_cos_generator_1 (    
        .aclk                (    alg_clk             ),    
        .s_axis_phase_tvalid (  angle_out_valid_1    ),    
        .s_axis_phase_tdata  (  angle_out_1            ),    
        .m_axis_dout_tvalid  ( cosine_valid    ),    
        .m_axis_dout_tdata   (     { cosine_wave,reserve2}    )     
       );  
       
 
       
 wire  search_req;
 wire [8:0] search_addr;
//wire  [15:0]  capture_raw_dat;

wire    [11:0]     average_1_position_max  ;    
wire    [11:0]     average_1_position_min  ;    
wire    [11:0]     average_2_position_max  ;    
wire    [11:0]     average_2_position_min  ;    
wire               init_phase_found_posedge;  

wire               average_1_max_select;   
wire               average_1_min_select;   
wire               average_2_max_select;   
wire               average_2_min_select;   
wire               select_valid        ;   

wire      retrigger;
wire   retrigger_delay;
mix_max_search mix_max_search_0(
  .alg_clk                   (    alg_clk                                            )    ,                    //input                alg_clk,
  .alg_rst_n                 (    alg_rst_n                                          )    ,                  //input                alg_rst_n,
  .research                  (    retrigger_delay                                  )     ,                   //input                research,   
  .sine_valid                (   sine_valid                                 )     ,                 //input                sine_valid,
  .sine_wave                 (    sine_wave                                   )     ,                  //input [47:0]         sine_wave,
  .sine_addr                 (   sine_addr                                   )     ,                  //input [8:0]          sine_addr,
  .cosine_valid              (  cosine_valid                              )     ,               //input                cosine_valid,
  .cosine_wave               (  cosine_wave                               )     ,                //input [47:0]         cosine_wave,
  .cosine_addr               (  cosine_addr                               )     ,                //input [8:0]          cosine_addr, 
  .search_req                ( search_req                                     )     ,                 //output               search_req,
  .search_addr               (  search_addr                                  )     ,                //output  reg [8:0]    search_addr,
  .capture_raw_dat           ( capture_raw_dat                             )     ,            //input       [15:0]   capture_raw_dat,
  .sine_wave_r               (   sine_wave_r                               )     ,                //output  reg [47:0]   sine_wave_r,
  .cosine_wave_r             (   cosine_wave_r                             )     ,              //output  reg [47:0]   cosine_wave_r,
  .sine_addr_r               (   sine_addr_r                               )     ,                //output  reg [8:0]    sine_addr_r,
  .cosine_addr_r             (   cosine_addr_r                             )     ,              //output  reg [8:0]    cosine_addr_r,
  .sine_valid_r              (   sine_valid_r                              )     ,               //output  reg          sine_valid_r,
  .cosine_valid_r            (   cosine_valid_r                            )     ,             //output  reg          cosine_valid_r,
  .average_1_position_max    (  average_1_position_max                      )     ,     //output    [11:0]     average_1_position_max,
  .average_1_position_min    (  average_1_position_min                      )     ,     //output    [11:0]     average_1_position_min,
  .average_2_position_max    (  average_2_position_max                      )     ,     //output    [11:0]     average_2_position_max,
  .average_2_position_min    (  average_2_position_min                      )     ,     //output    [11:0]     average_2_position_min, 
  .init_phase_found_posedge  (  init_phase_found_posedge                    )     ,     //output   wire        init_phase_found_posedge, 
  .mem_copy_end_1            (  mem_copy_end_1                             )     ,             //input                mem_copy_end_1,
  .mem_copy_1                (  mem_copy_1                                 )     ,                 //output reg           mem_copy_1,
  .mem_copy_end_2            (  mem_copy_end_2                             )     ,             //input                mem_copy_end_2,
  .mem_copy_2                (  mem_copy_2                                 )     ,                 //output reg           mem_copy_2,
  .mem_copy_end_3            (  mem_copy_end_3                             )     ,             //input                mem_copy_end_3,
  .mem_copy_3                (  mem_copy_3                                 )     ,                 //output reg           mem_copy_3,
  .mem_copy_end_4            (  mem_copy_end_4                             )     ,             //input                mem_copy_end_4,
  .mem_copy_4                (  mem_copy_4                                 )      ,                 //output reg           mem_copy_4,
  .fft_end                   (   fft_end                                   )             //output               fft_end                            //search degree
 );


max_min_select max_min_select_0(
 .alg_clk                 (   alg_clk                         ),      // input             alg_clk,
 .alg_rst_n               (   alg_rst_n                       ),    // input             alg_rst_n,                
 .average_1_position_max  (  average_1_position_max           ),    // input    [11:0]   average_1_position_max  ,
 .average_1_position_min  (  average_1_position_min           ),    // input    [11:0]   average_1_position_min  ,
 .average_2_position_max  (  average_2_position_max           ),    // input    [11:0]   average_2_position_max  ,
 .average_2_position_min  (  average_2_position_min           ),    // input    [11:0]   average_2_position_min  ,   
 .init_phase_found_posedge(  init_phase_found_posedge         ),    // input             init_phase_found_posedge, 
 .average_1_max_select    (  average_1_max_select             ),    // output    reg     average_1_max_select,  
 .average_1_min_select    (  average_1_min_select             ),    // output    reg     average_1_min_select,
 .average_2_max_select    (  average_2_max_select             ),    // output    reg     average_2_max_select,  
 .average_2_min_select    (  average_2_min_select             ),    // output    reg     average_2_min_select,
 .select_valid            (  select_valid                     )     // output    reg     select_valid
  );


wire wave_dat_req_1;
wire [8:0]  wave_addr_1;
wire [47:0]  wave_data_sine   ;
wire [47:0]  wave_data_cosine ;
wire       buf_refresh;

  buffer_group buffer_group_0(
   .alg_clk              (   alg_clk                      ),         //input          alg_clk,
   .alg_rst_n            (   alg_rst_n                    ),       //input          alg_rst_n,
   .sine_wave_r          (   sine_wave_r               ),     //input [47:0]   sine_wave_r,
   .cosine_wave_r        (   cosine_wave_r             ),   //input [47:0]   cosine_wave_r,
   .sine_addr_r          (   sine_addr_r               ),     //input [8:0]    sine_addr_r,
   .cosine_addr_r        (   cosine_addr_r             ),   //input [8:0]    cosine_addr_r,
   .sine_valid_r         (   sine_valid_r              ),    //input          sine_valid_r,
   .cosine_valid_r       (   cosine_valid_r            ),  //input          cosine_valid_r,
   .wave_length          (  8'd101                           ),     //input [8:0]    wave_length,     
   .start_search         ( trig_search_cdc                ),    //input          start_search,
   .search_end           ( retrigger_delay                       ),    //input          search_end  ,       
   .mem_copy_end_1       ( mem_copy_end_1                  ),  //output         mem_copy_end_1,
   .mem_copy_1           ( mem_copy_1                      ),      //input          mem_copy_1, 
   .mem_copy_end_2       ( mem_copy_end_2                  ),  //output         mem_copy_end_2,
   .mem_copy_2           ( mem_copy_2                      ),      //input          mem_copy_2,
   .mem_copy_end_3       ( mem_copy_end_3                  ),  //output         mem_copy_end_3,
   .mem_copy_3           ( mem_copy_3                      ),      //input          mem_copy_3,
   .mem_copy_end_4       ( mem_copy_end_4                  ),  //output         mem_copy_end_4,
   .mem_copy_4           ( mem_copy_4                      ),     //input          mem_copy_4 ,    
   .average_1_max_select (average_1_max_select             ),  
   .average_1_min_select (average_1_min_select             ),
   .average_2_max_select (average_2_max_select             ),  
   .average_2_min_select (average_2_min_select             ),
   .select_valid         (select_valid                     ),      
   .channel_A_en         (   wave_dat_req_1                ),   //input          channel_A_en ,
   .channel_A_addr       (  wave_addr_1                    ),  //input  [8:0]   channel_A_addr,
   .channel_A_data       (     wave_data_sine              ), //output [47:0]  channel_A_data ,         
   .channel_B_en         (  wave_dat_req_1                 ),    //input          channel_B_en,
   .channel_B_addr       ( wave_addr_1                     ),  //input  [8:0]   channel_B_addr,
   .channel_B_data       (  wave_data_cosine               ),  //output [47:0]  channel_B_data 
   . buf_refresh   (buf_refresh),
   .retrigger(retrigger)
          );    



 data_cap_ture data_cap_ture_0(
      .alg_clk               (  alg_clk                 ),                                 //input          alg_clk,
      .alg_rst_n             (  alg_rst_n               ),                                 //input          alg_rst_n,
	  .ref_sync_pem_dat      (  ref_sync_pem_dat        ),                                 //input   [15:0] ref_sync_pem_dat,
      .ref_sync_pem_dat_valid(  ref_sync_pem_dat_valid  ),                                 //input          ref_sync_pem_dat_valid,
	  .pem_posedge           (  filtered_pem_posedge    ),//filtered                                 //input          pem_posedge,//filtered
	  .frequency_detected    (   frequency_valid        ),                                 //input          frequency_detected,
	  .refresh_align         (   retrigger_delay          ),                                 //input          refresh_align,
	  .ram_dat               (   ram_dat                ),                                 //output  [15:0] ram_dat,
	  .ram_addr              (   ram_addr               ),                                 //output  [8:0]  ram_addr,
	  .ram_wr_valid          (   ram_wr_valid           ),                                 //output         ram_wr_valid,
	  .trig_search_cdc       (   trig_search_cdc        )                           //output         trig_search_cdc,	 
  );



phase_calcu phase_calcu_0(
  .alg_clk                    (  alg_clk         ),                           //input          alg_clk  ,
  .alg_rst_n                  (  alg_rst_n       ),                           //input          alg_rst_n,                
  .rst_n                      ( alg_rst_n       ),                           //input          rst_n    ,
  .ref_sync_with_pem_dat      (  ref_sync_pem_dat           ),         //input  [15:0]  ref_sync_with_pem_dat      ,//1 bit sign 15 bit int
  .ref_sync_with_pem_dat_valid( ref_sync_pem_dat_valid   ),         //input          ref_sync_with_pem_dat_valid,
  .pem_posedge                (filtered_pem_posedge              ),                     //input          pem_posedge    ,
  .search_end                 ( select_valid   ),                     //input          search_end     ,
  .wave_dat_sine              ( wave_data_sine    ),                     //input   [47:0] wave_dat_sine  ,             //1 bit sign 1 bit int 46 bit
  .wave_dat_cosine            ( wave_data_cosine  ),                     //input   [47:0] wave_dat_cosine,
  .atan_coef                  ({1'b0,8'd127,23'd0}),                           //input   [31:0] atan_coef,
  .wave_dat_req               ( wave_dat_req_1     ),                     //output         wave_dat_req   ,
  .wave_addr                  (  wave_addr_1      ),                     //output   [8:0] wave_addr      ,  
  .phase_out                  (                 ),                     //output [31:0]  phase_out      ,
  .phase_out_valid            (                 ) ,                     //output         phase_out_valid  
  . buf_refresh               ( buf_refresh      ),
  . phase_out_shift           (phase_out_shift            ) ,
  .   phase_out_shift_valid   (  phase_out_shift_valid    )
  
  );








  

   always@(posedge alg_clk or negedge alg_rst_n)
     if(!alg_rst_n)
 	begin
 	sine_addr  <=9'd0;
 	cosine_addr<=9'd0;
 	end
     else if( sine_valid )
     begin
 	sine_addr  <=sine_addr  +1'b1;
 	cosine_addr<=cosine_addr+1'b1;
 	end
     else
     begin
 	sine_addr  <=9'd0;
 	cosine_addr<=9'd0;
 	end
 







  
  
  
 data_ram data_ram_0 (
     .clka  (  alg_clk      ),//: IN STD_LOGIC;
     .ena   (  ram_wr_valid ),//: IN STD_LOGIC;
     .wea   (      1        ),//: IN STD_LOGIC_VECTOR(0 DOWNTO 0);
     .addra (  ram_addr     ),//: IN STD_LOGIC_VECTOR(8 DOWNTO 0);
     .dina  (   ram_dat     ),//: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
     .clkb  (  alg_clk      ),//: IN STD_LOGIC;
     .enb   (    search_req    ),//: IN STD_LOGIC;
     .addrb (    search_addr         ),//: IN STD_LOGIC_VECTOR(8 DOWNTO 0);
     .doutb (   capture_raw_dat  ) //: OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
   );

delay_unit delay_unit_0(
  . alg_clk  (  alg_clk      ),
  . alg_rst_n(  alg_rst_n    ),
  . pulse_in ( fft_end      ),
  . pulse_out( fft_end_delay   )

);


delay_unit delay_unit_1(
  . alg_clk  (  alg_clk      ),
  . alg_rst_n(  alg_rst_n    ),
  . pulse_in ( retrigger      ),
  . pulse_out( retrigger_delay   )

);








endmodule