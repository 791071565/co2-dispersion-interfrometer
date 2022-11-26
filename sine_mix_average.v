`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/03 19:59:10
// Design Name: 
// Module Name: sine_mix_average
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


module sine_mix_average#(
   parameter max_average_count = 10'd1001,
   parameter C_DATA_WIDTH = 48
)
(
   input clk,
   input rst_n,

   input [C_DATA_WIDTH-1:0]    DATA_in      ,
   input                       DATA_sof     ,
   input                       DATA_eof     ,
   input                       DATA_in_valid,                 
   output                      DATA_in_ready,             
                                           
   output[C_DATA_WIDTH+10-1+15:0] DATA_out ,    
   output                      DATA_out_valid                          

);
    wire [C_DATA_WIDTH+10-1:0]  expanded_DATA_in;
    wire                        divide_valid;
    wire                        reserve_1bit;
    reg  [C_DATA_WIDTH+10-1:0]  accum_reg;
    reg                         accum_reg_valid;  
    reg   [9:0]                 accum_dat_count;
    reg                         accum_reg_valid_r1;
    reg                         accum_reg_valid_r2;
   
   //  reg                         accum_reg_valid;
    wire   [6:0]                reserve ;
    reg                         DATA_in_ready_r;
    assign                      DATA_in_ready=DATA_in_ready_r;
    wire  [C_DATA_WIDTH+10-1:0] quotient  ;
    wire      [15:0]            fractional; 
    
       wire [C_DATA_WIDTH+10+15-1:0] int_expand;
       wire [C_DATA_WIDTH+10+15-1:0] fraction_expand;
       assign  int_expand={quotient,15'h0000};
       assign  fraction_expand={fractional[14],((fractional[14])?{58{1'b1}}:{58{1'b0}}) ,fractional[14:0]};
     //  wire [57:0]  data_out;
      // assign  data_out=
    
    assign  DATA_out=int_expand+fraction_expand;
    assign  DATA_out_valid=divide_valid;
    assign  expanded_DATA_in =(DATA_in[C_DATA_WIDTH-1])?{DATA_in[C_DATA_WIDTH-1],10'b1111111111,DATA_in[C_DATA_WIDTH-2:0]}:{DATA_in[C_DATA_WIDTH-1],10'b0000000000,DATA_in[C_DATA_WIDTH-2:0]} ;
    
    
    always@(posedge clk or negedge rst_n)
      if(rst_n == 1'b0)
    DATA_in_ready_r<=1;
    else if( DATA_out_valid  )
    DATA_in_ready_r<=1;
    else if( DATA_eof        )
    DATA_in_ready_r<=0;
    
     always@(posedge clk or negedge rst_n)
      if(rst_n == 1'b0)
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
     else if( DATA_in_valid  )
       accum_reg<=expanded_DATA_in+accum_reg;
    
    always@(posedge clk)
     begin
       accum_reg_valid_r1<=DATA_eof&&DATA_in_valid;
       accum_reg_valid_r2<=accum_reg_valid_r1;
       accum_reg_valid   <=accum_reg_valid_r2;
    end
    wire [63:0]  dividend_dat_in;
    assign  dividend_dat_in= (!accum_reg[C_DATA_WIDTH+10-1])?{accum_reg[C_DATA_WIDTH+10-1],8'b0,accum_reg[C_DATA_WIDTH+10-2:0]}:{accum_reg[C_DATA_WIDTH+10-1],8'b11111111,accum_reg[C_DATA_WIDTH+10-2:0]};
    
    
    
    div_100 div_100_0(
   .aclk                  (   clk                         ),  //: IN STD_LOGIC;
   .s_axis_divisor_tvalid (  accum_reg_valid              ),  //: IN STD_LOGIC;
   .s_axis_divisor_tdata  ({6'b0,accum_dat_count}         ),  //: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
   .s_axis_dividend_tvalid(  accum_reg_valid              ),  //: IN STD_LOGIC;
   .s_axis_dividend_tdata ( dividend_dat_in           ),  //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
   .m_axis_dout_tvalid    ( divide_valid                  ),  //: OUT STD_LOGIC;
   .m_axis_dout_tdata     ( {reserve,quotient,fractional}    )   //: OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
 );
    

    endmodule

