`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/30 20:27:29
// Design Name: 
// Module Name: buffer_group
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


module buffer_group(
   input          alg_clk,
   input          alg_rst_n,
   
   input [47:0]   sine_wave_r,
   input [47:0]   cosine_wave_r,
   input [8:0]    sine_addr_r,
   input [8:0]    cosine_addr_r,
   input          sine_valid_r,
   input          cosine_valid_r,
   input [8:0]    wave_length,
   
   
   input          start_search,
   input          search_end  ,
   
   output         mem_copy_end_1,
   input          mem_copy_1, 
   output         mem_copy_end_2,
   input          mem_copy_2,
   output         mem_copy_end_3,
   input          mem_copy_3,
   output         mem_copy_end_4,
   input          mem_copy_4 ,
   
   
    input         average_1_max_select,  
    input         average_1_min_select,
    input         average_2_max_select,  
    input         average_2_min_select,
    input         select_valid       ,
   

   
   input               channel_A_en  ,
   input  [8:0]        channel_A_addr,
   output reg [47:0]  channel_A_data ,
   
   input               channel_B_en,
   input  [8:0]        channel_B_addr,
   output reg [47:0]  channel_B_data ,
   input               buf_refresh,
   output   reg  retrigger 
             
   );
    localparam  IDLE=8'd0;
	localparam  WAIT_WRITE_PING=8'd1;
    localparam  MEM_COPY_PING=8'd2;
	localparam  MEM_COPY_END_PING=8'd3;
	localparam  WAIT_WRITE_PONG=8'd4;
    localparam  MEM_COPY_PONG=8'd5;
	localparam  MEM_COPY_END_PONG=8'd6;
   
 (*mark_debug = "true"*)   reg [7:0]  buf_state_0;
 (*mark_debug = "true"*)   reg [7:0]  buf_state_1;
 (*mark_debug = "true"*)   reg [7:0]  buf_state_2;
 (*mark_debug = "true"*)   reg [7:0]  buf_state_3;
   
   
   reg  [8:0]  mem_cpy_addr_0;
   reg  [8:0]  mem_cpy_addr_1;
   reg  [8:0]  mem_cpy_addr_2;
   reg  [8:0]  mem_cpy_addr_3;
   
   
   reg     mem_cpy_sig_0;   
   reg     mem_cpy_sig_1;
   reg     mem_cpy_sig_2;
   reg     mem_cpy_sig_3;
   
   
   wire  [47:0]  mem_cpy_data_0;   
   wire  [47:0]  mem_cpy_data_1;
   wire  [47:0]  mem_cpy_data_2;
   wire  [47:0]  mem_cpy_data_3;
   
   
   
   reg  channel_A_en_r;
   wire channel_A_en_negedge;
   assign channel_A_en_negedge= channel_A_en_r&&(!channel_A_en); 
   
   assign      mem_copy_end_1=(buf_state_0==MEM_COPY_END_PING)||(buf_state_0==MEM_COPY_END_PONG);
   assign      mem_copy_end_2=(buf_state_1==MEM_COPY_END_PING)||(buf_state_1==MEM_COPY_END_PONG);
   assign      mem_copy_end_3=(buf_state_2==MEM_COPY_END_PING)||(buf_state_2==MEM_COPY_END_PONG);
   assign      mem_copy_end_4=(buf_state_3==MEM_COPY_END_PING)||(buf_state_3==MEM_COPY_END_PONG);

    always@(posedge alg_clk) 
   channel_A_en_r<=channel_A_en;
   
   
   
   always@(posedge alg_clk or negedge alg_rst_n)
   if(!alg_rst_n)
    buf_state_0<=IDLE ;
   else begin
    case(buf_state_0)
	IDLE :
	  buf_state_0<=(start_search)?WAIT_WRITE_PING:IDLE;
	WAIT_WRITE_PING:
	   if(search_end)
	     buf_state_0<=WAIT_WRITE_PONG;
		else if(mem_copy_1) 	 
	     buf_state_0<=MEM_COPY_PING ;
	MEM_COPY_PING:
	  buf_state_0<=(mem_cpy_sig_0&&(mem_cpy_addr_0==wave_length-1'b1))?MEM_COPY_END_PING:MEM_COPY_PING;
	MEM_COPY_END_PING:
   	  buf_state_0<=WAIT_WRITE_PING;
	WAIT_WRITE_PONG:
      	if(search_end)
	      buf_state_0<= WAIT_WRITE_PING;
	   else if(mem_copy_1)
	      buf_state_0<= MEM_COPY_PONG  ;
	  
	 MEM_COPY_PONG:

      buf_state_0<=(mem_cpy_sig_0&&(mem_cpy_addr_0==wave_length-1'b1))?MEM_COPY_END_PONG:MEM_COPY_PONG;
    	 
	 MEM_COPY_END_PONG: 
	  buf_state_0<=WAIT_WRITE_PONG;
	  
	 
   default:;
   endcase
   end
   
   
   always@(posedge alg_clk or negedge alg_rst_n)
   if(!alg_rst_n)
    buf_state_1<=IDLE ;
   else begin
    case(buf_state_1)
	IDLE :
	  buf_state_1<=(start_search)?WAIT_WRITE_PING:IDLE;
	WAIT_WRITE_PING:
	   if(search_end)
	     buf_state_1<=WAIT_WRITE_PONG;
		else if(mem_copy_2) 	 
	     buf_state_1<=MEM_COPY_PING ;
	MEM_COPY_PING:
	  buf_state_1<=(mem_cpy_sig_1&&(mem_cpy_addr_1==wave_length-1'b1))?MEM_COPY_END_PING:MEM_COPY_PING;
	MEM_COPY_END_PING:
   	  buf_state_1<=WAIT_WRITE_PING;
	WAIT_WRITE_PONG:
      	if(search_end)
	      buf_state_1<= WAIT_WRITE_PING;
	   else if(mem_copy_2)
	      buf_state_1<= MEM_COPY_PONG  ;
	  
	 MEM_COPY_PONG:

      buf_state_1<=(mem_cpy_sig_1&&(mem_cpy_addr_1==wave_length-1'b1))?MEM_COPY_END_PONG:MEM_COPY_PONG;
    	 
	 MEM_COPY_END_PONG: 
	  buf_state_1<=WAIT_WRITE_PONG;

   default:;
   endcase
   end
   
   
   always@(posedge alg_clk or negedge alg_rst_n)
   if(!alg_rst_n)
    buf_state_2<=IDLE ;
   else begin
    case(buf_state_2)
	IDLE :
	  buf_state_2<=(start_search)?WAIT_WRITE_PING:IDLE;
	WAIT_WRITE_PING:
	   if(search_end)
	     buf_state_2<=WAIT_WRITE_PONG;
		else if(mem_copy_3) 	 
	     buf_state_2<=MEM_COPY_PING ;
	MEM_COPY_PING:
	  buf_state_2<=(mem_cpy_sig_2&&(mem_cpy_addr_2==wave_length-1'b1))?MEM_COPY_END_PING:MEM_COPY_PING;
	MEM_COPY_END_PING:
   	  buf_state_2<=WAIT_WRITE_PING;
	WAIT_WRITE_PONG:
      	if(search_end)
	      buf_state_2<= WAIT_WRITE_PING;
	   else if(mem_copy_3)
	      buf_state_2<= MEM_COPY_PONG  ;
	  
	 MEM_COPY_PONG:

      buf_state_2<=(mem_cpy_sig_2&&(mem_cpy_addr_2==wave_length-1'b1))?MEM_COPY_END_PONG:MEM_COPY_PONG;
    	 
	 MEM_COPY_END_PONG: 
	  buf_state_2<=WAIT_WRITE_PONG;
	  
	 
   default:;
   endcase
   end
   
   
  always@(posedge alg_clk or negedge alg_rst_n)
   if(!alg_rst_n)
    buf_state_3<=IDLE ;
   else begin
    case(buf_state_3)
	IDLE :
	  buf_state_3<=(start_search)?WAIT_WRITE_PING:IDLE;
	WAIT_WRITE_PING:
	   if(search_end)
	     buf_state_3<=WAIT_WRITE_PONG;
		else if(mem_copy_4) 	 
	     buf_state_3<=MEM_COPY_PING ;
	MEM_COPY_PING:
	  buf_state_3<=(mem_cpy_sig_3&&(mem_cpy_addr_3==wave_length-1'b1))?MEM_COPY_END_PING:MEM_COPY_PING;
	MEM_COPY_END_PING:
   	  buf_state_3<=WAIT_WRITE_PING;
	WAIT_WRITE_PONG:
      	if(search_end)
	      buf_state_3<= WAIT_WRITE_PING;
	   else if(mem_copy_4)
	      buf_state_3<= MEM_COPY_PONG  ;
	  
	 MEM_COPY_PONG:

      buf_state_3<=(mem_cpy_sig_3&&(mem_cpy_addr_3==wave_length-1'b1))?MEM_COPY_END_PONG:MEM_COPY_PONG;
    	 
	 MEM_COPY_END_PONG: 
	  buf_state_3<=WAIT_WRITE_PONG;
	  
	 
   default:;
   endcase
   end
    
   reg   mem_cpy_sig_0_r;
   
   
    always@(posedge alg_clk or negedge alg_rst_n)
      if(!alg_rst_n)
       mem_cpy_sig_0<=0;   
     else if( mem_copy_1 )
       mem_cpy_sig_0<=1; 
     else if( mem_cpy_sig_0&&(mem_cpy_addr_0==wave_length-1'b1))
       mem_cpy_sig_0<=0; 
	  
	always@(posedge alg_clk)
	  mem_cpy_sig_0_r<=mem_cpy_sig_0;
	  
	  
	 always@(posedge alg_clk or negedge alg_rst_n)
      if(!alg_rst_n)
       mem_cpy_addr_0<=0;
	  else if(mem_cpy_sig_0 )
	   mem_cpy_addr_0<=mem_cpy_addr_0+1'b1;
	  else
	   mem_cpy_addr_0<=0;
	  reg [8:0] mem_cpy_addr_0_r; 
	  always@(posedge alg_clk)
	  mem_cpy_addr_0_r<=mem_cpy_addr_0;
	  
	  
   reg     mem_cpy_sig_1_r;
   
    always@(posedge alg_clk or negedge alg_rst_n)
      if(!alg_rst_n)
       mem_cpy_sig_1<=0;   
     else if( mem_copy_2 )
       mem_cpy_sig_1<=1; 
     else if( mem_cpy_sig_1&&(mem_cpy_addr_1==wave_length-1'b1))
       mem_cpy_sig_1<=0; 
	  
	always@(posedge alg_clk)
	  mem_cpy_sig_1_r<=mem_cpy_sig_1;
	  
	  
	 always@(posedge alg_clk or negedge alg_rst_n)
      if(!alg_rst_n)
       mem_cpy_addr_1<=0;
	  else if(mem_cpy_sig_1 )
	   mem_cpy_addr_1<=mem_cpy_addr_1+1'b1;
      else
	   mem_cpy_addr_1<=0;
   
     reg [8:0] mem_cpy_addr_1_r; 
      always@(posedge alg_clk)
      mem_cpy_addr_1_r<=mem_cpy_addr_1;

   reg     mem_cpy_sig_2_r;
   
    always@(posedge alg_clk or negedge alg_rst_n)
      if(!alg_rst_n)
       mem_cpy_sig_2<=0;   
     else if( mem_copy_3 )
       mem_cpy_sig_2<=1; 
     else if( mem_cpy_sig_2&&(mem_cpy_addr_2==wave_length-1'b1))
       mem_cpy_sig_2<=0; 
	  
	always@(posedge alg_clk)
	  mem_cpy_sig_2_r<=mem_cpy_sig_2;
	  
	  
	 always@(posedge alg_clk or negedge alg_rst_n)
      if(!alg_rst_n)
       mem_cpy_addr_2<=0;
	  else if(mem_cpy_sig_2)
	   mem_cpy_addr_2<=mem_cpy_addr_2+1'b1;
     else 
       mem_cpy_addr_2<=0;
   
      reg [8:0] mem_cpy_addr_2_r; 
          always@(posedge alg_clk)
          mem_cpy_addr_2_r<=mem_cpy_addr_2;
    
   reg     mem_cpy_sig_3_r;
   
   always@(posedge alg_clk or negedge alg_rst_n)
      if(!alg_rst_n)
       mem_cpy_sig_3<=0;   
     else if( mem_copy_4 )
       mem_cpy_sig_3<=1; 
     else if( mem_cpy_sig_3&&(mem_cpy_addr_3==wave_length-1'b1))
       mem_cpy_sig_3<=0; 
	  
   always@(posedge alg_clk)
	  mem_cpy_sig_3_r<=mem_cpy_sig_3;
	  
	  
   always@(posedge alg_clk or negedge alg_rst_n)
      if(!alg_rst_n)
       mem_cpy_addr_3<=0;
	 else if(mem_cpy_sig_3)
	   mem_cpy_addr_3<=mem_cpy_addr_3+1'b1;
     else
	   mem_cpy_addr_3<=0;
   
      reg [8:0] mem_cpy_addr_3_r; 
    always@(posedge alg_clk)
          mem_cpy_addr_3_r<=mem_cpy_addr_3;
       
 
   reg        average_1_max_select_temp;
          reg        average_1_min_select_temp;
          reg        average_2_max_select_temp;
          reg        average_2_min_select_temp;
          reg        select_valid_temp        ; 
          
          
          always@(posedge  alg_clk or negedge alg_rst_n)
             if(!alg_rst_n)
             begin
             average_1_max_select_temp<=0;
             average_1_min_select_temp<=0;
             average_2_max_select_temp<=0;
             average_2_min_select_temp<=0;
             
          end
          else if(select_valid)
            begin
             average_1_max_select_temp<=average_1_max_select;
             average_1_min_select_temp<=average_1_min_select;
             average_2_max_select_temp<=average_2_max_select;
             average_2_min_select_temp<=average_2_min_select;
            end 
          reg  first_sig;
          
          reg  select_valid_temp_r;
          wire  select_valid_temp_negedge;
           assign  select_valid_temp_negedge=(!select_valid_temp_r)&&(select_valid_temp);
            reg  select_valid_temp_negedge_r;
            reg  select_valid_temp_negedge_rr;
            reg  select_valid_temp_negedge_rrr;
            
             always@(posedge alg_clk)
            begin
            select_valid_temp_r<=select_valid_temp;
            select_valid_temp_negedge_r  <= select_valid_temp_negedge ;  
            select_valid_temp_negedge_rr <=select_valid_temp_negedge_r; 
            select_valid_temp_negedge_rrr<=select_valid_temp_negedge_rr ;
            end
            
            
            always@(posedge alg_clk or negedge alg_rst_n)
             if(!alg_rst_n)
              select_valid_temp<=0;
            else if( select_valid_temp&&buf_refresh)
              select_valid_temp<=0;      
            else if( select_valid)
              select_valid_temp<=1;
          always@(posedge alg_clk or negedge alg_rst_n)
           if(!alg_rst_n)  
          first_sig<=0;
          else if(retrigger)
           first_sig<=1;
//           reg first_sig_1;
//             always@(posedge alg_clk or negedge alg_rst_n)
//                   if(!alg_rst_n)  
//                  first_sig_1<=0;
//                  else if(select_valid_temp_negedge_rrr )
//                   first_sig_1<=1; 
           
           
           
        (*mark_debug = "true"*)     reg  [7:0] rd_sel_state;
            localparam  SEL_IDLE    =8'd0;
            localparam  SEL_MAX_PING=8'd1;
            localparam  SEL_MAX_PONG=8'd2;
            localparam  SEL_MIN_PING=8'd3;
            localparam  SEL_MIN_PONG=8'd4;
            
            always@(posedge  alg_clk or negedge alg_rst_n)
             if(!alg_rst_n)
             rd_sel_state<=SEL_IDLE;
             else
             begin
             case(rd_sel_state)
             SEL_IDLE:
              rd_sel_state<=(select_valid)?SEL_MAX_PING:SEL_IDLE;
             SEL_MAX_PING:
               if(select_valid_temp&&buf_refresh&&average_1_max_select_temp&&(first_sig))     
              rd_sel_state<= SEL_MAX_PONG ;
              else if(select_valid_temp&&buf_refresh&&average_1_min_select_temp&&(first_sig))               
              rd_sel_state<= SEL_MIN_PONG ;
              
             SEL_MAX_PONG:
              if(select_valid_temp&&buf_refresh&&average_1_max_select_temp)     
              rd_sel_state<= SEL_MAX_PING ;
              else if(select_valid_temp&&buf_refresh&&average_1_min_select_temp)               
              rd_sel_state<= SEL_MIN_PING ;
             
             SEL_MIN_PING:
               if(select_valid_temp&&buf_refresh&&average_1_max_select_temp)     
              rd_sel_state<= SEL_MAX_PONG ;
              else if(select_valid_temp&&buf_refresh&&average_1_min_select_temp)               
              rd_sel_state<= SEL_MIN_PONG ;
             
             SEL_MIN_PONG:
              if(select_valid_temp&&buf_refresh&&average_1_max_select_temp)     
              rd_sel_state<= SEL_MAX_PING ;
              else if(select_valid_temp&&buf_refresh&&average_1_min_select_temp)               
              rd_sel_state<= SEL_MIN_PING ;
            
             default:rd_sel_state<=SEL_IDLE; 
             endcase
            end
            
            
            
         (*mark_debug = "true"*)      reg  [7:0] rd_sel_state_1;
       
            
            always@(posedge  alg_clk or negedge alg_rst_n)
             if(!alg_rst_n)
             rd_sel_state_1<=SEL_IDLE;
             else
             begin
             case(rd_sel_state_1)
             SEL_IDLE:
              rd_sel_state_1<=(select_valid)?SEL_MAX_PING:SEL_IDLE;
             SEL_MAX_PING:
               if(select_valid_temp&&buf_refresh&&average_2_max_select_temp&&(first_sig))     
              rd_sel_state_1<= SEL_MAX_PONG ;
              else if(select_valid_temp&&buf_refresh&&average_2_min_select_temp&&(first_sig))               
              rd_sel_state_1<= SEL_MIN_PONG ;
              
             SEL_MAX_PONG:
              if(select_valid_temp&&buf_refresh&&average_2_max_select_temp)     
              rd_sel_state_1<= SEL_MAX_PING ;
              else if(select_valid_temp&&buf_refresh&&average_2_min_select_temp)               
              rd_sel_state_1<= SEL_MIN_PING ;
             
             SEL_MIN_PING:
               if(select_valid_temp&&buf_refresh&&average_2_max_select_temp)     
              rd_sel_state_1<= SEL_MAX_PONG ;
              else if(select_valid_temp&&buf_refresh&&average_2_min_select_temp)               
              rd_sel_state_1<= SEL_MIN_PONG ;
             
             SEL_MIN_PONG:
              if(select_valid_temp&&buf_refresh&&average_2_max_select_temp)     
              rd_sel_state_1<= SEL_MAX_PING ;
              else if(select_valid_temp&&buf_refresh&&average_2_min_select_temp)               
              rd_sel_state_1<= SEL_MIN_PING ;
            
             default:rd_sel_state_1<=SEL_IDLE; 
             endcase
            end
            
            
            
            always@(posedge  alg_clk)
             retrigger<= select_valid_temp&&buf_refresh;
            
   
   wire [47:0] ram_dout1;
   wire [47:0] ram_dout2;
   wire [47:0] ram_dout3;
   wire [47:0] ram_dout4; 
   wire [47:0] ram_dout5;
   wire [47:0] ram_dout6;
   wire [47:0] ram_dout7;
   wire [47:0] ram_dout8;
   
 (*mark_debug = "true"*)  reg  a_sel_max_ping;
 (*mark_debug = "true"*)  reg  a_sel_max_pong;
 (*mark_debug = "true"*)  reg  a_sel_min_ping;
 (*mark_debug = "true"*)  reg  a_sel_min_pong; 
 (*mark_debug = "true"*)  reg  b_sel_max_ping;
 (*mark_debug = "true"*)  reg  b_sel_max_pong;
 (*mark_debug = "true"*)  reg  b_sel_min_ping;
 (*mark_debug = "true"*)  reg  b_sel_min_pong;  
   
   always@(posedge alg_clk)
   begin
    a_sel_max_ping<= (rd_sel_state  == SEL_MAX_PING );  
    a_sel_max_pong<= (rd_sel_state  == SEL_MAX_PONG );  
    a_sel_min_ping<= (rd_sel_state  == SEL_MIN_PING );  
    a_sel_min_pong<= (rd_sel_state  == SEL_MIN_PONG );  
    b_sel_max_ping<= (rd_sel_state_1== SEL_MAX_PING );  
    b_sel_max_pong<= (rd_sel_state_1== SEL_MAX_PONG );  
    b_sel_min_ping<= (rd_sel_state_1== SEL_MIN_PING );  
    b_sel_min_pong<= (rd_sel_state_1== SEL_MIN_PONG );  
   end
//    assign   a_sel_max_ping=(rd_sel_state  == SEL_MAX_PING );//1
//    assign   a_sel_max_pong=(rd_sel_state  == SEL_MAX_PONG );//2
//    assign   a_sel_min_ping=(rd_sel_state  == SEL_MIN_PING );//3
//    assign   a_sel_min_pong=(rd_sel_state  == SEL_MIN_PONG );//4 
//    assign   b_sel_max_ping=(rd_sel_state_1== SEL_MAX_PING );//5
//    assign   b_sel_max_pong=(rd_sel_state_1== SEL_MAX_PONG );//6
//    assign   b_sel_min_ping=(rd_sel_state_1== SEL_MIN_PING );//7
//    assign   b_sel_min_pong=(rd_sel_state_1== SEL_MIN_PONG );//8
   
   
   
   
   
 always@*
    if( a_sel_max_ping&&b_sel_max_ping)
    begin
    channel_A_data= ram_dout1  ;
    channel_B_data= ram_dout5  ;
    end
    
    else if( a_sel_max_pong&& b_sel_max_pong     )
    begin
        channel_A_data= ram_dout2  ;
        channel_B_data= ram_dout6  ;
        end
    
    else if( a_sel_max_ping&&b_sel_min_ping           )
        begin
            channel_A_data= ram_dout1  ;
            channel_B_data= ram_dout7  ;
            end
  
   
   else if( a_sel_max_pong&&b_sel_min_pong           )
     begin
             channel_A_data= ram_dout2  ;
             channel_B_data= ram_dout8  ;
             end
   
     else if( a_sel_min_ping&&b_sel_max_ping           )
                   begin
                       channel_A_data= ram_dout3  ;
                       channel_B_data= ram_dout5  ;
                       end
                  
     else if( a_sel_min_pong&&b_sel_max_pong           )
                begin
                        channel_A_data= ram_dout4  ;
                        channel_B_data= ram_dout6  ;
                        end
      else if( a_sel_min_ping&&b_sel_min_ping           )
        begin
            channel_A_data= ram_dout3  ;
            channel_B_data= ram_dout7  ;
            end
                                       
     else if( a_sel_min_pong&&b_sel_min_pong           )
        begin
                channel_A_data= ram_dout4  ;
                channel_B_data= ram_dout8  ;
                end
   
   
   
   
   else
   begin
       channel_A_data= ram_dout1  ;
       channel_B_data= ram_dout5  ;
       end
   
   
   
   //group 1
   
  //sine max data_buf
   wave_buffer  wave_buffer_0(
   .clka  (  alg_clk            ), 
   .ena   (  sine_valid_r       ), 
   .wea   (       1             ), 
   .addra (  sine_addr_r        ), 
   .dina  (  sine_wave_r        ), 
   .clkb  (  alg_clk            ), 
   .enb   (  mem_cpy_sig_0       ), 
   .addrb (  mem_cpy_addr_0     ), 
   .doutb (  mem_cpy_data_0     )  
 );
  //sine max_buf_ping
  wave_buffer  wave_buffer_1(
   .clka  (  alg_clk           ), 
   .ena   (  mem_cpy_sig_0_r&&(buf_state_0==MEM_COPY_PING)), 
   .wea   (       1                                       ), 
   .addra (  mem_cpy_addr_0_r                             ), 
   .dina  (  mem_cpy_data_0                               ), 
   .clkb  (  alg_clk           ), 
   .enb   ( (rd_sel_state==SEL_MAX_PING)&&channel_A_en             ), 
   .addrb (  channel_A_addr     ), 
   .doutb (   ram_dout1    )  
 );
 
 
 //sine max_buf_pong
  wave_buffer  wave_buffer_2(
   .clka  (  alg_clk           ), 
   .ena   (  mem_cpy_sig_0_r&&(buf_state_0==MEM_COPY_PONG)), 
   .wea   (       1                                       ), 
   .addra (  mem_cpy_addr_0_r                             ), 
   .dina  (  mem_cpy_data_0                               ), 
   .clkb  (  alg_clk           ), 
   .enb   ( (rd_sel_state==SEL_MAX_PONG)&&channel_A_en    ), 
   .addrb ( channel_A_addr    ), 
   .doutb (  ram_dout2      )  
 );
 
 //group2
 
  wave_buffer  wave_buffer_3(
   .clka  (  alg_clk            ), 
   .ena   (  sine_valid_r       ), 
   .wea   (       1             ), 
   .addra (  sine_addr_r        ), 
   .dina  (  sine_wave_r        ), 
   .clkb  (  alg_clk            ), 
   .enb   (  mem_cpy_sig_1      ), 
   .addrb (  mem_cpy_addr_1     ), 
   .doutb (  mem_cpy_data_1     )  
 );
 
 
  //sine min_buf_ping
  wave_buffer  wave_buffer_4(
   .clka  (  alg_clk           ), 
   .ena   ( mem_cpy_sig_1_r&&(buf_state_1==MEM_COPY_PING) ), 
   .wea   (      1                                        ), 
   .addra ( mem_cpy_addr_1_r                              ), 
   .dina  ( mem_cpy_data_1                                ), 
   .clkb  (  alg_clk           ), 
   .enb   ( (rd_sel_state==SEL_MIN_PING)&&channel_A_en      ), 
   .addrb (  channel_A_addr    ), 
   .doutb (   ram_dout3      )  
 );
 
 
 //sine min_buf_pong
  wave_buffer  wave_buffer_5(
   .clka  (  alg_clk           ), 
   .ena   ( mem_cpy_sig_1_r&&(buf_state_1==MEM_COPY_PONG)  ), 
   .wea   (      1                                         ), 
   .addra ( mem_cpy_addr_1_r                               ), 
   .dina  ( mem_cpy_data_1                                   ), 
   .clkb  (  alg_clk           ), 
   .enb   ( (rd_sel_state==SEL_MIN_PONG)&&channel_A_en     ), 
   .addrb (   channel_A_addr   ), 
   .doutb (   ram_dout4     )  
 );
 
 //group3
  
 
 
 
 
 
 
  //cosine max data_buf
   wave_buffer  wave_buffer_6(
   .clka  (  alg_clk            ), 
   .ena   (  cosine_valid_r     ), 
   .wea   (       1             ), 
   .addra (  cosine_addr_r      ), 
   .dina  (  cosine_wave_r      ), 
   .clkb  (  alg_clk            ), 
   .enb   (  mem_cpy_sig_2      ), 
   .addrb (  mem_cpy_addr_2     ), 
   .doutb (  mem_cpy_data_2     )  
 );
  //cosine max_buf_ping
  wave_buffer  wave_buffer_7(
   .clka  (  alg_clk            ), 
   .ena   ( mem_cpy_sig_2_r&&(buf_state_2==MEM_COPY_PING) ), 
   .wea   (      1                                        ), 
   .addra ( mem_cpy_addr_2_r                              ), 
   .dina  ( mem_cpy_data_2                                ), 
   .clkb  (  alg_clk           ), 
   .enb   ( (rd_sel_state_1==SEL_MAX_PING)&&channel_B_en     ), 
   .addrb (  channel_B_addr   ), 
   .doutb (   ram_dout5     )  
 );
 
 
 //cosine max_buf_pong
  wave_buffer  wave_buffer_8(
   .clka  (  alg_clk           ), 
   .ena   ( mem_cpy_sig_2_r&&(buf_state_2==MEM_COPY_PONG)), 
   .wea   (      1                                       ), 
   .addra ( mem_cpy_addr_2_r                             ), 
   .dina  ( mem_cpy_data_2                                ), 
   .clkb  (  alg_clk           ), 
   .enb   (  (rd_sel_state_1==SEL_MAX_PONG)&&channel_B_en    ), 
   .addrb (channel_B_addr      ), 
   .doutb ( ram_dout6      )  
 );
 
 // group 4
    wave_buffer  wave_buffer_9(
     .clka  (  alg_clk            ), 
     .ena   (  cosine_valid_r       ), 
     .wea   (       1             ), 
     .addra (  cosine_addr_r        ), 
     .dina  (  cosine_wave_r        ), 
     .clkb  (  alg_clk            ), 
     .enb   (  mem_cpy_sig_3      ), 
     .addrb (  mem_cpy_addr_3     ), 
     .doutb (  mem_cpy_data_3     )  
   );
 
 
  //cosine min_buf_ping
  wave_buffer  wave_buffer_10(
   .clka  (  alg_clk           ), 
   .ena   (  mem_cpy_sig_3_r&&(buf_state_3==MEM_COPY_PING)   ), 
   .wea   (       1                                          ), 
   .addra (  mem_cpy_addr_3_r                                ), 
   .dina  (  mem_cpy_data_3                                     ), 
   .clkb  (  alg_clk           ), 
   .enb   ( (rd_sel_state_1==SEL_MIN_PING)&&channel_B_en      ), 
   .addrb (channel_B_addr     ), 
   .doutb ( ram_dout7       )  
 );
 
 
 //cosine min_buf_pong
  wave_buffer  wave_buffer_11(
   .clka  (  alg_clk           ), 
   .ena   ( mem_cpy_sig_3_r&&(buf_state_3==MEM_COPY_PONG)    ), 
   .wea   (      1                                           ), 
   .addra ( mem_cpy_addr_3_r                                 ), 
   .dina  ( mem_cpy_data_3                                      ), 
   .clkb  (  alg_clk           ), 
   .enb   ( (rd_sel_state_1==SEL_MIN_PONG)&&channel_B_en      ), 
   .addrb ( channel_B_addr    ), 
   .doutb (   ram_dout8   )  
 );
 
   
   
   endmodule
 
