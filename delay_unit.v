`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/16 13:07:47
// Design Name: 
// Module Name: delay_unit
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


module delay_unit(
 input           alg_clk,
    input           alg_rst_n,

   input             pulse_in,
   output             pulse_out

);
  reg  [20:0] shift_reg;
  
  assign pulse_out=shift_reg[20];
  always@(posedge alg_clk or negedge alg_rst_n)
    if(!alg_rst_n)
    shift_reg<=0;
    else
    shift_reg<=(shift_reg<<1)|{20'b0,pulse_in};
    
    
    endmodule