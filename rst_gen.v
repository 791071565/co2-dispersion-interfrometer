`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/01 13:22:59
// Design Name: 
// Module Name: rst_gen
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


module rst_gen(
    input   clk,
 input   rst_n,
 input   rst_trig,
 output  rst_n_out,
 
 output reg pcie_fifo_rst_trig
);

 parameter  reset_time=32'd10000;
  reg [31:0] cnt=32'd0;
  reg   cnt_en=1'b0;
  reg   reg_rst_n_out=1'b1;
//    reg   pcie_fifo_rst_trig;
assign  rst_n_out=reg_rst_n_out;
always@(posedge clk or negedge rst_n)
 if(!rst_n)
 begin
 cnt<=32'd0;
 end
else if(cnt_en&&(cnt==reset_time-1))
 cnt<=32'd0;
else if(cnt_en)
 cnt<=cnt+1'b1;
 
 always@(posedge clk or negedge rst_n)
 if(!rst_n)
 begin
 cnt_en<=1'd0;
 end
else if(cnt_en&&(cnt==reset_time-1))
 cnt_en<=1'd0;
else if(rst_trig)
 cnt_en<=1'd1;
 
  always@(posedge clk or negedge rst_n)
 if(!rst_n)
 reg_rst_n_out<=1'b1;
 else if(cnt==32'd5000)
 reg_rst_n_out<=1'b0;
 else if(cnt==32'd5100)
 reg_rst_n_out<=1'b1;
 
  always@(posedge clk or negedge rst_n)
   if(!rst_n)
   pcie_fifo_rst_trig<=1'b0;
   
   else if(cnt==32'd8000)
   pcie_fifo_rst_trig<=1'b1;
   else
   pcie_fifo_rst_trig<=1'b0;
 
 
 
 endmodule