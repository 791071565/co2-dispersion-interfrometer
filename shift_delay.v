`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/07 17:58:38
// Design Name: 
// Module Name: shift_delay
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


module shift_delay#(
     parameter   delay_pace=8,
     parameter   D_WIDTH=32
)
(
   input                  clk,
   input                  rst_n,                
   input   [D_WIDTH-1:0]  data_in,
   input                  data_in_valid,

   output  [D_WIDTH-1:0]  data_out,
   output                 data_out_valid

   );
   reg  [delay_pace*D_WIDTH-1:0] data_shift_reg,data_shift_reg_next;
   reg  [delay_pace-1:0]         valid_shift_reg,valid_shift_reg_next;
   
   
   assign  data_out_valid=valid_shift_reg[delay_pace-1];
   assign  data_out      =data_shift_reg[delay_pace*D_WIDTH-1:(delay_pace-1)*D_WIDTH];
   
   
   always@*
   begin
   data_shift_reg_next=(data_shift_reg<<D_WIDTH)|data_in;
   valid_shift_reg_next=(valid_shift_reg<<1)|data_in_valid;
   end
   
   
   always@(posedge  clk )
   begin
     data_shift_reg<=(!rst_n)?{delay_pace*D_WIDTH{1'b0}}:data_shift_reg_next;
     valid_shift_reg<=(!rst_n)?{delay_pace{1'b0}}:valid_shift_reg_next;
   end
   
   
   endmodule
