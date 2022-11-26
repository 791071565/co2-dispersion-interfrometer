`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/04 16:19:25
// Design Name: 
// Module Name: dat_gen
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


module dat_gen(
    input          clk,
    input          rst_n,
    input [18:0]  valid_coef, //19 bit fractional
    input         coef_valid, 
    
    input          trig_search_cdc,
    input   [8:0]  cap_data_number,
    input          fft_end,
    output  [47:0] angle_out,
    output         angle_out_valid ,
     output [55:0] angle_out_temp 
);
  parameter   zero_point_one_degree=56'b00000000000000000000111001001100001110001000000111011011;  
  parameter   zero_point_one_degree_mul_ten=(zero_point_one_degree<<1)+(zero_point_one_degree<<3); 
  parameter   two_pi               =56'b00000000110010010000111111011010101000100010000101101000; //45+19
  parameter    pi                  =56'b00000000011001001000011111101101010100010001000010110100;//1bit sign  10 bit int 45 bit fractional
  parameter   three_pi             =56'b00000001001011011001011111000111111100110011001000011100; 
  parameter   four_pi               =56'b00000001100100100001111110110101010001000100001011010000; 
  parameter   zero_point_one_pi    =56'b00000000000010100000110110010111101110110100111001111000;  
  parameter   search_times         =12'd3600  ; 
 // parameter   search_times         =12'd360   ;        
//    parameter   search_times         =12'd36   ;                                       
//   parameter   search_times         =11'd5 ;//3600
  reg  [74:0]  zero_point_one_pi_temp,zero_point_one_pi_temp_next;
  reg  [8:0]   cap_data_number_r,cap_data_number_r_next;   
  reg  [11:0]  fft_end_count,fft_end_count_next;
  reg          data_gen_work,data_gen_work_next;
  reg          data_gen_work_r;    
  reg  [55:0]  theta_add_temp,theta_add_temp_next;  
  
  reg  [55:0]  zero_point_one_pi_add_temp,zero_point_one_pi_add_temp_next; 
  reg          zero_point_one_pi_add_temp_valid;
   reg          zero_point_one_pi_add_temp_valid_r;
    
  reg  [55:0]  theta_add_zero_point_pi_tmp,theta_add_zero_point_pi_tmp_next;
  reg          theta_add_zero_point_pi_tmp_valid;
  reg          theta_add_zero_point_pi_tmp_valid_r;
  reg  [55:0]  result_sub_bias,result_sub_bias_next;
  reg          result_sub_bias_valid;
  reg          larger_than_pi_r;
  
  reg  [55:0]  two_pi_add_temp,two_pi_add_temp_next; 
  reg  [55:0]  angle_out_temp,angle_out_temp_next;    //1bit sign 10 bit integer 45 bit fraction
  reg          angle_out_valid_temp; 
  reg          data_gen_req,data_gen_req_next;
  reg          add_ignore,add_ignore_next;
  reg          trig_search_cdc_r;
  
  reg  [55:0]  first_sub,first_sub_next;
  reg          first_sub_valid;
  
  
  wire [55:0]  zero_point_one_pi_temp_w;
  wire [55:0]  angle_out_temp_multi_two;    
  wire         data_gen_req_posedge;
  wire [55:0]  two_pi_add_temp_invert;
  wire [55:0]  two_pi_invert;
  wire [55:0]  four_pi_invert;
  wire         larger_than_pi;
  wire [55:0]  result_sub_bias_complement;
  wire         larger_than_pi_posedge;
  wire         larger_than_three_pi;
  wire         larger_than_pi_tmp1;
  
  reg          larger_than_three_pi_r,larger_than_three_pi_r_next;
  reg          larger_than_pi_tmp1_r,larger_than_pi_tmp1_r_next;
  
  assign      larger_than_pi_posedge=larger_than_pi&&(!larger_than_pi_r);
  assign      result_sub_bias_complement=(result_sub_bias[55])?{result_sub_bias[55],~result_sub_bias[54:0]+1'b1}:result_sub_bias;
  assign       data_gen_req_posedge=data_gen_req&&(!zero_point_one_pi_add_temp_valid);
  assign       angle_out={angle_out_temp[55],angle_out_temp[46:45],angle_out_temp[44:0]};
  assign       two_pi_add_temp_invert={~two_pi_add_temp[55],~two_pi_add_temp[54:0]+1'b1};
  assign       two_pi_invert={~two_pi[55],~two_pi[54:0]+1'b1};
  //assign       larger_than_pi=(result_sub_bias>=pi)&&result_sub_bias_valid;
  assign       larger_than_pi=((result_sub_bias[54:0]>=pi[54:0])&&(!result_sub_bias[55]))&&result_sub_bias_valid  ;
 
  assign       angle_out_valid=angle_out_valid_temp;
  assign       four_pi_invert={~four_pi[55],~four_pi[54:0]+1'b1};
  wire   theta_add_zero_point_pi_tmp_valid_posedge;
  wire  zero_point_one_pi_add_temp_valid_negedge;
  assign   theta_add_zero_point_pi_tmp_valid_posedge=theta_add_zero_point_pi_tmp_valid&&(!theta_add_zero_point_pi_tmp_valid_r);
  assign   zero_point_one_pi_add_temp_valid_negedge=(!zero_point_one_pi_add_temp_valid)&&zero_point_one_pi_add_temp_valid_r;
   assign       larger_than_three_pi=((theta_add_zero_point_pi_tmp[54:0]>=three_pi[54:0])&&(!theta_add_zero_point_pi_tmp[55]))&&theta_add_zero_point_pi_tmp_valid_posedge;
   assign       larger_than_pi_tmp1=((theta_add_zero_point_pi_tmp[54:0]>=pi[54:0])&&(!theta_add_zero_point_pi_tmp[55]))&&theta_add_zero_point_pi_tmp_valid_posedge;
  assign        zero_point_one_pi_temp_w=zero_point_one_pi_temp[74:19];
  always@*
  begin
   cap_data_number_r_next=cap_data_number_r;
   if(data_gen_req)
    cap_data_number_r_next=cap_data_number_r-1'b1;
   else if(trig_search_cdc||fft_end)
    cap_data_number_r_next=cap_data_number-1'b1;
  end
  
  
  always@*
    begin
     fft_end_count_next=fft_end_count;
     if(fft_end)
     fft_end_count_next=fft_end_count+1; 
     else if(trig_search_cdc)
     fft_end_count_next=0;
     
    end
  
  
  
  
  
  
  
  always@*
  begin
   zero_point_one_pi_temp_next=zero_point_one_pi_temp ;
   if(coef_valid)
   zero_point_one_pi_temp_next= valid_coef* pi   ; 
  end
  
  always@*
  begin
    data_gen_work_next=data_gen_work;
   if(trig_search_cdc_r)
    data_gen_work_next=1'b1; 
   else if(fft_end&&(fft_end_count==(search_times-1)))
    data_gen_work_next=1'b0; 
  end
  
  always@*
  begin
    data_gen_req_next=data_gen_req;
   if(cap_data_number_r==9'd1)
    data_gen_req_next=1'b0; 
   else if((fft_end&&(fft_end_count!=(search_times-1)))||trig_search_cdc_r)
    data_gen_req_next=1'b1; 
  end
  
  
  
  always@*
  begin
    zero_point_one_pi_add_temp_next=zero_point_one_pi_add_temp;
    if(trig_search_cdc_r||fft_end)
   // zero_point_one_pi_add_temp_next=56'b0;     
   zero_point_one_pi_add_temp_next=zero_point_one_pi_temp_w;
  //zero_point_one_pi_add_temp_next=zero_point_one_pi ;
    else if(data_gen_req&&(add_ignore))
    zero_point_one_pi_add_temp_next=zero_point_one_pi_add_temp+zero_point_one_pi_temp_w;    
//    zero_point_one_pi_add_temp_next=zero_point_one_pi_add_temp+zero_point_one_pi ;   
  end
  
  
  always@*
  begin
    theta_add_temp_next=theta_add_temp;
    if(fft_end)
   theta_add_temp_next=theta_add_temp+zero_point_one_degree; 
 //  theta_add_temp_next=theta_add_temp+ zero_point_one_degree_mul_ten;
   else  if( trig_search_cdc )
    theta_add_temp_next=0;
	
  end
  
  
  always@*
  begin
    add_ignore_next=add_ignore;
    if(fft_end)
     add_ignore_next=1'b0;
   else if(data_gen_req_posedge)
     add_ignore_next=1'b1; 
  end
  
  always@*
  begin
   two_pi_add_temp_next=two_pi_add_temp;
   if(fft_end)
   two_pi_add_temp_next=55'b0;
  else if(larger_than_pi_posedge&&result_sub_bias_valid)
   two_pi_add_temp_next=two_pi_add_temp+two_pi;
  end
  
  
 always@*
  begin
   theta_add_zero_point_pi_tmp_next=theta_add_zero_point_pi_tmp;
  if(zero_point_one_pi_add_temp_valid)
   theta_add_zero_point_pi_tmp_next=zero_point_one_pi_add_temp+theta_add_temp;
  end 
  
   always@*
  begin
  first_sub_next=theta_add_zero_point_pi_tmp;
  if(larger_than_three_pi||larger_than_three_pi_r )
   first_sub_next= theta_add_zero_point_pi_tmp+four_pi_invert;
  else if(larger_than_pi_tmp1||larger_than_pi_tmp1_r )
   first_sub_next= theta_add_zero_point_pi_tmp+two_pi_invert;
  end
  
  
  
  always@*
  begin
   result_sub_bias_next=result_sub_bias;
  if(first_sub_valid)
   result_sub_bias_next=(~(|two_pi_add_temp))?first_sub:(two_pi_add_temp_invert+first_sub);
  end 
  
  always@*
  begin
   angle_out_temp_next=angle_out_temp;
  if(result_sub_bias_valid&&larger_than_pi)
   angle_out_temp_next=two_pi_invert+result_sub_bias;
  else if(result_sub_bias_valid ) 
   angle_out_temp_next=result_sub_bias;
  end 
  
    
  always@*
  begin
  
  larger_than_three_pi_r_next=larger_than_three_pi_r;
    if(larger_than_three_pi)
  larger_than_three_pi_r_next=1'b1;
  else if(zero_point_one_pi_add_temp_valid_negedge )
   larger_than_three_pi_r_next=1'b0; 
  end
  always@*
  begin
  larger_than_pi_tmp1_r_next= larger_than_pi_tmp1_r;
    if(larger_than_pi_tmp1)
  larger_than_pi_tmp1_r_next=1'b1;
   else if( zero_point_one_pi_add_temp_valid_negedge )
  larger_than_pi_tmp1_r_next=1'b0;
 end
  always@(posedge clk)
    begin
     cap_data_number_r                <=(!rst_n)?9'b0:cap_data_number_r_next;
     fft_end_count                    <=(!rst_n)?11'b0:fft_end_count_next;
     data_gen_work                    <=(!rst_n)?1'b0:data_gen_work_next;
     theta_add_temp                   <=(!rst_n)?48'b0:theta_add_temp_next;  
     zero_point_one_pi_add_temp       <=(!rst_n)?56'b0:zero_point_one_pi_add_temp_next;
     two_pi_add_temp                  <=(!rst_n)?56'b0:two_pi_add_temp_next;
     angle_out_temp                   <=(!rst_n)?56'b0:angle_out_temp_next;
     data_gen_req                     <=(!rst_n)?1'b0:data_gen_req_next;
     zero_point_one_pi_add_temp_valid <=(!rst_n)?1'b0:data_gen_req; 
     data_gen_work_r                  <=(!rst_n)?1'b0:data_gen_work;
     add_ignore                       <=(!rst_n)?1'b0:add_ignore_next;
     theta_add_zero_point_pi_tmp_valid<=(!rst_n)?1'b0:zero_point_one_pi_add_temp_valid ;
     result_sub_bias_valid            <=(!rst_n)?1'b0:first_sub_valid;
     angle_out_valid_temp             <=(!rst_n)?1'b0:result_sub_bias_valid;
     theta_add_zero_point_pi_tmp      <=(!rst_n)?56'b0:theta_add_zero_point_pi_tmp_next;
     result_sub_bias                  <=(!rst_n)?56'b0:result_sub_bias_next;
     trig_search_cdc_r                <=(!rst_n)?1'b0:trig_search_cdc;
     larger_than_pi_r                 <=(!rst_n)?1'b0:larger_than_pi;
     theta_add_zero_point_pi_tmp_valid_r<=(!rst_n)?1'b0:theta_add_zero_point_pi_tmp_valid;
     first_sub_valid                  <=(!rst_n)?1'b0:theta_add_zero_point_pi_tmp_valid;
     first_sub                        <=(!rst_n)?56'b0:first_sub_next;
     larger_than_three_pi_r           <=(!rst_n)?1'b0:larger_than_three_pi_r_next;
     larger_than_pi_tmp1_r            <=(!rst_n)?1'b0:larger_than_pi_tmp1_r_next;
     zero_point_one_pi_add_temp_valid_r<=(!rst_n)?1'b0:zero_point_one_pi_add_temp_valid;
     zero_point_one_pi_temp            <=(!rst_n)?75'b0:zero_point_one_pi_temp_next;    
    end
  
  
  endmodule