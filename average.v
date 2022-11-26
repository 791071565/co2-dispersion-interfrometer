`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/16 09:55:47
// Design Name: 
// Module Name: average
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


module average(
 input         clk,
    input         rst_n,
    input  [15:0] din,
    input         din_valid,
    output [15:0] dout 
);
  reg [15:0]   shift_reg [0:255];
  always@(posedge  clk or negedge  rst_n)
   if(!rst_n)
  shift_reg[0]<=16'b0;
  else if(din_valid)
  shift_reg[0]<=din;
  
 integer i;
  
   always@(posedge clk or negedge  rst_n)
   begin
   if(!rst_n)
    for(i=1;i<256;i=i+1)
    begin
   shift_reg[i]<=0;
   end
   else if(din_valid)
   for(i=1;i<256;i=i+1)
    begin
   shift_reg[i]<=shift_reg[i-1];
   end
   end
   wire   [16:0]   add_temp_1 [0:127];
   wire   [17:0]   add_temp_2 [0:63];
   wire   [18:0]   add_temp_3 [0:31];
   wire   [19:0]   add_temp_4 [0:15];
   wire   [20:0]   add_temp_5 [0:7];
   wire   [21:0]   add_temp_6 [0:3];
   wire   [22:0]   add_temp_7 [0:1];
   wire   [23:0]   add_temp_8 ;
   genvar j;
   genvar k;
   genvar l;
   genvar m;
   genvar n;
   genvar o;
   genvar p;
   
   generate for(j=0;j<128;j=j+1)
   begin
  assign add_temp_1[j]=$signed(shift_reg[2*j])+$signed(shift_reg[2*j+1]);
   end
   endgenerate
   
   
   
   generate for(k=0;k<64;k=k+1)
   begin
  assign add_temp_2[k]=$signed(add_temp_1[2*k])+$signed(add_temp_1[2*k+1]);
   end
   endgenerate
   
   generate for(l=0;l<32;l=l+1)
   begin
assign   add_temp_3[l]=$signed(add_temp_2[2*l])+$signed(add_temp_2[2*l+1]);
   end
   endgenerate
   
   generate for(m=0;m<16;m=m+1)
   begin
 assign  add_temp_4[m]=$signed(add_temp_3[2*m])+$signed(add_temp_3[2*m+1]);
   end
   endgenerate
   
   generate for(n=0;n<8;n=n+1)
   begin
  assign add_temp_5[n]=$signed(add_temp_4[2*n])+$signed(add_temp_4[2*n+1]);
   end
   endgenerate
   generate for(o=0;o<4;o=o+1)
   begin
 assign  add_temp_6[o]=$signed(add_temp_5[2*o])+$signed(add_temp_5[2*o+1]);
   end
   endgenerate
   generate for(p=0;p<2;p=p+1)
   begin
  assign add_temp_7[p]=$signed(add_temp_6[2*p])+$signed(add_temp_6[2*p+1]);
   end
   endgenerate
   
   assign add_temp_8=$signed(add_temp_7[0])+$signed(add_temp_7[1]);
   
   
   
   assign dout=add_temp_8[23:8];
   
   
   
   
   endmodule
   
