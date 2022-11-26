`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/27 17:48:08
// Design Name: 
// Module Name: frequency_detect
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


module frequency_detect#(
 	parameter  frequency_detect_count=20'd1000000
//parameter  frequency_detect_count=20'd1000  
)
(
	input           clk,
	input           rst_n,

	input           data_valid,
	input           PEM_posedge,
						 
	output [19:0]   frequency,
    output          frequency_valid ,
    
    output [18:0]   coef,
    output          coef_valid,
    
    
	output          frequency_detected_w,
	output          PEM_posedge_filtered,
	output          filter_sig
);
    reg [19:0]   data_valid_cnt;
	reg [19:0]   PEM_posedge_cnt;
	reg          start_detect;
	reg          frequency_valid_r;
	reg          frequency_detected;
(*mark_debug = "true"*) 	wire [39:0]  m_axis_dout;
	assign       coef=(filter_sig)? {1'b0,m_axis_dout[18:1]} :m_axis_dout[19:1];
	assign       frequency=PEM_posedge_cnt;
	assign       frequency_valid=frequency_detected&&(!frequency_valid_r);
	assign       frequency_detected_w=frequency_detected;
	always@(posedge   clk or negedge rst_n)
	 if(!rst_n)
	 data_valid_cnt<=0;
	 else if(data_valid&&(data_valid_cnt==frequency_detect_count-1'b1))
	 data_valid_cnt<=data_valid_cnt;
	 else if((data_valid&&start_detect)||(PEM_posedge&&(!start_detect)))
	 data_valid_cnt<=data_valid_cnt+1'b1;
	
	always@(posedge   clk or negedge rst_n)
	 if(!rst_n)
	 PEM_posedge_cnt<=0;
	 else if(frequency_detected)
	 PEM_posedge_cnt<=PEM_posedge_cnt;
	 else if((PEM_posedge&&(!start_detect)||(PEM_posedge&&start_detect) ))
	 PEM_posedge_cnt<=PEM_posedge_cnt+1'b1;
	
	always@(posedge   clk or negedge rst_n)
	 if(!rst_n)
	start_detect<=0;
	else if((PEM_posedge&&(!start_detect)))
	start_detect<=1;
	
	always@(posedge   clk or negedge rst_n)
	 if(!rst_n)
	 frequency_detected<=0;
	 else if(data_valid&&(data_valid_cnt==frequency_detect_count-1'b1))
	frequency_detected<=1;
	
	always@(posedge   clk)
	frequency_valid_r<=frequency_detected;
	
	reg  filter_sig;
	
	always@(posedge   clk or negedge rst_n)
     if(!rst_n)
	   filter_sig<=0;
 	 else if(frequency_valid&&(frequency>20'd75000))
//else if(frequency_valid&&(frequency>20'd75))
	   filter_sig<=1;
	reg   filter_cnt;
	always@(posedge   clk or negedge rst_n)
         if(!rst_n)
	filter_cnt<=0;
	else if(filter_sig&&PEM_posedge)
	filter_cnt<=~filter_cnt;
	
	assign  PEM_posedge_filtered=(filter_sig)?PEM_posedge&&(~filter_cnt):PEM_posedge;
	
	
	
	 coef_divider coef_divider_0(
      . aclk                  (      clk              ), //: IN STD_LOGIC;
      . s_axis_divisor_tvalid (     frequency_valid        ), //: IN STD_LOGIC;
      . s_axis_divisor_tdata  ( { 4'b0,frequency_detect_count }       ), //: IN STD_LOGIC_VECTOR(23 DOWNTO 0);
      . s_axis_dividend_tvalid(    frequency_valid      ), //: IN STD_LOGIC;
      . s_axis_dividend_tdata ( {6'b0 ,PEM_posedge_cnt[16:0]} ), //: IN STD_LOGIC_VECTOR(23 DOWNTO 0);
      . m_axis_dout_tvalid    (  coef_valid     ), //: OUT STD_LOGIC;
      . m_axis_dout_tdata     (    m_axis_dout     )  //: OUT STD_LOGIC_VECTOR(39 DOWNTO 0)
     );
	
	
	
	
	
	
	
	
	
	
	
	
	
	endmodule
