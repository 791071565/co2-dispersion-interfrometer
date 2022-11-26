`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/15 16:22:22
// Design Name: 
// Module Name: data_cap_ture
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


module data_cap_ture(
      input          alg_clk,
    input          alg_rst_n,
    input   [15:0] ref_sync_pem_dat,
    input          ref_sync_pem_dat_valid,
    input          pem_posedge,//filtered
    
    input          frequency_detected,
    input          refresh_align,
     
    
    output  [15:0] ram_dat,
    output  [8:0]  ram_addr,
    output         ram_wr_valid,
    output         trig_search_cdc  
    
 );
 
 
   localparam  min_cap_count=8'd100;  
   localparam  pem_periodic_cnt= 5'd6 ;

   localparam  IDLE=8'd0;
   localparam  FIRST_CAPTURE=8'd1;
   localparam  WAIT_CAPTURE=8'd2;
   localparam  CAPTURE=8'd3;
   localparam  CAPTURE_FAILED=8'd4;
   localparam  CAPTURE_DETECT=8'd5;
   localparam  CAPTURE_SUCCESS=8'd6;
    
   (*mark_debug = "true"*)  reg  [7:0]   state;
    reg  [5:0]  pem_period_cnt=0;
  (*mark_debug = "true"*)  reg [8:0]   cap_cnt;
    reg [15:0]  ram_dat_r;
    reg [8:0]   ram_addr_r;
    reg         ram_wr_valid_r;
    reg         sync_pem_posedge;
    reg         trig_search_cdc_r;  
    
    
    assign    ram_dat                = ram_dat_r                      ; 
    assign    ram_addr               = ram_addr_r                     ;
    assign    ram_wr_valid           = ram_wr_valid_r                 ;
    assign    trig_search_cdc        = trig_search_cdc_r        ;
 
 
     always@(posedge alg_clk or negedge alg_rst_n)
        if(!alg_rst_n)
             state<=IDLE;
       else  begin
         case(state)
         
           IDLE:
             state<=( frequency_detected )?FIRST_CAPTURE:IDLE;
            
           FIRST_CAPTURE:  
             state<=( pem_posedge&&(pem_period_cnt==pem_periodic_cnt-1'b1))?CAPTURE_DETECT:FIRST_CAPTURE;
 
 
           CAPTURE_DETECT:
             state<=(cap_cnt>=min_cap_count)?CAPTURE_SUCCESS:CAPTURE_FAILED;
             
            CAPTURE_SUCCESS: 
              state<=WAIT_CAPTURE;
           
           WAIT_CAPTURE:
             state<=(refresh_align)?CAPTURE:WAIT_CAPTURE;  

           CAPTURE:

            state<=( pem_posedge&&(pem_period_cnt==pem_periodic_cnt-1'b1))?CAPTURE_DETECT:CAPTURE;

          CAPTURE_FAILED:
              state<=CAPTURE;
              default:;
           endcase
       end
       
       
   always@(posedge alg_clk or negedge alg_rst_n)
   if(!alg_rst_n)
    ram_dat_r<=16'd0;
   else 
    ram_dat_r<=ref_sync_pem_dat;
       
   always@(posedge alg_clk or negedge alg_rst_n)
   if(!alg_rst_n) 
    ram_addr_r<=9'd0;
   else if(state== CAPTURE_DETECT)
    ram_addr_r<=9'd0;
   
   else if(pem_posedge&&(!sync_pem_posedge))
    ram_addr_r<=9'd0; 

   else if(((state==CAPTURE)&&ref_sync_pem_dat_valid)||((state== FIRST_CAPTURE)&&ref_sync_pem_dat_valid)) 
    ram_addr_r<=ram_addr_r+1'b1;    
       
   always@(posedge alg_clk or negedge alg_rst_n)
   if(!alg_rst_n) 
    ram_wr_valid_r<=1'd0;

   else if(pem_posedge&&(pem_period_cnt==pem_periodic_cnt-1'b1)) 
    
    ram_wr_valid_r<=1'd0;
    
   else if((pem_posedge&&(!sync_pem_posedge)&&(state==CAPTURE))||(pem_posedge&&(!sync_pem_posedge)&&(state==FIRST_CAPTURE)))
    ram_wr_valid_r<=1'b1;
   
   else if( sync_pem_posedge&&ref_sync_pem_dat_valid )
    ram_wr_valid_r<=1'b1;
    
   else
    ram_wr_valid_r<=1'd0;    
       
       
       
       
   always@(posedge alg_clk or negedge alg_rst_n)
   if(!alg_rst_n)
   sync_pem_posedge<=0;
   else if(((state==CAPTURE)&&pem_posedge)||((state==FIRST_CAPTURE)&&pem_posedge))
   sync_pem_posedge<=1;
   else if(state== CAPTURE_DETECT)    
   sync_pem_posedge<=0;           
              
   
  always@(posedge alg_clk or negedge alg_rst_n)
   if(!alg_rst_n)
   pem_period_cnt<=0;
   else if(state==CAPTURE_DETECT)
   pem_period_cnt<=0;
   else if(((pem_posedge&&(!sync_pem_posedge)&&(state==CAPTURE))||(pem_posedge&&(!sync_pem_posedge)&&(state==FIRST_CAPTURE))))
   pem_period_cnt<=pem_period_cnt+1'b1;    
   else if(sync_pem_posedge&& pem_posedge) 
   pem_period_cnt<=pem_period_cnt+1'b1;

  always@(posedge alg_clk or negedge alg_rst_n)
   if(!alg_rst_n)
      cap_cnt<=0;
   else if((state== CAPTURE_SUCCESS)||    (state== CAPTURE_FAILED) )  
      cap_cnt<=0;
   else if(pem_posedge&&(!sync_pem_posedge)) 
      cap_cnt<=0;
   else if (ref_sync_pem_dat_valid&&sync_pem_posedge)
      cap_cnt<=cap_cnt+1'b1;
 always@(posedge alg_clk or negedge alg_rst_n)
        if(!alg_rst_n)
    trig_search_cdc_r<=0;
    else  
   trig_search_cdc_r<=(state== CAPTURE_SUCCESS);
 
 
 endmodule