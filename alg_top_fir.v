`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/15 01:50:14
// Design Name: 
// Module Name: alg_top_fir
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


module alg_top_fir(
 input alg_clk,
   input alg_rst_n,


   input dat_clk,
   //input dat_rst_n,

 //    input  init_phase_found,
   
  input  [15:0]  ref_dat,
  input          ref_dat_valid,

  input  [15:0]  pem_dat,
  input          pem_dat_valid,
  input  [15:0]  pem_dat_average,
  (*mark_debug = "true"*) output         pem_posedge,
  output         valid_pem_posedge,   
//   input  [47:0]  wave_dat_sine,
//   input  [47:0]  wave_dat_cosine,
//  output         wave_dat_req,
//  output  [8:0]  wave_addr,
//  output [31:0]  phase_out,
//  output    phase_out_valid,
 
 (*mark_debug = "true"*)  output  [15:0] ref_sync_pem_dat,
 (*mark_debug = "true"*)  output         ref_sync_pem_dat_valid 

//  output  [127:0]    phase_to_pcie       ,
//  output     phase_to_pcie_valid 


);
 //cdc

  (*mark_debug = "true"*) wire  [15:0]  ref_dat_cdc        ;
  (*mark_debug = "true"*) wire          ref_dat_valid_cdc  ;
  (*mark_debug = "true"*) wire  [15:0]  pem_dat_cdc        ;
  (*mark_debug = "true"*) wire          pem_dat_valid_cdc  ;
 
 wire  [15:0]  pem_dat_average_inv;
 assign        pem_dat_average_inv={~pem_dat_average[15],~pem_dat_average[14:0]+1};
 assign        valid_pem_posedge  =  pem_posedge&&(!ref_sync_pem_dat[15]);
 
ADC_data_cross_clock_domian ADC_data_cross_clock_domian_0(
  .adc_clk                  ( dat_clk        ),
  .ADC_data_in_A_channel    ( ref_dat        ),
  .ADC_data_in_A_channel_en ( ref_dat_valid  ),
  .ADC_data_in_B_channel    ( pem_dat        ),
  .ADC_data_in_B_channel_en ( pem_dat_valid  ),   
  .alg_clk                  ( alg_clk     ),
  .alg_rst_n                ( alg_rst_n   ),
  .data_in_A_channel        ( ref_dat_cdc        ),
  .data_in_A_channel_en     ( ref_dat_valid_cdc  ),
  .data_in_B_channel        ( pem_dat_cdc        ),
  .data_in_B_channel_en     ( pem_dat_valid_cdc  )   );


   reg [15:0] pem_dat_cdc_after_bias;
   reg        pem_dat_cdc_after_bias_valid;
   reg [15:0] ref_dat_cdc_r;
   reg        ref_dat_valid_cdc_r;
   reg [15:0] ref_dat_cdc_rr;
   reg        ref_dat_valid_cdc_rr;
   reg [15:0] ref_dat_cdc_rrr;
   reg        ref_dat_valid_cdc_rrr;
  reg [15:0] ref_dat_cdc_rrrr;
   reg        ref_dat_valid_cdc_rrrr;
   reg        ref_dat_valid_cdc_rrrrr;
  
  
 always@(posedge alg_clk or negedge alg_rst_n)
   if(!alg_rst_n)
    begin
    pem_dat_cdc_after_bias      <=16'b0;
    pem_dat_cdc_after_bias_valid<=1'b0;
    ref_dat_cdc_r               <=16'b0;
    ref_dat_valid_cdc_r         <=1'b0;
    ref_dat_cdc_rr               <=16'b0;   
    ref_dat_valid_cdc_rr         <=1'b0;  
   ref_dat_cdc_rrr               <=16'b0;   
    ref_dat_valid_cdc_rrr         <=1'b0; 
     ref_dat_cdc_rrrr               <=16'b0;   
    ref_dat_valid_cdc_rrrr         <=1'b0; 
    ref_dat_valid_cdc_rrrrr<=1'b0;
    end
  else 
    begin
    pem_dat_cdc_after_bias      <=pem_dat_cdc+pem_dat_average_inv;
    pem_dat_cdc_after_bias_valid<=pem_dat_valid_cdc;
    ref_dat_cdc_r               <=ref_dat_cdc;
    ref_dat_valid_cdc_r         <=ref_dat_valid_cdc;
    ref_dat_cdc_rr               <=ref_dat_cdc_r;   
    ref_dat_valid_cdc_rr         <=ref_dat_valid_cdc_r;    
    ref_dat_cdc_rrr               <=ref_dat_cdc_rr;   
    ref_dat_valid_cdc_rrr         <=ref_dat_valid_cdc_rr; 
     ref_dat_cdc_rrrr               <=ref_dat_cdc_rrr;   
    ref_dat_valid_cdc_rrrr         <=ref_dat_valid_cdc_rrr; 
    ref_dat_valid_cdc_rrrrr       <=ref_dat_valid_cdc_rrrr&&first_point_sig;
    end


   reg   [15:0] ref_sync_with_pem  ; 
   reg   [15:0] ref_sync_with_pem_r; 
    reg   [15:0] ref_sync_with_pem_rr; 
     reg   [15:0] ref_sync_with_pem_rrr; 
     reg   [15:0] ref_sync_with_pem_rrrr;  
    
   reg   [15:0]  ref_sync_with_pem_r_d1; 
   reg           ref_sync_with_pem_r_d1_valid;
   reg   [15:0]  ref_sync_with_pem_r_d2; 
   reg           ref_sync_with_pem_r_d2_valid;
   always@(posedge alg_clk)
   begin
   ref_sync_with_pem_r_d1<=ref_sync_with_pem_rrrr; 
   ref_sync_with_pem_r_d2<=ref_sync_with_pem_r_d1; 
   ref_sync_with_pem_r_d1_valid<=ref_dat_valid_cdc_rr;
   ref_sync_with_pem_r_d2_valid<=ref_sync_with_pem_r_d1_valid;
   
   end
assign   ref_sync_pem_dat=ref_sync_with_pem_r;
assign   ref_sync_pem_dat_valid=pem_filtered_valid ;
always@(posedge alg_clk or negedge alg_rst_n)
   if(!alg_rst_n)
    begin
    ref_sync_with_pem  <=16'b0;
    ref_sync_with_pem_r <=16'b0;
    ref_sync_with_pem_rr<=16'b0;
     ref_sync_with_pem_rrr <=16'b0;  
     ref_sync_with_pem_rrrr<=16'b0; 
    
    end
  else 
    begin
    ref_sync_with_pem  <= (ref_dat_valid_cdc_r)?ref_dat_cdc_r:ref_sync_with_pem;   
    ref_sync_with_pem_r <=(ref_dat_valid_cdc_r)?ref_sync_with_pem:ref_sync_with_pem_r;
    ref_sync_with_pem_rr <=(ref_dat_valid_cdc_r)?ref_sync_with_pem_r:ref_sync_with_pem_rr;
     ref_sync_with_pem_rrr <=(ref_dat_valid_cdc_r)?ref_sync_with_pem_rr :ref_sync_with_pem_rrr ;  
     ref_sync_with_pem_rrrr<=(ref_dat_valid_cdc_r)?ref_sync_with_pem_rrr :ref_sync_with_pem_rrrr ; 
    
    end 













    reg [15:0] pem_dat_cdc_after_bias_r;
    //reg        pem_dat_cdc_after_bias_valid_r;
    reg [15:0] pem_dat_cdc_after_bias_rr;
   // reg        pem_dat_cdc_after_bias_valid_rr;
    reg [15:0] pem_dat_cdc_after_bias_rrr;
   
    
   always@(posedge alg_clk or negedge alg_rst_n)
   if(!alg_rst_n)
    begin
    pem_dat_cdc_after_bias_r <=16'b0;
    
    pem_dat_cdc_after_bias_rr <=16'b0;
    
   
   
    end
  else 
    begin
    pem_dat_cdc_after_bias_r <=(pem_dat_cdc_after_bias_valid)?pem_dat_cdc_after_bias:pem_dat_cdc_after_bias_r;
     
    pem_dat_cdc_after_bias_rr <=(pem_dat_cdc_after_bias_valid)?pem_dat_cdc_after_bias_r:pem_dat_cdc_after_bias_rr;
     
   
    pem_dat_cdc_after_bias_rrr<=(pem_dat_cdc_after_bias_valid)?pem_dat_cdc_after_bias_rr:pem_dat_cdc_after_bias_rrr;
    
    
    
    end 
    
   (*mark_debug = "true"*)  wire [15:0]  pem_filtered;
   (*mark_debug = "true"*)  reg          pem_filtered_valid;
    reg   [1:0]  pem_dat_cnt;
    reg          first_point_sig;
    wire  [15:0] pem_dat_cdc_after_bias_inv_div4;
    assign pem_dat_cdc_after_bias_inv_div4={pem_dat_cdc_after_bias_r[15],(pem_dat_cdc_after_bias_r[14:0]>>2)|15'h6000};
    wire  [15:0] pem_dat_cdc_after_bias_r_inv_div2;
    assign pem_dat_cdc_after_bias_r_inv_div2={pem_dat_cdc_after_bias_rr[15],(pem_dat_cdc_after_bias_rr[14:0]>>1)|15'h4000 }; 
    wire  [15:0] pem_dat_cdc_after_bias_rr_inv_div4;
    assign pem_dat_cdc_after_bias_rr_inv_div4={pem_dat_cdc_after_bias_rrr[15],(pem_dat_cdc_after_bias_rrr[14:0]>>2)|15'h6000 };
    
    
//    assign pem_filtered={pem_dat_cdc_after_bias[15],pem_dat_cdc_after_bias[14:0]>>2}+{pem_dat_cdc_after_bias_r[15],pem_dat_cdc_after_bias_r[14:0]>>1}
//    +{pem_dat_cdc_after_bias_rr[15],pem_dat_cdc_after_bias_rr[14:0]>>2};
    assign pem_filtered=(pem_dat_cdc_after_bias_r[15]?pem_dat_cdc_after_bias_inv_div4:(pem_dat_cdc_after_bias_r>>2))+(pem_dat_cdc_after_bias_rr[15]?pem_dat_cdc_after_bias_r_inv_div2:(pem_dat_cdc_after_bias_rr>>1))
    
    +(pem_dat_cdc_after_bias_rrr[15]?pem_dat_cdc_after_bias_rr_inv_div4:(pem_dat_cdc_after_bias_rrr>>2));
    
    always@(posedge alg_clk or negedge alg_rst_n)
     if(!alg_rst_n)
    pem_dat_cnt<=2'b0;
    else if(ref_dat_valid_cdc_r&&(pem_dat_cnt==2'd2))
     pem_dat_cnt<=2'b0;
    else if(ref_dat_valid_cdc_r)
     pem_dat_cnt<=pem_dat_cnt+1'b1;
    
    always@(posedge alg_clk or negedge alg_rst_n)
     if(!alg_rst_n)
     pem_filtered_valid<=1'b0;
    else if(ref_dat_valid_cdc_r&&first_point_sig)
     pem_filtered_valid<=1'b1;
    else
     pem_filtered_valid<=1'b0;
     
    always@(posedge alg_clk or negedge alg_rst_n)
     if(!alg_rst_n)
     first_point_sig<=1'b0;
    else if(ref_dat_valid_cdc_r&&(pem_dat_cnt==2'd0))
     first_point_sig<=1'b1;
   //rr
   reg [15:0]   pem_filtered_tmp;

   //assign pem_posedge=pem_filtered_tmp[15]&&pem_filtered_valid&&(~pem_filtered[15]);
   assign pem_posedge=(~pem_filtered_tmp[15])&&pem_filtered_valid&&(pem_filtered[15]);
//   reg    dat_valid_sig;
//   //rrr
//   always@(posedge alg_clk or negedge alg_rst_n)
//     if(!alg_rst_n)
//   dat_valid_sig<=1'b0;
////   else if(pem_posedge&&init_phase_found)
// else if(pem_posedge&&init_phase_found)
//   dat_valid_sig<=1'b1;
   
   always@(posedge alg_clk or negedge alg_rst_n)
     if(!alg_rst_n)
   pem_filtered_tmp<=16'b0;
   else if(pem_filtered_valid )
    pem_filtered_tmp<= pem_filtered;
      //ref_dat_cdc_rr
//  wire  ref_alg_data_vld;
////  assign  ref_alg_data_vld=(dat_valid_sig&&ref_sync_pem_dat_valid)||(pem_posedge&&init_phase_found);

//assign  ref_alg_data_vld=(dat_valid_sig&&ref_sync_pem_dat_valid) ;
//input   1bit sign 15 bit fraction 

 //48 46  1bit sign 1 bit int 46 bit fraction

// reg          wave_dat_req_r;
//reg          wave_dat_req_rr;
// reg   [8:0]  wave_addr_r  ;
//reg   [7:0]  pem_cnt;
//reg          data_lock;
//always@(posedge alg_clk or negedge alg_rst_n)
//if(!alg_rst_n)
//pem_cnt<=0;
//else if(pem_posedge&&(pem_cnt==8'd10))
//pem_cnt<=1;

//else if(pem_posedge&&ref_alg_data_vld)
//pem_cnt<=pem_cnt+1;

//always@(posedge alg_clk or negedge alg_rst_n)
//if(!alg_rst_n)
//begin
// wave_dat_req_r<=0;
// wave_addr_r   <=0;
// wave_dat_req_rr<=0;
// data_lock    <=0;
//end
//else if(ref_alg_data_vld&&pem_posedge&&(pem_cnt==8'd0)&&(!data_lock))
//begin
// wave_dat_req_r<=1;
// wave_addr_r   <=0;
//  data_lock    <=1;
//end
//else if(ref_alg_data_vld&&(data_lock)&&(pem_cnt==8'd10)&&pem_posedge)
//begin
// wave_dat_req_r<=1;
// wave_addr_r   <=0;
//end


//else if(ref_alg_data_vld&&(data_lock))
//begin
// wave_dat_req_r<=1;
// wave_addr_r   <=wave_addr_r+1'b1;
//end
//else  
//begin
//  wave_dat_req_r<=0;
// wave_addr_r   <=wave_addr_r;
// wave_dat_req_rr<=wave_dat_req_r;
  

//end




//MIX  1bit sign  17 bit int 46 bit fraction
//  reg [63:0]  raw_mix_sine;
//  reg         raw_mix_valid;
//  reg [63:0]  raw_mix_cosine;
//always@(posedge alg_clk or negedge alg_rst_n)
//if(!alg_rst_n)
//begin
//raw_mix_sine  <=0;
//raw_mix_valid <=0;
//raw_mix_cosine<=0;
//end
//else if(wave_dat_req_rr&&init_phase_found)
//begin
////raw_mix_sine  <=$signed(ref_dat_cdc_rrrr)*$signed(wave_dat_sine);
//raw_mix_sine  <=$signed(ref_sync_with_pem_r)*$signed(wave_dat_sine);
//raw_mix_valid <=1;
////raw_mix_cosine<=$signed(ref_dat_cdc_rrrr)*$signed(wave_dat_cosine);
//raw_mix_cosine  <=$signed(ref_sync_with_pem_r)*$signed(wave_dat_cosine);
//end
//else
//raw_mix_valid <=0;

//wire [46:0] raw_mix_sine_fir;
//wire [46:0] raw_mix_cosine_fir;

//assign raw_mix_sine_fir  =raw_mix_sine[63:17];
//assign raw_mix_cosine_fir=raw_mix_cosine[63:17];

//wire [70:0] mix_sine_after_fir; //71:29 1bit sign  41bit integer  29bit fraction
//wire        mix_sine_after_fir_valid;
//wire [70:0] mix_cosine_after_fir; 
//wire        mix_cosine_after_fir_valid;
//wire        rese_zero_0;
//wire        rese_zero_1;



//fir_compiler_0 fir_compiler_0_0 (
//   .aclk               (alg_clk    ), 
//   .aresetn            (alg_rst_n),
//   .s_axis_data_tvalid ( raw_mix_valid    ), 
//   .s_axis_data_tready (           ), 
//   .s_axis_data_tdata  ({raw_mix_sine_fir[46],raw_mix_sine_fir }   ), 
//   .m_axis_data_tvalid ( mix_sine_after_fir_valid  ), 
//   .m_axis_data_tdata  ( {rese_zero_0,mix_sine_after_fir}  )  
// );

//fir_compiler_0 fir_compiler_0_1 (
//   .aclk               ( alg_clk                    ), 
//     .aresetn            (alg_rst_n),
//   .s_axis_data_tvalid ( raw_mix_valid             ), 
//   .s_axis_data_tready (                            ), 
//   .s_axis_data_tdata  ( {raw_mix_cosine_fir[46],raw_mix_cosine_fir }), 
//   .m_axis_data_tvalid ( mix_cosine_after_fir_valid ), 
//   .m_axis_data_tdata  (  {rese_zero_1,mix_cosine_after_fir}       )  
// );





//(*mark_debug = "true"*) wire [31:0] phase_before_rpjp_pre;
//(*mark_debug = "true"*) wire        phase_before_rpjp_pre_valid;


//atan atan_0(
//  . aclk                   (   alg_clk                                 ), // : IN STD_LOGIC;
//  . s_axis_cartesian_tvalid(   mix_sine_after_fir_valid                      ), // : IN STD_LOGIC;
//  . s_axis_cartesian_tdata (  {  mix_sine_after_fir[70:23],mix_cosine_after_fir[70:23] } ), // : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
//  . m_axis_dout_tvalid     (    phase_before_rpjp_pre_valid            ), // : OUT STD_LOGIC;
//  . m_axis_dout_tdata      (  phase_before_rpjp_pre                    ) // : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
// );













//(*mark_debug = "true"*)  reg [31:0]  phase_before_rpjp;
//(*mark_debug = "true"*)  reg         phase_before_rpjp_valid;
// reg  [31:0] phase_cnt;
// reg         valid_phase;
// assign       wave_dat_req =wave_dat_req_r;
// assign       wave_addr     =wave_addr_r   ;


//always@(posedge  alg_clk or negedge alg_rst_n)
//if(!alg_rst_n)
//begin
//phase_cnt<=32'b0;
//valid_phase<=1'b0;
//end
//else if(phase_before_rpjp_pre_valid&&(phase_cnt==32'd666 ))
//begin
//phase_cnt<=phase_cnt;
//valid_phase<=1'b1;
//end
//else if(phase_before_rpjp_pre_valid  )
//phase_cnt<=phase_cnt+1'b1;






//always@(posedge  alg_clk or negedge alg_rst_n)
//if(!alg_rst_n)
//phase_before_rpjp_valid<=1'b0;
//else
//phase_before_rpjp_valid<=phase_before_rpjp_pre_valid&&valid_phase;

//always@(posedge  alg_clk or negedge alg_rst_n)
//if(!alg_rst_n)
//phase_before_rpjp<=1'b0;
//else if(phase_before_rpjp_pre_valid)
//phase_before_rpjp<=phase_before_rpjp_pre;

 















//RPJP_processing_unit_v2 RPJP_processing_unit_v2_0(
//       .clk          (     alg_clk                   ),                                   //input           wire              clk,
//       .rst_n        (     alg_rst_n                    ),                           //input        wire           rst_n,
//       .PHASE_IN     (phase_before_rpjp       ),                        //input        wire[31:0]     PHASE_IN,
//       .PHASE_IN_en  (phase_before_rpjp_valid  ),                     //input        wire           PHASE_IN_en,
//       .PHASE_out    (   phase_out                   ),//floating_point       //output       wire[31:0]     PHASE_out,//floating_point
//       .PHASE_out_EN (   phase_out_valid             )                      //output       wire           PHASE_out_EN
//);
//(*mark_debug = "true"*) wire [31:0]  phase_out_fp      ;
//(*mark_debug = "true"*) wire         phase_out_valid_fp;



//fix_32_29_to_fp32 fix_32_29_to_fp32_1(
//   .aclk                 (    alg_clk        ),
//   .s_axis_a_tvalid      ( phase_out_valid    ),
//   .s_axis_a_tdata       ( phase_out       ),
//   .m_axis_result_tvalid (    phase_out_valid_fp    ), 
//   .m_axis_result_tdata  (  phase_out_fp            )  
//  );

// shift_reg#(
//  .shift_ele_width(32 ),
//  .shift_stage    (4  )
//)
//shift_reg_0(
//  .clk         (    alg_clk              ),
//  .rst_n       (      alg_rst_n                ),
//  .data_in     (  phase_out_fp    ),
//  .data_in_vld (  phase_out_valid_fp       ),
//  .data_out    (  phase_to_pcie         ), 
//  .data_out_vld(  phase_to_pcie_valid   )
//);



endmodule
