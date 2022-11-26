`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/29 09:56:19
// Design Name: 
// Module Name: data_store
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


module data_store#(
   parameter  ch1_base_addr=32'h80000000,//
   parameter  ch1_end_addr =32'h9FFFFF80,// 
   parameter  ch2_base_addr=32'hA0000000,//
   parameter  ch2_end_addr =32'hBFFFFF80,//
   parameter  algorithm_base_addr=32'h80000000,//
   parameter  algorithm_end_addr =32'hBFFFFF80,//
   parameter  burst_wr_length =8'd128 ,
   parameter  data_width =32'd128 ,
   parameter  addr_increase_pace=burst_wr_length ,
   parameter  fifo_threshold=7'd8 ,
   parameter  wr_ddr3_mode ="ring" //"once"
   
   
       
)
(
  input                sample_clk             ,
  input       [127:0]  sample_data_CH1        ,
  input                sample_data_valid_CH1  ,

  input       [127:0]  sample_data_CH2        ,
  input                sample_data_valid_CH2  ,
  
  input                algorithm_clk         ,
  input       [127:0]  algorithm_data        ,
  input                algorithm_data_valid  ,       
  
  
  input [0:0]          ddr3_ui_rst_n  ,
  input                ddr3_user_clk  ,
  output [31:0]        rd_addr_0      ,
  input [127:0]        rd_data_0      ,
  input                rd_data_end_0  ,
  input                rd_data_valid_0,
  output [19:0]        rd_len_0       ,
  input                rd_ready_0     ,
  output               rd_valid_0     ,
(*mark_debug = "true"*)  output reg  [31:0]   wr_addr_0      ,
(*mark_debug = "true"*) output reg [127:0]   wr_data_0      ,
(*mark_debug = "true"*)  input                wr_data_end_0  ,
(*mark_debug = "true"*)  input                wr_data_req_0  ,
  output [19:0]        wr_len_0       ,
(*mark_debug = "true"*)  input                wr_ready_0     ,
(*mark_debug = "true"*)  output               wr_valid_0 

);
  

 assign       wr_len_0=burst_wr_length;
 assign       rd_valid_0=0;
 assign       rd_len_0=0;
 assign       rd_addr_0=ch1_base_addr;
   wire [6:0]   rd_data_count_0;
   wire [6:0]   rd_data_count_1;
   wire [6:0]   rd_data_count_2;
 wire [127:0] fifo_dout_0;
 wire [127:0] fifo_dout_1;
 wire [127:0] fifo_dout_2;
 wire         wr_data_req  ;      
 wire         wr_data_req_1;
 wire         wr_data_req_2;
 
 
 reg          wr_valid_0,wr_valid_0_next;
 //reg  [31:0]  wr_addr_0,wr_addr_0_next;
 reg          wr_protect,wr_protect_next;
 //{clear_ack 3bits and indicate channel}
 
 
 
  reg        channel_0_req;
  reg        channel_1_req;
  reg        channel_2_req;
 
// assign   channel_0_req= wr_ready_0&&( rd_data_count_0>=fifo_threshold)&&(!wr_protect);  
// assign   channel_1_req= wr_ready_0&&( rd_data_count_1>=fifo_threshold)&&(!wr_protect);  
// assign   channel_2_req= wr_ready_0&&( rd_data_count_2>=fifo_threshold)&&(!wr_protect);

// assign   channel_0_req= ( rd_data_count_0>=fifo_threshold) ; 
// assign   channel_1_req= ( rd_data_count_1>=fifo_threshold) ; 
// assign   channel_2_req= ( rd_data_count_2>=fifo_threshold) ; 
 
  reg    channel_0_ack,channel_0_ack_next;      
  reg    channel_1_ack,channel_1_ack_next;
  reg    channel_2_ack,channel_2_ack_next;
 
   reg    ch_0_cmd_pro,ch_0_cmd_pro_next;     
   reg    ch_1_cmd_pro,ch_1_cmd_pro_next;
   reg    ch_2_cmd_pro,ch_2_cmd_pro_next;
 
 
  wire  [2:0]  cmd_out;
 wire         cmd_empty;
  reg  [2:0]   cmd_in,cmd_in_next; 
  reg          cmd_write,cmd_write_next; 
  reg          cmd_read,cmd_read_next;
  reg          cmd_read_r;
 
  reg          cmd_read_pro,cmd_read_pro_next;
 
   reg   [31:0] CH1_addr_reg,CH1_addr_reg_next;      
   reg   [31:0] CH2_addr_reg,CH2_addr_reg_next;
  reg   [31:0] CH3_addr_reg,CH3_addr_reg_next;

 assign       wr_data_req  =(cmd_out[0])?wr_data_req_0:1'b0;
 assign       wr_data_req_1=(cmd_out[1])?wr_data_req_0:1'b0;
 assign       wr_data_req_2=(cmd_out[2])?wr_data_req_0:1'b0;

//debug ports
  reg  [31:0]  cnt,cnt_next;
  reg          cnt_work,cnt_work_next;
 //debug
 wire   addr_range_out_0;
 assign addr_range_out_0=wr_data_end_0&&(wr_addr_0==ch1_end_addr);
   wire   addr_range_out_1;
  assign addr_range_out_1=wr_data_end_0&&(wr_addr_0==ch2_end_addr);
   wire         dram_fifo_full_0;
   wire         dram_fifo_full_1;
   wire         dram_fifo_full_2;
    wire         cmd_fifo_full;
  always@*
 begin
    channel_0_ack_next=channel_0_ack;
    channel_1_ack_next=channel_1_ack;
    channel_2_ack_next=channel_2_ack;
     if(wr_data_end_0)
     begin
      channel_0_ack_next=(cmd_out[0])?1'b0:channel_0_ack;
      channel_1_ack_next=(cmd_out[1])?1'b0:channel_1_ack; 
      channel_2_ack_next=(cmd_out[2])?1'b0:channel_2_ack;
     end
    
    else if(channel_0_req&&(!channel_0_ack))
    begin
     channel_0_ack_next=(!ch_0_cmd_pro)?1'b1:channel_0_ack;
    end
    
    else if(channel_1_req&&(!channel_1_ack))
    begin
     channel_1_ack_next=(!ch_1_cmd_pro)?1'b1:channel_1_ack;
    end
    
    else if(channel_2_req&&(!channel_2_ack))
    begin
     channel_2_ack_next=(!ch_2_cmd_pro)?1'b1:channel_2_ack;
    end
    
    end
 
 
 always@*
  begin
   ch_0_cmd_pro_next=ch_0_cmd_pro; 
   ch_1_cmd_pro_next=ch_1_cmd_pro;
   ch_2_cmd_pro_next=ch_2_cmd_pro;
  if(wr_data_end_0)
 begin
    ch_0_cmd_pro_next=(cmd_out[0])?1'b0:ch_0_cmd_pro;  
    ch_1_cmd_pro_next=(cmd_out[1])?1'b0:ch_1_cmd_pro;
    ch_2_cmd_pro_next=(cmd_out[2])?1'b0:ch_2_cmd_pro;
 end
else if(cmd_write)
  
    begin
    ch_0_cmd_pro_next=(cmd_in[0])?1'b1:ch_0_cmd_pro;  
    ch_1_cmd_pro_next=(cmd_in[1])?1'b1:ch_1_cmd_pro;
    ch_2_cmd_pro_next=(cmd_in[2])?1'b1:ch_2_cmd_pro;
  end
 end

   reg  cmd_write_abort_0,cmd_write_abort_0_next;
   reg  cmd_write_abort_1,cmd_write_abort_1_next;
   reg  cmd_write_abort_2,cmd_write_abort_2_next;
   
   
   always@*
   begin
   cmd_write_abort_0_next=cmd_write_abort_0; 
     if(ch_0_cmd_pro)
     cmd_write_abort_0_next=0;
     else if(channel_0_req&&channel_0_ack&&(!ch_0_cmd_pro)&&(!cmd_write_abort_0))
     
        cmd_write_abort_0_next=1;
   
   end
   
    always@*
      begin
      cmd_write_abort_1_next=cmd_write_abort_1; 
    
     if(ch_1_cmd_pro)
           cmd_write_abort_1_next=0;
       else    if(channel_1_req&&channel_1_ack&&(!ch_1_cmd_pro)&&(!cmd_write_abort_1))
                 cmd_write_abort_1_next=1;
       
       
       
      end
   
    always@*
         begin
         cmd_write_abort_2_next=cmd_write_abort_2; 
         
             if(ch_2_cmd_pro)
                      cmd_write_abort_2_next=0;
         
     else    if(channel_2_req&&channel_2_ack&&(!ch_2_cmd_pro)&&(!cmd_write_abort_2))
          cmd_write_abort_2_next=1;
      
         
         end
   
   
   
   
  always@*
   begin
    cmd_in_next=cmd_in;
  //  cmd_write_abort_0_next=cmd_write_abort_0; 
//     cmd_write_abort_1_next=cmd_write_abort_1; 
//     cmd_write_abort_2_next=cmd_write_abort_2; 
    cmd_write_next=1'b0;
    
    
//      else if(ch_1_cmd_pro)
//       cmd_write_abort_1_next=0;
//       else if(ch_2_cmd_pro)
//         cmd_write_abort_2_next=0;
    
    //cmd_write_next=cmd_write;
      if(channel_0_req&&channel_0_ack&&(!ch_0_cmd_pro)&&(!cmd_write_abort_0))
    begin
     cmd_in_next=3'b001;
   //  cmd_write_next=(cmd_write_abort_0)?1'b0:1'b1;
    cmd_write_next= 1'b1;
   //  cmd_write_abort_0_next=1;
    end
   else if(channel_1_req&&channel_1_ack&&(!ch_1_cmd_pro)&&(!cmd_write_abort_1))
    begin
     cmd_in_next=3'b010;
   //  cmd_write_next=(cmd_write_abort_1)?1'b0:1'b1;
    cmd_write_next= 1'b1;
  //   cmd_write_abort_1_next=1;
    end
   else if(channel_2_req&&channel_2_ack&&(!ch_2_cmd_pro)&&(!cmd_write_abort_2))
    begin
     cmd_in_next=3'b100;
   //  cmd_write_next=(cmd_write_abort_2)?1'b0:1'b1;
    cmd_write_next= 1'b1;
  //   cmd_write_abort_2_next=1;
     end

  //else
  //cmd_write_next=1'b0;
  
 end
 
 
 
  always@*
   begin
    if(cmd_read&&(!cmd_read_pro))
     cmd_read_next=1'b0;
   else if((!cmd_empty)&&(!cmd_read_pro))
     cmd_read_next=(wr_ready_0)?1'b1:1'b0; 
    else 
     cmd_read_next=1'b0;
  end
 
 always@*
   begin
   cmd_read_pro_next=cmd_read_pro;
   if(wr_data_end_0)
     cmd_read_pro_next=1'b0; 
   else if((!cmd_empty)&&(!cmd_read_pro)&&cmd_read)
     cmd_read_pro_next=1'b1; 
  end
 
 
 
 always@*
 begin
 wr_protect_next=wr_protect;
 if(wr_data_end_0)
 wr_protect_next=1'b0;
 
 else if(wr_ready_0&&wr_valid_0)
  wr_protect_next=1'b1;
 end
 
 
 
 always@*
 begin
  if(wr_ready_0&&wr_valid_0)
  wr_valid_0_next=1'b0;
  else if(wr_ready_0&&cmd_read_r&&(!wr_protect))
  wr_valid_0_next=1'b1;
 else
  wr_valid_0_next=1'b0;  
 end
//branch 
 generate  
  if( wr_ddr3_mode =="ring")
 begin

 always@*
 begin
   CH1_addr_reg_next=CH1_addr_reg;
 if(wr_data_end_0&&(CH1_addr_reg==ch1_end_addr)&&cmd_out[0])
   CH1_addr_reg_next=ch1_base_addr; 
 else  if(wr_data_end_0&&cmd_out[0])
   CH1_addr_reg_next=CH1_addr_reg+addr_increase_pace;
 end
 
 always@*
 begin
   CH2_addr_reg_next=CH2_addr_reg;
 if(wr_data_end_0&&(CH2_addr_reg==ch2_end_addr)&&cmd_out[1])
   CH2_addr_reg_next=ch2_base_addr; 
 else  if(wr_data_end_0&&cmd_out[1])
   CH2_addr_reg_next=CH2_addr_reg+addr_increase_pace;
 end

 always@*
 begin
   CH3_addr_reg_next=CH3_addr_reg;
 if(wr_data_end_0&&(CH3_addr_reg==algorithm_end_addr)&&cmd_out[2])
   CH3_addr_reg_next=algorithm_base_addr; 
 else  if(wr_data_end_0&&cmd_out[2])
   CH3_addr_reg_next=CH3_addr_reg+addr_increase_pace;
 end
 end
 else 
 begin
 always@*
   begin
     CH1_addr_reg_next=CH1_addr_reg;
   if(wr_data_end_0&&(CH1_addr_reg==ch1_end_addr)&&cmd_out[0])
     CH1_addr_reg_next=CH1_addr_reg; 
   else  if(wr_data_end_0&&cmd_out[0])
     CH1_addr_reg_next=CH1_addr_reg+addr_increase_pace;
   end
   
   always@*
   begin
     CH2_addr_reg_next=CH2_addr_reg;
   if(wr_data_end_0&&(CH2_addr_reg==ch2_end_addr)&&cmd_out[1])
     CH2_addr_reg_next=CH2_addr_reg; 
   else  if(wr_data_end_0&&cmd_out[1])
     CH2_addr_reg_next=CH2_addr_reg+addr_increase_pace;
   end
  
   always@*
   begin
     CH3_addr_reg_next=CH3_addr_reg;
   if(wr_data_end_0&&(CH3_addr_reg==algorithm_end_addr)&&cmd_out[2])
     CH3_addr_reg_next=CH3_addr_reg; 
   else  if(wr_data_end_0&&cmd_out[2])
     CH3_addr_reg_next=CH3_addr_reg+addr_increase_pace;
   end
 
 
 
 end

 endgenerate
 
 
 
 
 
  always@*
   begin
   if(cmd_out[0])
     wr_addr_0=CH1_addr_reg;
   else if(cmd_out[1])
 
     wr_addr_0=CH2_addr_reg;
   else if(cmd_out[2])
     wr_addr_0=CH3_addr_reg;
   else
     wr_addr_0=CH1_addr_reg; 
   
  end
  
  always@*
   begin
   if(cmd_out[0])    
  wr_data_0=fifo_dout_0;
  else if(cmd_out[1])
  wr_data_0=fifo_dout_1;
  else if(cmd_out[2])
   wr_data_0=fifo_dout_2;
  else
  wr_data_0=fifo_dout_0;
  end
  
  always@*
      begin
    
    cnt_next=cnt;
     if(addr_range_out_0||addr_range_out_1 )
      cnt_next=32'b0;
   else  if(cnt_work )
    cnt_next=cnt+1'b1;
    end
    
     always@*
       begin
        cnt_work_next=cnt_work;
        if(addr_range_out_0||addr_range_out_1 )
        cnt_work_next=~cnt_work;
       end
  
  
  
  
  
  
  
  
  
  
  
  
  
 always@(posedge ddr3_user_clk)
 begin
 wr_valid_0<=   (!ddr3_ui_rst_n)?1'b0:wr_valid_0_next;
// wr_addr_0<=    (!ddr3_ui_rst_n)?base_addr:wr_addr_0_next;
 wr_protect<=   (!ddr3_ui_rst_n)?1'b0:wr_protect_next;
 channel_0_ack<=(!ddr3_ui_rst_n)?1'b0:channel_0_ack_next;
 channel_1_ack<=(!ddr3_ui_rst_n)?1'b0:channel_1_ack_next;
 channel_2_ack<=(!ddr3_ui_rst_n)?1'b0:channel_2_ack_next;
 ch_0_cmd_pro <=(!ddr3_ui_rst_n)?1'b0:ch_0_cmd_pro_next;
 ch_1_cmd_pro <=(!ddr3_ui_rst_n)?1'b0:ch_1_cmd_pro_next;
 ch_2_cmd_pro <=(!ddr3_ui_rst_n)?1'b0:ch_2_cmd_pro_next;
 cmd_in       <=(!ddr3_ui_rst_n)?3'b0:cmd_in_next; 
 cmd_write    <=(!ddr3_ui_rst_n)?1'b0:cmd_write_next; 
 cmd_read     <=(!ddr3_ui_rst_n)?1'b0:cmd_read_next;
 cmd_read_r   <=(!ddr3_ui_rst_n)?1'b0:cmd_read;  
 cmd_read_pro <=(!ddr3_ui_rst_n)?1'b0:cmd_read_pro_next;
 CH1_addr_reg <=(!ddr3_ui_rst_n)?ch1_base_addr:CH1_addr_reg_next;
 CH2_addr_reg <=(!ddr3_ui_rst_n)?ch2_base_addr:CH2_addr_reg_next;
 CH3_addr_reg <=(!ddr3_ui_rst_n)?algorithm_base_addr:CH3_addr_reg_next;
 cmd_write_abort_0<=(!ddr3_ui_rst_n)?1'b0:cmd_write_abort_0_next;
 cmd_write_abort_1<=(!ddr3_ui_rst_n)?1'b0:cmd_write_abort_1_next;
 cmd_write_abort_2<=(!ddr3_ui_rst_n)?1'b0:cmd_write_abort_2_next;
  cnt       <=(!ddr3_ui_rst_n)?32'b0:cnt_next;
  cnt_work  <=(!ddr3_ui_rst_n)?1'b0:cnt_work_next;
  channel_0_req<=(!ddr3_ui_rst_n)?1'b0:(rd_data_count_0>=(7'd8)) ;   
  channel_1_req<=(!ddr3_ui_rst_n)?1'b0:(rd_data_count_1>=(7'd8)) ;   
  channel_2_req<=(!ddr3_ui_rst_n)?1'b0:(rd_data_count_2>=(7'd8)) ;   
  
 end
 
  cmd_fifo cmd_fifo_0 (
  .clk         ( ddr3_user_clk ),  
  .din         ( cmd_in  ),
  .wr_en       (cmd_write  ),
  .rd_en       ( cmd_read ),
  .dout        ( cmd_out  ),
  .full        ( cmd_fifo_full  ),
  .empty          (cmd_empty  ) 
 
 );
 
 
 
 
 
 dram_fifo dram_fifo_0 (
  .wr_clk         ( sample_clk ),
  .rd_clk         ( ddr3_user_clk ),  
  .din            ( sample_data_CH1  ),
  .wr_en          (sample_data_valid_CH1  ),
  .rd_en          ( wr_data_req ),
  .dout           ( fifo_dout_0  ),
  .full           ( dram_fifo_full_0 ),
  .empty          (             ),
  .rd_data_count  (rd_data_count_0 )
 );
 
 dram_fifo dram_fifo_1 (
  .wr_clk         ( sample_clk ),
  .rd_clk         ( ddr3_user_clk ),  
  .din            ( sample_data_CH2 ),
  .wr_en          (sample_data_valid_CH2 ),
  .rd_en          ( wr_data_req_1 ),
  .dout           ( fifo_dout_1  ),
  .full           (dram_fifo_full_1 ),
  .empty          (             ),
  .rd_data_count  (rd_data_count_1 )
 );
 
dram_fifo dram_fifo_2 (
  .wr_clk         ( algorithm_clk ),
  .rd_clk         ( ddr3_user_clk ),  
  .din            (algorithm_data       ),
  .wr_en          (algorithm_data_valid  ),
  .rd_en          ( wr_data_req_2 ),
  .dout           ( fifo_dout_2  ),
  .full           ( dram_fifo_full_2  ),
  .empty          (             ),
  .rd_data_count  (rd_data_count_2 )
 ); 
 
 
  endmodule
