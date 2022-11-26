`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/25 10:31:38
// Design Name: 
// Module Name: data_sample_rate
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


module data_sample_rate(
 input   clk,
 //input   dac_clk,
 input   rst_n,
 input   [15:0] DinA_r,                          
 input   [15:0] DinB_r,                           
 input     DinA_vld,                               
 input     DinB_vld,        
 
 output reg [15:0]  DinA_selected,
 output reg [15:0]  DinB_selected,
 output reg         DinA_vld_selected,
 output reg         DinB_vld_selected 
  
 
 );
 (*mark_debug = "true"*) reg [7:0] select_cnt;
 
  
 always@(posedge clk or negedge rst_n)
  if(!rst_n)
 select_cnt<=0;
 else if(DinA_vld&&(select_cnt==8'd19))
 select_cnt<=0;
 
 else if( DinA_vld )
 select_cnt<=select_cnt+1'b1;
 
  
 
 
 
 
 
 always@(posedge clk or negedge rst_n)
  if(!rst_n)
  begin
  DinA_selected     <=0;
  DinB_selected     <=0;
  DinA_vld_selected <=0;
  DinB_vld_selected <=0;
  
  end
  
  else if(DinA_vld&&(select_cnt==8'd2) )
  
  begin
  DinA_selected     <=DinA_r;
  DinB_selected     <=DinB_r;
  DinA_vld_selected <=1;
  DinB_vld_selected <=1;
  
  end
  
  else
  begin
  DinA_vld_selected <=0;
  DinB_vld_selected <=0;
  
  end
  
  endmodule
 
