`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/10 17:34:24
// Design Name: 
// Module Name: max_min_select
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


module max_min_select(
  input             alg_clk,
  input             alg_rst_n,                
  input    [11:0]   average_1_position_max  ,
  input    [11:0]   average_1_position_min  ,
  input    [11:0]   average_2_position_max  ,
  input    [11:0]   average_2_position_min  ,   
  input             init_phase_found_posedge, 

 (*mark_debug = "true"*) output    reg     average_1_max_select,  
 (*mark_debug = "true"*) output    reg     average_1_min_select,
 (*mark_debug = "true"*) output    reg     average_2_max_select,  
 (*mark_debug = "true"*) output    reg     average_2_min_select,
 (*mark_debug = "true"*) output    reg     select_valid
  );
  
  reg  first_sig;
  reg [11:0]  average_1_position_temp;//theta 0
  reg [11:0]  average_2_position_temp;//theta 0
  
  wire [12:0] average_1_d1a;
  wire [12:0] average_1_d1b; 
  wire [12:0] average_1_d1c; 
  wire [12:0] average_1_d2a;
  wire [12:0] average_1_d2b; 
  wire [12:0] average_1_d2c;  
  assign average_1_d1a=(average_1_position_temp>average_1_position_max)?(average_1_position_temp-average_1_position_max):(average_1_position_max-average_1_position_temp);
  assign average_1_d1b=((average_1_position_temp+3600)>average_1_position_max)?((average_1_position_temp+3600)-average_1_position_max):(average_1_position_max-(average_1_position_temp+3600));
  assign average_1_d1c=(average_1_position_temp<(average_1_position_max+3600))?((average_1_position_max+3600)-average_1_position_temp):(average_1_position_temp-(average_1_position_max+3600));
  assign average_1_d2a=(average_1_position_temp>average_1_position_min)?(average_1_position_temp-average_1_position_min):(average_1_position_min-average_1_position_temp);
  assign average_1_d2b=((average_1_position_temp+3600)>average_1_position_min)?((average_1_position_temp+3600)-average_1_position_min):(average_1_position_min-(average_1_position_temp+3600));
  assign average_1_d2c=(average_1_position_temp<(average_1_position_min+3600))?((average_1_position_min+3600)-average_1_position_temp):(average_1_position_temp-(average_1_position_min+3600));
  
  wire [12:0] average_1_d1;
  wire [12:0] average_1_d2;
  min min_0(
. a   (  average_1_d1a   ),
. b   (  average_1_d1b   ),
. c   (  average_1_d1c   ),
. min (  average_1_d1    )
);
  
  min min_1(
. a   (  average_1_d2a ),
. b   (  average_1_d2b ),
. c   (  average_1_d2c ),
. min (  average_1_d2  )
); 




  wire [12:0] average_2_d1a;
  wire [12:0] average_2_d1b; 
  wire [12:0] average_2_d1c; 
  wire [12:0] average_2_d2a;
  wire [12:0] average_2_d2b; 
  wire [12:0] average_2_d2c;  
  
  assign average_2_d1a=(average_2_position_temp>average_2_position_max)?(average_2_position_temp-average_2_position_max):(average_2_position_max-average_2_position_temp);
  assign average_2_d1b=((average_2_position_temp+3600)>average_2_position_max)?((average_2_position_temp+3600)-average_2_position_max):(average_2_position_max-(average_2_position_temp+3600));
  assign average_2_d1c=(average_2_position_temp<(average_2_position_max+3600))?((average_2_position_max+3600)-average_2_position_temp):(average_2_position_temp-(average_2_position_max+3600));
  assign average_2_d2a=(average_2_position_temp>average_2_position_min)?(average_2_position_temp-average_2_position_min):(average_2_position_min-average_2_position_temp);
  assign average_2_d2b=((average_2_position_temp+3600)>average_2_position_min)?((average_2_position_temp+3600)-average_2_position_min):(average_2_position_min-(average_2_position_temp+3600));
  assign average_2_d2c=(average_2_position_temp<(average_2_position_min+3600))?((average_2_position_min+3600)-average_2_position_temp):(average_2_position_temp-(average_2_position_min+3600));
  
  wire [12:0] average_2_d1;
  wire [12:0] average_2_d2;
  min min_2(
. a   (  average_2_d1a   ),
. b   (  average_2_d1b   ),
. c   (  average_2_d1c   ),
. min (  average_2_d1    )
);
  
  min min_3(
. a   (  average_2_d2a ),
. b   (  average_2_d2b ),
. c   (  average_2_d2c ),
. min (  average_2_d2  )
); 
  
  
  
  wire  average_1_smaller;
  wire  average_2_smaller;
  
  assign average_1_smaller= average_1_d1< average_1_d2 ; 
  assign average_2_smaller= average_2_d1< average_2_d2 ; 
  
  
  always@(posedge alg_clk or negedge alg_rst_n)
   if(!alg_rst_n)
   first_sig<=0;
   else if(select_valid)
   first_sig<=1;
  
   always@(posedge alg_clk or negedge alg_rst_n)
   if(!alg_rst_n)
  begin
   average_1_position_temp<=0;
   average_2_position_temp<=0;
  end
  else if((!first_sig)&&init_phase_found_posedge)
  begin
   average_1_position_temp<=average_1_position_max;
   average_2_position_temp<=average_2_position_max;
  end
  else if(first_sig&&init_phase_found_posedge)
  case({average_1_smaller,average_2_smaller} )
  2'b00:
  begin
   average_1_position_temp<=average_1_position_min;
   average_2_position_temp<=average_2_position_min;
  
  end
  2'b01:
   begin
   average_1_position_temp<=average_1_position_min;
   average_2_position_temp<=average_2_position_max;  
  end
  
  
  2'b10:
   begin
   average_1_position_temp<=average_1_position_max;
   average_2_position_temp<=average_2_position_min;
  
  end
  2'b11:
   begin
    average_1_position_temp<=average_1_position_max;
    average_2_position_temp<=average_2_position_max;
  
  end
  
  
  default:;
  endcase
  
  
   always@(posedge alg_clk or negedge alg_rst_n)
   if(!alg_rst_n)
    begin
     average_1_max_select<=0;
     average_1_min_select<=0;
     average_2_max_select<=0;
     average_2_min_select<=0;
     select_valid        <=0;
    end
   else if((!first_sig)&&init_phase_found_posedge)
   begin
     average_1_max_select<=1;
     average_1_min_select<=0;
     average_2_max_select<=1;
     average_2_min_select<=0;
     select_valid        <=1;
    end
     else if(first_sig&&init_phase_found_posedge)
  case({average_1_smaller,average_2_smaller} )
  2'b00:
  begin
     average_1_max_select<=0;
     average_1_min_select<=1;
     average_2_max_select<=0;
     average_2_min_select<=1;
     select_valid        <=1;
  
  end
  2'b01:
   begin
     average_1_max_select<=0;
     average_1_min_select<=1;
     average_2_max_select<=1;
     average_2_min_select<=0;
     select_valid        <=1; 
  end
  
  
  2'b10:
   begin
     average_1_max_select<=1;
     average_1_min_select<=0;
     average_2_max_select<=0;
     average_2_min_select<=1;
     select_valid        <=1;
  end
  2'b11:
   begin
     average_1_max_select<=1;
     average_1_min_select<=0;
     average_2_max_select<=1;
     average_2_min_select<=0;
     select_valid        <=1;
  
  end
  
  
  default:;
  endcase
  
  else
   select_valid        <=0;

  
  endmodule