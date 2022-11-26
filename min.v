`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/10 17:01:06
// Design Name: 
// Module Name: min
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


module min(
input [12:0] a,
  input [12:0] b,
  input [12:0] c,
  output reg [12:0] min
);
 wire ab_cmp;
 wire bc_cmp;
 wire ac_cmp;
 assign ab_cmp=(a>=b);
 assign bc_cmp=(b>=c);
 assign ac_cmp=(a>=c);
 
 
 always@*
  case({ab_cmp,bc_cmp,ac_cmp})
  3'b000:
  min=a;
  
  3'b001:
  min=a;
 
  3'b010:
    min=a;
  3'b011:
	min=c;
  3'b100:
	min=b;	 
  3'b101:
	min=b;	   
	 3'b110: 
	  min=a;
	  3'b111: 
	 min=c; 
	  
	  default:;
	  endcase
	  
	  endmodule
