`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/27 15:18:03
// Design Name: 
// Module Name: average_filp
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


module average_filp#(
	parameter average_count = 10'd1001,
	parameter C_DATA_WIDTH = 16
)
(
	input clk,
	input rst_n,

	input [C_DATA_WIDTH-1:0] DATA_in      ,	 
	input                    DATA_in_valid,				 
					 
                                         
	output[C_DATA_WIDTH+10-1:0] DATA_out ,						 
	output                   DATA_out_valid						 
					 
);
     wire [C_DATA_WIDTH+10-1:0] expanded_DATA_in;
	 reg [C_DATA_WIDTH+10-1:0]  expanded_DATA_in_r;
     reg  [C_DATA_WIDTH+10-1:0]  accum_reg;
	 reg                        accum_reg_valid;
     reg    [9:0]               data_in_count;     
	 reg                        fifo_rd;
	 reg                        start_de;
	 reg                        DATA_in_valid_r;
	 reg                        DATA_in_valid_rr;
	 reg                        DATA_in_valid_rrr;
	 wire [C_DATA_WIDTH-1:0]    fifo_dout;  
	 wire [C_DATA_WIDTH+10-1:0] fifo_dout_expand;
	 wire   [9:0]               rd_data_count;
	 wire   [25:0]              quotient;
	 wire   [15:0]              fractional;
	 wire   [5:0]               reserve;
	 wire                       divide_valid;
	 assign   DATA_out_valid=divide_valid;
	 assign   DATA_out=quotient[25:0];
	 
	 
	 assign  expanded_DATA_in =(DATA_in[C_DATA_WIDTH-1])?{DATA_in[C_DATA_WIDTH-1],10'b1111111111,DATA_in[C_DATA_WIDTH-2:0]}:{DATA_in[C_DATA_WIDTH-1],10'b0000000000,DATA_in[C_DATA_WIDTH-2:0]} ;
	 assign  fifo_dout_expand =(fifo_dout[C_DATA_WIDTH-1])?{fifo_dout[C_DATA_WIDTH-1],10'b1111111111,fifo_dout[C_DATA_WIDTH-2:0]}:{fifo_dout[C_DATA_WIDTH-1],10'b0000000000,fifo_dout[C_DATA_WIDTH-2:0]} ;
	 wire   [C_DATA_WIDTH+10-1:0]  fifo_dout_expand_inv;
	 assign fifo_dout_expand_inv={~fifo_dout_expand[C_DATA_WIDTH+10-1],~fifo_dout_expand[C_DATA_WIDTH+10-2:0]+1'b1};
	  always@(posedge clk or negedge rst_n)
	   if(rst_n == 1'b0)
	 expanded_DATA_in_r<=0;
	 else if( DATA_in_valid )
	 expanded_DATA_in_r<=expanded_DATA_in;
	 
	 
	 
	 always@(posedge clk )
	 begin
	 DATA_in_valid_r<=DATA_in_valid;
	 DATA_in_valid_rr<=DATA_in_valid_r;
	 DATA_in_valid_rrr<=DATA_in_valid_rr;
	 end
	 always@(posedge clk or negedge rst_n)
	   if(rst_n == 1'b0)
	 data_in_count<=0;
	 else if( DATA_in_valid  )
	 data_in_count<=(data_in_count==average_count-1'b1)?10'd0:(data_in_count+1'b1);
	 
	 
	  always@(posedge clk or negedge rst_n)
	   if(rst_n == 1'b0)
	    start_de<=0;
	 else if((data_in_count==average_count-1'b1)&&DATA_in_valid)
	    start_de<=1;
	 
	  always@(posedge clk or negedge rst_n)
	   if(rst_n == 1'b0)
	    fifo_rd<=0;
	 else if((data_in_count==average_count-1'b1)&&DATA_in_valid&&(!start_de))
	    fifo_rd<=1;
	 else if(DATA_in_valid&&(start_de))
	    fifo_rd<=1;
	 else 
	    fifo_rd<=0;
	 
	  always@(posedge clk or negedge rst_n)
	   if(rst_n == 1'b0)
	    accum_reg<=0;
	
	  else if(DATA_in_valid_rr&&(start_de))
	    accum_reg<=accum_reg+fifo_dout_expand_inv+expanded_DATA_in;
	
	
	  else if( DATA_in_valid_rr)
	    accum_reg<=accum_reg+expanded_DATA_in;
	 
	   always@(posedge clk or negedge rst_n)
	   if(rst_n == 1'b0)
	   accum_reg_valid<=0;
	  else if((!start_de)&&(data_in_count==average_count-1'b1)&&DATA_in_valid_rrr)
	   accum_reg_valid<=1;
	   else if( start_de&&DATA_in_valid_rrr )
	   accum_reg_valid<=1;
	  else
	   accum_reg_valid<=0;
	 
	  average_fifo average_fifo_0 (
    .clk        (     clk           ),   //: IN STD_LOGIC;
    .srst       (    ~rst_n         ),   //: IN STD_LOGIC;
    .din        (  DATA_in          ),   //: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    .wr_en      (  DATA_in_valid    ),   //: IN STD_LOGIC;
    .rd_en      (  fifo_rd            ),   //: IN STD_LOGIC;
    .dout       (  fifo_dout          ),   //: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    .full       (                     ),   //: OUT STD_LOGIC;
    .empty      (                     ),   //: OUT STD_LOGIC;
    .data_count ( rd_data_count      )   //: OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
  );
	 
	 
	 div_1000  div_1000_0(
    .aclk                  (   clk               ),  //: IN STD_LOGIC;
    .s_axis_divisor_tvalid (  accum_reg_valid    ),  //: IN STD_LOGIC;
    .s_axis_divisor_tdata  (      16'd1000       ),  //: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    .s_axis_dividend_tvalid(  accum_reg_valid    ),  //: IN STD_LOGIC;
    .s_axis_dividend_tdata ({6'b0,accum_reg}     ),  //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    .m_axis_dout_tvalid    ( divide_valid        ),  //: OUT STD_LOGIC;
    .m_axis_dout_tdata     ( {reserve,quotient,fractional})   //: OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
  );
	 
	 endmodule
