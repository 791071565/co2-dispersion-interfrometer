`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/06 16:10:44
// Design Name: 
// Module Name: average_calcu_float
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


module average_calcu_float#(
   parameter max_average_count = 10'd1001,
   parameter C_DATA_WIDTH = 54 //1bit sign 17 bit int 36 bit int
)
(
   input clk,
   input rst_n,

   input [C_DATA_WIDTH-1:0]    DATA_in      ,
   input                       DATA_sof     ,
   input                       DATA_eof     ,
   input                       DATA_in_valid,                 
   output                      DATA_in_ready,             
                                        
   //output[C_DATA_WIDTH+10-1+14:0] DATA_out ,    
   //output                      DATA_out_valid                          
   output[63:0]                data_out       , //double 
   output                      data_out_valid    
   
);
    wire [C_DATA_WIDTH+10-1:0]  expanded_DATA_in;//63
    //wire                        divide_valid;
   // wire                        reserve_1bit;
    reg  [C_DATA_WIDTH+10-1:0]  accum_reg;//
    reg                         accum_reg_valid;  
    reg   [9:0]                 accum_dat_count;//10bit
    reg                         accum_reg_valid_r1;
    reg                         accum_reg_valid_r2;
   reg                          calcu_sig;
   //  reg                         accum_reg_valid;
 
    reg                         DATA_in_ready_r;
    assign                      DATA_in_ready=DATA_in_ready_r;
 
  //  assign  expanded_DATA_in =(DATA_in[C_DATA_WIDTH-1])?{DATA_in[C_DATA_WIDTH-1],10'b1111111111,DATA_in[C_DATA_WIDTH-2:0]}:{DATA_in[C_DATA_WIDTH-1],10'b0000000000,DATA_in[C_DATA_WIDTH-2:0]} ;
     assign  expanded_DATA_in ={DATA_in[C_DATA_WIDTH-1],{(DATA_in[C_DATA_WIDTH-1])?{10{1'b1}}:{10{1'b0}}},DATA_in[C_DATA_WIDTH-2:0]};
    
    
    
    
    always@(posedge clk or negedge rst_n)
      if(rst_n == 1'b0)
    DATA_in_ready_r<=1;
    else if( data_out_valid  )
    DATA_in_ready_r<=1;
    else if( DATA_eof        )
    DATA_in_ready_r<=0;
    
     always@(posedge clk or negedge rst_n)
         if(rst_n == 1'b0)
    
    calcu_sig<=0;
    else if(data_out_valid  )
     calcu_sig<=0;
      else if( DATA_sof&&DATA_in_valid   )
       calcu_sig<=1;
    
     always@(posedge clk or negedge rst_n)
      if(rst_n == 1'b0)
    accum_dat_count<=0;
    
    else if(data_out_valid)
     accum_dat_count<=0;
    else if( DATA_sof&&DATA_in_valid  )
    accum_dat_count<=1;
    else if(DATA_in_valid )
    accum_dat_count<=accum_dat_count+1;
    
     always@(posedge clk or negedge rst_n)
      if(rst_n == 1'b0)
       accum_reg<=64'b0;
     else if(DATA_sof&&DATA_in_valid )
       accum_reg<=expanded_DATA_in;
     else if( DATA_in_valid &&calcu_sig )
       accum_reg<=expanded_DATA_in+accum_reg;
    
    always@(posedge clk)
     begin
      // accum_reg_valid_r1<=DATA_eof&&DATA_in_valid;
      accum_reg_valid_r1<=DATA_eof ;
       accum_reg_valid_r2<=accum_reg_valid_r1;
       accum_reg_valid   <=accum_reg_valid_r2;
    end
    
    wire [63:0]  float_accum_reg;//double
    wire         float_accum_reg_valid;
    
   uint9_2_floati uint9_2_floati_0(
   .aclk                 (    clk         ),//: IN STD_LOGIC;
   .s_axis_a_tvalid      ( accum_reg_valid    ),//: IN STD_LOGIC;
   .s_axis_a_tdata       (      {6'b0,accum_dat_count }),//: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
   .m_axis_result_tvalid ( float_accum_reg_valid  ),//: OUT STD_LOGIC;
   .m_axis_result_tdata  ( float_accum_reg    ) //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
  );
  
  wire [63:0]  float_expanded_DATA;//double
    wire         float_expanded_DATA_valid;
  
  
  
  //1bit sign 17 bit int 36 bit int ->1 bit sign 53 bit int
   int54_2_float   int54_2_float_0(
    .aclk                 (    clk           ),  //: IN STD_LOGIC;
    .s_axis_a_tvalid      ( accum_reg_valid  ),  //: IN STD_LOGIC;
    .s_axis_a_tdata       ( accum_reg ),  //: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    .m_axis_result_tvalid (  float_expanded_DATA_valid  ),  //: OUT STD_LOGIC;
    .m_axis_result_tdata  (  float_expanded_DATA  )   //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
  );

  fp_divider_double fp_divider_double_0(
    .aclk                 (      clk         ),//: IN STD_LOGIC;
    .s_axis_a_tvalid      ( float_expanded_DATA_valid  ),//: IN STD_LOGIC;
    .s_axis_a_tdata       (  float_expanded_DATA    ),//: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    .s_axis_b_tvalid      (  float_accum_reg_valid  ),//: IN STD_LOGIC;
    .s_axis_b_tdata       (    float_accum_reg     ),//: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    .m_axis_result_tvalid (  data_out_valid    ),//: OUT STD_LOGIC;
    .m_axis_result_tdata  (    data_out       ) //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
  );
  
  

    endmodule
